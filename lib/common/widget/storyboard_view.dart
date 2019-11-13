import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

const double OSB_WIDTH = 640.0;
const double OSB_HEIGHT = 480.0;

/// storyboard player视图
class StoryBoardView extends StatefulWidget {
  @override
  _StoryBoardViewState createState() => _StoryBoardViewState();
}

class _StoryBoardViewState extends State<StoryBoardView>
    with TickerProviderStateMixin {
  /// FPS Counter
  Timer _fpsTimer;
  int _fps = 0;
  int _fpsTemp = 0;

  /// refresh canvas
  Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fpsTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _fps = _fpsTemp;
      _fpsTemp = 0;
    });
    _refreshTimer = Timer.periodic(Duration(milliseconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _fpsTimer.cancel();
    _refreshTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: Size.infinite,
          painter: _StoryBoardPainter(
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

  final PaintCallback callback;

  _StoryBoardPainter({
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
