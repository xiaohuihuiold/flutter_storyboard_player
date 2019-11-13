import 'dart:ui';

/// 精灵事件
class SpriteEvent {
  /// 曲线
  int easing;

  /// 开始时间
  int startTime;

  /// 结束时间
  int endTime;
}

/// 透明度变换
class FadeEvent extends SpriteEvent {
  /// 起始透明度
  double startOpacity;

  /// 结束透明度
  double endOpacity;
}

/// 位置变换XY
class MoveEvent extends SpriteEvent {
  /// 起始位置
  Offset startOffset;

  /// 结束位置
  Offset endOffset;
}

/// 位置变换X
class MoveXEvent extends SpriteEvent {
  /// 起始位置
  int startX;

  /// 结束位置
  int endX;
}

/// 位置变换Y
class MoveYEvent extends SpriteEvent {
  /// 起始位置
  int startY;

  /// 结束位置
  int endY;
}

/// 缩放变换
class ScaleEvent extends SpriteEvent {
  /// 起始大小
  double startScale;

  /// 结束大小
  double endScale;
}

/// 缩放变换
class VectorScaleEvent extends SpriteEvent {
  /// 起始x大小
  double startX;

  /// 起始Y大小
  double startY;

  /// 结束x大小
  double endX;

  /// 结束y大小
  double endY;
}

/// 旋转变换
class RotateEvent extends SpriteEvent {
  /// 开始角度
  double startRotate;

  /// 结束角度
  double endRotate;
}

/// 着色变换
class ColourEvent extends SpriteEvent {
  /// 开始颜色
  Color startColor;

  /// 结束颜色
  Color endColor;
}

enum ParameterType {
  H,
  V,
  A,
}

/// 参数事件
class ParameterEvent extends SpriteEvent {
  /// 类型
  ParameterType type;
}


