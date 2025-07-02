import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../virtual_file_system/vfs_service_provider.dart';

/// 音频播放配置
class AudioPlayerConfig {
  /// 自动播放
  final bool autoPlay;

  /// 循环播放
  final bool looping;

  /// 初始音量 (0.0 - 1.0)
  final double volume;

  /// 播放速度 (0.25 - 4.0)
  final double playbackRate;

  /// 平衡 (-1.0 左声道, 0.0 中央, 1.0 右声道)
  final double balance;

  /// 是否静音
  final bool muted;

  const AudioPlayerConfig({
    this.autoPlay = false,
    this.looping = false,
    this.volume = 1.0,
    this.playbackRate = 1.0,
    this.balance = 0.0,
    this.muted = false,
  });

  /// 默认配置
  static const AudioPlayerConfig defaultConfig = AudioPlayerConfig();

  /// 静音配置
  static const AudioPlayerConfig mutedConfig = AudioPlayerConfig(muted: true);

  /// 自动播放配置
  static const AudioPlayerConfig autoPlayConfig = AudioPlayerConfig(
    autoPlay: true,
  );

  /// 循环播放配置
  static const AudioPlayerConfig loopingConfig = AudioPlayerConfig(
    looping: true,
  );

  AudioPlayerConfig copyWith({
    bool? autoPlay,
    bool? looping,
    double? volume,
    double? playbackRate,
    double? balance,
    bool? muted,
  }) {
    return AudioPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      looping: looping ?? this.looping,
      volume: volume ?? this.volume,
      playbackRate: playbackRate ?? this.playbackRate,
      balance: balance ?? this.balance,
      muted: muted ?? this.muted,
    );
  }
}

/// 播放队列项
class PlaylistItem {
  /// 音频源（VFS路径或网络URL）
  final String source;

  /// 显示标题
  final String title;

  /// 艺术家
  final String? artist;

  /// 专辑
  final String? album;

  /// 时长（秒）
  final Duration? duration;

  /// 是否为VFS路径
  final bool isVfsPath;

  /// 封面图片URL
  final String? artworkUrl;

  const PlaylistItem({
    required this.source,
    required this.title,
    this.artist,
    this.album,
    this.duration,
    this.isVfsPath = true,
    this.artworkUrl,
  });

  /// 从VFS路径创建播放列表项
  factory PlaylistItem.fromVfsPath(String vfsPath, {String? title}) {
    final fileName = vfsPath.split('/').last;
    final displayTitle = title ?? fileName.split('.').first;

    return PlaylistItem(source: vfsPath, title: displayTitle, isVfsPath: true);
  }

  /// 从网络URL创建播放列表项
  factory PlaylistItem.fromUrl(
    String url, {
    required String title,
    String? artist,
    String? album,
  }) {
    return PlaylistItem(
      source: url,
      title: title,
      artist: artist,
      album: album,
      isVfsPath: false,
    );
  }

  PlaylistItem copyWith({
    String? source,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    bool? isVfsPath,
    String? artworkUrl,
  }) {
    return PlaylistItem(
      source: source ?? this.source,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      isVfsPath: isVfsPath ?? this.isVfsPath,
      artworkUrl: artworkUrl ?? this.artworkUrl,
    );
  }
}

/// 音频播放状态
enum AudioPlaybackState {
  /// 已停止
  stopped,

  /// 播放中
  playing,

  /// 已暂停
  paused,

  /// 加载中
  loading,

  /// 错误
  error,

  /// 已完成
  completed,
}

/// 播放模式
enum PlaybackMode {
  /// 顺序播放
  sequential,

  /// 循环播放整个列表
  loopAll,

  /// 循环播放当前歌曲
  loopOne,

  /// 随机播放
  shuffle,
}

/// 音频播放器服务
/// 提供完整的音频播放功能，支持VFS和网络音频源
class AudioPlayerService extends ChangeNotifier {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  final VfsServiceProvider _vfsService = VfsServiceProvider();

  // 播放状态
  AudioPlaybackState _state = AudioPlaybackState.stopped;
  String? _currentSource;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  double _playbackRate = 1.0;
  double _balance = 0.0;
  bool _muted = false;
  String? _errorMessage;

  // 播放队列
  final List<PlaylistItem> _playlist = [];
  int _currentIndex = -1;
  PlaybackMode _playbackMode = PlaybackMode.sequential;
  bool _backgroundPlayback = false;

  // 临时队列（只存一个）
  PlaylistItem? _tempQueueItem;
  String? _tempQueueId;
  Duration? _tempQueueStartPosition;
  String? _tempQueueOwnerId; // 新增：临时队列归属组件id
  // 保存主队列播放状态
  int? _savedIndex;
  Duration? _savedPosition;
  String? _savedSource;

  // 组件暂停监听
  final Map<String, VoidCallback> _tempQueuePauseListeners = {};

  // 流订阅
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  // Getters
  AudioPlaybackState get state => _state;
  String? get currentSource => _currentSource;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  double get playbackRate => _playbackRate;
  double get balance => _balance;
  bool get muted => _muted;
  String? get errorMessage => _errorMessage;
  List<PlaylistItem> get playlist => List.unmodifiable(_playlist);
  int get currentIndex => _currentIndex;
  PlaylistItem? get currentItem =>
      _currentIndex >= 0 && _currentIndex < _playlist.length
      ? _playlist[_currentIndex]
      : null;
  PlaybackMode get playbackMode => _playbackMode;
  bool get backgroundPlayback => _backgroundPlayback;
  bool get isPlaying => _state == AudioPlaybackState.playing;
  bool get isPaused => _state == AudioPlaybackState.paused;
  bool get hasPlaylist => _playlist.isNotEmpty;

  /// 初始化音频播放器
  Future<void> initialize() async {
    try {
      // 设置音频会话
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              // 移除 defaultToSpeaker，因为它只能在 playAndRecord 类别中使用
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      // 订阅播放状态变化
      _playerStateSubscription = _player.onPlayerStateChanged.listen(
        _onPlayerStateChanged,
      );
      _positionSubscription = _player.onPositionChanged.listen(
        _onPositionChanged,
      );
      _durationSubscription = _player.onDurationChanged.listen(
        _onDurationChanged,
      );

      print('🎵 AudioPlayerService: 音频播放器初始化完成');
    } catch (e) {
      print('🎵 AudioPlayerService: 初始化失败 - $e');
      _setError('音频播放器初始化失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _player.dispose();
    super.dispose();
  }

  /// 播放音频
  /// [source] VFS路径或网络URL
  /// [config] 播放配置
  Future<bool> play({
    String? source,
    AudioPlayerConfig config = AudioPlayerConfig.defaultConfig,
  }) async {
    // 如果有临时队列，优先播放
    if (_tempQueueItem != null &&
        (source == null || source == _tempQueueItem!.source)) {
      try {
        _setState(AudioPlaybackState.loading);
        _clearError();
        await _applyConfig(config);
        await _loadAudioSource(_tempQueueItem!.source);
        _currentSource = _tempQueueItem!.source;
        await _player.resume().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('🎵 AudioPlayerService: 临时队列播放超时，但继续处理');
            _setState(AudioPlaybackState.playing);
          },
        );
        print('🎵 AudioPlayerService: 临时队列开始播放 - ${_tempQueueItem!.title}');
        return true;
      } catch (e) {
        print('🎵 AudioPlayerService: 临时队列播放失败 - $e');
        _setError('临时队列播放失败: $e');
        return false;
      }
    }

    try {
      String? audioSource = source ?? _currentSource;
      if (audioSource == null) {
        _setError('没有指定音频源');
        return false;
      }
      _setState(AudioPlaybackState.loading);
      _clearError();
      await _applyConfig(config);
      if (audioSource != _currentSource) {
        await _loadAudioSource(audioSource);
        _currentSource = audioSource;
      }
      await _player.resume().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('🎵 AudioPlayerService: 播放操作超时，但继续处理');
          _setState(AudioPlaybackState.playing);
        },
      );
      print('🎵 AudioPlayerService: 开始播放 - $audioSource');
      return true;
    } catch (e) {
      print('🎵 AudioPlayerService: 播放失败 - $e');
      _setError('播放失败: $e');
      return false;
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _player.pause().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('🎵 AudioPlayerService: 暂停操作超时，但继续处理');
          _setState(AudioPlaybackState.paused);
        },
      );
      print('🎵 AudioPlayerService: 已暂停');
    } catch (e) {
      print('🎵 AudioPlayerService: 暂停失败 - $e');
      _setError('暂停失败: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _player.stop();
      _currentPosition = Duration.zero;
      print('🎵 AudioPlayerService: 已停止');
    } catch (e) {
      print('🎵 AudioPlayerService: 停止失败 - $e');
      _setError('停止失败: $e');
    }
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    try {
      // 检查位置是否有效
      if (position.isNegative) {
        position = Duration.zero;
      }
      if (_totalDuration > Duration.zero && position > _totalDuration) {
        position = _totalDuration;
      }

      // 添加超时保护，最多等待5秒
      await _player
          .seek(position)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('🎵 AudioPlayerService: 跳转操作超时，使用备选方案');
              // 直接更新位置，不等待播放器响应
              _currentPosition = position;
              notifyListeners();
            },
          );

      print('🎵 AudioPlayerService: 跳转到 ${position.inSeconds}秒');
    } catch (e) {
      print('🎵 AudioPlayerService: 跳转失败 - $e');
      _setError('跳转失败: $e');

      // 即使跳转失败，也尝试更新本地位置状态
      if (!position.isNegative &&
          (_totalDuration <= Duration.zero || position <= _totalDuration)) {
        _currentPosition = position;
        notifyListeners();
      }
    }
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
      _volume = clampedVolume;
      notifyListeners();
      print('🎵 AudioPlayerService: 音量设置为 ${(_volume * 100).round()}%');
    } catch (e) {
      print('🎵 AudioPlayerService: 设置音量失败 - $e');
      _setError('设置音量失败: $e');
    }
  }

  /// 设置播放速度
  Future<void> setPlaybackRate(double rate) async {
    try {
      final clampedRate = rate.clamp(0.25, 4.0);
      await _player.setPlaybackRate(clampedRate);
      _playbackRate = clampedRate;
      notifyListeners();
      print('🎵 AudioPlayerService: 播放速度设置为 ${_playbackRate}x');
    } catch (e) {
      print('🎵 AudioPlayerService: 设置播放速度失败 - $e');
      _setError('设置播放速度失败: $e');
    }
  }

  /// 设置音频平衡
  Future<void> setBalance(double balance) async {
    try {
      final clampedBalance = balance.clamp(-1.0, 1.0);
      await _player.setBalance(clampedBalance);
      _balance = clampedBalance;
      notifyListeners();
      print('🎵 AudioPlayerService: 音频平衡设置为 $_balance');
    } catch (e) {
      print('🎵 AudioPlayerService: 设置音频平衡失败 - $e');
      _setError('设置音频平衡失败: $e');
    }
  }

  /// 切换静音状态
  Future<void> toggleMute() async {
    await setMuted(!_muted);
  }

  /// 设置静音状态
  Future<void> setMuted(bool muted) async {
    try {
      if (muted) {
        await _player.setVolume(0.0);
      } else {
        await _player.setVolume(_volume);
      }
      _muted = muted;
      notifyListeners();
      print('🎵 AudioPlayerService: ${_muted ? "已静音" : "取消静音"}');
    } catch (e) {
      print('🎵 AudioPlayerService: 切换静音失败 - $e');
      _setError('切换静音失败: $e');
    }
  }

  /// 添加到播放队列
  void addToPlaylist(PlaylistItem item) {
    _playlist.add(item);
    notifyListeners();
    print('🎵 AudioPlayerService: 添加到播放队列 - ${item.title}');
  }

  /// 批量添加到播放队列
  void addAllToPlaylist(List<PlaylistItem> items) {
    _playlist.addAll(items);
    notifyListeners();
    print('🎵 AudioPlayerService: 批量添加到播放队列 - ${items.length}首');
  }

  /// 在指定位置插入到播放队列
  void insertToPlaylist(int index, PlaylistItem item) {
    if (index < 0 || index > _playlist.length) {
      _playlist.add(item);
    } else {
      _playlist.insert(index, item);
    }
    notifyListeners();
    print('🎵 AudioPlayerService: 插入到播放队列[$index] - ${item.title}');
  }

  /// 从播放队列移除
  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      final item = _playlist.removeAt(index);

      // 如果移除的是当前播放的项目
      if (index == _currentIndex) {
        _currentIndex = -1;
        stop();
      } else if (index < _currentIndex) {
        _currentIndex--;
      }

      notifyListeners();
      print('🎵 AudioPlayerService: 从播放队列移除 - ${item.title}');
    }
  }

  /// 按source移除播放队列中的项
  void removeFromPlaylistBySource(String source) {
    final idx = _playlist.indexWhere((item) => item.source == source);
    if (idx != -1) {
      removeFromPlaylist(idx);
    }
  }

  /// 清空播放队列
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = -1;
    stop();
    notifyListeners();
    print('🎵 AudioPlayerService: 清空播放队列');
  }

  /// 替换整个播放队列（用于拖拽排序等场景）
  void updatePlaylist(List<PlaylistItem> newList) {
    _playlist
      ..clear()
      ..addAll(newList);
    notifyListeners();
    print('🎵 AudioPlayerService: 播放队列已更新');
  }

  /// 播放队列中的指定项目
  Future<bool> playFromPlaylist(int index) async {
    if (index < 0 || index >= _playlist.length) {
      _setError('播放队列索引超出范围');
      return false;
    }

    final item = _playlist[index];
    _currentIndex = index;
    notifyListeners();

    return await play(source: item.source);
  }

  /// 播放下一首
  Future<bool> playNext() async {
    if (_playlist.isEmpty) {
      _setError('播放队列为空');
      return false;
    }

    int nextIndex = _getNextIndex();
    if (nextIndex == -1) {
      print('🎵 AudioPlayerService: 已到播放队列末尾');
      return false;
    }

    return await playFromPlaylist(nextIndex);
  }

  /// 播放上一首
  Future<bool> playPrevious() async {
    if (_playlist.isEmpty) {
      _setError('播放队列为空');
      return false;
    }

    int prevIndex = _getPreviousIndex();
    if (prevIndex == -1) {
      print('🎵 AudioPlayerService: 已到播放队列开头');
      return false;
    }

    return await playFromPlaylist(prevIndex);
  }

  /// 设置播放模式
  void setPlaybackMode(PlaybackMode mode) {
    _playbackMode = mode;
    notifyListeners();
    print('🎵 AudioPlayerService: 播放模式设置为 $_playbackMode');
  }

  /// 启用/禁用后台播放
  void setBackgroundPlayback(bool enabled) {
    _backgroundPlayback = enabled;
    notifyListeners();
    print('🎵 AudioPlayerService: 后台播放 ${enabled ? "已启用" : "已禁用"}');
  }

  /// 加载音频源
  Future<void> _loadAudioSource(String source) async {
    print('🎵 AudioPlayerService: 开始加载音频源 - $source');

    if (_isNetworkUrl(source)) {
      // 网络URL直接播放
      print('🎵 AudioPlayerService: 使用网络URL播放');
      await _player.setSourceUrl(source);
    } else {
      // VFS路径需要先获取临时文件路径或Data URI
      print('🎵 AudioPlayerService: 从VFS生成播放URL');
      final playableUrl = await _vfsService.generateFileUrl(source);
      if (playableUrl == null) {
        throw Exception('无法从VFS获取音频文件');
      }

      print('🎵 AudioPlayerService: 生成的播放URL - $playableUrl');

      if (kIsWeb) {
        // Web平台使用Data URI
        await _player.setSourceUrl(playableUrl);
      } else {
        // 移动端/桌面端使用临时文件路径
        if (playableUrl.startsWith('http')) {
          await _player.setSourceUrl(playableUrl);
        } else {
          await _player.setSourceDeviceFile(playableUrl);
        }
      }
    }

    print('🎵 AudioPlayerService: 音频源加载完成');
  }

  /// 应用播放配置
  Future<void> _applyConfig(AudioPlayerConfig config) async {
    await setVolume(config.volume);
    await setPlaybackRate(config.playbackRate);
    await setBalance(config.balance);
    await setMuted(config.muted);

    // 循环播放设置
    await _player.setReleaseMode(
      config.looping ? ReleaseMode.loop : ReleaseMode.release,
    );
  }

  /// 检查是否为网络URL
  bool _isNetworkUrl(String source) {
    return source.startsWith('http://') || source.startsWith('https://');
  }

  /// 获取下一首索引
  int _getNextIndex() {
    if (_currentIndex == -1) return 0;

    switch (_playbackMode) {
      case PlaybackMode.sequential:
        return _currentIndex + 1 < _playlist.length ? _currentIndex + 1 : -1;

      case PlaybackMode.loopAll:
        return (_currentIndex + 1) % _playlist.length;

      case PlaybackMode.loopOne:
        return _currentIndex;

      case PlaybackMode.shuffle:
        if (_playlist.length <= 1) return _currentIndex;
        int nextIndex;
        do {
          nextIndex =
              (DateTime.now().millisecondsSinceEpoch % _playlist.length);
        } while (nextIndex == _currentIndex);
        return nextIndex;
    }
  }

  /// 获取上一首索引
  int _getPreviousIndex() {
    if (_currentIndex == -1) return _playlist.length - 1;

    switch (_playbackMode) {
      case PlaybackMode.sequential:
        return _currentIndex - 1 >= 0 ? _currentIndex - 1 : -1;

      case PlaybackMode.loopAll:
        return _currentIndex - 1 >= 0
            ? _currentIndex - 1
            : _playlist.length - 1;

      case PlaybackMode.loopOne:
        return _currentIndex;

      case PlaybackMode.shuffle:
        if (_playlist.length <= 1) return _currentIndex;
        int prevIndex;
        do {
          prevIndex =
              (DateTime.now().millisecondsSinceEpoch % _playlist.length);
        } while (prevIndex == _currentIndex);
        return prevIndex;
    }
  }

  /// 播放器状态变化回调
  void _onPlayerStateChanged(PlayerState state) {
    // 使用Future.microtask确保在主线程中处理状态变化
    Future.microtask(() {
      switch (state) {
        case PlayerState.playing:
          _setState(AudioPlaybackState.playing);
          break;
        case PlayerState.paused:
          _setState(AudioPlaybackState.paused);
          break;
        case PlayerState.stopped:
          _setState(AudioPlaybackState.stopped);
          break;
        case PlayerState.completed:
          _setState(AudioPlaybackState.completed);
          _onPlaybackCompleted();
          break;
        case PlayerState.disposed:
          _setState(AudioPlaybackState.stopped);
          break;
      }
    });
  }

  /// 播放位置变化回调
  void _onPositionChanged(Duration position) {
    // 使用Future.microtask确保在主线程中处理位置变化
    Future.microtask(() {
      _currentPosition = position;
      notifyListeners();
    });
  }

  /// 播放时长变化回调
  void _onDurationChanged(Duration? duration) {
    // 使用Future.microtask确保在主线程中处理时长变化
    Future.microtask(() {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });
  }

  /// 播放完成处理
  void _onPlaybackCompleted() {
    print('🎵 AudioPlayerService: 播放完成');
    // 如果是临时队列，播放完后清空并恢复主队列
    if (_tempQueueItem != null) {
      clearTempQueue();
      // 恢复主队列
      if (_savedIndex != null &&
          _savedIndex! >= 0 &&
          _savedIndex! < _playlist.length) {
        _currentIndex = _savedIndex!;
        _currentSource = _savedSource;
        notifyListeners();
        playFromPlaylist(_currentIndex);
        if (_savedPosition != null && _savedPosition! > Duration.zero) {
          seek(_savedPosition!);
        }
      }
      _savedIndex = null;
      _savedPosition = null;
      _savedSource = null;
      return;
    }

    // 根据播放模式决定下一步操作
    if (_playbackMode != PlaybackMode.loopOne) {
      final nextIndex = _getNextIndex();
      if (nextIndex != -1 && nextIndex != _currentIndex) {
        // 自动播放下一首
        Future.delayed(const Duration(milliseconds: 500), () {
          playFromPlaylist(nextIndex);
        });
      }
    }
  }

  /// 设置播放状态
  void _setState(AudioPlaybackState state) {
    if (_state != state) {
      _state = state;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String message) {
    _errorMessage = message;
    _setState(AudioPlaybackState.error);
    print('🎵 AudioPlayerService: 错误 - $message');
  }

  /// 清除错误信息
  void _clearError() {
    _errorMessage = null;
  }

  /// 强制刷新UI状态
  void forceRefreshUI() {
    print('🎵 AudioPlayerService: 强制刷新UI状态');
    notifyListeners();
  }

  /// 获取当前真实的播放器状态（用于调试）
  PlayerState? get currentPlayerState => _player.state;

  /// 确保流监听已注册（多次调用安全）
  void ensureListeners() {
    _playerStateSubscription ??= _player.onPlayerStateChanged.listen(
      _onPlayerStateChanged,
    );
    _positionSubscription ??= _player.onPositionChanged.listen(
      _onPositionChanged,
    );
    _durationSubscription ??= _player.onDurationChanged.listen(
      _onDurationChanged,
    );
  }

  /// 注销流监听（不销毁底层播放器）
  Future<void> removeListeners() async {
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _durationSubscription?.cancel();
    _durationSubscription = null;
  }

  /// 注册临时队列暂停监听
  void registerTempQueuePauseListener(String ownerId, VoidCallback onPause) {
    _tempQueuePauseListeners[ownerId] = onPause;
  }

  /// 注销监听
  void unregisterTempQueuePauseListener(String ownerId) {
    _tempQueuePauseListeners.remove(ownerId);
  }

  /// 更新临时队列
  /// [item] 临时播放项
  /// [startPosition] 可选，起始播放进度
  /// [id] 可选，临时队列id，默认时间戳
  /// [ownerId] 必须，归属组件id
  Future<void> updateTempQueue(
    PlaylistItem item, {
    Duration? startPosition,
    String? id,
    required String ownerId,
  }) async {
    // 如果已有临时队列且ownerId不同，通知旧owner暂停
    if (_tempQueueOwnerId != null && _tempQueueOwnerId != ownerId) {
      final oldListener = _tempQueuePauseListeners[_tempQueueOwnerId!];
      if (oldListener != null) {
        oldListener();
      }
    }
    _tempQueueItem = item;
    _tempQueueId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _tempQueueStartPosition = startPosition;
    _tempQueueOwnerId = ownerId;
    // 保存主队列状态
    _savedIndex = _currentIndex;
    _savedPosition = _currentPosition;
    _savedSource = _currentSource;
    notifyListeners();
    await _playTempQueue();
  }

  /// 清空临时队列
  void clearTempQueue() {
    _tempQueueItem = null;
    _tempQueueId = null;
    _tempQueueStartPosition = null;
    _tempQueueOwnerId = null;
    notifyListeners();
  }

  /// 查询临时队列
  Map<String, dynamic>? getTempQueue() {
    if (_tempQueueItem == null) return null;
    return {
      'item': _tempQueueItem,
      'id': _tempQueueId,
      'startPosition': _tempQueueStartPosition,
      'ownerId': _tempQueueOwnerId,
    };
  }

  /// 内部方法：播放临时队列
  Future<void> _playTempQueue() async {
    if (_tempQueueItem == null) return;
    // 播放临时队列项
    await play(source: _tempQueueItem!.source);
    // 跳转到指定进度
    if (_tempQueueStartPosition != null) {
      await seek(_tempQueueStartPosition!);
    }
  }
}
