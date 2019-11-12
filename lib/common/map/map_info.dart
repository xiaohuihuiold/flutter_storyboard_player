class OSUMapInfo {
  /// 一般信息
  OSUMapGeneral general;

  /// 编辑器保存的信息
  OSUMapEditor editor;

  /// 地图元数据
  OSUMapMetadata metadata;

  /// 难度信息
  OSUMapDifficulty difficulty;
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
}
