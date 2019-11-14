import 'dart:ui';

import 'package:flutter_storyboard_player/common/map/storyboard_event.dart';

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
  double scaleX;
  double scaleY;
  Offset position;
  Offset offset;

  bool isEmpty() {
    if (scaleX == null) {
      if (opacity != null) {
        scaleX = 1.0;
        scaleY = 1.0;
      }
    }
    return scaleX == null ||
        scaleY == null ||
        opacity == null ||
        position == null;
  }

  @override
  String toString() {
    return 'SpriteData($angle,$opacity,{$scaleX,$scaleY},$position,$offset)';
  }
}

/// 精灵
class Sprite {
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

  SpriteData getData(int time) {
    if (image == null || events == null) {
      return null;
    }
    SpriteData spriteData = SpriteData();
    for (int i = 0; i < events.length; i++) {
      SpriteEvent event = events[i];
      if (event == null) {
        continue;
      }
      // 开始时间等于结束时间
      if (event.startTime == event.endTime && time > event.startTime) {
        if (event is FadeEvent) {
          spriteData.opacity = event.endOpacity;
        } else if (event is MoveEvent) {
          spriteData.position = event.endOffset;
        } else if (event is MoveXEvent) {
          spriteData.position = Offset(event.endX, position.dy);
        } else if (event is MoveYEvent) {
          spriteData.position = Offset(position.dx, event.endY);
        } else if (event is ScaleEvent) {
          spriteData.scaleX = event.endScale;
          spriteData.scaleY = event.endScale;
        } else if (event is VectorScaleEvent) {
          spriteData.scaleX = event.endX;
          spriteData.scaleY = event.endY;
        } else if (event is RotateEvent) {
          spriteData.angle = event.endRotate;
        }
        continue;
      }
      // 不在范围
      if ((time < event.startTime || time > event.endTime)) {
        continue;
      }
      // 在范围内
      double timeLong = (event.endTime - event.startTime).toDouble();
      double timeCurrent = (time - event.startTime).toDouble();
      double progress = timeCurrent / timeLong;
      if (event is FadeEvent) {
        double opacity = (event.endOpacity - event.startOpacity) * progress +
            event.startOpacity;
        spriteData.opacity = opacity;
      } else if (event is MoveEvent) {
        Offset position = (event.endOffset - event.startOffset) * progress +
            event.startOffset;
        spriteData.position = position;
      } else if (event is MoveXEvent) {
        double x = (event.endX - event.startX) * progress + event.startX;
        spriteData.position = Offset(x, position.dy);
      } else if (event is MoveYEvent) {
        double y = (event.endY - event.startY) * progress + event.startY;
        spriteData.position = Offset(y, event.endY);
      } else if (event is ScaleEvent) {
        double scale =
            (event.endScale - event.startScale) * progress + event.startScale;
        spriteData.scaleX = scale;
        spriteData.scaleY = scale;
      } else if (event is VectorScaleEvent) {
        double scaleX = (event.endX - event.startX) * progress + event.startX;
        double scaleY = (event.endY - event.startY) * progress + event.startY;
        spriteData.scaleX = scaleX;
        spriteData.scaleY = scaleY;
      } else if (event is RotateEvent) {
        double angle = (event.endRotate - event.startRotate) * progress +
            event.startRotate;
        spriteData.angle = angle;
      }
    }
    if (spriteData.opacity == null) {
      FadeEvent fadeEvent = events.firstWhere((event) {
        return (event is FadeEvent && time > event.endTime);
      }, orElse: () {});
      if (fadeEvent != null) {
        spriteData.opacity = fadeEvent.endOpacity;
      }
    }
    if (spriteData.isEmpty()) {
      return null;
    }
    if (spriteData.angle == null) {
      spriteData.angle = 0;
    }
    spriteData.offset = () {
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
    }();
    if (spriteData.offset == null) {
      return null;
    }
    spriteData.offset = spriteData.offset.scale(
      spriteData.scaleX,
      spriteData.scaleY,
    );
    return spriteData;
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
