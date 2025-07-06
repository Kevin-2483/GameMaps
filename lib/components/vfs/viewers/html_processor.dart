import 'package:html/dom.dart' as h;
import 'package:markdown/markdown.dart' as m;
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html/dom_parsing.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'video_processor.dart';

/// HTML处理器 - 用于在Markdown中渲染HTML内容
/// 基于markdown_widget的HTML扩展支持
class HtmlProcessor {
  /// HTML标签正则表达式
  static final RegExp htmlRep = RegExp(
    r'<[^>]*>',
    multiLine: true,
    caseSensitive: true,
  );

  /// 表格标签正则表达式
  static final RegExp tableRep = RegExp(
    r'<table[^>]*>',
    multiLine: true,
    caseSensitive: true,
  );

  /// 将HTML节点转换为Markdown节点
  /// 解决了markdown包中HTML处理的问题
  /// 参考: https://github.com/dart-lang/markdown/issues/284#event-3216258013
  static void htmlToMarkdown(h.Node? node, int deep, List<m.Node> mNodes) {
    if (node == null) return;

    if (node is h.Text) {
      mNodes.add(m.Text(node.text));
    } else if (node is h.Element) {
      final tag = node.localName;
      List<m.Node> children = [];

      // 递归处理子节点
      for (final child in node.children) {
        htmlToMarkdown(child, deep + 1, children);
      }

      m.Element element;

      // 特殊处理媒体标签
      if (tag == MarkdownTag.img.name || tag == 'video' || tag == 'audio') {
        element = HtmlElement(tag!, children, node.text);
        element.attributes.addAll(node.attributes.cast());
      } else {
        element = HtmlElement(tag!, children, node.text);
        element.attributes.addAll(node.attributes.cast());
      }

      mNodes.add(element);
    }
  }

  /// 解析Markdown Text节点中的HTML内容为SpanNode
  static List<SpanNode> parseHtml(
    m.Text node, {
    ValueCallback<dynamic>? onError,
    WidgetVisitor? visitor,
    TextStyle? parentStyle,
  }) {
    debugPrint(
      '🔧 HtmlProcessor.parseHtml: 开始解析 - textContent: ${node.textContent.substring(0, node.textContent.length > 100 ? 100 : node.textContent.length)}...',
    );

    try {
      final text = node.textContent.replaceAll(
        visitor?.splitRegExp ?? WidgetVisitor.defaultSplitRegExp,
        '',
      );

      // 如果不包含HTML标签，直接返回文本节点
      if (!text.contains(htmlRep)) {
        debugPrint('🔧 HtmlProcessor.parseHtml: 不包含HTML标签，返回文本节点');
        return [TextNode(text: node.text)];
      }

      debugPrint('🔧 HtmlProcessor.parseHtml: 检测到HTML标签，开始解析');

      // 解析HTML片段
      h.DocumentFragment document = parseFragment(text);

      debugPrint(
        '🔧 HtmlProcessor.parseHtml: 解析完成，节点数量: ${document.nodes.length}',
      );

      // 使用HTML转SpanNode访问器处理
      final result = HtmlToSpanVisitor(
        visitor: visitor,
        parentStyle: parentStyle,
      ).toVisit(document.nodes.toList());

      debugPrint(
        '🔧 HtmlProcessor.parseHtml: 转换完成，SpanNode数量: ${result.length}',
      );
      return result;
    } catch (e) {
      debugPrint('🔧 HtmlProcessor.parseHtml: 解析失败 - $e');
      onError?.call(e);
      return [TextNode(text: node.text)];
    }
  }

  /// 检查文本是否包含HTML标签
  static bool containsHtml(String text) {
    return htmlRep.hasMatch(text);
  }

  /// 检查文本是否包含表格HTML
  static bool containsTable(String text) {
    return tableRep.hasMatch(text);
  }

  /// 清理HTML标签，保留纯文本
  static String stripHtmlTags(String html) {
    return html.replaceAll(htmlRep, '');
  }

  /// 获取支持的HTML标签列表
  static List<String> getSupportedTags() {
    return [
      'p',
      'div',
      'span',
      'br',
      'hr',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'strong',
      'b',
      'em',
      'i',
      'u',
      's',
      'del',
      'ins',
      'a',
      'img',
      'video',
      'audio',
      'ul',
      'ol',
      'li',
      'table',
      'thead',
      'tbody',
      'tr',
      'th',
      'td',
      'blockquote',
      'pre',
      'code',
      'details',
      'summary',
      'mark',
      'small',
      'sub',
      'sup',
    ];
  }

  /// 转换HTML内容为Markdown兼容格式
  /// 这个方法会将一些HTML标签转换为对应的Markdown语法
  static String convertHtmlToMarkdown(String content) {
    if (!containsHtml(content)) return content;

    try {
      final document = HtmlUtils.safeParseFragment(content);
      if (document == null) return content;

      // 转换HTML标签为Markdown等价形式
      var result = content;

      // 转换标题标签
      result = _convertHeadings(result);

      // 转换格式化标签
      result = _convertFormatting(result);

      // 转换链接标签
      result = _convertLinks(result);

      // 转换列表标签
      result = _convertLists(result);

      // 转换表格标签
      result = _convertTables(result);

      // 转换引用块
      result = _convertBlockquotes(result);
      // 转换代码块
      result = _convertCodeBlocks(result);

      // 转换视频标签
      result = _convertVideoTags(result);

      // 转换段落标签
      result = _convertParagraphs(result);

      return result;
    } catch (e) {
      debugPrint('HTML转Markdown失败: $e');
      return content;
    }
  }

  /// 转换标题标签
  static String _convertHeadings(String html) {
    // 转换 <h1> 到 <h6>
    for (int i = 1; i <= 6; i++) {
      final pattern = RegExp(
        r'<h' + i.toString() + r'[^>]*>(.*?)</h' + i.toString() + r'>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      );
      html = html.replaceAllMapped(pattern, (match) {
        final content = match.group(1) ?? '';
        final prefix = '#' * i;
        return '\n$prefix $content\n';
      });
    }
    return html;
  }

  /// 转换格式化标签
  static String _convertFormatting(String html) {
    // 粗体
    html = html.replaceAllMapped(
      RegExp(
        r'<(b|strong)[^>]*>(.*?)</\1>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '**${match.group(2)}**',
    );

    // 斜体
    html = html.replaceAllMapped(
      RegExp(
        r'<(i|em)[^>]*>(.*?)</\1>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '*${match.group(2)}*',
    );

    // 行内代码
    html = html.replaceAllMapped(
      RegExp(
        r'<code[^>]*>(.*?)</code>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '`${match.group(1)}`',
    );

    // 删除线
    html = html.replaceAllMapped(
      RegExp(
        r'<(s|del|strike)[^>]*>(.*?)</\1>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '~~${match.group(2)}~~',
    );

    return html;
  }

  /// 转换链接标签
  static String _convertLinks(String html) {
    // 转换 <a href="url">text</a> 为 [text](url)
    html = html.replaceAllMapped(
      RegExp(
        r"""<a[^>]*href=["\']([^"\']*)["\'][^>]*>(.*?)</a>""",
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) {
        final url = match.group(1) ?? '';
        final text = match.group(2) ?? '';
        return '[$text]($url)';
      },
    );

    return html;
  }

  /// 转换列表标签
  static String _convertLists(String html) {
    // 转换无序列表
    html = _convertUnorderedLists(html);

    // 转换有序列表
    html = _convertOrderedLists(html);

    return html;
  }

  /// 转换无序列表
  static String _convertUnorderedLists(String html) {
    // 匹配完整的 <ul> 标签，使用非贪婪匹配避免嵌套问题
    final ulPattern = RegExp(
      r'<ul[^>]*>(.*?)</ul>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );

    // 多次处理以处理嵌套列表，从内到外
    String result = html;
    int maxIterations = 5; // 限制迭代次数避免无限循环
    int iteration = 0;

    while (result.contains('<ul>') && iteration < maxIterations) {
      bool hasChanges = false;
      result = result.replaceAllMapped(ulPattern, (match) {
        String listContent = match.group(1) ?? '';

        // 只处理不包含嵌套<ul>的列表（从最内层开始）
        if (!listContent.contains('<ul>') && !listContent.contains('<ol>')) {
          hasChanges = true;

          // 提取所有 <li> 项
          final liPattern = RegExp(
            r'<li[^>]*>(.*?)</li>',
            caseSensitive: false,
            multiLine: true,
            dotAll: true,
          );

          final items = <String>[];
          listContent.replaceAllMapped(liPattern, (liMatch) {
            String itemContent = liMatch.group(1)?.trim() ?? '';
            // 清理内部HTML标签但保留文本
            itemContent = _cleanHtmlTags(itemContent);
            items.add('- $itemContent');
            return '';
          });

          return '\n${items.join('\n')}\n';
        }

        return match.group(0) ?? ''; // 保持原样
      });

      if (!hasChanges) break;
      iteration++;
    }

    return result;
  }

  /// 转换有序列表
  static String _convertOrderedLists(String html) {
    // 匹配完整的 <ol> 标签，使用非贪婪匹配避免嵌套问题
    final olPattern = RegExp(
      r'<ol[^>]*>(.*?)</ol>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );

    // 多次处理以处理嵌套列表，从内到外
    String result = html;
    int maxIterations = 5; // 限制迭代次数避免无限循环
    int iteration = 0;

    while (result.contains('<ol>') && iteration < maxIterations) {
      bool hasChanges = false;
      result = result.replaceAllMapped(olPattern, (match) {
        String listContent = match.group(1) ?? '';

        // 只处理不包含嵌套<ol>的列表（从最内层开始）
        if (!listContent.contains('<ul>') && !listContent.contains('<ol>')) {
          hasChanges = true;

          // 提取所有 <li> 项
          final liPattern = RegExp(
            r'<li[^>]*>(.*?)</li>',
            caseSensitive: false,
            multiLine: true,
            dotAll: true,
          );

          final items = <String>[];
          int index = 1;
          listContent.replaceAllMapped(liPattern, (liMatch) {
            String itemContent = liMatch.group(1)?.trim() ?? '';
            // 清理内部HTML标签但保留文本
            itemContent = _cleanHtmlTags(itemContent);
            items.add('$index. $itemContent');
            index++;
            return '';
          });

          return '\n${items.join('\n')}\n';
        }

        return match.group(0) ?? ''; // 保持原样
      });

      if (!hasChanges) break;
      iteration++;
    }

    return result;
  }

  /// 清理HTML标签但保留基本格式
  static String _cleanHtmlTags(String content) {
    // 保留一些基本的格式标签
    content = content.replaceAllMapped(
      RegExp(
        r'<(b|strong)[^>]*>(.*?)</\1>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '**${match.group(2)}**',
    );

    content = content.replaceAllMapped(
      RegExp(
        r'<(i|em)[^>]*>(.*?)</\1>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '*${match.group(2)}*',
    );

    content = content.replaceAllMapped(
      RegExp(
        r'<code[^>]*>(.*?)</code>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '`${match.group(1)}`',
    );

    // 移除其他HTML标签
    content = content.replaceAll(RegExp(r'<[^>]*>'), '');

    // 清理多余的空白字符
    content = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    return content;
  }

  /// 转换表格标签
  static String _convertTables(String html) {
    // 匹配完整的 <table> 标签
    final tablePattern = RegExp(
      r'<table[^>]*>(.*?)</table>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );

    html = html.replaceAllMapped(tablePattern, (match) {
      String tableContent = match.group(1) ?? '';

      // 提取表头
      final theadPattern = RegExp(
        r'<thead[^>]*>(.*?)</thead>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      );
      String? headerContent;
      tableContent = tableContent.replaceAllMapped(theadPattern, (theadMatch) {
        headerContent = theadMatch.group(1);
        return '';
      });

      // 提取表体
      final tbodyPattern = RegExp(
        r'<tbody[^>]*>(.*?)</tbody>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      );
      String? bodyContent;
      tableContent = tableContent.replaceAllMapped(tbodyPattern, (tbodyMatch) {
        bodyContent = tbodyMatch.group(1);
        return '';
      });

      // 如果没有显式的tbody，使用整个表格内容
      if (bodyContent == null) {
        bodyContent = tableContent;
      }

      final rows = <String>[];

      // 处理表头
      if (headerContent != null) {
        final headerRow = _convertTableRow(headerContent!, true);
        if (headerRow.isNotEmpty) {
          rows.add(headerRow);
          // 添加分隔行
          final separatorCells = headerRow.split('|').length - 2; // 减去前后的空格
          rows.add('|${List.filled(separatorCells, ' --- ').join('|')}|');
        }
      }

      // 处理表体行
      final trPattern = RegExp(
        r'<tr[^>]*>(.*?)</tr>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      );

      bodyContent!.replaceAllMapped(trPattern, (trMatch) {
        final rowContent = trMatch.group(1) ?? '';
        final row = _convertTableRow(rowContent, false);
        if (row.isNotEmpty) {
          rows.add(row);
        }
        return '';
      });

      return rows.isEmpty ? '' : '\n${rows.join('\n')}\n';
    });

    return html;
  }

  /// 转换表格行
  static String _convertTableRow(String rowContent, bool isHeader) {
    final cellPattern = isHeader
        ? RegExp(
            r'<th[^>]*>(.*?)</th>',
            caseSensitive: false,
            multiLine: true,
            dotAll: true,
          )
        : RegExp(
            r'<td[^>]*>(.*?)</td>',
            caseSensitive: false,
            multiLine: true,
            dotAll: true,
          );

    final cells = <String>[];
    rowContent.replaceAllMapped(cellPattern, (cellMatch) {
      final cellContent = cellMatch.group(1)?.trim() ?? '';
      cells.add(' $cellContent ');
      return '';
    });

    return cells.isEmpty ? '' : '|${cells.join('|')}|';
  }

  /// 转换引用块
  static String _convertBlockquotes(String html) {
    // 转换 <blockquote> 为 > 引用格式
    html = html.replaceAllMapped(
      RegExp(
        r'<blockquote[^>]*>(.*?)</blockquote>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) {
        String content = match.group(1)?.trim() ?? '';

        // 移除内部的段落标签
        content = content.replaceAll(
          RegExp(r'</?p[^>]*>', caseSensitive: false),
          '',
        );

        // 为每行添加 > 前缀
        final lines = content.split('\n');
        final quotedLines = lines
            .map((line) => '> ${line.trim()}')
            .where((line) => line.trim() != '>');

        return '\n${quotedLines.join('\n')}\n';
      },
    );

    return html;
  }

  /// 转换代码块
  static String _convertCodeBlocks(String html) {
    // 转换 <pre><code> 为 ``` 代码块
    html = html.replaceAllMapped(
      RegExp(
        r'<pre[^>]*><code[^>]*>(.*?)</code></pre>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) {
        String code = match.group(1) ?? '';

        // 解码HTML实体
        code = _decodeHtmlEntities(code);

        return '\n```\n$code\n```\n';
      },
    );

    return html;
  }

  /// 解码常见的HTML实体
  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  /// 转换段落标签
  static String _convertParagraphs(String html) {
    // 简单的段落转换
    html = html.replaceAllMapped(
      RegExp(
        r'<p[^>]*>(.*?)</p>',
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      ),
      (match) => '\n${match.group(1)}\n',
    );

    // 换行标签
    html = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    return html;
  }

  /// 转换视频标签
  static String _convertVideoTags(String html) {
    // 保留视频标签，让后续的视频处理器处理
    // 这里我们可以做一些基本的格式化
    final videoPattern = RegExp(
      r'<video([^>]*)>(.*?)</video>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );

    html = html.replaceAllMapped(videoPattern, (match) {
      final attributes = match.group(1) ?? '';
      final content = match.group(2) ?? '';

      // 提取src属性
      final srcPattern = RegExp(
        r'''src=["\']([^"\']*)["\']''',
        caseSensitive: false,
      );
      final srcMatch = srcPattern.firstMatch(attributes);

      if (srcMatch != null) {
        // 保持video标签格式，确保有controls属性
        var cleanAttributes = attributes;
        if (!cleanAttributes.contains('controls')) {
          cleanAttributes += ' controls';
        }
        return '<video$cleanAttributes>$content</video>';
      }

      return match.group(0) ?? '';
    });

    return html;
  }
}

/// HTML元素扩展类
/// 继承自markdown的Element类，添加文本内容支持
class HtmlElement extends m.Element {
  /// HTML元素的文本内容
  final String textContent;

  /// 构造函数
  HtmlElement(String tag, List<m.Node>? children, this.textContent)
    : super(tag, children);

  /// 获取元素的纯文本内容
  String get plainText => textContent;

  /// 判断是否为块级元素
  bool get isBlockElement {
    const blockTags = {
      'div',
      'p',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'blockquote',
      'pre',
      'ul',
      'ol',
      'li',
      'table',
      'thead',
      'tbody',
      'tr',
      'th',
      'td',
      'details',
      'summary',
      'hr',
    };
    return blockTags.contains(tag.toLowerCase());
  }

  /// 判断是否为内联元素
  bool get isInlineElement => !isBlockElement;
}

/// HTML转SpanNode访问器
/// 负责将HTML DOM树转换为markdown_widget可以渲染的SpanNode树
class HtmlToSpanVisitor extends TreeVisitor {
  /// 结果span节点列表
  final List<SpanNode> _spans = [];

  /// span节点栈，用于处理嵌套结构
  final List<SpanNode> _spansStack = [];

  /// Widget访问器
  final WidgetVisitor visitor;

  /// 父级文本样式
  final TextStyle parentStyle;

  /// 构造函数
  HtmlToSpanVisitor({WidgetVisitor? visitor, TextStyle? parentStyle})
    : this.visitor = visitor ?? WidgetVisitor(),
      this.parentStyle = parentStyle ?? const TextStyle();

  /// 访问HTML节点列表并转换为SpanNode列表
  List<SpanNode> toVisit(List<h.Node> nodes) {
    _spans.clear();
    _spansStack.clear();

    for (final node in nodes) {
      final emptyNode = ConcreteElementNode(style: parentStyle);
      _spans.add(emptyNode);
      _spansStack.add(emptyNode);
      visit(node);
      _spansStack.removeLast();
    }

    final result = List.of(_spans);
    _spans.clear();
    _spansStack.clear();
    return result;
  }

  @override
  void visitText(h.Text node) {
    final last = _spansStack.last;
    if (last is ElementNode) {
      final textNode = TextNode(text: node.text);
      last.accept(textNode);
    }
  }

  @override
  void visitElement(h.Element node) {
    final localName = node.localName ?? '';
    debugPrint(
      '🔧 HtmlToSpanVisitor.visitElement: 处理标签 - $localName, attributes: ${node.attributes}',
    );

    // 特殊处理video标签 - 直接创建VideoNode
    if (localName == 'video') {
      debugPrint('🎥 HtmlToSpanVisitor: 发现video标签，创建VideoNode');
      final videoNode = _createVideoNode(node);
      final last = _spansStack.last;
      if (last is ElementNode) {
        last.accept(videoNode);
        debugPrint('🎥 HtmlToSpanVisitor: VideoNode已添加到父节点');
      }
      return; // video标签不需要处理子节点
    }

    // 创建对应的markdown元素
    final mdElement = m.Element(localName, []);
    mdElement.attributes.addAll(node.attributes.cast());

    // 通过visitor获取对应的SpanNode
    SpanNode spanNode = visitor.getNodeByElement(mdElement, visitor.config);

    // 如果不是ElementNode，包装成ElementNode
    if (spanNode is! ElementNode) {
      final wrapper = ConcreteElementNode(tag: localName, style: parentStyle);
      wrapper.accept(spanNode);
      spanNode = wrapper;
    }

    // 添加到父节点
    final last = _spansStack.last;
    if (last is ElementNode) {
      last.accept(spanNode);
    }

    // 处理子节点
    _spansStack.add(spanNode);
    for (var child in node.nodes.toList(growable: false)) {
      visit(child);
    }
    _spansStack.removeLast();
  }

  /// 创建VideoNode
  SpanNode _createVideoNode(h.Element videoElement) {
    final attributes = <String, String>{};

    // 正确处理attributes - html包的Element.attributes是LinkedHashMap<Object, String>
    for (final entry in videoElement.attributes.entries) {
      attributes[entry.key.toString()] = entry.value;
    }

    // 提取text content
    final textContent = videoElement.text;

    debugPrint(
      '🎥 HtmlToSpanVisitor._createVideoNode: attributes: $attributes, textContent: $textContent',
    );

    // 创建VideoNode实例
    return VideoNode(attributes, textContent);
  }
}

/// HTML配置扩展
/// 为MarkdownConfig添加HTML处理支持
extension HtmlConfigExtension on MarkdownConfig {
  /// 创建支持HTML的Markdown配置
  static MarkdownConfig createWithHtmlSupport({
    bool isDarkTheme = false,
    MarkdownConfig? baseConfig,
    // 添加VFS协议支持参数
    void Function(String)? onLinkTap,
    Widget Function(String, Map<String, String>)? imageBuilder,
    Widget Function(String, String, dynamic)? imageErrorBuilder,
  }) {
    // 基础配置列表
    final configs = <WidgetConfig>[
      // HTML文本处理配置
      PConfig(
        textStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 16,
          height: 1.6,
        ),
      ),

      // HTML链接处理 - 保留VFS协议支持
      LinkConfig(
        style: TextStyle(
          color: isDarkTheme ? Colors.lightBlueAccent : Colors.blue,
          decoration: TextDecoration.underline,
        ),
        onTap: onLinkTap, // 使用传入的链接处理器
      ),

      // HTML图片处理 - 保留VFS协议支持
      ImgConfig(
        builder:
            imageBuilder ??
            (url, attributes) {
              // 默认的网络图片处理逻辑
              return Image.network(
                url,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, color: Colors.red.shade400),
                        const SizedBox(width: 8),
                        Text(
                          '图片加载失败',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
        errorBuilder:
            imageErrorBuilder ??
            (url, alt, error) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Text(
                    '图片加载失败: $error',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ],
              ),
            ),
      ),

      // 添加标题配置
      H1Config(
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H2Config(
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H3Config(
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H4Config(
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H5Config(
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      H6Config(
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),

      // 代码块配置
      PreConfig(
        theme: isDarkTheme
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
          color: isDarkTheme
              ? const Color(0xFFE6E6E6)
              : const Color(0xFF333333),
          backgroundColor: isDarkTheme
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF8F8F8),
          fontFamily: 'Courier',
          fontSize: 14,
        ),
      ),

      // 引用块配置
      BlockquoteConfig(
        textColor: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade700,
        sideColor: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400,
      ),

      // 列表配置
      ListConfig(
        marginLeft: 32.0,
        marginBottom: 4.0,
        marker: (isOrdered, depth, index) {
          final color = isDarkTheme ? Colors.white : Colors.black87;
          if (isOrdered) {
            // 有序列表数字标记
            return Container(
              alignment: Alignment.centerRight,
              width: 24,
              child: Text(
                '${index + 1}.',
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
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

      // 复选框配置
      CheckBoxConfig(
        builder: (checked) => Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          size: 20,
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ), // 表格配置
      TableConfig(
        wrapper: (table) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        ),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        headerStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        bodyStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
        border: TableBorder.all(
          color: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400,
          width: 1,
        ),
        headerRowDecoration: BoxDecoration(
          color: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),

      // 如果是深色主题，添加深色配置
      if (isDarkTheme) ...[
        HrConfig.darkConfig,
        H1Config.darkConfig,
        H2Config.darkConfig,
        H3Config.darkConfig,
        H4Config.darkConfig,
        H5Config.darkConfig,
        H6Config.darkConfig,
        PreConfig.darkConfig,
        CodeConfig.darkConfig,
        BlockquoteConfig.darkConfig,
      ],
    ];

    // 如果提供了基础配置，基于它创建新配置
    if (baseConfig != null) {
      return baseConfig.copy(configs: configs);
    }

    // 否则创建新的配置
    return MarkdownConfig(configs: configs);
  }

  /// 获取无序列表标记装饰
  static BoxDecoration _getUnorderedListDecoration(int depth, Color color) {
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
}

/// HTML工具类
class HtmlUtils {
  /// 安全解析HTML文档片段
  static h.DocumentFragment? safeParseFragment(String html) {
    try {
      return parseFragment(html);
    } catch (e) {
      debugPrint('HTML解析失败: $e');
      return null;
    }
  }

  /// 提取HTML中的所有链接
  static List<String> extractLinks(String html) {
    final document = safeParseFragment(html);
    if (document == null) return [];

    final links = <String>[];
    document.querySelectorAll('a[href]').forEach((element) {
      final href = element.attributes['href'];
      if (href != null && href.isNotEmpty) {
        links.add(href);
      }
    });

    return links;
  }

  /// 提取HTML中的所有图片URL
  static List<String> extractImages(String html) {
    final document = safeParseFragment(html);
    if (document == null) return [];

    final images = <String>[];
    document.querySelectorAll('img[src]').forEach((element) {
      final src = element.attributes['src'];
      if (src != null && src.isNotEmpty) {
        images.add(src);
      }
    });

    return images;
  }

  /// 提取HTML中的所有视频URL
  static List<String> extractVideos(String html) {
    final document = safeParseFragment(html);
    if (document == null) return [];

    final videos = <String>[];
    document.querySelectorAll('video[src]').forEach((element) {
      final src = element.attributes['src'];
      if (src != null && src.isNotEmpty) {
        videos.add(src);
      }
    });

    // 也检查source标签
    document.querySelectorAll('video source[src]').forEach((element) {
      final src = element.attributes['src'];
      if (src != null && src.isNotEmpty) {
        videos.add(src);
      }
    });

    return videos;
  }

  /// 清理不安全的HTML标签和属性
  static String sanitizeHtml(String html) {
    final document = safeParseFragment(html);
    if (document == null) return html;

    // 移除脚本标签
    document.querySelectorAll('script').forEach((element) {
      element.remove();
    });

    // 移除样式标签
    document.querySelectorAll('style').forEach((element) {
      element.remove();
    });

    // 移除事件处理属性
    document.querySelectorAll('*').forEach((element) {
      final attributesToRemove = <String>[];
      element.attributes.forEach((key, value) {
        if (key is String && key.startsWith('on')) {
          attributesToRemove.add(key);
        }
      });
      for (final attr in attributesToRemove) {
        element.attributes.remove(attr);
      }
    });

    return document.outerHtml;
  }
}
