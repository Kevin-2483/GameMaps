import 'package:flutter/material.dart';
import '../../../services/audio/audio_player_service.dart';

/// 音频播放器组件
class AudioPlayerWidget extends StatefulWidget {
  /// 音频源（VFS路径或网络URL）
  final String source;

  /// 标题
  final String title;

  /// 艺术家
  final String? artist;

  /// 专辑
  final String? album;

  /// 是否为VFS路径
  final bool isVfsPath;

  /// 播放配置
  final AudioPlayerConfig config;

  /// 是否连接到现有播放器实例（而不是创建新实例）
  final bool connectToExisting;

  /// 错误回调
  final Function(String)? onError;

  /// 是否插播到队列最前并立即播放
  final bool forcePlayFirst;

  const AudioPlayerWidget({
    super.key,
    required this.source,
    required this.title,
    this.artist,
    this.album,
    this.isVfsPath = true,
    this.config = AudioPlayerConfig.defaultConfig,
    this.connectToExisting = false,
    this.onError,
    this.forcePlayFirst = false,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  late final AudioPlayerService _audioService;
  late final AnimationController _progressAnimationController;
  late final AnimationController _volumeAnimationController;
  bool _showVolumeSlider = false;
  bool _showEqualizerPanel = false;
  bool _isMinimized = false;
  bool _showPlaylistPanel = false; // 播放列表面板显示状态

  @override
  void initState() {
    super.initState();
    // 音频服务始终使用单例
    _audioService = AudioPlayerService();
    _audioService.ensureListeners(); // 保证每次都注册监听
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _volumeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    if (widget.connectToExisting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _audioService.ensureListeners(); // 再次保证监听
        _checkCurrentPlayingState();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializePlayer();
      });
    }
  }

  @override
  void dispose() {
    if (!widget.connectToExisting) {
      _audioService.stop().catchError((e) {
        debugPrint('停止音频播放失败: $e');
      });
      _audioService.dispose().catchError((e) {
        debugPrint('清理音频服务失败: $e');
      });
    } else {
      _audioService.removeListeners(); // 只注销监听，不销毁底层播放器
      debugPrint('🎵 窗口关闭，音频继续在后台播放');
    }
    _progressAnimationController.dispose();
    _volumeAnimationController.dispose();
    super.dispose();
  }

  /// 初始化播放器
  Future<void> _initializePlayer() async {
    try {
      await _audioService.initialize();

      // 添加播放列表项
      final playlistItem = PlaylistItem(
        source: widget.source,
        title: widget.title,
        artist: widget.artist,
        album: widget.album,
        isVfsPath: widget.isVfsPath,
      );

      _audioService.clearPlaylist();
      _audioService.addToPlaylist(playlistItem);

      // 如果配置要求自动播放
      if (widget.config.autoPlay) {
        await _audioService.playFromPlaylist(0);
      }
    } catch (e) {
      widget.onError?.call('初始化播放器失败: $e');
    }
  }

  /// 检查当前播放状态（连接到现有播放器时使用）
  Future<void> _checkCurrentPlayingState() async {
    try {
      _audioService.forceRefreshUI();
      final currentSource = _audioService.currentSource;
      debugPrint('🎵 检查播放状态 - 当前源: $currentSource, 目标源: ${widget.source}');
      final playlistItem = PlaylistItem(
        source: widget.source,
        title: widget.title,
        artist: widget.artist,
        album: widget.album,
        isVfsPath: widget.isVfsPath,
      );
      int existingIndex = _getOurAudioIndex();
      // 插播逻辑：插入队列最前并立即播放
      if (widget.forcePlayFirst) {
        if (_audioService.currentSource == widget.source) {
          // 已经在播放同一个音频，直接刷新UI即可
          _audioService.forceRefreshUI();
          debugPrint('🎵 插播请求与当前播放源一致，跳过插播。');
          return;
        }
        _audioService.removeFromPlaylistBySource(widget.source);
        _audioService.insertToPlaylist(0, playlistItem);
        await _audioService.stop(); // 强制停止，确保底层播放器状态刷新
        await _audioService.playFromPlaylist(0);
      } else {
        if (existingIndex == -1) {
          _audioService.addToPlaylist(playlistItem);
          existingIndex = _audioService.playlist.length - 1;
        }
        if (!_isPlayingOurAudio() && widget.config.autoPlay) {
          await _audioService.playFromPlaylist(existingIndex);
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      _audioService.forceRefreshUI();
      debugPrint('🎵 连接到现有播放器完成:');
      debugPrint('  - 当前播放: ${_audioService.currentSource}');
      debugPrint('  - 播放状态: ${_audioService.state}');
      debugPrint(
        '  - 播放进度: ${_audioService.currentPosition}/${_audioService.totalDuration}',
      );
      debugPrint('  - 播放列表长度: ${_audioService.playlist.length}');
      debugPrint('  - 当前索引: ${_audioService.currentIndex}');
      debugPrint('  - 是否播放我们的音频: ${_isPlayingOurAudio()}');
      debugPrint('  - 是否在播放列表中: ${_isInPlaylist()}');
    } catch (e) {
      debugPrint('🎵 连接到播放器失败: $e');
      widget.onError?.call('连接到播放器失败: $e');
    }
  }

  /// 构建完整播放器界面
  Widget _buildFullPlayer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // 播放器头部
          _buildPlayerHeader(),

          // 专辑封面/可视化区域
          Expanded(flex: 3, child: _buildArtworkArea()),

          // 音频信息区域
          _buildAudioInfo(),

          // 进度条区域
          _buildProgressArea(),

          // 主控制按钮
          _buildMainControls(),

          // 功能按钮区域
          _buildFunctionButtons(),

          // 音量/均衡器面板
          if (_showVolumeSlider || _showEqualizerPanel) _buildControlPanels(),
        ],
      ),
    );
  }

  /// 构建最小化播放器界面
  Widget _buildMinimizedPlayer() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 专辑封面
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note, size: 32),
          ),

          const SizedBox(width: 12),
          // 音频信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _audioService.currentItem?.title ?? widget.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_audioService.currentItem?.artist != null ||
                    widget.artist != null)
                  Text(
                    _audioService.currentItem?.artist ?? widget.artist!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // 播放控制按钮
          _buildMiniControls(),

          // 展开按钮
          IconButton(
            onPressed: () => setState(() => _isMinimized = false),
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: '展开播放器',
          ),
        ],
      ),
    );
  }

  /// 构建播放器头部
  Widget _buildPlayerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('音频播放器', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          // 播放列表按钮
          IconButton(
            icon: const Icon(Icons.queue_music),
            tooltip: '播放列表',
            onPressed: () => setState(() => _showPlaylistPanel = true),
          ),
          // 播放模式切换
          _buildPlaybackModeButton(),
          // 最小化按钮
          IconButton(
            onPressed: () => setState(() => _isMinimized = true),
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: '最小化播放器',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _audioService,
          builder: (context, child) {
            if (_isMinimized) {
              return _buildMinimizedPlayer();
            }
            return _buildFullPlayer();
          },
        ),
        if (_showPlaylistPanel)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showPlaylistPanel = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: _buildPlaylistPanel(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建播放列表面板
  Widget _buildPlaylistPanel() {
    final playlist = _audioService.playlist;
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).dialogBackgroundColor,
      child: Container(
        width: 400,
        height: 480,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.queue_music),
                const SizedBox(width: 8),
                const Text(
                  '播放列表',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showPlaylistPanel = false),
                ),
              ],
            ),
            const Divider(),
            if (playlist.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('播放列表为空', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: playlist.length,
                  onReorder: (oldIndex, newIndex) async {
                    final currentSource = _audioService.currentItem?.source;
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final newList = List.of(playlist);
                      final item = newList.removeAt(oldIndex);
                      newList.insert(newIndex, item);
                      _audioService.updatePlaylist(newList);
                    });
                    // 拖拽后自动播放当前曲目的新索引
                    if (currentSource != null) {
                      final newIndexInList = _audioService.playlist.indexWhere(
                        (e) => e.source == currentSource,
                      );
                      if (newIndexInList != -1 &&
                          _audioService.currentIndex != newIndexInList) {
                        await _audioService.playFromPlaylist(newIndexInList);
                        setState(() {});
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    final item = playlist[index];
                    final isCurrent = _audioService.currentIndex == index;
                    return ListTile(
                      key: ValueKey(item.source),
                      leading: Icon(
                        isCurrent ? Icons.play_arrow : Icons.music_note,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: item.artist != null
                          ? Text(
                              item.artist!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: '移除',
                            onPressed: () {
                              setState(() {
                                _audioService.removeFromPlaylistBySource(
                                  item.source,
                                );
                              });
                            },
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                      selected: isCurrent,
                      onTap: () async {
                        await _audioService.playFromPlaylist(index);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建专辑封面区域
  Widget _buildArtworkArea() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _audioService.state == AudioPlaybackState.playing
            ? _buildVisualization()
            : const Icon(Icons.music_note, size: 80),
      ),
    );
  }

  /// 构建音频可视化效果
  Widget _buildVisualization() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: RadialGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: const Center(child: Icon(Icons.equalizer, size: 80)),
    );
  }

  /// 构建音频信息
  Widget _buildAudioInfo() {
    // 获取当前正在播放的音频信息，如果没有则使用widget的信息
    final currentItem = _audioService.currentItem;
    final displayTitle = currentItem?.title ?? widget.title;
    final displayArtist = currentItem?.artist ?? widget.artist;
    final displayAlbum = currentItem?.album ?? widget.album;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Text(
            displayTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (displayArtist != null) ...[
            const SizedBox(height: 4),
            Text(
              displayArtist,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (displayAlbum != null) ...[
            const SizedBox(height: 2),
            Text(
              displayAlbum,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 构建进度条区域
  Widget _buildProgressArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // 进度条
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _audioService.totalDuration.inSeconds > 0
                  ? (_audioService.currentPosition.inSeconds.toDouble() /
                            _audioService.totalDuration.inSeconds.toDouble())
                        .clamp(0.0, 1.0)
                  : 0.0,
              onChanged: _audioService.totalDuration.inSeconds > 0
                  ? (value) {
                      final position = Duration(
                        seconds: (value * _audioService.totalDuration.inSeconds)
                            .round(),
                      );
                      debugPrint(
                        '🎵 进度条拖拽到: ${_formatDuration(position)} / ${_formatDuration(_audioService.totalDuration)}',
                      );
                      // 异步调用seek，不阻塞UI
                      _audioService.seek(position).catchError((e) {
                        debugPrint('进度条拖拽跳转失败: $e');
                      });
                    }
                  : null, // 如果没有总时长，禁用拖拽
            ),
          ),

          // 时间显示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_audioService.currentPosition),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(_audioService.totalDuration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建主控制按钮
  Widget _buildMainControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 上一首
          IconButton(
            onPressed: _audioService.hasPlaylist
                ? _audioService.playPrevious
                : null,
            icon: const Icon(Icons.skip_previous),
            iconSize: 36,
            tooltip: '上一首',
          ),
          // 快退
          IconButton(
            onPressed: () {
              final newPosition =
                  _audioService.currentPosition - const Duration(seconds: 10);
              _audioService
                  .seek(newPosition.isNegative ? Duration.zero : newPosition)
                  .catchError((e) {
                    debugPrint('快退操作失败: $e');
                  });
            },
            icon: const Icon(Icons.replay_10),
            iconSize: 28,
            tooltip: '快退10秒',
          ),

          // 播放/暂停
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                _audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              iconSize: 48,
              tooltip: _audioService.isPlaying ? '暂停' : '播放',
            ),
          ),
          // 快进
          IconButton(
            onPressed: () {
              final newPosition =
                  _audioService.currentPosition + const Duration(seconds: 10);
              if (newPosition < _audioService.totalDuration) {
                _audioService.seek(newPosition).catchError((e) {
                  debugPrint('快进操作失败: $e');
                });
              }
            },
            icon: const Icon(Icons.forward_10),
            iconSize: 28,
            tooltip: '快进10秒',
          ),

          // 下一首
          IconButton(
            onPressed: _audioService.hasPlaylist
                ? _audioService.playNext
                : null,
            icon: const Icon(Icons.skip_next),
            iconSize: 36,
            tooltip: '下一首',
          ),
        ],
      ),
    );
  }

  /// 构建功能按钮区域
  Widget _buildFunctionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 音量控制
          IconButton(
            onPressed: () =>
                setState(() => _showVolumeSlider = !_showVolumeSlider),
            icon: Icon(_getVolumeIcon()),
            tooltip: '音量控制',
          ),

          // 播放速度
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed),
            tooltip: '播放速度',
            onSelected: (speed) => _audioService.setPlaybackRate(speed),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0.5, child: Text('0.5x')),
              const PopupMenuItem(value: 0.75, child: Text('0.75x')),
              const PopupMenuItem(value: 1.0, child: Text('1.0x')),
              const PopupMenuItem(value: 1.25, child: Text('1.25x')),
              const PopupMenuItem(value: 1.5, child: Text('1.5x')),
              const PopupMenuItem(value: 2.0, child: Text('2.0x')),
            ],
          ),

          // 音频平衡
          IconButton(
            onPressed: () =>
                setState(() => _showEqualizerPanel = !_showEqualizerPanel),
            icon: const Icon(Icons.tune),
            tooltip: '音频均衡器',
          ),

          // 静音切换
          IconButton(
            onPressed: _audioService.toggleMute,
            icon: Icon(
              _audioService.muted ? Icons.volume_off : Icons.volume_up,
            ),
            tooltip: _audioService.muted ? '取消静音' : '静音',
          ),

          // 更多选项
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_to_playlist',
                child: ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('添加到播放列表'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'sleep_timer',
                child: ListTile(
                  leading: Icon(Icons.timer),
                  title: Text('睡眠定时器'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'audio_info',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('音频信息'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanels() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          if (_showVolumeSlider) _buildVolumePanel(),
          if (_showEqualizerPanel) _buildEqualizerPanel(),
        ],
      ),
    );
  }

  /// 构建音量面板
  Widget _buildVolumePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('音量控制', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.volume_down),
            Expanded(
              child: Slider(
                value: _audioService.volume,
                onChanged: _audioService.setVolume,
                min: 0.0,
                max: 1.0,
              ),
            ),
            const Icon(Icons.volume_up),
            const SizedBox(width: 8),
            Text('${(_audioService.volume * 100).round()}%'),
          ],
        ),
      ],
    );
  }

  /// 构建均衡器面板
  Widget _buildEqualizerPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('音频平衡', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('L'),
            Expanded(
              child: Slider(
                value: _audioService.balance,
                onChanged: _audioService.setBalance,
                min: -1.0,
                max: 1.0,
              ),
            ),
            const Text('R'),
            const SizedBox(width: 8),
            Text(_formatBalance(_audioService.balance)),
          ],
        ),
      ],
    );
  }

  /// 构建播放模式按钮
  Widget _buildPlaybackModeButton() {
    return PopupMenuButton<PlaybackMode>(
      icon: Icon(_getPlaybackModeIcon()),
      tooltip: '播放模式',
      onSelected: _audioService.setPlaybackMode,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: PlaybackMode.sequential,
          child: ListTile(
            leading: Icon(Icons.playlist_play),
            title: Text('顺序播放'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: PlaybackMode.loopAll,
          child: ListTile(
            leading: Icon(Icons.repeat),
            title: Text('循环列表'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: PlaybackMode.loopOne,
          child: ListTile(
            leading: Icon(Icons.repeat_one),
            title: Text('单曲循环'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: PlaybackMode.shuffle,
          child: ListTile(
            leading: Icon(Icons.shuffle),
            title: Text('随机播放'),
            dense: true,
          ),
        ),
      ],
    );
  }

  /// 构建迷你控制按钮
  Widget _buildMiniControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _audioService.hasPlaylist
              ? _audioService.playPrevious
              : null,
          icon: const Icon(Icons.skip_previous),
          iconSize: 20,
        ),
        IconButton(
          onPressed: _togglePlayPause,
          icon: Icon(_audioService.isPlaying ? Icons.pause : Icons.play_arrow),
          iconSize: 24,
        ),
        IconButton(
          onPressed: _audioService.hasPlaylist ? _audioService.playNext : null,
          icon: const Icon(Icons.skip_next),
          iconSize: 20,
        ),
      ],
    );
  }

  /// 切换播放/暂停
  void _togglePlayPause() async {
    try {
      if (_audioService.isPlaying) {
        await _audioService.pause();
      } else {
        if (_audioService.currentSource == null) {
          // 如果没有当前音频源，从播放列表播放第一首
          if (_audioService.playlist.isNotEmpty) {
            await _audioService.playFromPlaylist(0);
          } else {
            // 如果播放列表也为空，添加当前音频并播放
            final playlistItem = PlaylistItem(
              source: widget.source,
              title: widget.title,
              artist: widget.artist,
              album: widget.album,
              isVfsPath: widget.isVfsPath,
            );
            _audioService.addToPlaylist(playlistItem);
            await _audioService.playFromPlaylist(0);
          }
        } else if (_isPlayingOurAudio()) {
          // 如果当前音频源就是我们的音频，直接恢复播放
          await _audioService.play();
        } else {
          // 如果当前音频源不是我们的音频，找到我们的音频并播放
          int targetIndex = _getOurAudioIndex();

          if (targetIndex >= 0) {
            await _audioService.playFromPlaylist(targetIndex);
          } else {
            // 如果找不到，添加并播放
            final playlistItem = PlaylistItem(
              source: widget.source,
              title: widget.title,
              artist: widget.artist,
              album: widget.album,
              isVfsPath: widget.isVfsPath,
            );
            _audioService.addToPlaylist(playlistItem);
            await _audioService.playFromPlaylist(
              _audioService.playlist.length - 1,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('播放/暂停操作失败: $e');
      widget.onError?.call('播放操作失败: $e');
    }
  }

  /// 获取音量图标
  IconData _getVolumeIcon() {
    if (_audioService.muted || _audioService.volume == 0) {
      return Icons.volume_off;
    } else if (_audioService.volume < 0.5) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  /// 获取播放模式图标
  IconData _getPlaybackModeIcon() {
    switch (_audioService.playbackMode) {
      case PlaybackMode.sequential:
        return Icons.playlist_play;
      case PlaybackMode.loopAll:
        return Icons.repeat;
      case PlaybackMode.loopOne:
        return Icons.repeat_one;
      case PlaybackMode.shuffle:
        return Icons.shuffle;
    }
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'add_to_playlist':
        // 添加到播放列表
        break;
      case 'sleep_timer':
        // 睡眠定时器
        _showSleepTimerDialog();
        break;
      case 'audio_info':
        // 显示音频信息
        _showAudioInfoDialog();
        break;
    }
  }

  /// 显示睡眠定时器对话框
  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('睡眠定时器'),
        content: const Text('定时器功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示音频信息对话框
  void _showAudioInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('音频信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('标题', widget.title),
            if (widget.artist != null) _buildInfoRow('艺术家', widget.artist!),
            if (widget.album != null) _buildInfoRow('专辑', widget.album!),
            _buildInfoRow('源', widget.isVfsPath ? 'VFS文件' : '网络URL'),
            _buildInfoRow('时长', _formatDuration(_audioService.totalDuration)),
            _buildInfoRow(
              '当前位置',
              _formatDuration(_audioService.currentPosition),
            ),
            _buildInfoRow('播放速度', '${_audioService.playbackRate}x'),
            _buildInfoRow('音量', '${(_audioService.volume * 100).round()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  /// 检查当前播放器是否正在播放我们的音频
  bool _isPlayingOurAudio() {
    return _audioService.currentSource == widget.source;
  }

  /// 检查我们的音频是否在播放列表中
  bool _isInPlaylist() {
    return _audioService.playlist.any((item) => item.source == widget.source);
  }

  /// 获取我们的音频在播放列表中的索引
  int _getOurAudioIndex() {
    for (int i = 0; i < _audioService.playlist.length; i++) {
      if (_audioService.playlist[i].source == widget.source) {
        return i;
      }
    }
    return -1;
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化平衡值
  String _formatBalance(double balance) {
    if (balance == 0) return 'C';
    if (balance < 0) return 'L${(-balance * 100).round()}';
    return 'R${(balance * 100).round()}';
  }
}
