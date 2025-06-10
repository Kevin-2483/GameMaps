import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/span_node.dart';
import 'package:markdown_widget/widget/widget_visitor.dart';
import 'package:video_player/video_player.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';

/// 视频处理器 - 用于在Markdown中渲染视频内容
/// 支持HTML video标签和自定义Markdown视频语法
class VideoProcessor {
  /// 视频标签名
  static const String videoTag = 'video';
  
  /// VFS视频支持的格式
  static const List<String> supportedFormats = [
    'mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv', 'm4v'
  ];

  /// 检查文本是否包含视频标签
  static bool containsVideo(String text) {
    return text.contains(RegExp(r'<video[^>]*>|!\[.*\]\(.*\.(mp4|webm|ogg|mov|avi|mkv|m4v)\)', 
        caseSensitive: false));
  }

  /// 创建视频节点生成器
  static SpanNodeGeneratorWithTag createGenerator() {
    return SpanNodeGeneratorWithTag(
      tag: videoTag,
      generator: (e, config, visitor) => VideoNode(e.attributes, e.textContent),
    );
  }

  /// 获取视频统计信息
  static Map<String, dynamic> getVideoStats(String content) {
    final stats = <String, dynamic>{
      'hasVideo': false,
      'videoCount': 0,
      'videos': <String>[],
    };

    if (!containsVideo(content)) {
      return stats;
    }

    stats['hasVideo'] = true;

    // 统计HTML video标签
    final videoTagPattern = RegExp(r'''<video[^>]*src=["\']([^"\']*)["\'][^>]*>''', 
        caseSensitive: false);
    final videoMatches = videoTagPattern.allMatches(content);
    
    // 统计Markdown视频语法 ![](video.mp4)
    final markdownVideoPattern = RegExp(r'!\[.*\]\(([^)]*\.(mp4|webm|ogg|mov|avi|mkv|m4v))\)', 
        caseSensitive: false);
    final markdownMatches = markdownVideoPattern.allMatches(content);

    final videos = <String>[];
    
    for (final match in videoMatches) {
      final src = match.group(1);
      if (src != null && src.isNotEmpty) {
        videos.add(src);
      }
    }
    
    for (final match in markdownMatches) {
      final src = match.group(1);
      if (src != null && src.isNotEmpty) {
        videos.add(src);
      }
    }

    stats['videoCount'] = videos.length;
    stats['videos'] = videos;

    return stats;
  }

  /// 转换Markdown图片语法为视频（如果是视频文件）
  static String convertMarkdownVideos(String content) {
    // 将Markdown图片语法中的视频文件转换为video标签
    final pattern = RegExp(r'!\[(.*?)\]\(([^)]*\.(mp4|webm|ogg|mov|avi|mkv|m4v))\)', 
        caseSensitive: false);
    
    return content.replaceAllMapped(pattern, (match) {
      final alt = match.group(1) ?? '';
      final src = match.group(2) ?? '';      // 构建video标签
      final controls = 'controls';
      final width = alt.contains('width:') 
          ? alt.replaceAll(RegExp(r'.*width:(\d+).*'), r'width="$1"')
          : '';
      final height = alt.contains('height:') 
          ? alt.replaceAll(RegExp(r'.*height:(\d+).*'), r'height="$1"')
          : '';
      
      return '<video src="$src" $controls $width $height></video>';
    });
  }
}

/// 视频节点配置
/// 实现WidgetConfig接口，用于Markdown配置
class VideoNodeConfig implements WidgetConfig {
  @override
  String get tag => VideoProcessor.videoTag;
  
  final bool isDarkTheme;
  final void Function(String)? onVideoTap;
  final Widget Function(String, String, dynamic)? errorBuilder;
  
  const VideoNodeConfig({
    this.isDarkTheme = false,
    this.onVideoTap,
    this.errorBuilder,
  });
  
  static const VideoNodeConfig light = VideoNodeConfig(isDarkTheme: false);
  static const VideoNodeConfig dark = VideoNodeConfig(isDarkTheme: true);
}

/// 视频节点 - 渲染视频播放器
class VideoNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;

  VideoNode(this.attributes, this.textContent);

  @override
  InlineSpan build() {
    double? width;
    double? height;
    
    if (attributes['width'] != null) {
      try {
        width = double.parse(attributes['width']!);
      } catch (e) {
        // 忽略解析错误
      }
    }
    
    if (attributes['height'] != null) {
      try {
        height = double.parse(attributes['height']!);
      } catch (e) {
        // 忽略解析错误
      }
    }
    
    final src = attributes['src'] ?? '';
    final autoplay = attributes.containsKey('autoplay');
    final loop = attributes.containsKey('loop');
    final muted = attributes.containsKey('muted');
    
    final config = VideoConfig(
      autoPlay: autoplay,
      looping: loop,
      autoInitialize: true,
      aspectRatio: width != null && height != null ? width / height : null,
    );
    
    return WidgetSpan(
      child: Container(
        width: width,
        height: height,
        constraints: BoxConstraints(
          maxWidth: width ?? 800,
          maxHeight: height ?? 450,
        ),
        child: VideoWidget(
          url: src,
          config: config,
          muted: muted,
        ),
      ),
    );
  }
}

/// 视频配置类
class VideoConfig {
  final double? aspectRatio;
  final bool autoPlay;
  final bool autoInitialize;
  final bool looping;

  const VideoConfig({
    this.aspectRatio,
    this.autoPlay = false,
    this.autoInitialize = true,
    this.looping = false,
  });
}

/// 视频播放器组件
class VideoWidget extends StatefulWidget {
  final String url;
  final VideoConfig? config;
  final bool muted;

  const VideoWidget({
    Key? key, 
    required this.url, 
    this.config,
    this.muted = false,
  }) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _videoPlayerController;
  bool _isButtonHiding = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// 初始化视频播放器
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
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    await _initializeController();
  }

  /// 初始化VFS视频
  Future<void> _initializeVfsVideo() async {
    try {
      final vfsService = VfsServiceProvider();
      final fileContent = await vfsService.vfs.readFile(widget.url);
      
      if (fileContent == null) {
        throw Exception('VFS视频文件不存在');
      }

      // 对于VFS视频，我们需要创建临时文件或使用内存数据
      // 这里先使用网络URL的方式，实际应用中可能需要其他处理方式
      throw UnimplementedError('VFS视频播放暂未实现，请使用网络视频URL');
    } catch (e) {
      setState(() {
        _errorMessage = 'VFS视频加载失败: $e';
      });
    }
  }

  /// 初始化控制器
  Future<void> _initializeController() async {
    final config = widget.config;
    
    if (config?.autoInitialize ?? true) {
      await _videoPlayerController.initialize();
      setState(() {
        _isInitialized = true;
      });
    }
    
    if (widget.muted) {
      _videoPlayerController.setVolume(0.0);
    }
    
    if (config?.autoPlay ?? false) {
      _videoPlayerController.play();
    }
    
    _videoPlayerController.addListener(_onVideoStateChanged);
  }

  /// 视频状态变化监听
  void _onVideoStateChanged() {
    if (_videoPlayerController.value.position == _videoPlayerController.value.duration) {
      if (widget.config?.looping ?? false) {
        _videoPlayerController.play();
      }
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

    final aspectRatio = widget.config?.aspectRatio ?? 
        _videoPlayerController.value.aspectRatio;
    final isPlaying = _videoPlayerController.value.isPlaying;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        children: [
          GestureDetector(
            child: VideoPlayer(_videoPlayerController),
            onTap: () {
              if (_isButtonHiding) {
                setState(() {
                  _isButtonHiding = false;
                });
                _hideButton();
              }
            },
          ),
          _buildPlayButton(isPlaying),
          _buildVideoInfo(),
        ],
      ),
    );
  }

  /// 构建播放按钮
  Widget _buildPlayButton(bool isPlaying) {
    if (_isButtonHiding && isPlaying) return Container();
    
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
        ),
        child: IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            if (isPlaying) {
              _videoPlayerController.pause();
            } else {
              _videoPlayerController.play();
            }
            setState(() {});
            _hideButton();
          },
        ),
      ),
    );
  }

  /// 构建视频信息
  Widget _buildVideoInfo() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _getVideoInfo(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// 获取视频信息文本
  String _getVideoInfo() {
    final duration = _videoPlayerController.value.duration;
    final position = _videoPlayerController.value.position;
    
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    
    return "${formatDuration(position)} / ${formatDuration(duration)}";
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
          ],
        ),
      ),
    );
  }

  /// 隐藏播放按钮
  void _hideButton() {
    if (!_isButtonHiding) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isButtonHiding) {
          setState(() {
            _isButtonHiding = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_onVideoStateChanged);
    _videoPlayerController.dispose();
    super.dispose();
  }
}

/// 视频配置扩展
/// 为MarkdownConfig添加视频处理支持
extension VideoConfigExtension on MarkdownConfig {
  /// 创建支持视频的Markdown配置
  static MarkdownConfig createWithVideoSupport({
    bool isDarkTheme = false,
    MarkdownConfig? baseConfig,
    void Function(String)? onLinkTap,
    Widget Function(String, Map<String, String>)? imageBuilder,
    Widget Function(String, String, dynamic)? imageErrorBuilder,
  }) {    // 基础配置 - 如果提供了 baseConfig，使用它；否则使用默认配置
    final base = baseConfig ?? 
        (isDarkTheme ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig);

    // 创建视频配置
    final videoConfig = VideoNodeConfig(
      isDarkTheme: isDarkTheme,
      onVideoTap: onLinkTap,
      errorBuilder: imageErrorBuilder,
    );
    
    // 基于现有配置创建新配置，添加视频支持
    return base.copy(configs: [videoConfig]);
  }
}
