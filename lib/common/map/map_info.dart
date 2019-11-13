import 'package:flutter_storyboard_player/common/map/storyboard_info.dart';

class OSUMapInfo {
  /// 一般信息
  OSUMapGeneral general;

  /// 编辑器保存的信息
  OSUMapEditor editor;

  /// 地图元数据
  OSUMapMetadata metadata;

  /// 难度信息
  OSUMapDifficulty difficulty;

  /// 故事板
  OSBEvents events;
}

/// 样本集
enum SampleSet {
  Normal,
  Soft,
  Drum,
}

/// 游戏模式
enum GameMode {
  OSU,
  TAIKO,
  CATCH,
  MANIA,
}

enum OverlayPosition {
  NoChange,
  Below,
  Above,
}

/// 一般信息
class OSUMapGeneral {
  /// 音频文件
  String audioFilename;

  /// 播放前的静音时间
  int audioLeadIn;

  /// 预览时间
  int previewTime;

  /// 倒数速度
  int countDown;

  /// 样本集
  SampleSet sampleSet;

  ///堆叠在一起的时间阈值倍数
  double stackLeniency;

  /// 模式
  GameMode mode;

  bool letterboxInBreaks;
  bool storyFireInFront;

  /// StoryBoard是否可以使用用户皮肤
  bool useSkinSprites;

  bool alwaysShowPlayField;

  /// 叠加层绘制顺序
  OverlayPosition overlayPosition;

  /// 首选皮肤
  String skinPreference;

  /// 地图开头是否显示颜色闪烁警告
  bool epilepsyWarning;

  /// 从第一个打击对象开始倒计时开始的节拍时间
  int countdownOffset;

  /// osu mania是否使用n+i的键盘布局
  bool specialStyle;

  /// StoryBoard是否允许宽屏观看
  bool wideScreenStoryBoard;

  /// 使用变速模块时是否改变声音样本速率
  bool samplesMatchPlaybackRate;

  OSUMapGeneral();

  factory OSUMapGeneral.fromMap(Map<String, String> map) {
    if (map == null) {
      return null;
    }
    OSUMapGeneral general = OSUMapGeneral();
    general.audioFilename = map['AudioFilename'];
    general.audioLeadIn = int.tryParse(map['AudioLeadIn'] ?? '0') ?? 0;
    general.previewTime = int.tryParse(map['PreviewTime'] ?? '-1') ?? -1;
    general.countDown = int.tryParse(map['Countdown'] ?? '1') ?? 1;
    general.sampleSet = () {
      switch (map['SampleSet']) {
        case 'Normal':
          return SampleSet.Normal;
        case 'Soft':
          return SampleSet.Soft;
        case 'Drum':
          return SampleSet.Drum;
      }
      return SampleSet.Normal;
    }();
    general.stackLeniency =
        double.tryParse(map['StackLeniency'] ?? '0.7') ?? 0.7;
    general.mode = () {
      switch (map['Mode']) {
        case '0':
          return GameMode.OSU;
        case '1':
          return GameMode.TAIKO;
        case '2':
          return GameMode.CATCH;
        case '3':
          return GameMode.MANIA;
      }
      return GameMode.OSU;
    }();
    general.letterboxInBreaks = (map['LetterboxInBreaks'] ?? '0') == '1';
    general.storyFireInFront = (map['StoryFireInFront'] ?? '1') == '1';
    general.useSkinSprites = (map['UseSkinSprites'] ?? '0') == '1';
    general.alwaysShowPlayField = (map['AlwaysShowPlayfield'] ?? '0') == '1';
    general.overlayPosition = () {
      switch (map['OverlayPosition']) {
        case 'NoChange ':
          return OverlayPosition.NoChange;
        case 'Below ':
          return OverlayPosition.Below;
        case 'Above ':
          return OverlayPosition.Above;
      }
      return OverlayPosition.NoChange;
    }();
    general.skinPreference = map['SkinPreference'];
    general.epilepsyWarning = (map['EpilepsyWarning'] ?? '0') == '1';
    general.countdownOffset = int.tryParse(map['CountdownOffset'] ?? '0') ?? 0;
    general.specialStyle = (map['SpecialStyle'] ?? '0') == '1';
    general.wideScreenStoryBoard = (map['WidescreenStoryboard'] ?? '0') == '1';
    general.samplesMatchPlaybackRate =
        (map['SamplesMatchPlaybackRate'] ?? '0') == '1';
    return general;
  }

  @override
  String toString() {
    return '''======[General]======
| AudioFilename: $audioFilename
| AudioLeadIn: $audioLeadIn
| PreviewTime: $previewTime
| Countdown: $countDown
| SampleSet: $sampleSet
| StackLeniency: $stackLeniency
| Mode: $mode
| LetterboxInBreaks: $letterboxInBreaks
| StoryFireInFront: $storyFireInFront
| UseSkinSprites: $useSkinSprites
| AlwaysShowPlayfield: $alwaysShowPlayField
| OverlayPosition: $overlayPosition
| SkinPreference: $skinPreference
| EpilepsyWarning: $epilepsyWarning
| CountdownOffset: $countdownOffset
| SpecialStyle: $specialStyle
| WidescreenStoryboard: $wideScreenStoryBoard
| SamplesMatchPlaybackRate: $samplesMatchPlaybackRate
==================
''';
  }
}

/// 编辑器保存的信息
class OSUMapEditor {
  /// 书签时间(ms)
  List<int> bookmarks;

  /// 距离间距
  double distanceSpacing;

  /// 节拍除数
  double beatDivisor;

  /// 网格大小
  int gridSize;

  /// 时间轴缩放
  double timelineZoom;

  OSUMapEditor();

  factory OSUMapEditor.fromMap(Map<String, String> map) {
    if (map == null) {
      return null;
    }
    OSUMapEditor editor = OSUMapEditor();
    editor.bookmarks = () {
      List<String> marks = map['Bookmarks']?.split(',');
      List<int> bookmarks = List<int>.generate(marks?.length ?? 0, (index) {
        return int.tryParse(marks[index]?.trim() ?? '-1');
      });
      return bookmarks;
    }();
    if (map['DistanceSpacing'] != null) {
      editor.distanceSpacing = double.tryParse(map['DistanceSpacing']);
    }
    if (map['BeatDivisor'] != null) {
      editor.beatDivisor = double.tryParse(map['BeatDivisor']);
    }
    if (map['GridSize'] != null) {
      editor.gridSize = int.tryParse(map['GridSize']);
    }
    if (map['TimelineZoom'] != null) {
      editor.timelineZoom = double.tryParse(map['TimelineZoom']);
    }

    return editor;
  }

  @override
  String toString() {
    return '''======[Editor]======
| Bookmarks: $bookmarks
| DistanceSpacing: $distanceSpacing
| BeatDivisor: $beatDivisor
| GridSize: $gridSize
| TimelineZoom: $timelineZoom
==================
''';
  }
}

/// 地图元数据
class OSUMapMetadata {
  /// 标题
  String title;

  /// 标题unicode
  String titleUnicode;

  /// 艺术家
  String artist;

  /// 艺术家unicode
  String artistUnicode;

  /// 地图创建者
  String creator;

  /// 难度名称
  String version;

  /// 歌曲源
  String source;

  /// 标签
  List<String> tags;

  /// 地图id
  int beatmapID;

  /// 地图集id
  int beatmapSetID;

  OSUMapMetadata();

  factory OSUMapMetadata.fromMap(Map<String, String> map) {
    if (map == null) {
      return null;
    }
    OSUMapMetadata metadata = OSUMapMetadata();
    metadata.title = map['Title'];
    metadata.titleUnicode = map['TitleUnicode'];
    metadata.artist = map['Artist'];
    metadata.artistUnicode = map['ArtistUnicode'];
    metadata.creator = map['Creator'];
    metadata.version = map['Version'];
    metadata.source = map['Source'];
    metadata.tags = () {
      List<String> tags = map['Tags']?.split(RegExp(r'\s+'));
      return List<String>.generate(tags?.length ?? 0, (index) {
        return tags[index]?.trim();
      });
    }();
    if (map['BeatmapID'] != null) {
      metadata.beatmapID = int.tryParse(map['BeatmapID']);
    }
    if (map['BeatmapSetID'] != null) {
      metadata.beatmapSetID = int.tryParse(map['BeatmapSetID']);
    }
    return metadata;
  }

  @override
  String toString() {
    return '''======[Metadata]======
| Title: $title
| TitleUnicode: $titleUnicode
| Artist: $artist
| ArtistUnicode: $artistUnicode
| Creator: $creator
| Version: $version
| Source: $source
| Tags: $tags
| BeatmapID: $beatmapID
| BeatmapSetID: $beatmapSetID
==================
''';
  }
}

/// 难度信息
class OSUMapDifficulty {
  /// HP 设置(0-10)
  double hpDrainRate;

  /// circle 大小设置(0-10)
  double circleSize;

  /// 总体难度(0-10)
  double overallDifficulty;

  /// AR 设置(0-10)
  double approachRate;

  double sliderMultiplier;

  double sliderTickRate;

  OSUMapDifficulty();

  factory OSUMapDifficulty.fromMap(Map<String, String> map) {
    if (map == null) {
      return null;
    }
    OSUMapDifficulty difficulty = OSUMapDifficulty();
    if (map['HPDrainRate'] != null) {
      difficulty.hpDrainRate = double.tryParse(map['HPDrainRate']);
    }
    if (map['CircleSize'] != null) {
      difficulty.circleSize = double.tryParse(map['CircleSize']);
    }
    if (map['OverallDifficulty'] != null) {
      difficulty.overallDifficulty = double.tryParse(map['OverallDifficulty']);
    }
    if (map['ApproachRate'] != null) {
      difficulty.approachRate = double.tryParse(map['ApproachRate']);
    }
    if (map['SliderMultiplier'] != null) {
      difficulty.sliderMultiplier = double.tryParse(map['SliderMultiplier']);
    }
    if (map['SliderTickRate'] != null) {
      difficulty.sliderTickRate = double.tryParse(map['SliderTickRate']);
    }

    return difficulty;
  }

  @override
  String toString() {
    return '''======[Difficulty]======
| HPDrainRate: $hpDrainRate
| CircleSize: $circleSize
| OverallDifficulty: $overallDifficulty
| ApproachRate: $approachRate
| SliderMultiplier: $sliderMultiplier
| SliderTickRate: $sliderTickRate
==================
''';
  }
}
