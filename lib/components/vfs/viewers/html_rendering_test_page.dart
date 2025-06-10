import 'package:flutter/material.dart';
import 'vfs_markdown_renderer.dart';

/// HTML渲染测试页面
/// 用于展示和测试VFS Markdown渲染器的HTML功能
class HtmlRenderingTestPage extends StatefulWidget {
  const HtmlRenderingTestPage({super.key});

  @override
  State<HtmlRenderingTestPage> createState() => _HtmlRenderingTestPageState();
}

class _HtmlRenderingTestPageState extends State<HtmlRenderingTestPage> {
  /// 测试用的Markdown内容，包含各种HTML标签
  final String _testMarkdownContent = '''
# HTML渲染功能测试

## 基础文本格式化
这是普通文本，<b>这是粗体文本</b>，<i>这是斜体文本</i>，<u>这是下划线文本</u>。

<p>这是一个HTML段落，包含<strong>强调文本</strong>和<em>重点文本</em>。</p>

## 标题测试
<h2>这是HTML H2标题</h2>
<h3>这是HTML H3标题</h3>
<h4>这是HTML H4标题</h4>

## 链接和图片
<a href="https://flutter.dev">这是外部链接</a>

<img src="https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png" alt="Flutter Logo" width="200">

## 列表测试
<ul>
  <li>HTML无序列表项1</li>
  <li>HTML无序列表项2
    <ul>
      <li>嵌套项1</li>
      <li>嵌套项2</li>
    </ul>
  </li>
  <li>HTML无序列表项3</li>
</ul>

<ol>
  <li>HTML有序列表项1</li>
  <li>HTML有序列表项2</li>
  <li>HTML有序列表项3</li>
</ol>

## 表格测试
<table border="1" style="border-collapse: collapse; width: 100%;">
  <thead>
    <tr style="background-color: #f0f0f0;">
      <th style="padding: 8px; border: 1px solid #ddd;">功能</th>
      <th style="padding: 8px; border: 1px solid #ddd;">状态</th>
      <th style="padding: 8px; border: 1px solid #ddd;">说明</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">基础HTML标签</td>
      <td style="padding: 8px; border: 1px solid #ddd;"><span style="color: green;">✓ 支持</span></td>
      <td style="padding: 8px; border: 1px solid #ddd;">p, div, span, b, i, u等</td>
    </tr>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">HTML表格</td>
      <td style="padding: 8px; border: 1px solid #ddd;"><span style="color: green;">✓ 支持</span></td>
      <td style="padding: 8px; border: 1px solid #ddd;">table, tr, td, th等</td>
    </tr>
    <tr>
      <td style="padding: 8px; border: 1px solid #ddd;">HTML链接</td>
      <td style="padding: 8px; border: 1px solid #ddd;"><span style="color: green;">✓ 支持</span></td>
      <td style="padding: 8px; border: 1px solid #ddd;">包括VFS协议链接</td>
    </tr>
  </tbody>
</table>

## 代码块测试
<pre><code>
function testHtmlRendering() {
    console.log("HTML渲染测试");
    return true;
}
</code></pre>

行内代码：<code>const isHtmlEnabled = true;</code>

## 引用块测试
<blockquote style="border-left: 4px solid #ccc; padding-left: 16px; margin: 16px 0; font-style: italic;">
这是一个HTML引用块，展示了HTML在Markdown中的渲染效果。
</blockquote>

## 特殊元素测试
<details>
  <summary><strong>点击展开更多信息</strong></summary>
  <div style="padding: 10px; background-color: #f9f9f9; margin-top: 10px;">
    <p>这是折叠内容，只有点击摘要才会显示。</p>
    <ul>
      <li>支持复杂的嵌套结构</li>
      <li>可以包含任意HTML内容</li>
      <li>非常适合FAQ和帮助文档</li>
    </ul>
  </div>
</details>

<hr style="margin: 20px 0; border: 1px solid #eee;">

## 混合内容测试
<div style="border: 2px solid #007acc; border-radius: 8px; padding: 16px; margin: 16px 0; background-color: #f0f8ff;">
  <h4 style="color: #007acc; margin-top: 0;">📋 功能清单</h4>
  
  **Markdown标准语法：**
  - [x] 标题
  - [x] 段落
  - [x] 列表
  - [x] 链接
  - [x] 图片
  - [x] 代码块
  
  **HTML扩展支持：**
  - [x] <span style="color: green;">基础HTML标签渲染</span>
  - [x] <span style="color: green;">HTML表格支持</span>
  - [x] <span style="color: green;">HTML链接处理</span>
  - [x] <span style="color: green;">混合内容渲染</span>
  - [x] <span style="color: green;">安全HTML过滤</span>
</div>

## 使用说明
1. **启用HTML渲染**：点击工具栏的HTML按钮（代码图标）
2. **查看HTML信息**：点击信息按钮查看HTML内容统计
3. **切换渲染模式**：可以在HTML渲染和纯文本模式之间切换
4. **状态栏显示**：底部状态栏会显示HTML渲染状态和统计信息

---
*测试完成 - HTML渲染功能正常工作*
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML渲染测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文本
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'HTML渲染功能测试',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '这个页面展示了VFS Markdown渲染器的HTML功能。'
                      '您可以测试各种HTML标签的渲染效果，'
                      '以及HTML渲染开关的功能。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.html, size: 16),
                          label: const Text('HTML支持'),
                          backgroundColor: Colors.green.shade100,
                        ),
                        Chip(
                          avatar: const Icon(Icons.table_chart, size: 16),
                          label: const Text('表格渲染'),
                          backgroundColor: Colors.blue.shade100,
                        ),
                        Chip(
                          avatar: const Icon(Icons.link, size: 16),
                          label: const Text('链接处理'),
                          backgroundColor: Colors.orange.shade100,
                        ),
                        Chip(
                          avatar: const Icon(Icons.security, size: 16),
                          label: const Text('安全过滤'),
                          backgroundColor: Colors.purple.shade100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // VFS Markdown渲染器
            Expanded(
              child: Card(
                child: VfsMarkdownRenderer(
                  vfsPath: 'memory://test/html_test.md',
                  config: MarkdownRendererConfig.page,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('渲染错误: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onLoaded: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('HTML测试内容加载完成'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 内存模拟的VFS服务，用于测试
class MockMemoryVfsService {
  static final Map<String, String> _memoryFiles = {
    'memory://test/html_test.md': '''
# HTML渲染功能测试

这是一个测试文档，包含各种HTML标签以验证渲染功能。

## 基础HTML标签
<p>这是一个段落标签。</p>
<div>这是一个div容器。</div>

**格式化测试：**
- <b>粗体文本</b>
- <i>斜体文本</i>
- <u>下划线文本</u>
- <s>删除线文本</s>

## HTML表格测试
<table border="1">
  <tr>
    <th>标题1</th>
    <th>标题2</th>
  </tr>
  <tr>
    <td>内容1</td>
    <td>内容2</td>
  </tr>
</table>

## 链接测试
<a href="https://flutter.dev">Flutter官网</a>

使用工具栏按钮可以切换HTML渲染模式。
''',
  };

  static String? getFileContent(String path) {
    return _memoryFiles[path];
  }
}
