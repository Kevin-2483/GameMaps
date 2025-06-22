import 'package:flutter/material.dart';
import '../../../services/audio/audio_player_service.dart';

/// 嵌入式音频播放器配置
class EmbeddedAudioConfig {
  /// 是否自动播放
  final bool autoPlay;
  
  /// 是否显示完整信息
  final bool showFullInfo;
  
  /// 默认是否折叠
  final bool defaultCollapsed;
  
  /// 主题色
  final Color? accentColor;

  const EmbeddedAudioConfig({
    this.autoPlay = false,
    this.showFullInfo = true,
    this.defaultCollapsed = true,
    this.accentColor,
  });

  static const EmbeddedAudioConfig defaultConfig = EmbeddedAudioConfig();
}

/// 嵌入式音频播放器组件
/// 专为Markdown渲染器设计的轻量级音频播放器
class EmbeddedAudioPlayer extends StatefulWidget {
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
  
  /// 是否自动播放
  final bool autoPlay;
  
  /// 是否连接到现有播放器实例
  final bool connectToExisting;
  
  /// 配置
  final EmbeddedAudioConfig config;
  
  /// 错误回调
  final Function(String)? onError;
  const EmbeddedAudioPlayer({
    super.key,
    required this.source,
    required this.title,
    this.artist,
    this.album,
    this.isVfsPath = true,
    this.autoPlay = false,
    this.connectToExisting = true, // 嵌入式播放器默认连接到现有实例
    this.config = EmbeddedAudioConfig.defaultConfig,
    this.onError,
  });

  @override
  State<EmbeddedAudioPlayer> createState() => _EmbeddedAudioPlayerState();
}

class _EmbeddedAudioPlayerState extends State<EmbeddedAudioPlayer>
    with TickerProviderStateMixin {
  late final AudioPlayerService _audioService;
  late final AnimationController _expandController;
  bool _isExpanded = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioService = AudioPlayerService();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 根据配置设置初始展开状态
    _isExpanded = !widget.config.defaultCollapsed;
    if (_isExpanded) {
      _expandController.value = 1.0;
    }
    
    _initializePlayer();
  }
  @override
  void dispose() {
    _expandController.dispose();
    
    // 嵌入式播放器默认连接到现有实例，不清理服务
    if (!widget.connectToExisting) {
      // 只有在创建新播放会话时才清理
      print('🎵 清理嵌入式播放器的播放会话');
    } else {
      // 连接到现有播放器时，让音频继续在后台播放
      print('🎵 嵌入式播放器关闭，音频继续在后台播放');
    }
    
    super.dispose();
  }
  /// 初始化播放器
  Future<void> _initializePlayer() async {
    try {
      await _audioService.initialize();
      
      if (widget.connectToExisting) {
        // 连接到现有播放器实例，检查当前播放状态
        await _checkCurrentPlayingState();
      } else {
        // 创建新的播放会话
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
        if (widget.autoPlay) {
          await _audioService.playFromPlaylist(0);
        }
      }
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      widget.onError?.call('初始化音频播放器失败: $e');
    }
  }

  /// 检查当前播放状态（连接到现有播放器时使用）
  Future<void> _checkCurrentPlayingState() async {
    try {
      // 如果当前正在播放的音频不是我们要播放的，则添加到播放列表
      final currentSource = _audioService.currentSource;
      if (currentSource != widget.source) {
        final playlistItem = PlaylistItem(
          source: widget.source,
          title: widget.title,
          artist: widget.artist,
          album: widget.album,
          isVfsPath: widget.isVfsPath,
        );
        
        // 检查是否已经在播放列表中
        int existingIndex = -1;
        for (int i = 0; i < _audioService.playlist.length; i++) {
          if (_audioService.playlist[i].source == widget.source) {
            existingIndex = i;
            break;
          }
        }
        
        if (existingIndex == -1) {
          // 如果不在播放列表中，添加它
          _audioService.addToPlaylist(playlistItem);
          existingIndex = _audioService.playlist.length - 1;
        }
        
        // 如果配置要求自动播放，切换到这个音频
        if (widget.autoPlay) {
          await _audioService.playFromPlaylist(existingIndex);
        }
      }
      
      print('🎵 嵌入式播放器连接到现有播放器，当前播放: ${_audioService.currentSource}');
    } catch (e) {
      widget.onError?.call('连接到播放器失败: $e');
    }
  }

  /// 切换展开/折叠状态
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return AnimatedBuilder(
      animation: _audioService,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 折叠状态的播放器
              _buildCollapsedPlayer(),
              
              // 展开状态的详细控制
              AnimatedBuilder(
                animation: _expandController,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _expandController,
                    child: _isExpanded ? _buildExpandedControls() : const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建加载中的Widget
  Widget _buildLoadingWidget() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            '正在加载音频...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 构建折叠状态的播放器
  Widget _buildCollapsedPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // 音频图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.config.accentColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.music_note,
              color: widget.config.accentColor ?? Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 音频信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.artist != null && widget.config.showFullInfo) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.artist!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // 播放按钮
          _buildPlayButton(),
          
          const SizedBox(width: 8),
          
          // 展开/折叠按钮
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.keyboard_arrow_down, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建播放按钮
  Widget _buildPlayButton() {
    return InkWell(
      onTap: _togglePlayPause,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.config.accentColor ?? Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _audioService.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
      ),
    );
  }

  /// 构建展开状态的详细控制
  Widget _buildExpandedControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          // 分隔线
          Divider(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            height: 1,
          ),
          
          const SizedBox(height: 12),
          
          // 详细信息
          if (widget.config.showFullInfo) _buildDetailedInfo(),
          
          // 进度条
          _buildProgressSlider(),
          
          const SizedBox(height: 8),
          
          // 时间显示
          _buildTimeDisplay(),
          
          const SizedBox(height: 12),
          
          // 扩展控制按钮
          _buildExtendedControls(),
        ],
      ),
    );
  }

  /// 构建详细信息
  Widget _buildDetailedInfo() {
    return Column(
      children: [
        if (widget.album != null) ...[
          Text(
            widget.album!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// 构建进度条
  Widget _buildProgressSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        activeTrackColor: widget.config.accentColor ?? Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        thumbColor: widget.config.accentColor ?? Theme.of(context).colorScheme.primary,
      ),
      child: Slider(
        value: _audioService.totalDuration.inSeconds > 0
            ? _audioService.currentPosition.inSeconds.toDouble() /
                _audioService.totalDuration.inSeconds.toDouble()
            : 0.0,
        onChanged: (value) {
          final position = Duration(
            seconds: (value * _audioService.totalDuration.inSeconds).round(),
          );
          _audioService.seek(position).catchError((e) {
            print('进度条拖拽跳转失败: $e');
          });
        },
      ),
    );
  }

  /// 构建时间显示
  Widget _buildTimeDisplay() {
    return Row(
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
    );
  }

  /// 构建扩展控制按钮
  Widget _buildExtendedControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 快退10秒
        _buildControlButton(
          icon: Icons.replay_10,
          onTap: () {
            final newPosition = _audioService.currentPosition - const Duration(seconds: 10);
            _audioService.seek(newPosition.isNegative ? Duration.zero : newPosition).catchError((e) {
              print('快退操作失败: $e');
            });
          },
          tooltip: '快退10秒',
        ),
        
        // 播放速度
        PopupMenuButton<double>(
          icon: Icon(
            Icons.speed,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
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
        
        // 音量控制
        _buildVolumeControl(),
        
        // 快进10秒
        _buildControlButton(
          icon: Icons.forward_10,
          onTap: () {
            final newPosition = _audioService.currentPosition + const Duration(seconds: 10);
            if (newPosition < _audioService.totalDuration) {
              _audioService.seek(newPosition).catchError((e) {
                print('快进操作失败: $e');
              });
            }
          },
          tooltip: '快进10秒',
        ),
      ],
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  /// 构建音量控制
  Widget _buildVolumeControl() {
    return PopupMenuButton(
      icon: Icon(
        _getVolumeIcon(),
        size: 20,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      tooltip: '音量控制',
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 200,
            child: Column(
              children: [
                const Text('音量'),
                Row(
                  children: [
                    const Icon(Icons.volume_down, size: 16),
                    Expanded(
                      child: Slider(
                        value: _audioService.volume,
                        onChanged: _audioService.setVolume,
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                    const Icon(Icons.volume_up, size: 16),
                  ],
                ),
                Text('${(_audioService.volume * 100).round()}%'),
              ],
            ),
          ),
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
          await _audioService.playFromPlaylist(0);
        } else {
          await _audioService.play();
        }
      }
    } catch (e) {
      print('播放/暂停操作失败: $e');
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

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
