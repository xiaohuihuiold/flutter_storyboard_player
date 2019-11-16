import 'dart:ui';

import 'package:flutter_storyboard_player/common/map/storyboard_event.dart';

import 'storyboard_event.dart';

/// 故事板事件
class OSBEvents {
  /// 背景
  OSBBackground background;

  /// 休息时间
  /// OSBBreakPeriods breakPeriods;

  /// 故事板图层
  List<Sprite> backgrounds = List();
  List<Sprite> fails = List();
  List<Sprite> passes = List();
  List<Sprite> foregrounds = List();
}

/// 背景
class OSBBackground {
  /// 背景类型:0-图片 1-视频
  int type;

  /// 开始时间
  int startTime;

  /// 文件
  String fileName;

  /// 坐标偏移
  Offset offset;

  @override
  String toString() {
    return 'Background($type,$startTime,$fileName, $offset)';
  }
}

/// 休息时间
class OSBBreakPeriods {
  /// 开始时间
  int startTime;

  /// 结束时间
  int endTime;

  @override
  String toString() {
    return 'BreakPeriods($startTime,$endTime)';
  }
}

/// 图层
enum SpriteLayer {
  Background,
  Fail,
  Pass,
  Foreground,
}

/// 中心点
enum SpriteOrigin {
  TopLeft,
  Centre,
  CentreLeft,
  TopRight,
  BottomCentre,
  TopCentre,
  CentreRight,
  BottomLeft,
  BottomRight,
}

/// 动画循环类型
enum SpriteLoopType {
  LoopForever,
  LoopOnce,
}

/// 精灵数据
class SpriteData {
  double angle;
  double opacity;
  double scale;
  double scaleX;
  double scaleY;
  Offset position;
  Offset offset;
  Color color;
  ParameterType parameterType;

  bool isEmpty() {
    return angle == null &&
        opacity == null &&
        scale == null &&
        scaleX == null &&
        scaleY == null &&
        position == null &&
        color == null;
  }

  @override
  String toString() {
    return 'SpriteData($angle,$opacity,{$scaleX,$scaleY},$position,$offset)';
  }
}

/// 精灵
class Sprite {
  /// 开始时间
  int startTime;

  /// 结束时间
  int endTime;

  /// 图层
  SpriteLayer layer;

  /// 中心点
  SpriteOrigin origin;

  /// 图片文件
  String fileName;

  /// 位置
  Offset position;

  /// 精灵事件列表
  List<SpriteEvent> events;

  /// 图片
  Image image;

  /// 偏移
  Offset _offset;

  SpriteData getSpriteData(int time) {
    if (image == null || events == null) {
      return null;
    }
    if (time < startTime || time > endTime) {
      return null;
    }
    SpriteData spriteData = SpriteData();
    for (int i = 0; i < events.length; i++) {
      SpriteEvent event = events[i];
      _calEvent(time, spriteData, event);
    }
    if (spriteData.opacity == null) {
      return null;
    }
    if (spriteData.scale != null) {
      if (spriteData.scaleX != null) {
        spriteData.scaleX += spriteData.scale;
      }
      if (spriteData.scaleY != null) {
        spriteData.scaleY += spriteData.scale;
      }
    }
    if (spriteData.scaleX == null) {
      spriteData.scaleX = spriteData.scale ?? 1.0;
    }
    if (spriteData.scaleY == null) {
      spriteData.scaleY = spriteData.scale ?? 1.0;
    }
    if (spriteData.position == null) {
      spriteData.position = position;
    }
    if (spriteData.angle == null) {
      spriteData.angle = 0;
    }
    if (spriteData.color == null) {
      spriteData.color = Color.fromRGBO(255, 255, 255, 1.0);
    }
    spriteData.color = spriteData.color.withOpacity(spriteData.opacity);
    spriteData.offset = _getOffset();
    _offset = spriteData.offset;
    if (spriteData.offset == null) {
      return null;
    }
    spriteData.offset = spriteData.offset.scale(
      spriteData.scaleX,
      spriteData.scaleY,
    );
    return spriteData;
  }

  /// 计算事件
  void _calEvent(int time, SpriteData spriteData, SpriteEvent event) {
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
        spriteData.position =
            Offset(event.endX, spriteData.position?.dy ?? position.dy);
      } else if (event is MoveYEvent) {
        spriteData.position =
            Offset(spriteData.position?.dx ?? position.dx, event.endY);
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
        spriteData.opacity = event.endOpacity;
      } else if (event is MoveEvent) {
        spriteData.position = event.endOffset;
      } else if (event is MoveXEvent) {
        spriteData.position =
            Offset(event.endX, spriteData.position?.dy ?? position.dy);
      } else if (event is MoveYEvent) {
        spriteData.position =
            Offset(spriteData.position?.dx ?? position.dx, event.endY);
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
      spriteData.position = Offset(x, spriteData.position?.dy ?? position.dy);
    } else if (event is MoveYEvent) {
      // Y移动
      double diff = event.endY - event.startY;
      double y = diff * progress + event.startY;
      spriteData.position = Offset(spriteData.position?.dx ?? position.dx, y);
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

  /// 获取偏移值
  Offset _getOffset() {
    if (_offset != null) {
      return _offset;
    }
    switch (origin) {
      case SpriteOrigin.TopLeft:
        return Offset(0, 0);
      case SpriteOrigin.Centre:
        return Offset(image.width / 2.0, image.height / 2.0);
      case SpriteOrigin.CentreLeft:
        return Offset(0, image.height / 2.0);
      case SpriteOrigin.TopRight:
        return Offset(image.width.toDouble(), 0.0);
      case SpriteOrigin.BottomCentre:
        return Offset(image.width / 2.0, image.height.toDouble());
      case SpriteOrigin.TopCentre:
        return Offset(image.width / 2.0, 0);
      case SpriteOrigin.CentreRight:
        return Offset(image.width.toDouble(), image.height / 2.0);
      case SpriteOrigin.BottomLeft:
        return Offset(0, image.height.toDouble());
      case SpriteOrigin.BottomRight:
        return Offset(image.width.toDouble(), image.height.toDouble());
    }
    return null;
  }

  @override
  String toString() {
    return 'Sprite($layer,$origin,$fileName,$position)';
  }
}

/// 动画精灵
class AnimationSprite extends Sprite {
  /// 动画张数
  int frameCount;

  /// 动画每帧延时
  int frameDelay;

  /// 动画循环方式
  SpriteLoopType loopType;

  @override
  String toString() {
    return 'Animation($layer,$origin,$fileName,$position,$frameCount,$frameDelay,$loopType)';
  }
}
