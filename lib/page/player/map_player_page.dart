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

  void _onTimeUpdate(int time) {
    _controller.time = time;
  }

  Future<Null> _onFrame(_) async {
    String path =
        r'/sdcard/osu/372552 yuiko - Azuma no Sora kara Hajimaru Sekai/yuiko - Azuma no Sora kara Hajimaru Sekai (Short) (KaedekaShizuru) [Easy].osu';
    OSUMapLoader loader = OSUMapLoader();
    OSUMapInfo mapInfo = await loader.loadFromPath(path);
    mapInfo = await loader.loadOSB();
    mapInfo?.events?.backgrounds?.forEach((e) {
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
    });
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
      body: StoryBoardView(
        controller: _controller,
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