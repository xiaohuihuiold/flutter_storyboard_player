import 'package:flutter/material.dart';
import 'package:flutter_storyboard_player/common/widget/storyboard_view.dart';

class MapPlayerPage extends StatefulWidget {
  static const routerName = '/map_player';

  @override
  _MapPlayerPageState createState() => _MapPlayerPageState();
}

class _MapPlayerPageState extends State<MapPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryBoardView(),
    );
  }
}
