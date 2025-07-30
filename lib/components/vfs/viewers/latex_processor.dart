// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

import '../../../services/localization_service.dart';

/// LaTeX处理器 - 用于在Markdown中渲染LaTeX数学公式
class LatexProcessor {
  /// LaTeX标签名称
  static const String latexTag = 'latex';

  /// LaTeX语法正则表达式
  /// 匹配 $$....$$ (块级公式) 和 $....$ (行内公式)
  static final RegExp latexRegExp = RegExp(r'(\$\$[\s\S]+\$\$)|(\$.+?\$)');

  /// 检查文本是否包含LaTeX语法
  static bool containsLatex(String text) {
    return latexRegExp.hasMatch(text);
  }

  /// 创建LaTeX语法解析器
  static LatexSyntax createSyntax() {
    return LatexSyntax();
  }

  /// 创建LaTeX节点生成器
  static SpanNodeGeneratorWithTag createGenerator() {
    return SpanNodeGeneratorWithTag(
      tag: latexTag,
      generator: (e, config, visitor) =>
          LatexNode(e.attributes, e.textContent, config),
    );
  }
}

/// LaTeX语法解析器
/// 继承自markdown包的InlineSyntax，用于识别LaTeX语法
class LatexSyntax extends m.InlineSyntax {
  LatexSyntax() : super(r'(\$\$[\s\S]+\$\$)|(\$.+?\$)');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final input = match.input;
    final matchValue = input.substring(match.start, match.end);
    String content = '';
    bool isInline = true;
    const blockSyntax = '\$\$';
    const inlineSyntax = '\$';

    if (matchValue.startsWith(blockSyntax) &&
        matchValue.endsWith(blockSyntax) &&
        (matchValue != blockSyntax)) {
      // 块级公式
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = false;
    } else if (matchValue.startsWith(inlineSyntax) &&
        matchValue.endsWith(inlineSyntax) &&
        matchValue != inlineSyntax) {
      // 行内公式
      content = matchValue.substring(1, matchValue.length - 1);
    }

    // 创建LaTeX元素
    m.Element el = m.Element.text(LatexProcessor.latexTag, matchValue);
    el.attributes['content'] = content;
    el.attributes['isInline'] = '$isInline';
    parser.addNode(el);
    return true;
  }
}

/// LaTeX渲染节点
/// 继承自SpanNode，用于渲染LaTeX数学公式
class LatexNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  LatexNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    final content = attributes['content'] ?? '';
    final isInline = attributes['isInline'] == 'true';
    final style = parentStyle ?? config.p.textStyle;

    // 如果内容为空，返回原始文本
    if (content.isEmpty) return TextSpan(style: style, text: textContent);

    // 获取主题信息
    final isDark = _isDarkMode(style);

    try {
      // 创建LaTeX渲染组件
      final latex = Math.tex(
        content,
        mathStyle: MathStyle.text,
        textStyle: style.copyWith(color: isDark ? Colors.white : Colors.black),
        textScaleFactor: 1,
        onErrorFallback: (error) {
          return Text(
            textContent, // 出错时显示原始文本
            style: style.copyWith(color: Colors.red),
          );
        },
      );

      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: !isInline
            ? Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: latex),
              )
            : latex,
      );
    } catch (e) {
      // LaTeX解析失败，返回错误提示
      return TextSpan(
        style: style.copyWith(color: Colors.red),
        text: LocalizationService.instance.current.latexErrorWarning(
          textContent,
        ),
      );
    }
  }

  /// 判断是否为暗色主题
  bool _isDarkMode(TextStyle style) {
    final color = style.color;
    if (color == null) return false;

    // 简单的亮度判断
    final brightness = color.computeLuminance();
    return brightness > 0.5; // 亮色文字通常在暗色背景上
  }
}

/// LaTeX配置类
/// 实现WidgetConfig接口，用于LaTeX渲染配置
class LatexConfig implements WidgetConfig {
  @override
  String get tag => LatexProcessor.latexTag;

  final bool isDarkTheme;

  const LatexConfig({this.isDarkTheme = false});

  static const LatexConfig light = LatexConfig(isDarkTheme: false);
  static const LatexConfig dark = LatexConfig(isDarkTheme: true);
}

/// LaTeX配置扩展类
class LatexConfigExtension {
  /// 创建支持LaTeX的Markdown配置
  static MarkdownConfig createWithLatexSupport({
    bool isDarkTheme = false,
    void Function(String)? onLinkTap,
    Widget Function(String, String)? imageBuilder,
    Widget Function(String, String, dynamic)? imageErrorBuilder,
  }) {
    // 基础配置列表
    final configs = <WidgetConfig>[
      // 添加LaTeX配置
      LatexConfig(isDarkTheme: isDarkTheme),

      // 段落文本配置
      PConfig(
        textStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
          fontSize: 16,
          height: 1.6,
        ),
      ),

      // 标题配置
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

      // 链接配置
      if (onLinkTap != null)
        LinkConfig(
          style: TextStyle(
            color: isDarkTheme ? Colors.lightBlueAccent : Colors.blue,
            decoration: TextDecoration.underline,
          ),
          onTap: onLinkTap,
        ), // 图片配置
      if (imageBuilder != null)
        ImgConfig(
          builder: (url, attributes) =>
              imageBuilder(url, attributes['alt'] ?? ''),
          errorBuilder: imageErrorBuilder != null
              ? (url, alt, error) => imageErrorBuilder(url, alt, error)
              : null,
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

      // 复选框配置
      CheckBoxConfig(
        builder: (checked) => Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          size: 20,
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ),
    ];

    // 创建新的配置
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

/// LaTeX工具类
class LatexUtils {
  /// 验证LaTeX语法是否有效
  static bool isValidLatex(String latex) {
    if (latex.isEmpty) return false;

    try {
      // 简单的语法检查
      // 检查括号是否匹配
      int braceCount = 0;
      for (int i = 0; i < latex.length; i++) {
        if (latex[i] == '{') {
          braceCount++;
        } else if (latex[i] == '}') {
          braceCount--;
          if (braceCount < 0) return false;
        }
      }
      return braceCount == 0;
    } catch (e) {
      return false;
    }
  }

  /// 提取文本中的所有LaTeX表达式
  static List<String> extractLatexExpressions(String text) {
    final expressions = <String>[];
    final matches = LatexProcessor.latexRegExp.allMatches(text);

    for (final match in matches) {
      final fullMatch = match.group(0) ?? '';
      if (fullMatch.startsWith('\$\$') && fullMatch.endsWith('\$\$')) {
        // 块级公式
        expressions.add(fullMatch.substring(2, fullMatch.length - 2));
      } else if (fullMatch.startsWith('\$') && fullMatch.endsWith('\$')) {
        // 行内公式
        expressions.add(fullMatch.substring(1, fullMatch.length - 1));
      }
    }

    return expressions;
  }

  /// 获取LaTeX统计信息
  static Map<String, dynamic> getLatexStats(String text) {
    final expressions = extractLatexExpressions(text);
    final inlineCount = expressions
        .where(
          (expr) =>
              text.contains('\$$expr\$') && !text.contains('\$\$$expr\$\$'),
        )
        .length;
    final blockCount = expressions.length - inlineCount;

    return {
      'hasLatex': expressions.isNotEmpty,
      'totalCount': expressions.length,
      'inlineCount': inlineCount,
      'blockCount': blockCount,
      'expressions': expressions,
    };
  }
}
