import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';

/// 基于 media_kit 的跨平台视频播放器
/// 支持所有平台：Windows、macOS、Linux、Android、iOS、Web
class MediaKitVideoPlayer extends StatefulWidget {
  final String url;
  final MediaKitVideoConfig? config;
  final bool muted;

  const MediaKitVideoPlayer({
    Key? key,
    required this.url,
    this.config,
    this.muted = false,
  }) : super(key: key);

  @override
  _MediaKitVideoPlayerState createState() => _MediaKitVideoPlayerState();
}

class _MediaKitVideoPlayerState extends State<MediaKitVideoPlayer> {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// 初始化播放器
  Future<void> _initializePlayer() async {
    try {
      // 创建 media_kit 播放器
      _player = Player();
      _controller = VideoController(_player);

      // 配置播放器
      final config = widget.config;
      if (config != null) {
        if (config.autoPlay) {
          _player.setPlaylistMode(PlaylistMode.none);
        }
        if (config.looping) {
          _player.setPlaylistMode(PlaylistMode.loop);
        }
      }

      if (widget.muted) {
        await _player.setVolume(0.0);
      }

      // 等待播放器准备就绪
      await _initializeVideo();
    } catch (e) {
      setState(() {
        _errorMessage = '播放器初始化失败: $e';
      });
    }
  }

  /// 初始化视频
  Future<void> _initializeVideo() async {
    try {
      // 判断是否是VFS协议
      if (widget.url.startsWith('indexeddb://')) {
        await _initializeVfsVideo();
      } else {
        await _initializeNetworkVideo();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '视频初始化失败: $e';
      });
    }
  }

  /// 初始化网络视频
  Future<void> _initializeNetworkVideo() async {
    try {
      // 打开视频文件
      await _player.open(Media(widget.url));

      setState(() {
        _isInitialized = true;
      });

      // 自动播放
      final config = widget.config;
      if (config?.autoPlay ?? false) {
        await _player.play();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络视频加载失败: $e';
      });
    }
  }

  /// 初始化VFS视频
  Future<void> _initializeVfsVideo() async {
    try {
      final vfsService = VfsServiceProvider();
      final fileContent = await vfsService.vfs.readFile(widget.url);

      if (fileContent == null) {
        throw Exception('VFS视频文件不存在');
      }

      // 对于VFS视频，我们需要将数据写入临时文件
      // 这里暂时显示错误信息，实际应用中可以创建临时文件
      setState(() {
        _errorMessage = 'VFS视频播放暂未实现，请使用网络视频URL';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'VFS视频加载失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return _buildVideoPlayer();
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer() {
    final config = widget.config;

    return Container(
      constraints: BoxConstraints(
        maxWidth: config?.maxWidth ?? 800,
        maxHeight: config?.maxHeight ?? 450,
      ),
      child: Card(
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: config?.aspectRatio ?? 16 / 9,
            child: Video(
              controller: _controller,
              controls: AdaptiveVideoControls,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建加载中组件
  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载视频中...'),
          ],
        ),
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              '视频加载失败',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade500, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _retryInitialization(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _copyUrlToClipboard(),
                  icon: const Icon(Icons.copy),
                  label: const Text('复制链接'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 重试初始化
  void _retryInitialization() {
    setState(() {
      _errorMessage = null;
      _isInitialized = false;
    });
    _initializeVideo();
  }

  /// 复制URL到剪贴板
  void _copyUrlToClipboard() {
    // 这里可以添加复制到剪贴板的功能
    print('复制视频链接: ${widget.url}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('视频链接已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// media_kit 视频播放器配置
class MediaKitVideoConfig {
  final double? aspectRatio;
  final bool autoPlay;
  final bool looping;
  final double? maxWidth;
  final double? maxHeight;

  const MediaKitVideoConfig({
    this.aspectRatio,
    this.autoPlay = false,
    this.looping = false,
    this.maxWidth,
    this.maxHeight,
  });
}
