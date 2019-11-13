import 'package:flutter/cupertino.dart';
import 'package:flutter_storyboard_player/common/map/storyboard_event.dart';

/// 故事板事件
class OSBEvents {
  /// 背景
  OSBBackground background;

  /// 休息时间
  OSBBreakPeriods breakPeriods;

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
  String file;

  /// 坐标偏移
  Offset offset;
}

/// 休息时间
class OSBBreakPeriods {
  /// 开始时间
  int startTime;

  /// 结束时间
  int endTime;
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
  List<SpriteEvent> events = List();
}

/// 动画精灵
class AnimationSprite extends Sprite {
  /// 动画张数
  int frameCount;

  /// 动画每帧延时
  int frameDelay;

  /// 动画循环方式
  SpriteLoopType loopType;
}
