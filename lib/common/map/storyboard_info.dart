import 'package:flutter/cupertino.dart';

/// 故事板事件
class OSBEvents {
  /// 背景
  OSBBackground background;

  /// 休息时间
  OSBBreakPeriods breakPeriods;

  /// 故事板图层
  List<Sprite> layer0 = List();
  List<Sprite> layer1 = List();
  List<Sprite> layer2 = List();
  List<Sprite> layer3 = List();
}

/// 背景
class OSBBackground {
  int type;
  int startTime;
  String file;
  Offset offset;
}

/// 休息时间
class OSBBreakPeriods {
  int startTime;
  int endTime;
}

/// 精灵
class Sprite {}
