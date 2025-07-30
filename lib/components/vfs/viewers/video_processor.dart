// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/all.dart';

import 'package:markdown_widget/widget/all.dart';
import 'package:markdown/markdown.dart' as m;
import 'media_kit_video_player.dart';
import '../../../services/localization_service.dart';

/// 视频处理器 - 用于在Markdown中渲染视频内容
/// 支持HTML video标签和自定义Markdown视频语法
class VideoProcessor {
  /// 视频标签名
  static const String videoTag = 'video';

  /// VFS视频支持的格式
  static const List<String> supportedFormats = [
    'mp4',
    'webm',
    'ogg',
    'mov',
    'avi',
    'mkv',
    'm4v',
  ];

  /// 检查文本是否包含视频标签
  static bool containsVideo(String text) {
    final result = text.contains(
      RegExp(
        r'<video[^>]*>|!\[.*\]\(.*\.(mp4|webm|ogg|mov|avi|mkv|m4v)\)',
        caseSensitive: false,
      ),
    );
    debugPrint(
      LocalizationService.instance.current.videoProcessorDebug(
        text.length,
        result,
      ),
    );
    return result;
  }

  /// 创建视频节点生成器
  static SpanNodeGeneratorWithTag createGenerator() {
    debugPrint(LocalizationService.instance.current.videoProcessorCreated_4821);
    return SpanNodeGeneratorWithTag(
      tag: videoTag,
      generator: (e, config, visitor) {
        debugPrint(
          LocalizationService.instance.current.videoNodeGenerationLog(
            e.tag,
            e.attributes,
            e.textContent,
          ),
        );
        return VideoNode(e.attributes, e.textContent);
      },
    );
  }

  /// 创建视频语法解析器
  static VideoSyntax createSyntax() {
    return VideoSyntax();
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
    final videoTagPattern = RegExp(
      r'''<video[^>]*src=["\']([^"\']*)["\'][^>]*>''',
      caseSensitive: false,
    );
    final videoMatches = videoTagPattern.allMatches(content);

    // 统计Markdown视频语法 ![](video.mp4)
    final markdownVideoPattern = RegExp(
      r'!\[.*\]\(([^)]*\.(mp4|webm|ogg|mov|avi|mkv|m4v))\)',
      caseSensitive: false,
    );
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
    debugPrint(
      LocalizationService.instance.current.videoProcessorStartConversion_7281,
    );
    // 将Markdown图片语法中的视频文件转换为video标签
    final pattern = RegExp(
      r'!\[(.*?)\]\(([^)]*\.(mp4|webm|ogg|mov|avi|mkv|m4v))\)',
      caseSensitive: false,
    );

    final result = content.replaceAllMapped(pattern, (match) {
      final alt = match.group(1) ?? '';
      final src = match.group(2) ?? '';
      debugPrint(
        '🎥 ${LocalizationService.instance.current.videoProcessorConvertMarkdownVideos_7425(src)}',
      );

      // 构建video标签
      final controls = 'controls';
      final width = alt.contains('width:')
          ? alt.replaceAll(RegExp(r'.*width:(\d+).*'), r'width="$1"')
          : '';
      final height = alt.contains('height:')
          ? alt.replaceAll(RegExp(r'.*height:(\d+).*'), r'height="$1"')
          : '';

      final videoTag = '<video src="$src" $controls $width $height></video>';
      debugPrint(
        '🎥 VideoProcessor.convertMarkdownVideos: ${LocalizationService.instance.current.generateTagMessage(videoTag)}',
      );
      return videoTag;
    });

    debugPrint(
      LocalizationService.instance.current.videoConversionComplete_7281,
    );
    return result;
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

  VideoNode(this.attributes, this.textContent) {
    debugPrint(
      LocalizationService.instance.current.videoNodeCreationLog(
        attributes,
        textContent,
      ),
    );
  }
  @override
  InlineSpan build() {
    debugPrint(
      '🎥 VideoNode.build: ${LocalizationService.instance.current.videoNodeBuildStart(attributes['src'] ?? '')}',
    );

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
    final config = MediaKitVideoConfig(
      autoPlay: autoplay,
      looping: loop,
      aspectRatio: width != null && height != null ? width / height : null,
      maxWidth: width ?? 800,
      maxHeight: height ?? 450,
    );

    debugPrint(LocalizationService.instance.current.videoNodeBuildLog(src));

    return WidgetSpan(
      child: MediaKitVideoPlayer(url: src, config: config, muted: muted),
    );
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
  }) {
    // 基础配置列表
    final configs = <WidgetConfig>[
      // 添加视频配置
      VideoNodeConfig(
        isDarkTheme: isDarkTheme,
        onVideoTap: onLinkTap,
        errorBuilder: imageErrorBuilder,
      ),

      // 视频文本处理配置
      PConfig(
        textStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 16,
          height: 1.6,
        ),
      ),

      // 视频链接处理 - 保留VFS协议支持
      LinkConfig(
        style: TextStyle(
          color: isDarkTheme ? Colors.lightBlueAccent : Colors.blue,
          decoration: TextDecoration.underline,
        ),
        onTap: onLinkTap,
      ),

      // 图片配置 - 支持VFS协议图片
      if (imageBuilder != null)
        ImgConfig(builder: imageBuilder, errorBuilder: imageErrorBuilder),
    ];

    // 基础配置 - 如果提供了 baseConfig，使用它；否则使用默认配置
    final base =
        baseConfig ??
        (isDarkTheme
            ? MarkdownConfig.darkConfig
            : MarkdownConfig.defaultConfig); // 基于现有配置创建新配置，添加视频支持
    return base.copy(configs: configs);
  }
}

/// 视频语法解析器
/// 继承自markdown包的InlineSyntax，用于识别HTML video标签
class VideoSyntax extends m.InlineSyntax {
  VideoSyntax() : super(r'<video[^>]*>.*?</video>');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final input = match.input;
    final matchValue = input.substring(match.start, match.end);

    debugPrint(
      '🎥 VideoSyntax.onMatch: ${LocalizationService.instance.current.videoTagMatched(matchValue)}',
    );

    // 解析video标签属性
    final attributes = <String, String>{};

    // 提取src属性
    final srcPattern = RegExp(
      r'''src=["\']([^"\']*)["\']''',
      caseSensitive: false,
    );
    final srcMatch = srcPattern.firstMatch(matchValue);
    if (srcMatch != null) {
      attributes['src'] = srcMatch.group(1)!;
    }

    // 提取width属性
    final widthPattern = RegExp(
      r'''width=["\']?(\d+)["\']?''',
      caseSensitive: false,
    );
    final widthMatch = widthPattern.firstMatch(matchValue);
    if (widthMatch != null) {
      attributes['width'] = widthMatch.group(1)!;
    }

    // 提取height属性
    final heightPattern = RegExp(
      r'''height=["\']?(\d+)["\']?''',
      caseSensitive: false,
    );
    final heightMatch = heightPattern.firstMatch(matchValue);
    if (heightMatch != null) {
      attributes['height'] = heightMatch.group(1)!;
    }

    // 检查布尔属性
    if (matchValue.contains('controls')) {
      attributes['controls'] = 'true';
    }
    if (matchValue.contains('autoplay')) {
      attributes['autoplay'] = 'true';
    }
    if (matchValue.contains('loop')) {
      attributes['loop'] = 'true';
    }
    if (matchValue.contains('muted')) {
      attributes['muted'] = 'true';
    }

    // 创建视频元素
    final element = m.Element.text(VideoProcessor.videoTag, matchValue);
    element.attributes.addAll(attributes);

    debugPrint(
      LocalizationService.instance.current.videoElementCreationLog(
        element.tag,
        element.attributes,
      ),
    );

    parser.addNode(element);
    return true;
  }
}
