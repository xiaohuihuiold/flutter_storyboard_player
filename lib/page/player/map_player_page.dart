import 'package:flutter/material.dart';
import 'package:flutter_storyboard_player/common/map/map_info.dart';
import 'package:flutter_storyboard_player/common/map/map_loader.dart';
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
