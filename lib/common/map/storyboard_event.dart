import 'dart:ui';

import 'storyboard_info.dart';
import 'storyboard_info.dart';
import 'storyboard_info.dart';

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

  /// 是否有透明度
  bool hasFade = false;

  void updateSpriteData(int time, Sprite sprite, SpriteData spriteData) {
    if (time < startTime) {
      return;
    }
    int totalTime = loopCount * endTime;
    int diffTime = time - startTime;
    if (diffTime > totalTime) {
      return;
    }
    int times = diffTime % time;
    for (int i = events.length - 1; i >= 0; i--) {
      SpriteEvent event = events[i];
      _calEvent(times, sprite, spriteData, event);
    }
  }

  /// 计算事件
  void _calEvent(
      int time, Sprite sprite, SpriteData spriteData, SpriteEvent event) {
    if (event == null || event is LoopEvent || event is TriggerEvent) {
      return;
    }
    // 小于开始时间
    if (time < event.startTime) {
      return;
    }
    // 开始时间等于结束时间
    if (event.startTime == event.endTime) {
      if (event is FadeEvent) {
        spriteData.opacity = event.endOpacity;
      } else if (event is MoveEvent) {
        spriteData.position = event.endOffset;
      } else if (event is MoveXEvent) {
        spriteData.x = event.endX;
      } else if (event is MoveYEvent) {
        spriteData.y = event.endY;
      } else if (event is ScaleEvent) {
        spriteData.scale = event.endScale;
      } else if (event is VectorScaleEvent) {
        spriteData.scaleX = event.endX;
        spriteData.scaleY = event.endY;
      } else if (event is RotateEvent) {
        spriteData.angle = event.endRotate;
      } else if (event is ColourEvent) {
        spriteData.color = event.endColor;
      } else if (event is ParameterEvent) {
        spriteData.parameterType = event.type;
      }
      return;
    }
    // 大于结束时间
    if (time > event.endTime) {
      if (event is FadeEvent) {
        spriteData.opacity = spriteData.opacity ?? event.endOpacity;
      } else if (event is MoveEvent) {
        spriteData.position = spriteData.position ?? event.endOffset;
      } else if (event is MoveXEvent) {
        spriteData.x = spriteData.x ?? event.endX;
      } else if (event is MoveYEvent) {
        spriteData.y = spriteData.y ?? event.endY;
      } else if (event is ScaleEvent) {
        spriteData.scale = spriteData.scale ?? event.endScale;
      } else if (event is VectorScaleEvent) {
        spriteData.scaleX = spriteData.scaleX ?? event.endX;
        spriteData.scaleY = spriteData.scaleY ?? event.endY;
      } else if (event is RotateEvent) {
        spriteData.angle = event.endRotate;
      } else if (event is ColourEvent) {
        spriteData.color = event.endColor;
      } else if (event is ParameterEvent) {
        spriteData.parameterType = event.type;
      }
      return;
    }
    // 在事件时间范围内
    // 计算在事件内的位置
    double timeLong = (event.endTime - event.startTime).toDouble();
    double timeCurrent = (time - event.startTime).toDouble();
    double progress = timeCurrent / timeLong;

    // 根据事件类型进行计算
    if (event is FadeEvent) {
      // 透明度
      double diff = event.endOpacity - event.startOpacity;
      double opacity = diff * progress + event.startOpacity;
      spriteData.opacity = opacity;
    } else if (event is MoveEvent) {
      // 移动
      spriteData.position =
          Offset.lerp(event.startOffset, event.endOffset, progress);
    } else if (event is MoveXEvent) {
      // X移动
      double diff = event.endX - event.startX;
      double x = diff * progress + event.startX;
      spriteData.x = x;
    } else if (event is MoveYEvent) {
      // Y移动
      double diff = event.endY - event.startY;
      double y = diff * progress + event.startY;
      spriteData.y = y;
    } else if (event is ScaleEvent) {
      // 缩放
      double diff = event.endScale - event.startScale;
      double scale = diff * progress + event.startScale;
      spriteData.scale = scale;
    } else if (event is VectorScaleEvent) {
      // 宽高单独缩放
      double diffX = event.endX - event.startX;
      double diffY = event.endY - event.startY;
      double scaleX = diffX * progress + event.startX;
      double scaleY = diffY * progress + event.startY;
      spriteData.scaleX = scaleX;
      spriteData.scaleY = scaleY;
    } else if (event is RotateEvent) {
      // 旋转
      double diff = event.endRotate - event.startRotate;
      double angle = diff * progress + event.startRotate;
      spriteData.angle = angle;
    } else if (event is ColourEvent) {
      // 颜色
      spriteData.color = Color.lerp(event.startColor, event.endColor, progress);
    } else if (event is ParameterEvent) {
      spriteData.parameterType = event.type;
    }
  }

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
