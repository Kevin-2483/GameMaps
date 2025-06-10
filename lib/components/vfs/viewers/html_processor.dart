import 'package:html/dom.dart' as h;
import 'package:markdown/markdown.dart' as m;
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html/dom_parsing.dart';
import 'package:markdown_widget/markdown_widget.dart';

/// HTML处理器 - 用于在Markdown中渲染HTML内容
/// 基于markdown_widget的HTML扩展支持
class HtmlProcessor {
  /// HTML标签正则表达式
  static final RegExp htmlRep = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  
  /// 表格标签正则表达式
  static final RegExp tableRep = RegExp(r'<table[^>]*>', multiLine: true, caseSensitive: true);

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
    try {
      final text = node.textContent.replaceAll(
          visitor?.splitRegExp ?? WidgetVisitor.defaultSplitRegExp, '');
      
      // 如果不包含HTML标签，直接返回文本节点
      if (!text.contains(htmlRep)) {
        return [TextNode(text: node.text)];
      }
      
      // 解析HTML片段
      h.DocumentFragment document = parseFragment(text);
      
      // 使用HTML转SpanNode访问器处理
      return HtmlToSpanVisitor(
        visitor: visitor, 
        parentStyle: parentStyle,
      ).toVisit(document.nodes.toList());
    } catch (e) {
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
      'p', 'div', 'span', 'br', 'hr',
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'strong', 'b', 'em', 'i', 'u', 's', 'del', 'ins',
      'a', 'img', 'video', 'audio',
      'ul', 'ol', 'li',
      'table', 'thead', 'tbody', 'tr', 'th', 'td',
      'blockquote', 'pre', 'code',
      'details', 'summary',
      'mark', 'small', 'sub', 'sup',
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
      
      // 转换列表（保持HTML形式，因为markdown_widget支持）
      // 表格也保持HTML形式
      
      // 转换段落标签
      result = _convertParagraphs(result);
      
      return result;
    } catch (e) {
      print('HTML转Markdown失败: $e');
      return content;
    }
  }

  /// 转换标题标签
  static String _convertHeadings(String html) {
    // 转换 <h1> 到 <h6>
    for (int i = 1; i <= 6; i++) {
      final pattern = RegExp(r'<h' + i.toString() + r'[^>]*>(.*?)</h' + i.toString() + r'>', 
          caseSensitive: false, multiLine: true, dotAll: true);
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
        RegExp(r'<(b|strong)[^>]*>(.*?)</\1>', caseSensitive: false, multiLine: true, dotAll: true),
        (match) => '**${match.group(2)}**');
    
    // 斜体
    html = html.replaceAllMapped(
        RegExp(r'<(i|em)[^>]*>(.*?)</\1>', caseSensitive: false, multiLine: true, dotAll: true),
        (match) => '*${match.group(2)}*');
    
    // 行内代码
    html = html.replaceAllMapped(
        RegExp(r'<code[^>]*>(.*?)</code>', caseSensitive: false, multiLine: true, dotAll: true),
        (match) => '`${match.group(1)}`');
    
    // 删除线
    html = html.replaceAllMapped(
        RegExp(r'<(s|del|strike)[^>]*>(.*?)</\1>', caseSensitive: false, multiLine: true, dotAll: true),
        (match) => '~~${match.group(2)}~~');
    
    return html;
  }

  /// 转换段落标签
  static String _convertParagraphs(String html) {
    // 简单的段落转换
    html = html.replaceAllMapped(
        RegExp(r'<p[^>]*>(.*?)</p>', caseSensitive: false, multiLine: true, dotAll: true),
        (match) => '\n${match.group(1)}\n');
    
    // 换行标签
    html = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    
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
      'div', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'blockquote', 'pre', 'ul', 'ol', 'li',
      'table', 'thead', 'tbody', 'tr', 'th', 'td',
      'details', 'summary', 'hr'
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
  HtmlToSpanVisitor({
    WidgetVisitor? visitor, 
    TextStyle? parentStyle,
  }) : this.visitor = visitor ?? WidgetVisitor(),
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
}

/// HTML配置扩展
/// 为MarkdownConfig添加HTML处理支持
extension HtmlConfigExtension on MarkdownConfig {
  /// 创建支持HTML的Markdown配置
  static MarkdownConfig createWithHtmlSupport({
    bool isDarkTheme = false,
    MarkdownConfig? baseConfig,
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
      
      // HTML链接处理
      LinkConfig(
        style: TextStyle(
          color: isDarkTheme ? Colors.lightBlueAccent : Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
      
      // HTML图片处理
      ImgConfig(
        builder: (url, attributes) {
          // 可以在这里添加特殊的HTML图片处理逻辑
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
}

/// HTML工具类
class HtmlUtils {
  /// 安全解析HTML文档片段
  static h.DocumentFragment? safeParseFragment(String html) {
    try {
      return parseFragment(html);
    } catch (e) {
      print('HTML解析失败: $e');
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
