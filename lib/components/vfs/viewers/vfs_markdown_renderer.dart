import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/virtual_file_system/vfs_protocol.dart';
import 'vfs_text_viewer_window.dart';
import 'html_processor.dart';
import 'latex_processor.dart';
import 'video_processor.dart';
import 'audio_processor.dart';
import 'media_kit_video_player.dart';

/// Markdown渲染器配置
class MarkdownRendererConfig {
  /// 是否显示工具栏
  final bool showToolbar;

  /// 是否显示状态栏
  final bool showStatusBar;

  /// 是否允许编辑模式
  final bool allowEdit;

  /// 自定义工具栏按钮
  final List<Widget>? customToolbarActions;

  /// 自定义状态栏内容
  final Widget? customStatusBar;

  /// 工具栏样式
  final BoxDecoration? toolbarDecoration;

  /// 状态栏样式
  final BoxDecoration? statusBarDecoration;

  const MarkdownRendererConfig({
    this.showToolbar = true,
    this.showStatusBar = true,
    this.allowEdit = true,
    this.customToolbarActions,
    this.customStatusBar,
    this.toolbarDecoration,
    this.statusBarDecoration,
  });

  /// 创建窗口模式配置
  static const MarkdownRendererConfig window = MarkdownRendererConfig(
    showToolbar: true,
    showStatusBar: true,
    allowEdit: true,
  );

  /// 创建页面模式配置
  static const MarkdownRendererConfig page = MarkdownRendererConfig(
    showToolbar: true,
    showStatusBar: false,
    allowEdit: false,
  );

  /// 创建嵌入模式配置
  static const MarkdownRendererConfig embedded = MarkdownRendererConfig(
    showToolbar: false,
    showStatusBar: false,
    allowEdit: false,
  );
}

/// VFS Markdown渲染器核心组件
class VfsMarkdownRenderer extends StatefulWidget {
  /// VFS文件路径
  final String vfsPath;

  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;

  /// 渲染器配置
  final MarkdownRendererConfig config;

  /// 关闭回调
  final VoidCallback? onClose;

  /// 错误回调
  final void Function(String error)? onError;

  /// 加载完成回调
  final void Function()? onLoaded;

  const VfsMarkdownRenderer({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    this.config = MarkdownRendererConfig.window,
    this.onClose,
    this.onError,
    this.onLoaded,
  });

  @override
  State<VfsMarkdownRenderer> createState() => _VfsMarkdownRendererState();
}

class _VfsMarkdownRendererState extends State<VfsMarkdownRenderer> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();
  final TocController _tocController = TocController();

  bool _isLoading = true;
  String? _errorMessage;
  String _markdownContent = '';
  VfsFileInfo? _fileInfo;
  // 显示配置
  bool? _isDarkTheme; // 使用null表示自动模式
  bool _showToc = false;
  double _contentScale = 1.0;
  bool _enableHtmlRendering = true;
  bool _enableLatexRendering = true;
  bool _enableVideoRendering = true;
  bool _enableAudioRendering = true;

  // 音频source到uuid的映射
  final Map<String, String> _audioUuidMap = {};

  @override
  void initState() {
    super.initState();
    _loadMarkdownFile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 如果是自动模式，根据Material主题更新
    if (_isDarkTheme == null) {
      setState(() {
        // 自动模式保持null，在使用时动态获取
      });
    }
  }

  /// 获取当前主题模式（自动模式时使用Material主题，手动模式时使用设定值）
  bool get _effectiveIsDarkTheme {
    return _isDarkTheme ?? Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    // 清理VFS临时文件
    VfsServiceProvider.cleanupTempFiles()
        .then((_) {
          debugPrint('🔗 VfsMarkdownRenderer: 已清理临时文件');
        })
        .catchError((e) {
          debugPrint('🔗 VfsMarkdownRenderer: 清理临时文件失败 - $e');
        });
    _audioUuidMap.clear();
    _tocController.dispose();
    super.dispose();
  }

  /// 加载Markdown文件
  Future<void> _loadMarkdownFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fileContent = await _vfsService.vfs.readFile(widget.vfsPath);
      if (fileContent != null) {
        String textContent;
        try {
          textContent = utf8.decode(fileContent.data);
        } catch (e) {
          textContent = latin1.decode(fileContent.data);
        } // 如果启用HTML渲染，预处理HTML内容
        if (_enableHtmlRendering && HtmlProcessor.containsHtml(textContent)) {
          debugPrint('🔧 _loadMarkdownFile: 预处理HTML内容');
          textContent = _preprocessHtmlContent(textContent);
        }

        // 如果启用LaTeX渲染，预处理LaTeX内容
        if (_enableLatexRendering &&
            LatexProcessor.containsLatex(textContent)) {
          debugPrint('🔧 _loadMarkdownFile: 预处理LaTeX内容');
          textContent = _preprocessLatexContent(textContent);
        } // 如果启用视频渲染，预处理视频内容
        if (_enableVideoRendering &&
            VideoProcessor.containsVideo(textContent)) {
          debugPrint('🎥 _loadMarkdownFile: 预处理视频内容');
          textContent = _preprocessVideoContent(textContent);
        }

        // 如果启用音频渲染，预处理音频内容
        if (_enableAudioRendering &&
            AudioProcessor.containsAudio(textContent)) {
          debugPrint('🎵 _loadMarkdownFile: 预处理音频内容');
          textContent = _preprocessAudioContent(textContent);
        }

        // 生成音频uuid映射
        _audioUuidMap.clear();
        final audioSources = AudioProcessor.extractAudioSources(textContent);
        for (final src in audioSources) {
          _audioUuidMap[src] = const Uuid().v4();
        }
        debugPrint('🎵 渲染器: _audioUuidMap=$_audioUuidMap');

        setState(() {
          _markdownContent = textContent;
          _fileInfo = widget.fileInfo;
          _isLoading = false;
        });

        // 通知加载完成
        widget.onLoaded?.call();
      } else {
        final error = '无法读取Markdown文件';
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
        widget.onError?.call(error);
      }
    } catch (e) {
      final error = '加载Markdown文件失败: $e';
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
      widget.onError?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        if (widget.config.showToolbar) _buildToolbar(),
        // 内容区域
        Expanded(child: _buildContent()),
        // 状态栏
        if (widget.config.showStatusBar)
          widget.config.customStatusBar ?? _buildStatusBar(),
      ],
    );
  }

  /// 构建工具栏
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          widget.config.toolbarDecoration ??
          BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
      child: Row(
        children: [
          // 基础控制按钮
          ..._buildBasicControls(),

          // 缩放控制
          const SizedBox(width: 16),
          ..._buildZoomControls(),

          const Spacer(),

          // 自定义按钮
          if (widget.config.customToolbarActions != null)
            ...widget.config.customToolbarActions!,

          // 标准动作按钮
          if (widget.config.allowEdit) ..._buildActionButtons(),
        ],
      ),
    );
  }

  /// 构建基础控制按钮
  List<Widget> _buildBasicControls() {
    return [
      // 目录切换
      IconButton(
        onPressed: _toggleToc,
        icon: Icon(_showToc ? Icons.menu_open : Icons.menu),
        tooltip: _showToc ? '隐藏目录' : '显示目录',
      ),

      const SizedBox(width: 16),

      // 主题切换
      IconButton(
        onPressed: _toggleTheme,
        icon: Icon(_effectiveIsDarkTheme ? Icons.light_mode : Icons.dark_mode),
        tooltip: _isDarkTheme == null
            ? (_effectiveIsDarkTheme ? '自动主题(当前深色)' : '自动主题(当前浅色)')
            : (_effectiveIsDarkTheme ? '浅色主题' : '深色主题'),
      ),

      const SizedBox(width: 16), // HTML渲染切换
      IconButton(
        onPressed: _toggleHtmlRendering,
        icon: Icon(_enableHtmlRendering ? Icons.code : Icons.code_off),
        tooltip: _enableHtmlRendering ? '禁用HTML渲染' : '启用HTML渲染',
        style: IconButton.styleFrom(
          foregroundColor: _enableHtmlRendering
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),

      const SizedBox(width: 16), // LaTeX渲染切换
      IconButton(
        onPressed: _toggleLatexRendering,
        icon: Icon(
          _enableLatexRendering ? Icons.functions : Icons.functions_outlined,
        ),
        tooltip: _enableLatexRendering ? '禁用LaTeX渲染' : '启用LaTeX渲染',
        style: IconButton.styleFrom(
          foregroundColor: _enableLatexRendering
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),

      const SizedBox(width: 16), // 视频渲染切换
      IconButton(
        onPressed: _toggleVideoRendering,
        icon: Icon(_enableVideoRendering ? Icons.videocam : Icons.videocam_off),
        tooltip: _enableVideoRendering ? '禁用视频渲染' : '启用视频渲染',
        style: IconButton.styleFrom(
          foregroundColor: _enableVideoRendering
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),

      const SizedBox(width: 16),

      // 音频渲染切换
      IconButton(
        onPressed: _toggleAudioRendering,
        icon: Icon(
          _enableAudioRendering ? Icons.audiotrack : Icons.audiotrack_outlined,
        ),
        tooltip: _enableAudioRendering ? '禁用音频渲染' : '启用音频渲染',
        style: IconButton.styleFrom(
          foregroundColor: _enableAudioRendering
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    ];
  }

  /// 构建缩放控制
  List<Widget> _buildZoomControls() {
    return [
      IconButton(
        onPressed: _canZoomOut() ? _zoomOut : null,
        icon: const Icon(Icons.zoom_out),
        tooltip: '缩小',
      ),
      Text(
        '${(_contentScale * 100).toInt()}%',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      IconButton(
        onPressed: _canZoomIn() ? _zoomIn : null,
        icon: const Icon(Icons.zoom_in),
        tooltip: '放大',
      ),

      const SizedBox(width: 16),

      // 重置缩放
      IconButton(
        onPressed: _resetZoom,
        icon: const Icon(Icons.crop_free),
        tooltip: '重置缩放',
      ),
    ];
  }

  /// 构建动作按钮
  List<Widget> _buildActionButtons() {
    return [
      // HTML信息按钮（如果包含HTML）
      if (_containsHtml())
        IconButton(
          onPressed: _showHtmlInfo,
          icon: const Icon(Icons.info_outline),
          tooltip: 'HTML信息',
        ), // LaTeX信息按钮（如果包含LaTeX）
      if (_containsLatex())
        IconButton(
          onPressed: _showLatexInfo,
          icon: const Icon(Icons.analytics_outlined),
          tooltip: 'LaTeX信息',
        ),

      // 视频信息按钮（如果包含视频）
      if (_containsVideo())
        IconButton(
          onPressed: _showVideoInfo,
          icon: const Icon(Icons.videocam_outlined),
          tooltip: '视频信息',
        ),

      // 音频信息按钮（如果包含音频）
      if (_containsAudio())
        IconButton(
          onPressed: _showAudioInfo,
          icon: const Icon(Icons.audiotrack),
          tooltip: '音频信息',
        ),

      // 使用文本编辑器打开
      IconButton(
        onPressed: _openWithTextEditor,
        icon: const Icon(Icons.edit),
        tooltip: '使用文本编辑器打开',
      ),

      // 复制按钮
      IconButton(
        onPressed: _copyContent,
        icon: const Icon(Icons.copy),
        tooltip: '复制Markdown内容',
      ),

      // 刷新按钮
      IconButton(
        onPressed: _loadMarkdownFile,
        icon: const Icon(Icons.refresh),
        tooltip: '刷新',
      ),
    ];
  }

  /// 构建内容区域
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载Markdown文件中...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMarkdownFile,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_markdownContent.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Markdown文件为空'),
          ],
        ),
      );
    }

    return Row(
      children: [
        // 目录面板
        if (_showToc) ...[
          SizedBox(width: 250, child: _buildTocPanel()),
          const VerticalDivider(),
        ],

        // 主内容区域
        Expanded(child: _buildMarkdownContent()),
      ],
    );
  }

  /// 构建目录面板
  Widget _buildTocPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '目录',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(child: TocWidget(controller: _tocController)),
        ],
      ),
    );
  }

  /// 构建Markdown内容
  Widget _buildMarkdownContent() {
    debugPrint('🔧 _buildMarkdownContent: 开始构建');
    debugPrint(
      '🔧 _buildMarkdownContent: _enableVideoRendering = $_enableVideoRendering',
    );
    debugPrint(
      '🔧 _buildMarkdownContent: _enableHtmlRendering = $_enableHtmlRendering',
    );
    debugPrint(
      '🔧 _buildMarkdownContent: _enableLatexRendering = $_enableLatexRendering',
    );

    final config = _buildMarkdownConfig();

    // 创建自定义的MarkdownGenerator来支持多种扩展渲染
    MarkdownGenerator? markdownGenerator;
    final generators = <SpanNodeGeneratorWithTag>[];
    final inlineSyntaxList = <m.InlineSyntax>[];

    // 添加LaTeX支持
    if (_enableLatexRendering) {
      inlineSyntaxList.add(LatexSyntax());
      generators.add(LatexProcessor.createGenerator());
    } // 添加视频支持
    if (_enableVideoRendering) {
      debugPrint('🎥 _buildMarkdownContent: 添加视频语法解析器和生成器');
      inlineSyntaxList.add(VideoProcessor.createSyntax());
      generators.add(VideoProcessor.createGenerator());
    }

    // 添加音频支持
    if (_enableAudioRendering) {
      debugPrint('🎵 _buildMarkdownContent: 添加音频语法解析器和生成器');
      inlineSyntaxList.add(AudioProcessor.createSyntax());
      generators.add(AudioProcessor.createGenerator(_audioUuidMap));
    }

    // 如果有任何自定义生成器或语法，创建MarkdownGenerator
    if (generators.isNotEmpty || inlineSyntaxList.isNotEmpty) {
      debugPrint(
        '🔧 _buildMarkdownContent: 创建MarkdownGenerator - generators: ${generators.length}, syntaxes: ${inlineSyntaxList.length}',
      );
      markdownGenerator = MarkdownGenerator(
        inlineSyntaxList: inlineSyntaxList,
        generators: generators,
      );
    }

    return Container(
      color: _effectiveIsDarkTheme
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFFAFAFA),
      padding: const EdgeInsets.all(24),
      child: Transform.scale(
        scale: _contentScale,
        alignment: Alignment.topLeft,
        child: MarkdownWidget(
          data: _markdownContent,
          config: config,
          tocController: _tocController,
          markdownGenerator: markdownGenerator,
        ),
      ),
    );
  }

  /// 构建Markdown配置
  MarkdownConfig _buildMarkdownConfig() {
    final isDark = _effectiveIsDarkTheme; // 如果启用HTML、LaTeX、视频和音频渲染，使用混合配置
    if (_enableHtmlRendering &&
        _enableLatexRendering &&
        _enableVideoRendering &&
        _enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用HTML、LaTeX和视频渲染，使用混合配置
    else if (_enableHtmlRendering &&
        _enableLatexRendering &&
        _enableVideoRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用HTML、LaTeX和音频渲染，使用混合配置
    else if (_enableHtmlRendering &&
        _enableLatexRendering &&
        _enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用HTML、视频和音频渲染，使用混合配置
    else if (_enableHtmlRendering &&
        _enableVideoRendering &&
        _enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用LaTeX、视频和音频渲染，使用混合配置
    else if (_enableLatexRendering &&
        _enableVideoRendering &&
        _enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用HTML和LaTeX渲染，使用混合配置
    else if (_enableHtmlRendering && _enableLatexRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用HTML和视频渲染，使用混合配置
    else if (_enableHtmlRendering && _enableVideoRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用HTML和音频渲染，使用混合配置
    else if (_enableHtmlRendering && _enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用LaTeX和视频渲染，使用混合配置
    else if (_enableLatexRendering && _enableVideoRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用LaTeX和音频渲染，使用混合配置
    else if (_enableLatexRendering && _enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果启用视频和音频渲染，使用混合配置
    else if (_enableVideoRendering && _enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }
    // 如果只启用HTML渲染，使用HTML扩展配置
    else if (_enableHtmlRendering) {
      return HtmlConfigExtension.createWithHtmlSupport(
        isDarkTheme: isDark,
        onLinkTap: _onLinkTap,
        imageBuilder: _buildImage,
        imageErrorBuilder: (url, alt, error) => _buildImageError(url, error),
      );
    }
    // 如果只启用LaTeX渲染，使用LaTeX扩展配置
    else if (_enableLatexRendering) {
      return LatexConfigExtension.createWithLatexSupport(
        isDarkTheme: isDark,
        onLinkTap: _onLinkTap,
        imageBuilder: (url, alt) => _buildImage(url, {'alt': alt}),
        imageErrorBuilder: (url, alt, error) => _buildImageError(url, error),
      );
    } // 如果只启用视频渲染，使用视频扩展配置
    else if (_enableVideoRendering) {
      return VideoConfigExtension.createWithVideoSupport(
        isDarkTheme: isDark,
        onLinkTap: _onLinkTap,
        imageBuilder: _buildImage,
        imageErrorBuilder: (url, alt, error) => _buildImageError(url, error),
      );
    }
    // 如果只启用音频渲染，使用混合配置
    else if (_enableAudioRendering) {
      return _createMixedRenderingConfig(isDark);
    }

    // 否则使用标准配置
    final baseConfig = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    return baseConfig.copy(
      configs: [
        // 段落文本配置 - 确保在黑暗模式下文本可见
        PConfig(
          textStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.6,
          ),
        ),

        // 标题配置
        H1Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H2Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H3Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H4Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H5Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H6Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),

        // 链接配置 - 支持VFS协议链接
        LinkConfig(
          style: TextStyle(
            color: isDark ? Colors.lightBlueAccent : Colors.blue,
            decoration: TextDecoration.underline,
          ),
          onTap: _onLinkTap,
        ),

        // 图片配置 - 支持VFS协议图片
        ImgConfig(
          builder: (url, attributes) => _buildImage(url, attributes),
          errorBuilder: (url, alt, error) =>
              _buildImageError(url, error.toString()),
        ),

        // 代码块配置
        PreConfig(
          theme: isDark
              ? const {
                  'root': TextStyle(
                    backgroundColor: Color(0xFF2D2D2D),
                    color: Color(0xFFE6E6E6),
                  ),
                }
              : const {
                  'root': TextStyle(
                    backgroundColor: Color(0xFFF8F8F8),
                    color: Color(0xFF333333),
                  ),
                },
        ),

        // 行内代码配置
        CodeConfig(
          style: TextStyle(
            color: isDark ? const Color(0xFFE6E6E6) : const Color(0xFF333333),
            backgroundColor: isDark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF8F8F8),
            fontFamily: 'Courier',
            fontSize: 14,
          ),
        ),

        // 引用块配置
        BlockquoteConfig(
          textColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          sideColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),

        // 列表配置 - 支持自定义标记颜色
        ListConfig(
          marginLeft: 32.0,
          marginBottom: 4.0,
          marker: (isOrdered, depth, index) {
            final color = isDark ? Colors.white : Colors.black87;
            if (isOrdered) {
              // 有序列表数字标记
              return Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 1),
                child: SelectionContainer.disabled(
                  child: Text(
                    '${index + 1}.',
                    style: TextStyle(color: color, fontSize: 16, height: 1.6),
                  ),
                ),
              );
            } else {
              // 无序列表点标记
              final parentStyleHeight = 16.0 * 1.6;
              return Padding(
                padding: EdgeInsets.only(top: (parentStyleHeight / 2) - 1.5),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: _getUnorderedListDecoration(depth, color),
                  ),
                ),
              );
            }
          },
        ),

        // 复选框配置 - 支持自定义颜色
        CheckBoxConfig(
          builder: (checked) => Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    final wordCount = _markdownContent.split(RegExp(r'\s+')).length;
    final charCount = _markdownContent.length;
    final lineCount = _markdownContent.split('\n').length;
    final htmlStats = _getHtmlStats();
    final latexStats = _getLatexStats();
    final videoStats = _getVideoStats();
    final audioStats = _getAudioStats();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          widget.config.statusBarDecoration ??
          BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
      child: Row(
        children: [
          Text('行数: $lineCount', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 16),
          Text('字数: $wordCount', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 16),
          Text('字符数: $charCount', style: Theme.of(context).textTheme.bodySmall),
          // 显示HTML信息
          if (htmlStats['hasHtml'] == true) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _enableHtmlRendering
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _enableHtmlRendering
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.orange.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _enableHtmlRendering ? Icons.code : Icons.code_off,
                    size: 12,
                    color: _enableHtmlRendering ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'HTML${_enableHtmlRendering ? '' : '(禁用)'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _enableHtmlRendering
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (htmlStats['linkCount'] != null &&
                htmlStats['linkCount'] > 0) ...[
              const SizedBox(width: 8),
              Text(
                '链接: ${htmlStats['linkCount']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (htmlStats['imageCount'] != null &&
                htmlStats['imageCount'] > 0) ...[
              const SizedBox(width: 8),
              Text(
                '图片: ${htmlStats['imageCount']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],

          // 显示LaTeX信息
          if (latexStats['hasLatex'] == true) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _enableLatexRendering
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _enableLatexRendering
                      ? Colors.blue.withValues(alpha: 0.5)
                      : Colors.orange.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _enableLatexRendering
                        ? Icons.functions
                        : Icons.functions_outlined,
                    size: 12,
                    color: _enableLatexRendering ? Colors.blue : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LaTeX${_enableLatexRendering ? '' : '(禁用)'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _enableLatexRendering
                          ? Colors.blue
                          : Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (latexStats['totalCount'] != null &&
                latexStats['totalCount'] > 0) ...[
              const SizedBox(width: 8),
              Text(
                '公式: ${latexStats['totalCount']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],

          // 显示视频信息
          if (videoStats['hasVideo'] == true) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _enableVideoRendering
                    ? Colors.purple.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _enableVideoRendering
                      ? Colors.purple.withValues(alpha: 0.5)
                      : Colors.orange.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _enableVideoRendering ? Icons.videocam : Icons.videocam_off,
                    size: 12,
                    color: _enableVideoRendering
                        ? Colors.purple
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '视频${_enableVideoRendering ? '' : '(禁用)'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _enableVideoRendering
                          ? Colors.purple
                          : Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (videoStats['videoCount'] != null &&
                videoStats['videoCount'] > 0) ...[
              const SizedBox(width: 8),
              Text(
                '视频: ${videoStats['videoCount']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],

          // 显示音频信息
          if (audioStats['hasAudio'] == true) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _enableAudioRendering
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _enableAudioRendering
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.orange.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _enableAudioRendering
                        ? Icons.audiotrack
                        : Icons.audiotrack_outlined,
                    size: 12,
                    color: _enableAudioRendering ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '音频${_enableAudioRendering ? '' : '(禁用)'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _enableAudioRendering
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (audioStats['audioCount'] != null &&
                audioStats['audioCount'] > 0) ...[
              const SizedBox(width: 8),
              Text(
                '音频: ${audioStats['audioCount']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],

          const Spacer(),
          if (_fileInfo != null) ...[
            Text(
              '文件大小: ${_formatFileSize(_fileInfo!.size)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
          ],
          Text(
            '缩放: ${(_contentScale * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ========== 业务逻辑方法 ==========

  /// 处理链接点击
  void _onLinkTap(String url) {
    if (url.startsWith('indexeddb://')) {
      // VFS协议链接，使用文件打开服务
      _openVfsLink(url);
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      // 外部链接
      _openExternalLink(url);
    } else if (url.startsWith('#')) {
      // 锚点链接，跳转到对应位置
      _handleAnchorLink(url);
    } else {
      // 相对路径链接，解析为VFS路径
      _openRelativeLink(url);
    }
  }

  /// 打开VFS链接
  Future<void> _openVfsLink(String vfsUrl) async {
    try {
      await VfsFileOpenerService.openFile(context, vfsUrl);
    } catch (e) {
      _showErrorSnackBar('打开VFS链接失败: $e');
    }
  }

  /// 打开外部链接
  Future<void> _openExternalLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar('无法打开链接: $url');
      }
    } catch (e) {
      _showErrorSnackBar('打开链接失败: $e');
    }
  }

  /// 处理锚点链接
  void _handleAnchorLink(String anchor) {
    try {
      // 移除 # 前缀并进行URL解码
      String anchorId = Uri.decodeComponent(anchor.substring(1));
      _scrollToText(anchorId);
    } catch (e) {
      _showErrorSnackBar('跳转到锚点失败: $e');
    }
  }

  /// 使用TOC控制器跳转到锚点
  void _scrollToText(String searchText) {
    try {
      if (_tocController.tocList.isNotEmpty) {
        // 查找匹配的TOC项
        for (final toc in _tocController.tocList) {
          final headingSpan = toc.node.childrenSpan;
          final headingText = headingSpan.toPlainText().replaceAll(
            RegExp(r'[#\s]+'),
            '',
          );

          // 尝试匹配标题文本
          if (headingText.toLowerCase().contains(searchText.toLowerCase())) {
            _tocController.jumpToIndex(toc.widgetIndex);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已跳转到: $headingText'),
                duration: const Duration(seconds: 1),
              ),
            );
            return;
          }
        }
      }

      // 如果TOC中没找到，显示未找到提示
      _showErrorSnackBar('未找到锚点: $searchText');
    } catch (e) {
      _showErrorSnackBar('锚点跳转失败: $e');
    }
  }

  /// 打开相对路径链接
  Future<void> _openRelativeLink(String relativePath) async {
    try {
      // 获取当前文件的目录路径
      final currentDir = _getCurrentDirectory();

      // 解析相对路径为绝对VFS路径
      final absolutePath = _resolveRelativePath(currentDir, relativePath);

      // 使用VFS文件打开服务打开文件
      await VfsFileOpenerService.openFile(context, absolutePath);
    } catch (e) {
      _showErrorSnackBar('打开相对路径链接失败: $e');
    }
  }

  /// 构建图片组件 - 支持VFS协议
  Widget _buildImage(String url, Map<String, String> attributes) {
    // 检查是否为视频文件
    if (_isVideoFile(url)) {
      // 如果是视频文件，使用视频播放器
      return _buildVideoPlayer(url, attributes);
    }

    if (url.startsWith('indexeddb://')) {
      return _buildVfsImage(url, attributes);
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      return _buildNetworkImage(url, attributes);
    } else {
      // 处理相对路径，解析为VFS绝对路径
      final currentDir = _getCurrentDirectory();
      final absolutePath = _resolveRelativePath(currentDir, url);

      // 再次检查解析后的路径是否为视频文件
      if (_isVideoFile(absolutePath)) {
        return _buildVideoPlayer(absolutePath, attributes);
      }

      return _buildVfsImage(absolutePath, attributes);
    }
  }

  /// 检查是否为视频文件
  bool _isVideoFile(String url) {
    final videoExtensions = ['mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv', 'm4v'];
    final extension = url.split('.').last.toLowerCase();
    return videoExtensions.contains(extension);
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer(String url, Map<String, String> attributes) {
    // 解析视频属性
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: MediaKitVideoPlayer(url: url, config: config, muted: muted),
    );
  }

  /// 构建VFS图片
  Widget _buildVfsImage(String vfsUrl, Map<String, String> attributes) {
    return FutureBuilder<Uint8List?>(
      future: _loadVfsImage(vfsUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildImageError(vfsUrl, snapshot.error?.toString() ?? '加载失败');
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError(vfsUrl, error.toString());
              },
            ),
          ),
        );
      },
    );
  }

  /// 构建网络图片
  Widget _buildNetworkImage(String url, Map<String, String> attributes) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError(url, error.toString());
          },
        ),
      ),
    );
  }

  /// 构建图片错误显示
  Widget _buildImageError(String url, String? error) {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.red.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(color: Colors.red.shade500, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// 加载VFS图片
  Future<Uint8List?> _loadVfsImage(String vfsUrl) async {
    try {
      final fileContent = await _vfsService.vfs.readFile(vfsUrl);
      return fileContent?.data;
    } catch (e) {
      debugPrint('加载VFS图片失败: $e');
      return null;
    }
  }

  // ========== 控制方法 ==========

  /// 切换目录显示
  void _toggleToc() {
    setState(() {
      _showToc = !_showToc;
    });
  }

  /// 切换主题
  void _toggleTheme() {
    setState(() {
      if (_isDarkTheme == null) {
        // 从自动模式切换到手动模式，设置为与当前自动主题相反的状态
        _isDarkTheme = !_effectiveIsDarkTheme;
      } else {
        // 在手动模式下切换，或者切换回自动模式
        _isDarkTheme = _isDarkTheme! ? false : null;
      }
    });
  }

  /// 切换HTML渲染
  void _toggleHtmlRendering() {
    setState(() {
      _enableHtmlRendering = !_enableHtmlRendering;
    });
    // 重新加载内容以应用HTML渲染设置
    _loadMarkdownFile();
  }

  /// 缩放控制
  bool _canZoomIn() => _contentScale < 3.0;
  bool _canZoomOut() => _contentScale > 0.5;

  void _zoomIn() {
    if (_canZoomIn()) {
      setState(() {
        _contentScale = (_contentScale * 1.2).clamp(0.5, 3.0);
      });
    }
  }

  void _zoomOut() {
    if (_canZoomOut()) {
      setState(() {
        _contentScale = (_contentScale / 1.2).clamp(0.5, 3.0);
      });
    }
  }

  void _resetZoom() {
    setState(() {
      _contentScale = 1.0;
    });
  }

  /// 复制内容
  void _copyContent() {
    Clipboard.setData(ClipboardData(text: _markdownContent));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 2)),
    );
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示HTML信息对话框
  void _showHtmlInfo() {
    final htmlStats = _getHtmlStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.code, size: 24),
            SizedBox(width: 8),
            Text('HTML内容信息'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HTML状态
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _enableHtmlRendering
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _enableHtmlRendering
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HTML渲染状态',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            _enableHtmlRendering ? '已启用' : '已禁用',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _enableHtmlRendering
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _toggleHtmlRendering();
                        },
                        child: Text(_enableHtmlRendering ? '禁用' : '启用'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // HTML内容统计
              if (htmlStats['hasHtml'] == true) ...[
                Text('HTML内容统计', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),

                if (htmlStats['linkCount'] != null &&
                    htmlStats['linkCount'] > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.link, size: 16),
                      const SizedBox(width: 8),
                      Text('HTML链接: ${htmlStats['linkCount']}个'),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                if (htmlStats['imageCount'] != null &&
                    htmlStats['imageCount'] > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.image, size: 16),
                      const SizedBox(width: 8),
                      Text('HTML图片: ${htmlStats['imageCount']}个'),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                const SizedBox(height: 16),

                // 支持的HTML标签
                Text(
                  '支持的HTML标签',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: HtmlProcessor.getSupportedTags()
                          .map(
                            (tag) => Chip(
                              label: Text(
                                '<$tag>',
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示LaTeX信息对话框
  void _showLatexInfo() {
    final latexStats = _getLatexStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.functions, size: 24),
            SizedBox(width: 8),
            Text('LaTeX公式信息'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LaTeX状态
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _enableLatexRendering
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _enableLatexRendering
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LaTeX渲染状态',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            _enableLatexRendering ? '已启用' : '已禁用',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _enableLatexRendering
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _toggleLatexRendering();
                        },
                        child: Text(_enableLatexRendering ? '禁用' : '启用'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16), // LaTeX统计信息
              if (latexStats['hasLatex'] == true) ...[
                Text(
                  'LaTeX公式统计',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (latexStats['inlineCount'] != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('行内公式'),
                            Text('${latexStats['inlineCount']}个'),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (latexStats['blockCount'] != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('块级公式'),
                            Text('${latexStats['blockCount']}个'),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (latexStats['totalCount'] != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('总计'),
                            Text(
                              '${latexStats['totalCount']}个',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  '此文档不包含LaTeX公式',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示音频信息对话框
  void _showAudioInfo() {
    final audioStats = _getAudioStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('音频信息'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('音频数量: ${audioStats['audioCount']}'),
              const SizedBox(height: 16),
              if (audioStats['hasAudio'] as bool) ...[
                const Text('音频列表:'),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: (audioStats['audios'] as List<String>)
                          .take(10)
                          .map(
                            (audio) => Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.music_note, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      audio.length > 50
                                          ? '${audio.substring(0, 50)}...'
                                          : audio,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if ((audioStats['audios'] as List).length > 10)
                  Text(
                    '... 还有${(audioStats['audios'] as List).length - 10}个音频',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ] else ...[
                Text(
                  '此文档不包含音频内容',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 使用文本编辑器打开当前Markdown文件
  Future<void> _openWithTextEditor() async {
    try {
      await VfsTextViewerWindow.show(
        context,
        vfsPath: widget.vfsPath,
        fileInfo: _fileInfo,
        config: VfsFileOpenConfig.forText,
      );
    } catch (e) {
      _showErrorSnackBar('打开文本编辑器失败: $e');
    }
  }

  /// 获取当前Markdown文件的目录路径
  String _getCurrentDirectory() {
    // 解析VFS路径
    final vfsPath = VfsProtocol.parsePath(widget.vfsPath);
    if (vfsPath == null || vfsPath.segments.isEmpty) {
      return '';
    }

    // 获取文件所在目录的路径（移除文件名）
    if (vfsPath.segments.length > 1) {
      final dirSegments = vfsPath.segments.sublist(
        0,
        vfsPath.segments.length - 1,
      );
      return dirSegments.join('/');
    }

    return '';
  }

  /// 解析相对路径为绝对路径
  String _resolveRelativePath(String currentDir, String relativePath) {
    // 如果是绝对路径，直接返回
    if (relativePath.startsWith('/') ||
        relativePath.startsWith('indexeddb://')) {
      return relativePath;
    }

    // 从当前VFS路径中提取数据库和集合信息
    final currentVfsPath = VfsProtocol.parsePath(widget.vfsPath);
    if (currentVfsPath == null) {
      return relativePath; // 如果解析失败，返回原路径
    }

    // 处理相对路径
    List<String> currentParts = currentDir.isEmpty ? [] : currentDir.split('/');
    List<String> relativeParts = relativePath.split('/');

    // 处理 ".." 和 "." 路径段
    for (String part in relativeParts) {
      if (part == '..') {
        if (currentParts.isNotEmpty) {
          currentParts.removeLast();
        }
      } else if (part != '.' && part.isNotEmpty) {
        currentParts.add(part);
      }
    }

    // 构建最终路径
    final finalRelativePath = currentParts.join('/');

    // 使用VfsProtocol构建完整的VFS路径
    return VfsProtocol.buildPath(
      currentVfsPath.database,
      currentVfsPath.collection,
      finalRelativePath,
    );
  }

  /// 获取无序列表标记装饰
  BoxDecoration _getUnorderedListDecoration(int depth, Color color) {
    switch (depth % 3) {
      case 0:
        // 第一层：实心圆点
        return BoxDecoration(shape: BoxShape.circle, color: color);
      case 1:
        // 第二层：空心圆点
        return BoxDecoration(
          border: Border.all(color: color, width: 1),
          shape: BoxShape.circle,
        );
      case 2:
      default:
        // 第三层及以上：实心方块
        return BoxDecoration(color: color);
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  // ========== HTML处理方法 ==========
  /// 预处理HTML内容
  /// 将HTML标签转换为Markdown兼容格式或保持原样以便后续处理
  String _preprocessHtmlContent(String content) {
    try {
      // 首先清理不安全的HTML内容
      final sanitizedContent = HtmlUtils.sanitizeHtml(content);

      if (_enableHtmlRendering) {
        // 如果启用HTML渲染，可以选择性转换一些HTML为Markdown
        // 同时保留复杂的HTML结构（如表格）给markdown_widget处理
        return HtmlProcessor.convertHtmlToMarkdown(sanitizedContent);
      } else {
        // 如果禁用HTML渲染，移除所有HTML标签
        return HtmlProcessor.stripHtmlTags(sanitizedContent);
      }
    } catch (e) {
      debugPrint('HTML预处理失败: $e');
      // 如果预处理失败，返回原内容
      return content;
    }
  }

  /// 检查内容是否包含HTML
  bool _containsHtml() {
    return HtmlProcessor.containsHtml(_markdownContent);
  }

  /// 获取HTML统计信息
  Map<String, dynamic> _getHtmlStats() {
    if (!_containsHtml()) {
      return {'hasHtml': false};
    }

    try {
      final links = HtmlUtils.extractLinks(_markdownContent);
      final images = HtmlUtils.extractImages(_markdownContent);

      return {
        'hasHtml': true,
        'linkCount': links.length,
        'imageCount': images.length,
        'links': links,
        'images': images,
      };
    } catch (e) {
      debugPrint('HTML统计失败: $e');
      return {'hasHtml': true, 'error': e.toString()};
    }
  }

  // ========== LaTeX处理方法 ==========

  /// 预处理LaTeX内容
  String _preprocessLatexContent(String content) {
    try {
      if (_enableLatexRendering) {
        // LaTeX渲染已启用，保持LaTeX语法
        return content;
      } else {
        // LaTeX渲染已禁用，移除LaTeX语法标记
        return _stripLatexSyntax(content);
      }
    } catch (e) {
      debugPrint('LaTeX预处理失败: $e');
      return content;
    }
  }

  /// 移除LaTeX语法标记
  String _stripLatexSyntax(String content) {
    // 移除块级LaTeX语法 $$...$$
    content = content.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', multiLine: true, dotAll: true),
      (match) => match.group(1) ?? '',
    );

    // 移除行内LaTeX语法 $...$
    content = content.replaceAllMapped(
      RegExp(r'\$([^$]+)\$'),
      (match) => match.group(1) ?? '',
    );

    return content;
  }

  /// 检查内容是否包含LaTeX
  bool _containsLatex() {
    return LatexProcessor.containsLatex(_markdownContent);
  }

  /// 获取LaTeX统计信息
  Map<String, dynamic> _getLatexStats() {
    return LatexUtils.getLatexStats(_markdownContent);
  }

  /// 切换LaTeX渲染
  void _toggleLatexRendering() {
    setState(() {
      _enableLatexRendering = !_enableLatexRendering;
    });
    // 重新加载内容以应用LaTeX渲染设置
    _loadMarkdownFile();
  }

  /// 切换视频渲染
  void _toggleVideoRendering() {
    setState(() {
      _enableVideoRendering = !_enableVideoRendering;
    });
    // 重新加载内容以应用视频渲染设置
    _loadMarkdownFile();
  }

  /// 切换音频渲染
  void _toggleAudioRendering() {
    setState(() {
      _enableAudioRendering = !_enableAudioRendering;
    });
    // 重新加载内容以应用音频渲染设置
    _loadMarkdownFile();
  }

  /// 预处理视频内容
  String _preprocessVideoContent(String content) {
    debugPrint('🎥 _preprocessVideoContent: 开始处理');
    if (!_enableVideoRendering) {
      debugPrint('🎥 _preprocessVideoContent: 视频渲染已禁用');
      return content;
    }

    final result = VideoProcessor.convertMarkdownVideos(content);
    debugPrint('🎥 _preprocessVideoContent: 转换完成');
    return result;
  }

  /// 预处理音频内容
  String _preprocessAudioContent(String content) {
    debugPrint('🎵 _preprocessAudioContent: 开始处理');
    if (!_enableAudioRendering) {
      debugPrint('🎵 _preprocessAudioContent: 音频渲染已禁用');
      return content;
    }

    final result = AudioProcessor.convertMarkdownAudios(content);
    debugPrint('🎵 _preprocessAudioContent: 转换完成');
    return result;
  }

  /// 检查内容是否包含视频
  bool _containsVideo() {
    return _enableVideoRendering &&
        VideoProcessor.containsVideo(_markdownContent);
  }

  /// 检查内容是否包含音频
  bool _containsAudio() {
    return _enableAudioRendering &&
        AudioProcessor.containsAudio(_markdownContent);
  }

  /// 获取视频统计信息
  Map<String, dynamic> _getVideoStats() {
    if (!_enableVideoRendering) {
      return {'hasVideo': false, 'videoCount': 0, 'videos': []};
    }
    return VideoProcessor.getVideoStats(_markdownContent);
  }

  /// 获取音频统计信息
  Map<String, dynamic> _getAudioStats() {
    if (!_enableAudioRendering) {
      return {'hasAudio': false, 'audioCount': 0, 'audios': []};
    }
    return AudioProcessor.getAudioStats(_markdownContent);
  }

  /// 显示视频信息对话框
  void _showVideoInfo() {
    final videoStats = _getVideoStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('视频信息'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('视频数量: ${videoStats['videoCount']}'),
              const SizedBox(height: 16),
              if (videoStats['hasVideo'] as bool) ...[
                const Text('视频列表:'),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: (videoStats['videos'] as List<String>)
                          .take(10)
                          .map(
                            (video) => Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.videocam, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      video.length > 50
                                          ? '${video.substring(0, 50)}...'
                                          : video,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if ((videoStats['videos'] as List).length > 10)
                  Text(
                    '... 还有${(videoStats['videos'] as List).length - 10}个视频',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ] else ...[
                Text(
                  '此文档不包含视频内容',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 创建混合渲染配置（支持HTML、LaTeX和视频）
  MarkdownConfig _createMixedRenderingConfig(bool isDark) {
    // 创建基础配置
    final baseConfig = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    // 合并HTML、LaTeX和视频的配置
    final configs = <WidgetConfig>[
      // 段落文本配置 - 确保在黑暗模式下文本可见
      PConfig(
        textStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          height: 1.6,
        ),
      ),

      // 标题配置
      H1Config(
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H2Config(
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H3Config(
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H4Config(
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H5Config(
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H6Config(
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),

      // 链接配置 - 支持VFS协议链接
      LinkConfig(
        style: TextStyle(
          color: isDark ? Colors.lightBlueAccent : Colors.blue,
          decoration: TextDecoration.underline,
        ),
        onTap: _onLinkTap,
      ),

      // 图片配置 - 支持VFS协议图片
      ImgConfig(
        builder: (url, attributes) => _buildImage(url, attributes),
        errorBuilder: (url, alt, error) =>
            _buildImageError(url, error.toString()),
      ),

      // 代码块配置
      PreConfig(
        theme: isDark
            ? const {
                'root': TextStyle(
                  backgroundColor: Color(0xFF2D2D2D),
                  color: Color(0xFFE6E6E6),
                ),
              }
            : const {
                'root': TextStyle(
                  backgroundColor: Color(0xFFF8F8F8),
                  color: Color(0xFF333333),
                ),
              },
      ),

      // 行内代码配置
      CodeConfig(
        style: TextStyle(
          color: isDark ? const Color(0xFFE6E6E6) : const Color(0xFF333333),
          backgroundColor: isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF8F8F8),
          fontFamily: 'Courier',
          fontSize: 14,
        ),
      ),

      // 引用块配置
      BlockquoteConfig(
        textColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        sideColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      ),

      // 列表配置 - 支持自定义标记颜色
      ListConfig(
        marginLeft: 32.0,
        marginBottom: 4.0,
        marker: (isOrdered, depth, index) {
          final color = isDark ? Colors.white : Colors.black87;
          if (isOrdered) {
            // 有序列表数字标记
            return Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 1),
              child: SelectionContainer.disabled(
                child: Text(
                  '${index + 1}.',
                  style: TextStyle(color: color, fontSize: 16, height: 1.6),
                ),
              ),
            );
          } else {
            // 无序列表点标记
            final parentStyleHeight = 16.0 * 1.6;
            return Padding(
              padding: EdgeInsets.only(top: (parentStyleHeight / 2) - 1.5),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: _getUnorderedListDecoration(depth, color),
                ),
              ),
            );
          }
        },
      ),

      // 复选框配置 - 支持自定义颜色
      CheckBoxConfig(
        builder: (checked) => Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    ]; // 如果启用LaTeX渲染，添加LaTeX配置
    if (_enableLatexRendering) {
      configs.add(LatexConfig(isDarkTheme: isDark));
    } // 如果启用视频渲染，添加视频配置
    if (_enableVideoRendering) {
      configs.add(
        VideoNodeConfig(
          isDarkTheme: isDark,
          onVideoTap: _onLinkTap,
          errorBuilder: (url, alt, error) =>
              _buildImageError(url, error.toString()),
        ),
      );
    }

    // 如果启用音频渲染，添加音频配置
    if (_enableAudioRendering) {
      configs.add(
        AudioNodeConfig(
          isDarkTheme: isDark,
          onAudioTap: _onLinkTap,
          audioUuidMap: _audioUuidMap, // 新增
          errorBuilder: (url, alt, error) =>
              _buildImageError(url, error.toString()),
        ),
      );
    }

    // 创建配置
    var config = baseConfig.copy(configs: configs);

    return config;
  }
}
