import 'dart:io';

import 'package:flutter_storyboard_player/common/map/map_info.dart';

/// osu地图加载器
class OSUMapLoader {
  /// 地图路径
  String path;

  /// 地图信息
  OSUMapInfo mapInfo;

  /// .osu文件里面的[Events]
  List<String> _events;

  /// 从路径加载
  Future<OSUMapInfo> loadFromPath(String path) async {
    this.path = path;
    File file = File(path);
    if (!(await file.exists())) {
      print('没有找到文件: $path');
      return null;
    }
    // 读取数据按行
    List<String> lines = file.readAsLinesSync();

    // 初始化数据
    mapInfo = OSUMapInfo();
    String struct;
    List<String> strings;

    // 循环处理数据
    lines.forEach((el) {
      if (el.startsWith('[')) {
        // 数据解包
        unpackData(struct, strings);
        struct = el;
        strings?.clear();
        strings = List();
        return;
      }
      strings?.add(el);
    });
    // 数据解包,最后一个
    unpackData(struct, strings);

    return mapInfo;
  }

  Future<OSUMapInfo> loadOSB() async {
    if (mapInfo == null) {
      print('未加载地图文件');
      return null;
    }
    File file = File(path);
    if (!(await file.exists())) {
      print('没有找到文件: $path');
      return null;
    }
    Directory directory = file.parent;
    FileSystemEntity entity = directory
        .listSync()
        .firstWhere((e) => e.path.endsWith('.osb'), orElse: () {});
    if (entity == null) {
      print('没有找到osb文件');
      return mapInfo;
    }
    String osbPath = entity.path;
    File osbFile = File(osbPath);
    List<String> lines = osbFile.readAsLinesSync();
    lines?.remove('[Events]');
    if (_events != null) {
      lines.insertAll(0, _events);
    }
    _OSUStoryBoardLoader(mapInfo).parse();
    return mapInfo;
  }

  /// 解包数据
  void unpackData(String struct, List<String> strings) {
    if (mapInfo == null || struct == null || strings == null) {
      return;
    }
    switch (struct?.trim()) {
      case '[General]':
        Map<String, String> map = stringToMap(strings);
        mapInfo.general = OSUMapGeneral.fromMap(map);
        map?.clear();
        break;
      case '[Editor]':
        Map<String, String> map = stringToMap(strings);
        mapInfo.editor = OSUMapEditor.fromMap(map);
        map?.clear();
        break;
      case '[Metadata]':
        Map<String, String> map = stringToMap(strings);
        mapInfo.metadata = OSUMapMetadata.fromMap(map);
        map?.clear();
        break;
      case '[Difficulty]':
        Map<String, String> map = stringToMap(strings);
        mapInfo.difficulty = OSUMapDifficulty.fromMap(map);
        map?.clear();
        break;
      case '[Events]':
        _events = List<String>.from(strings);
        break;
      case '[TimingPoints]':
        break;
      case '[Colours]':
        break;
      case '[HitObjects]':
        break;
    }
  }

  /// 字符串列表转map
  Map<String, String> stringToMap(List<String> strings) {
    Map<String, String> map = Map();
    strings?.forEach((el) {
      List<String> els = el?.split(':');
      if ((els?.length ?? 0) < 2) {
        return;
      }
      String key = els[0]?.trim();
      String value = els[1];
      if (els.length > 2) {
        for (int i = 2; i < els.length; i++) {
          value = '$value${els[i]}';
        }
      }
      value = value?.trim();
      if (key != null) {
        map[key] = value;
      }
    });
    return map;
  }
}

/// StoryBoard加载器
class _OSUStoryBoardLoader {
  /// 地图信息
  OSUMapInfo mapInfo;

  _OSUStoryBoardLoader(this.mapInfo);

  /// 开始解析
  void parse() {

  }
}
