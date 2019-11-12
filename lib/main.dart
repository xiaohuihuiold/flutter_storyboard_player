import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_storyboard_player/page/home/home_page.dart';
import 'package:flutter_storyboard_player/page/maps/maps_page.dart';
import 'package:flutter_storyboard_player/page/player/map_player_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 全屏并横屏
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryBoardPlayer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // TODO: 地图播放页
      home: MapPlayerPage(),
      routes: <String, WidgetBuilder>{
        // 首页
        HomePage.routerName: (_) => HomePage(),
        // 地图列表页
        MapsPage.routerName: (_) => MapsPage(),
        // 地图播放器
        MapPlayerPage.routerName: (_) => MapPlayerPage(),
      },
    );
  }
}
