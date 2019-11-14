import 'package:flutter/services.dart';

typedef MediaTimeUpdate = void Function(int);

class MediaPlugin {
  static MediaPlugin _instance;

  factory MediaPlugin() => _getInstance();

  static MediaPlugin _getInstance() {
    if (_instance == null) {
      _instance = MediaPlugin._internal();
    }
    return _instance;
  }

  final MethodChannel _methodChannel =
      MethodChannel('com.xhhold.flutter.storyboard.player/method/media');
  final EventChannel _eventChannel =
      EventChannel('com.xhhold.flutter.storyboard.player/event/media');

  Set<MediaTimeUpdate> _mediaTimeUpdates;

  String _path;

  String get path => _path;

  bool _isPlaying;

  bool get isPlaying => _isPlaying;

  MediaPlugin._internal() {
    _eventChannel.receiveBroadcastStream().listen(_update);
    _methodChannel.setMethodCallHandler(_handler);
  }

  void _update(data) {
    if (data is Map) {
      int type = data['type'];
      switch (type) {
        case 1:
          int time = data['time'];
          _mediaTimeUpdates?.forEach((callback) {
            if (callback != null) {
              callback(time);
            }
          });
          break;
      }
    }
  }

  void _handler(MethodCall call) {
    /* switch (call.method) {
      case '':
        break;
    }*/
  }

  /// 添加时间更新监听
  void addTimeUpdateListener(MediaTimeUpdate timeUpdate) {
    if (_mediaTimeUpdates == null) {
      _mediaTimeUpdates = Set();
    }
    _mediaTimeUpdates.add(timeUpdate);
  }

  /// 播放
  Future<Null> play([String path]) async {
    _isPlaying = true;
    await _methodChannel.invokeMethod('play', {'path': path});
  }

  /// 暂停
  Future<Null> pause() async {
    _isPlaying = false;
    await _methodChannel.invokeMethod('pause');
  }
}
