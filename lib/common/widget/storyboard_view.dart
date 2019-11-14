import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_storyboard_player/common/map/map_info.dart';

const double OSB_WIDTH = 640.0;
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
    _time = time;
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
    _fpsTimer.cancel();
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

    _clearCanvas();
    _drawGird();

    if (callback != null) {
      callback();
    }
  }

  /// 清理画布
  void _clearCanvas() {
    _canvas.drawColor(Colors.black, BlendMode.src);
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
}
