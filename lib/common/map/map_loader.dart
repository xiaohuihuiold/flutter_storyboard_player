import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_storyboard_player/common/map/map_info.dart';
import 'package:flutter_storyboard_player/common/map/storyboard_event.dart';
import 'package:flutter_storyboard_player/common/map/storyboard_info.dart';

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
    _OSUStoryBoardLoader(mapInfo, lines).parse();
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

  /// osb
  List<String> lines;

  _OSUStoryBoardLoader(this.mapInfo, this.lines);

  /// 开始解析
  void parse() {
    if (mapInfo == null || lines == null) {
      return;
    }
    OSBEvents events = OSBEvents();
    mapInfo.events = events;
    for (int i = 0; i < lines.length;) {
      String line = lines[i];
      switch (line.trim()) {
        case '//Background and Video events':
          i = _parseBackground(i + 1);
          break;
        case '//Break Periods':
          i = _parseBreakPeriods(i + 1);
          break;
        case '//Storyboard Layer 0 (Background)':
          i = _parseLayer(i + 1, events.backgrounds);
          break;
        case '//Storyboard Layer 1 (Fail)':
          i = _parseLayer(i + 1, events.fails);
          break;
        case '//Storyboard Layer 2 (Pass)':
          i = _parseLayer(i + 1, events.passes);
          break;
        case '//Storyboard Layer 3 (Foreground)':
          i = _parseLayer(i + 1, events.foregrounds);
          break;
        default:
          // 跳过不能处理的语句
          i++;
          break;
      }
    }
  }

  /// 解析背景
  int _parseBackground(int i) {
    OSBBackground osbBackground = OSBBackground();
    String line = lines[i];
    i++;
    List<String> params = line.split(',');
    if (params.length != 5) {
      return i;
    }
    osbBackground.type = int.tryParse(params[0]);
    osbBackground.startTime = int.tryParse(params[1]);
    osbBackground.fileName = params[2].replaceAll('"', '');
    Offset offset = Offset(double.tryParse(params[3] ?? '0') ?? 0,
        double.tryParse(params[4] ?? '0') ?? 0);
    osbBackground.offset = offset;
    mapInfo.events.background = osbBackground;
    return i;
  }

  /// 解析休息点
  int _parseBreakPeriods(int i) {
    for (; i < lines.length; i++) {
      String line = lines[i];
      if (line.startsWith('//')) {
        return i;
      }
    }
    return i;
  }

  /// 解析精灵图层
  int _parseLayer(int i, List<Sprite> sprites) {
    for (; i < lines.length;) {
      String line = lines[i];
      if (line.startsWith('//')) {
        return i;
      } else if (line.startsWith('Sprite') || line.startsWith('Animation')) {
        i = _parseSprite(i, sprites);
        continue;
      } else {
        i++;
        continue;
      }
    }
    return i;
  }

  /// 解析精灵图层
  int _parseSprite(int i, List<Sprite> sprites) {
    List<String> spriteStr = lines[i].split(',');
    if (spriteStr.length < 6) {
      return i + 1;
    }
    SpriteLayer layer = () {
      switch (spriteStr[1]) {
        case 'Background':
          return SpriteLayer.Background;
        case 'Fail':
          return SpriteLayer.Fail;
        case 'Pass':
          return SpriteLayer.Pass;
        case 'Foreground':
          return SpriteLayer.Foreground;
      }
      return null;
    }();
    SpriteOrigin origin = () {
      switch (spriteStr[2]) {
        case 'TopLeft':
          return SpriteOrigin.TopLeft;
        case 'Centre':
          return SpriteOrigin.Centre;
        case 'CentreLeft':
          return SpriteOrigin.CentreLeft;
        case 'TopRight':
          return SpriteOrigin.TopRight;
        case 'BottomCentre':
          return SpriteOrigin.BottomCentre;
        case 'TopCentre':
          return SpriteOrigin.TopCentre;
        case 'CentreRight':
          return SpriteOrigin.CentreRight;
        case 'BottomLeft':
          return SpriteOrigin.BottomLeft;
        case 'BottomRight':
          return SpriteOrigin.BottomRight;
      }
      return null;
    }();
    String fileName;
    if (spriteStr[3].trim().length > 2) {
      fileName = spriteStr[3].trim().substring(1, spriteStr[3].length - 1);
    }
    Offset position = Offset(double.tryParse(spriteStr[4] ?? '0') ?? 0,
        double.tryParse(spriteStr[5] ?? '0') ?? 0);
    Sprite sprite = () {
      switch (spriteStr[0].trim()) {
        case 'Sprite':
          return Sprite();
        case 'Animation':
          if (spriteStr.length != 9) {
            return null;
          }
          int frameCount = int.tryParse(spriteStr[6] ?? '0') ?? 0;
          int frameDelay = (double.tryParse(spriteStr[7] ?? '0') ?? 0).toInt();
          SpriteLoopType loopType = () {
            switch (spriteStr[8]) {
              case 'LoopForever':
                return SpriteLoopType.LoopForever;
              case 'LoopOnce':
                return SpriteLoopType.LoopOnce;
            }
            return null;
          }();
          return AnimationSprite()
            ..frameCount = frameCount
            ..frameDelay = frameDelay
            ..loopType = loopType;
      }
      return null;
    }();
    if (sprite == null) {
      return i + 1;
    }
    sprite.layer = layer;
    sprite.origin = origin;
    sprite.fileName = fileName;
    sprite.position = position;

    i = _parseEvents(i + 1, sprite);

    sprites.add(sprite);
    //
    return i;
  }

  int _parseEvents(int i, Sprite sprite) {
    for (; i < lines.length;) {
      String line = lines[i];
      if (line.startsWith('//') ||
          line.startsWith('Sprite') ||
          line.startsWith('Animation')) {
        return i;
      }
      List<String> eventStrs = line.split(',');
      if (eventStrs.length < 1) {
        i++;
        continue;
      }
      i = _parseEventType(i + 1, sprite, eventStrs);
    }
    return i;
  }

  int _parseEventType(int i, Sprite sprite, List<String> event) {
    if (sprite == null || (event?.length ?? 0) < 1) {
      return i;
    }
    if (sprite.events == null) {
      sprite.events = List();
    }
    String type = event[0].replaceAll('_', '').replaceAll(' ', '');
    switch (type) {
      case 'F':
        FadeEvent fadeEvent = FadeEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'M':
        MoveEvent fadeEvent = MoveEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'MX':
        MoveXEvent fadeEvent = MoveXEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'MY':
        MoveYEvent fadeEvent = MoveYEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'S':
        ScaleEvent fadeEvent = ScaleEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'V':
        VectorScaleEvent fadeEvent = VectorScaleEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'R':
        RotateEvent fadeEvent = RotateEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'C':
        ColourEvent fadeEvent = ColourEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'P':
        ParameterEvent fadeEvent = ParameterEvent();
        sprite.events.add(fadeEvent);
        break;
      case 'L':
        break;
      case 'T':
        break;
    }
    return i;
  }
}
