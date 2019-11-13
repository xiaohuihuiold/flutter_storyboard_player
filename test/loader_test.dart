import 'package:flutter_storyboard_player/common/map/map_info.dart';
import 'package:flutter_storyboard_player/common/map/map_loader.dart';
import 'package:flutter_storyboard_player/common/map/storyboard_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loader test',
    () async {
      String path = r'assets\test.osu';
      OSUMapLoader loader = OSUMapLoader();
      OSUMapInfo mapInfo = await loader.loadFromPath(path);
      mapInfo = await loader.loadOSB();
      print(mapInfo?.general);
      print(mapInfo?.editor);
      print(mapInfo?.metadata);
      print(mapInfo?.difficulty);
      print(mapInfo?.events?.background);
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
    },
    timeout: Timeout(Duration(days: 1)),
  );
}

void printSprite(Sprite sprite) {
  print('$sprite');
  sprite?.events?.forEach((e) {
    print(' $e:(${e.easing},${e.startTime},${e.endTime})');
  });
}
