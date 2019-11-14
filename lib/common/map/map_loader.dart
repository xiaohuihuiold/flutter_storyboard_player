import 'dart:io';
import 'dart:math';
import 'dart:ui';

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
    List<String> lines = await file.readAsLines();

    // 初始化数据
    mapInfo = OSUMapInfo();
    mapInfo.path = file.parent.path;
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
    List<String> lines = await osbFile.readAsLines();
    lines?.remove('[Events]');
    if (_events != null) {
      lines.insertAll(0, _events);
    }
    await (_OSUStoryBoardLoader(mapInfo, lines).parse());
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
  Future<Null> parse() async {
    if (mapInfo == null || lines == null) {
      return;
    }
    OSBEvents events = OSBEvents();
    mapInfo.events = events;
    for (int i = 0; i < lines.length;) {
      String line = lines[i];
      switch (line.trim()) {
        case '//Background and Video events':
          i = await _parseBackground(i + 1);
          break;
        case '//Break Periods':
          i = await _parseBreakPeriods(i + 1);
          break;
        case '//Storyboard Layer 0 (Background)':
          i = await _parseLayer(i + 1, events.backgrounds);
          break;
        case '//Storyboard Layer 1 (Fail)':
          i = await _parseLayer(i + 1, events.fails);
          break;
        case '//Storyboard Layer 2 (Pass)':
          i = await _parseLayer(i + 1, events.passes);
          break;
        case '//Storyboard Layer 3 (Foreground)':
          i = await _parseLayer(i + 1, events.foregrounds);
          break;
        default:
          // 跳过不能处理的语句
          i++;
          break;
      }
    }
  }

  /// 解析背景
  Future<int> _parseBackground(int i) async {
    OSBBackground osbBackground = OSBBackground();
    for (; i < lines.length; i++) {
      String line = lines[i];
      if (line.startsWith('//')) {
        return i;
      }
      List<String> params = line.split(',');
      if (params.length < 3 || params[0].trim() != '0') {
        continue;
      }
      osbBackground.type = int.tryParse(params[0]);
      osbBackground.startTime = int.tryParse(params[1]);
      osbBackground.fileName =
          params[2].replaceAll('"', '').replaceAll(r'\', '/');
      if (params.length != 3) {
        Offset offset = Offset(double.tryParse(params[3] ?? '0') ?? 0,
            double.tryParse(params[4] ?? '0') ?? 0);
        osbBackground.offset = offset;
      }
      i++;
      break;
    }
    mapInfo.events.background = osbBackground;
    return i;
  }

  /// 解析休息点
  Future<int> _parseBreakPeriods(int i) async {
    for (; i < lines.length; i++) {
      String line = lines[i];
      if (line.startsWith('//')) {
        return i;
      }
    }
    return i;
  }

  /// 解析精灵图层
  Future<int> _parseLayer(int i, List<Sprite> sprites) async {
    for (; i < lines.length;) {
      String line = lines[i];
      if (line.startsWith('//')) {
        return i;
      } else if (line.startsWith('Sprite') || line.startsWith('Animation')) {
        i = await _parseSprite(i, sprites);
        continue;
      } else {
        i++;
        continue;
      }
    }
    return i;
  }

  /// 解析精灵图层
  Future<int> _parseSprite(int i, List<Sprite> sprites) async {
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
    sprite.fileName = fileName.replaceAll(r'\', '/');
    sprite.position = position;
    sprite.image = await _loadImage('${mapInfo.path}/${sprite.fileName}');

    i = await _parseEvents(i + 1, sprite: sprite);

    sprites.add(sprite);
    //
    return i;
  }

  /// 解析事件
  Future<int> _parseEvents(int i,
      {Sprite sprite, LoopEvent loopEvent, TriggerEvent triggerEvent}) async {
    for (; i < lines.length;) {
      String line = lines[i];
      if ((loopEvent != null || triggerEvent != null) &&
          !line.startsWith('  ') &&
          !line.startsWith('__')) {
        return i;
      }
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
      i = await _parseEventType(
        i + 1,
        eventStrs,
        sprite: sprite,
        loopEvent: loopEvent,
        triggerEvent: triggerEvent,
      );
    }
    return i;
  }

  /// 根据类型解析事件
  Future<int> _parseEventType(int i, List<String> event,
      {Sprite sprite, LoopEvent loopEvent, TriggerEvent triggerEvent}) async {
    SpriteEvent spriteEvent;
    String type = event[0].replaceAll('_', '').replaceAll(' ', '');
    if (type != 'L' && type != 'T') {
      if ((event?.length ?? 0) < 4) {
        return i;
      }
    } else {
      if ((event?.length ?? 0) < 3) {
        return i;
      }
    }
    int easing;
    int startTime;
    int endTime;
    if (type != 'L' && type != 'T') {
      easing = int.tryParse(event[1].trim());
      startTime = int.tryParse(event[2].trim());
      if (event[3].trim() == '') {
        endTime = startTime;
      } else {
        endTime = int.tryParse(event[3].trim());
      }
    }
    switch (type) {
      case 'F':
        FadeEvent fadeEvent = FadeEvent();
        spriteEvent = fadeEvent;
        fadeEvent.startOpacity = double.tryParse(event[4].trim());
        if (event.length < 6) {
          fadeEvent.endOpacity = fadeEvent.startOpacity;
        } else {
          fadeEvent.endOpacity = double.tryParse(event[5].trim());
        }
        break;
      case 'M':
        MoveEvent moveEvent = MoveEvent();
        spriteEvent = moveEvent;
        Offset startOffset =
            Offset(double.tryParse(event[4]), double.tryParse(event[5]));
        Offset endOffset;
        if (event.length == 6) {
          endOffset = startOffset;
        } else {
          endOffset =
              Offset(double.tryParse(event[6]), double.tryParse(event[7]));
        }

        moveEvent.startOffset = startOffset;
        moveEvent.endOffset = endOffset;
        break;
      case 'MX':
        MoveXEvent moveXEvent = MoveXEvent();
        spriteEvent = moveXEvent;
        moveXEvent.startX = double.tryParse(event[4].trim());
        if (event.length < 6) {
          moveXEvent.endX = moveXEvent.startX;
        } else {
          moveXEvent.endX = double.tryParse(event[5].trim());
        }
        break;
      case 'MY':
        MoveYEvent moveYEvent = MoveYEvent();
        spriteEvent = moveYEvent;
        moveYEvent.startY = double.tryParse(event[4].trim());
        if (event.length < 6) {
          moveYEvent.endY = moveYEvent.startY;
        } else {
          moveYEvent.endY = double.tryParse(event[5].trim());
        }
        break;
      case 'S':
        ScaleEvent scaleEvent = ScaleEvent();
        spriteEvent = scaleEvent;
        scaleEvent.startScale = double.tryParse(event[4].trim());
        if (event.length < 6) {
          scaleEvent.endScale = scaleEvent.startScale;
        } else {
          scaleEvent.endScale = double.tryParse(event[5].trim());
        }
        break;
      case 'V':
        VectorScaleEvent vectorScaleEvent = VectorScaleEvent();
        spriteEvent = vectorScaleEvent;
        vectorScaleEvent.startX = double.tryParse(event[4].trim());
        vectorScaleEvent.startY = double.tryParse(event[5].trim());
        if (event.length == 6) {
          vectorScaleEvent.endX = vectorScaleEvent.startX;
          vectorScaleEvent.endY = vectorScaleEvent.startY;
        } else {
          vectorScaleEvent.endX = double.tryParse(event[6].trim());
          vectorScaleEvent.endY = double.tryParse(event[7].trim());
        }
        break;
      case 'R':
        RotateEvent rotateEvent = RotateEvent();
        spriteEvent = rotateEvent;
        rotateEvent.startRotate = double.tryParse(event[4].trim());
        if (event.length < 6) {
          rotateEvent.endRotate = rotateEvent.startRotate;
        } else {
          rotateEvent.endRotate = double.tryParse(event[5].trim());
        }
        break;
      case 'C':
        ColourEvent colourEvent = ColourEvent();
        spriteEvent = colourEvent;
        // TODO: 未实现
        return i;
        break;
      case 'P':
        ParameterEvent parameterEvent = ParameterEvent();
        spriteEvent = parameterEvent;
        switch (event[4]) {
          case 'H':
            parameterEvent.type = ParameterType.H;
            break;
          case 'V':
            parameterEvent.type = ParameterType.V;
            break;
          case 'A':
            parameterEvent.type = ParameterType.A;
            break;
        }
        break;
      case 'L':
        LoopEvent loopEvent = LoopEvent();
        spriteEvent = loopEvent;
        loopEvent.startTime = int.tryParse(event[1]);
        loopEvent.loopCount = int.tryParse(event[2]);
        i = await _parseEvents(i, loopEvent: loopEvent);
        break;
      case 'T':
        TriggerEvent triggerEvent = TriggerEvent();
        spriteEvent = triggerEvent;
        triggerEvent.startTime = int.tryParse(event[2]);
        triggerEvent.endTime = int.tryParse(event[3]);
        triggerEvent.triggerType = () {
          switch (event[1]) {
            case 'HitSound':
              return TriggerType.HitSound;
            case 'Failing':
              return TriggerType.Failing;
            case 'Passing':
              return TriggerType.Passing;
          }
          return null;
        }();
        i = await _parseEvents(i, triggerEvent: triggerEvent);
        break;
    }
    if (spriteEvent == null) {
      return i;
    }
    if (type != 'L' && type != 'T') {
      spriteEvent.easing = easing;
      spriteEvent.startTime = startTime;
      spriteEvent.endTime = endTime;
    }
    if (sprite != null) {
      if (sprite.events == null) {
        sprite.events = List();
      }
      sprite.events.add(spriteEvent);
    } else if (loopEvent != null) {
      if (loopEvent.events == null) {
        loopEvent.events = List();
      }
      loopEvent.events.add(spriteEvent);
    } else if (triggerEvent != null) {
      if (triggerEvent.events == null) {
        triggerEvent.events = List();
      }
      triggerEvent.events.add(spriteEvent);
    }
    return i;
  }

  Map<String, Image> _imageCache = Map();

  Future<Image> _loadImage(String path) async {
    Image image = _imageCache[path.trim()];
    if (image != null) {
      return image;
    }
    File file = File(path);
    if (!(await file.exists())) {
      return null;
    }
    Codec codec = await instantiateImageCodec(
        file.readAsBytesSync().buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    _imageCache[path.trim()] = image;
    return image;
  }
}
