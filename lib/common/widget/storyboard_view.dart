import 'package:flutter/material.dart';

const double OSB_WIDTH = 640.0;
const double OSB_HEIGHT = 480.0;

/// storyboard player视图
class StoryBoardView extends StatefulWidget {
  @override
  _StoryBoardViewState createState() => _StoryBoardViewState();
}

class _StoryBoardViewState extends State<StoryBoardView> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _StoryBoardPainter(),
    );
  }
}

/// 自定义storyboard画板
class _StoryBoardPainter extends CustomPainter {
  Paint _girdPaint = Paint();

  Canvas _canvas;
  Size _size;
  double _scale;
  double _offsetX;

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
  }

  void _clearCanvas() {
    _canvas.drawColor(Colors.black, BlendMode.src);
  }

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

  void _drawLine(Offset start, Offset end, Paint paint) {
    _canvas.drawLine(
      start.translate(_offsetX, 0).scale(_scale, _scale),
      end.translate(_offsetX, 0).scale(_scale, _scale),
      _girdPaint,
    );
  }
}
