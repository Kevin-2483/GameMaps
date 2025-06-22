import 'package:flutter/material.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/span_node.dart';
import 'package:markdown_widget/widget/widget_visitor.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:markdown/markdown.dart' as m;
import 'embedded_audio_player.dart';

/// 音频处理器 - 用于在Markdown中渲染音频内容
/// 支持HTML audio标签和自定义Markdown音频语法
class AudioProcessor {
  /// 音频标签名
  static const String audioTag = 'audio';

  /// VFS音频支持的格式
  static const List<String> supportedFormats = [
    'mp3',
    'wav',
    'ogg',
    'aac',
    'm4a',
    'flac',
    'wma',
    'opus',
  ];

  /// 检查文本是否包含音频标签
  static bool containsAudio(String text) {
    final result = text.contains(
      RegExp(
        r'<audio[^>]*>|!\[.*\]\(.*\.(mp3|wav|ogg|aac|m4a|flac|wma|opus)\)',
        caseSensitive: false,
      ),
    );
    print(
      '🎵 AudioProcessor.containsAudio: text长度=${text.length}, 包含音频=$result',
    );
    return result;
  }

  /// 创建音频节点生成器
  static SpanNodeGeneratorWithTag createGenerator() {
    print('🎵 AudioProcessor: 创建音频生成器');
    return SpanNodeGeneratorWithTag(
      tag: audioTag,
      generator: (e, config, visitor) {
        print(
          '🎵 AudioProcessor: 生成AudioNode - tag: ${e.tag}, attributes: ${e.attributes}, textContent: ${e.textContent}',
        );
        return AudioNode(e.attributes, e.textContent);
      },
    );
  }

  /// 创建音频语法解析器
  static AudioSyntax createSyntax() {
    return AudioSyntax();
  }

  /// 获取音频统计信息
  static Map<String, dynamic> getAudioStats(String content) {
    final stats = <String, dynamic>{
      'hasAudio': false,
      'audioCount': 0,
      'audios': <String>[],
    };

    if (!containsAudio(content)) {
      return stats;
    }

    stats['hasAudio'] = true;

    // 统计HTML audio标签
    final audioTagPattern = RegExp(
      r'''<audio[^>]*src=["\']([^"\']*)["\'][^>]*>''',
      caseSensitive: false,
    );
    final audioMatches = audioTagPattern.allMatches(content);

    // 统计Markdown音频语法 ![](audio.mp3)
    final markdownAudioPattern = RegExp(
      r'!\[.*\]\(([^)]*\.(mp3|wav|ogg|aac|m4a|flac|wma|opus))\)',
      caseSensitive: false,
    );
    final markdownMatches = markdownAudioPattern.allMatches(content);

    final audios = <String>[];

    for (final match in audioMatches) {
      final src = match.group(1);
      if (src != null && src.isNotEmpty) {
        audios.add(src);
      }
    }

    for (final match in markdownMatches) {
      final src = match.group(1);
      if (src != null && src.isNotEmpty) {
        audios.add(src);
      }
    }

    stats['audioCount'] = audios.length;
    stats['audios'] = audios;

    return stats;
  }

  /// 转换Markdown图片语法为音频（如果是音频文件）
  static String convertMarkdownAudios(String content) {
    print('🎵 AudioProcessor.convertMarkdownAudios: 开始转换');
    // 将Markdown图片语法中的音频文件转换为audio标签
    final pattern = RegExp(
      r'!\[(.*?)\]\(([^)]*\.(mp3|wav|ogg|aac|m4a|flac|wma|opus))\)',
      caseSensitive: false,
    );

    final result = content.replaceAllMapped(pattern, (match) {
      final alt = match.group(1) ?? '';
      final src = match.group(2) ?? '';
      print('🎵 AudioProcessor.convertMarkdownAudios: 转换 $src');

      // 从alt文本中解析参数
      final controls = 'controls';
      final autoplay = alt.contains('autoplay') ? 'autoplay' : '';
      final loop = alt.contains('loop') ? 'loop' : '';
      final title = alt.contains('title:')
          ? alt.replaceAll(RegExp(r'.*title:([^,]*).*'), r'$1').trim()
          : _extractFileName(src);
      final artist = alt.contains('artist:')
          ? alt.replaceAll(RegExp(r'.*artist:([^,]*).*'), r'$1').trim()
          : '';
      final album = alt.contains('album:')
          ? alt.replaceAll(RegExp(r'.*album:([^,]*).*'), r'$1').trim()
          : '';

      // 构建audio标签
      final audioTag = '<audio src="$src" $controls $autoplay $loop title="$title" artist="$artist" album="$album"></audio>';
      print('🎵 AudioProcessor.convertMarkdownAudios: 生成标签 $audioTag');
      return audioTag;
    });

    print('🎵 AudioProcessor.convertMarkdownAudios: 转换完成');
    return result;
  }

  /// 从文件路径提取文件名（不含扩展名）
  static String _extractFileName(String path) {
    final fileName = path.split('/').last.split('\\').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  }
}

/// 音频节点配置
/// 实现WidgetConfig接口，用于Markdown配置
class AudioNodeConfig implements WidgetConfig {
  @override
  String get tag => AudioProcessor.audioTag;

  final bool isDarkTheme;
  final void Function(String)? onAudioTap;
  final Widget Function(String, String, dynamic)? errorBuilder;

  const AudioNodeConfig({
    this.isDarkTheme = false,
    this.onAudioTap,
    this.errorBuilder,
  });

  static const AudioNodeConfig light = AudioNodeConfig(isDarkTheme: false);
  static const AudioNodeConfig dark = AudioNodeConfig(isDarkTheme: true);
}

/// 音频节点 - 渲染音频播放器
class AudioNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;

  AudioNode(this.attributes, this.textContent) {
    print(
      '🎵 AudioNode: 创建节点 - attributes: $attributes, textContent: $textContent',
    );
  }

  @override
  InlineSpan build() {
    print('🎵 AudioNode.build: 开始构建 - src: ${attributes['src']}');

    final src = attributes['src'] ?? '';
    final title = attributes['title'] ?? AudioProcessor._extractFileName(src);
    final artist = attributes['artist'];
    final album = attributes['album'];
    final autoplay = attributes.containsKey('autoplay');

    // 创建可折叠的音频播放器
    return WidgetSpan(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: EmbeddedAudioPlayer(
          source: src,
          title: title,
          artist: artist,
          album: album,
          isVfsPath: _isVfsPath(src),
          autoPlay: autoplay,
          onError: (error) {
            print('🎵 AudioNode: 播放器错误 - $error');
          },
        ),
      ),
    );
  }

  /// 判断是否为VFS路径
  bool _isVfsPath(String path) {
    return path.startsWith('vfs://') || !path.startsWith('http');
  }
}

/// 音频语法解析器
/// 扩展InlineSyntax以支持自定义音频语法
class AudioSyntax extends m.InlineSyntax {
  AudioSyntax() : super(r'<audio[^>]*>.*?</audio>', caseSensitive: false);

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final audioHtml = match.group(0)!;
    print('🎵 AudioSyntax.onMatch: 匹配到音频标签 - $audioHtml');    // 解析audio标签属性
    final srcMatch = RegExp(r'''src=["']([^"']*)["']''').firstMatch(audioHtml);
    final titleMatch = RegExp(r'''title=["']([^"']*)["']''').firstMatch(audioHtml);
    final artistMatch = RegExp(r'''artist=["']([^"']*)["']''').firstMatch(audioHtml);
    final albumMatch = RegExp(r'''album=["']([^"']*)["']''').firstMatch(audioHtml);

    final attributes = <String, String>{};
    if (srcMatch != null) attributes['src'] = srcMatch.group(1)!;
    if (titleMatch != null) attributes['title'] = titleMatch.group(1)!;
    if (artistMatch != null) attributes['artist'] = artistMatch.group(1)!;
    if (albumMatch != null) attributes['album'] = albumMatch.group(1)!;

    // 检查其他属性
    if (audioHtml.contains('autoplay')) attributes['autoplay'] = 'autoplay';
    if (audioHtml.contains('loop')) attributes['loop'] = 'loop';
    if (audioHtml.contains('controls')) attributes['controls'] = 'controls';

    print('🎵 AudioSyntax.onMatch: 解析属性 - $attributes');

    // 创建audio元素
    final element = m.Element.text(AudioProcessor.audioTag, '');
    element.attributes.addAll(attributes);

    parser.addNode(element);
    return true;
  }
}
