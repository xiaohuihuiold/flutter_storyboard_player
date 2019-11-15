import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_storyboard_player/common/map/map_info.dart';
import 'package:flutter_storyboard_player/common/map/map_loader.dart';
import 'package:flutter_storyboard_player/common/map/storyboard_event.dart';
import 'package:flutter_storyboard_player/common/map/storyboard_info.dart';
import 'package:flutter_storyboard_player/common/plugin/media_plugin.dart';
import 'package:flutter_storyboard_player/common/widget/storyboard_view.dart';

class MapPlayerPage extends StatefulWidget {
  static const routerName = '/map_player';

  @override
  _MapPlayerPageState createState() => _MapPlayerPageState();
}

class _MapPlayerPageState extends State<MapPlayerPage> {
  StoryBoardController _controller = StoryBoardController();
  OSUMapInfo _mapInfo;

  void _onTimeUpdate(int time) {
    _controller.time = time;
  }

  Future<Null> _onFrame(_) async {
    String path =
        r"/sdcard/osu/416153 Remo Prototype[CV_ Hanamori Yumiri] - Send/Remo Prototype[CV Hanamori Yumiri] - Sendan Life (Lami) [Nostalgia].osu";
    OSUMapLoader loader = OSUMapLoader();
    OSUMapInfo mapInfo = await loader.loadFromPath(path);
    mapInfo = await loader.loadOSB();
    setState(() {
      _mapInfo = mapInfo;
    });
    /*  mapInfo?.events?.backgrounds?.forEach((e) {
      printSprite(e);
    });
    mapInfo?.events?.fails?.forEach((e) {
      printSprite(e);
    });
    mapInfo?.events?.passes?.forEach((e) {
      printSprite(e);
    });
    mapInfo?.events?.foregrounds?.forEach((e) {
      printSprite(e);
    });*/
    if (mapInfo != null) {
      _controller.mapInfo = mapInfo;
      MediaPlugin().play('${mapInfo.path}/${mapInfo.general.audioFilename}');
    }
  }

  @override
  void initState() {
    super.initState();
    MediaPlugin().addTimeUpdateListener(_onTimeUpdate);
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          if (_mapInfo != null)
            Container(
              alignment: Alignment.center,
              child: Image.file(
                File(
                    '${_mapInfo.path}/${_mapInfo.events.background?.fileName}'),
              ),
            ),
          StoryBoardView(
            controller: _controller,
          ),
        ],
      ),
    );
  }
}

void printSprite(Sprite sprite) {
  print('$sprite');
  sprite?.events?.forEach((e) {
    if (e is TriggerEvent) {
      print(' $e:(${e.startTime},${e.endTime})');
      e.events?.forEach((el) {
        print('  $el:(${el.easing},${el.startTime},${el.endTime})');
      });
    } else if (e is LoopEvent) {
      print(' $e:(${e.startTime})');
      e.events?.forEach((el) {
        print('  $el:(${el.easing},${el.startTime},${el.endTime})');
      });
    } else {
      print(' $e:(${e.easing},${e.startTime},${e.endTime})');
    }
  });
}
