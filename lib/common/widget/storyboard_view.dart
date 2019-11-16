import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_storyboard_player/common/map/map_info.dart';
import 'package:flutter_storyboard_player/common/map/storyboard_info.dart';

import '../map/storyboard_event.dart';

const double OSB_WIDTH = 640.0;
const double OSB_WIDTH_LARGE = 800.0;
const double OSB_HEIGHT = 480.0;

enum StoryBoardActionType {
  time,
  info,
}

typedef StoryBoardCallback = void Function(StoryBoardActionType);

/// storyboard控制器
class StoryBoardController {
  Set<StoryBoardCallback> _callbacks;

  int _time;

  int get time => _time;

  set time(int value) {
    _time = value;
    _update(StoryBoardActionType.time);
  }

  OSUMapInfo _mapInfo;

  OSUMapInfo get mapInfo => _mapInfo;

  set mapInfo(OSUMapInfo value) {
    _mapInfo = value;
    _update(StoryBoardActionType.info);
  }

  /// 添加监听
  void addListener(StoryBoardCallback callback) {
    if (_callbacks == null) {
      _callbacks = Set();
    }
    _callbacks.add(callback);
  }

  /// 更新数据
  void _update(StoryBoardActionType type) {
    _callbacks?.forEach((callback) {
      if (callback != null) {
        callback(type);
      }
    });
  }
}

/// storyboard player视图
class StoryBoardView extends StatefulWidget {
  final StoryBoardController controller;

  StoryBoardView({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  _StoryBoardViewState createState() => _StoryBoardViewState();
}

class _StoryBoardViewState extends State<StoryBoardView>
    with TickerProviderStateMixin {
  /// FPS计数器
  Timer _fpsTimer;
  int _fps = 0;
  int _fpsTemp = 0;

  /// 时间轴
  int _time = 0;

  /// 地图信息
  OSUMapInfo _mapInfo;

  /// 更新信息
  void _update(StoryBoardActionType type) {
    switch (type) {
      case StoryBoardActionType.time:
        if (!mounted) return;
        setState(() {
          _time = widget.controller?.time ?? 0;
        });
        break;
      case StoryBoardActionType.info:
        if (!mounted) return;
        setState(() {
          _mapInfo = widget.controller?.mapInfo;
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fpsTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _fps = _fpsTemp;
      _fpsTemp = 0;
    });
    widget.controller?.addListener(_update);
  }

  @override
  void dispose() {
    super.dispose();
    _fpsTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: Size.infinite,
          painter: _StoryBoardPainter(
            time: _time,
            mapInfo: _mapInfo,
            callback: () {
              _fpsTemp++;
            },
          ),
        ),
        Text(
          'FPS:$_fps',
          style: TextStyle(
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 3.0)],
          ),
        ),
      ],
    );
  }
}

typedef PaintCallback = void Function();

/// 自定义storyboard画板
class _StoryBoardPainter extends CustomPainter {
  Paint _girdPaint = Paint();
  Paint _spritePaint = Paint();
  Paint _borderPaint = Paint()
    ..color = Colors.redAccent.withOpacity(0.7)
    ..style = PaintingStyle.stroke;

  Canvas _canvas;
  Size _size;
  double _scale;
  double _offsetX;

  final int time;
  final OSUMapInfo mapInfo;
  final PaintCallback callback;

  _StoryBoardPainter({
    this.time = 0,
    this.mapInfo,
    this.callback,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;
    _scale = _size.height / OSB_HEIGHT;
    _offsetX = (_size.width - OSB_WIDTH * _scale) / 2.0;
    double offsetXLarge = (_size.width - OSB_WIDTH_LARGE * _scale) / 2.0;

    _clearCanvas();
    // _drawGird();

    if (mapInfo?.events != null) {
      _canvas.save();
      _canvas.clipRect(Rect.fromLTWH(
          offsetXLarge, 0.0, OSB_WIDTH_LARGE * _scale, OSB_HEIGHT * _scale));
      _drawSprites(mapInfo.events.backgrounds);
      _drawSprites(mapInfo.events.foregrounds);
      _canvas.restore();
    }

    if (callback != null) {
      callback();
    }
  }

  void _drawSprites(List<Sprite> sprites) {
    sprites.forEach((sprite) {
      SpriteData spriteData = sprite.getSpriteData(time);
      if (spriteData == null) {
        return;
      }
      _drawImage(sprite, sprite.getImage(time), spriteData);
    });
  }

  /// 清理画布
  void _clearCanvas() {
    _canvas.drawColor(Colors.white.withOpacity(0), BlendMode.color);
  }

  /// 绘制网格
  void _drawGird() {
    _girdPaint.color = Colors.white54;
    _girdPaint.strokeWidth = 1.5;
    _drawLine(Offset(0, 0), Offset(640.0, 0), _girdPaint);
    _drawLine(Offset(0, 480.0), Offset(640.0, 480.0), _girdPaint);
    _drawLine(Offset(0, 0), Offset(0, 480), _girdPaint);
    _drawLine(Offset(640.0, 0), Offset(640.0, 480.0), _girdPaint);
    _drawLine(Offset(320.0, 0), Offset(320.0, 480), _girdPaint);
    _drawLine(Offset(0.0, 240.0), Offset(640.0, 240.0), _girdPaint);

    _girdPaint.color = Colors.white30;
    _girdPaint.strokeWidth = 1.0;
    for (int w = 1; w < 8; w++) {
      if (w == 4) {
        continue;
      }
      _drawLine(Offset(80.0 * w, 0), Offset(80.0 * w, 480.0), _girdPaint);
    }
    for (int h = 1; h < 6; h++) {
      if (h == 3) {
        continue;
      }
      _drawLine(Offset(0, 80.0 * h), Offset(640.0, 80.0 * h), _girdPaint);
    }
  }

  /// 适应画线
  void _drawLine(Offset start, Offset end, Paint paint) {
    _canvas.drawLine(
      start.translate(_offsetX, 0).scale(_scale, _scale),
      end.translate(_offsetX, 0).scale(_scale, _scale),
      _girdPaint,
    );
  }

  /// 适应画图片
  void _drawImage(Sprite sprite, ui.Image image, SpriteData spriteData) {
    if (spriteData.opacity <= 0.0 ||
        spriteData.scaleX <= 0.0 ||
        spriteData.scaleY <= 0.0) {
      return;
    }
    double scaleX = spriteData.scaleX;
    double scaleY = spriteData.scaleY;
    double angle = spriteData.angle;
    Offset position =
        spriteData.position.scale(_scale, _scale).translate(_offsetX, 0);

    _spritePaint.color = spriteData.color;
    double r = spriteData.color.red / 255.0;
    double g = spriteData.color.green / 255.0;
    double b = spriteData.color.blue / 255.0;
    double a = spriteData.color.alpha / 255.0;
    _spritePaint.colorFilter = ColorFilter.matrix([
      r, 0.0, 0.0, 0.0, 0.0, //
      0.0, g, 0.0, 0.0, 0.0, //
      0.0, 0.0, b, 0.0, 0.0, //
      0.0, 0.0, 0.0, 1.0, 0.0, //
    ]);

    _canvas.save();
    _canvas.translate(position.dx, position.dy);
    _canvas.rotate(angle);
    _canvas.translate(-position.dx, -position.dy);

    position = (spriteData.position - spriteData.offset)
        .scale(_scale, _scale)
        .translate(_offsetX, 0);

    Rect rectPos = Rect.fromLTWH(
      position.dx,
      position.dy,
      image.width * scaleX * _scale,
      image.height * scaleY * _scale,
    );

    _spritePaint.blendMode = BlendMode.srcOver;
    switch (spriteData.parameterType) {
      case ParameterType.H:
        //rectPos = Rect.fromLTRB(rectPos.right, rectPos.top, rectPos.left, rectPos.bottom);
        break;
      case ParameterType.V:
        //rectPos = Rect.fromLTRB(rectPos.top, rectPos.bottom, rectPos.right, rectPos.top);
        break;
      case ParameterType.A:
        _spritePaint.blendMode = BlendMode.plus;
        break;
    }

    _canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rectPos,
      _spritePaint,
    );
    // 绘制边框
    // _canvas.drawRect(rectPos, _borderPaint);
    _canvas.restore();
  }
}
