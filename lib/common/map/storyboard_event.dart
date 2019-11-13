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

  @override
  String toString() {
    return 'Fade($startOpacity,$endOpacity)';
  }
}

/// 位置变换XY
class MoveEvent extends SpriteEvent {
  /// 起始位置
  Offset startOffset;

  /// 结束位置
  Offset endOffset;

  @override
  String toString() {
    return 'Move{$startOffset,$endOffset}';
  }
}

/// 位置变换X
class MoveXEvent extends SpriteEvent {
  /// 起始位置
  double startX;

  /// 结束位置
  double endX;

  @override
  String toString() {
    return 'MoveX($startX,$endX)';
  }
}

/// 位置变换Y
class MoveYEvent extends SpriteEvent {
  /// 起始位置
  double startY;

  /// 结束位置
  double endY;

  @override
  String toString() {
    return 'MoveY($startY,$endY)';
  }
}

/// 缩放变换
class ScaleEvent extends SpriteEvent {
  /// 起始大小
  double startScale;

  /// 结束大小
  double endScale;

  @override
  String toString() {
    return 'Scale($startScale,$endScale)';
  }
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

  @override
  String toString() {
    return 'VectorScale($startX,$startY,$endX,$endY)';
  }
}

/// 旋转变换
class RotateEvent extends SpriteEvent {
  /// 开始角度
  double startRotate;

  /// 结束角度
  double endRotate;

  @override
  String toString() {
    return 'Rotate($startRotate,$endRotate)';
  }
}

/// 着色变换
class ColourEvent extends SpriteEvent {
  /// 开始颜色
  Color startColor;

  /// 结束颜色
  Color endColor;

  @override
  String toString() {
    return 'Colour{$startColor,$endColor}';
  }
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

  @override
  String toString() {
    return 'Parameter($type)';
  }
}

/// 循环事件
class LoopEvent extends SpriteEvent {
  /// 循环次数
  int loopCount;

  /// 循环的事件
  List<SpriteEvent> events;

  @override
  String toString() {
    return 'Loop($loopCount)';
  }
}

enum TriggerType {
  HitSound,
  Passing,
  Failing,
}

/// 触发事件
class TriggerEvent extends SpriteEvent {
  /// 事件类型
  TriggerType triggerType;

  /// 触发的事件
  List<SpriteEvent> events;

  @override
  String toString() {
    return 'Trigger($triggerType)';
  }
}
