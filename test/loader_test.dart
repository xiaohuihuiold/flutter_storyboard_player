import 'package:flutter_storyboard_player/common/map/map_info.dart';
import 'package:flutter_storyboard_player/common/map/map_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loader test',
    () async {
      String path = r'F:\app\flutter_storyboard_player\assets\test.osu';
      OSUMapInfo mapInfo = await OSUMapLoader().loadFromPath(path);
      print(mapInfo);
    },
    timeout: Timeout(Duration(days: 1)),
  );
}
