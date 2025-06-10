import 'package:flutter/material.dart';
import '../../pages/vfs/vfs_markdown_viewer_page.dart';
import '../../components/vfs/viewers/vfs_markdown_viewer_window.dart';
import '../../components/vfs/viewers/vfs_markdown_renderer.dart';
import '../../services/vfs/vfs_file_opener_service.dart';

/// Markdown 渲染器演示页面
class MarkdownRendererDemoPage extends StatelessWidget {
  const MarkdownRendererDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown 渲染器演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Markdown 渲染器组件演示',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            Text(
              '现在支持三种不同的使用模式：',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // 窗口模式演示
            _buildDemoCard(
              context,
              title: '1. 窗口模式',
              description: '在浮动窗口中显示 Markdown，适合快速预览',
              icon: Icons.open_in_new,
              onTap: () => _showWindowDemo(context),
            ),
            
            const SizedBox(height: 16),

            // 页面模式演示
            _buildDemoCard(
              context,
              title: '2. 页面模式',
              description: '全屏页面显示 Markdown，适合深度阅读',
              icon: Icons.fullscreen,
              onTap: () => _showPageDemo(context),
            ),
            
            const SizedBox(height: 16),

            // 嵌入模式演示
            _buildDemoCard(
              context,
              title: '3. 嵌入模式',
              description: '纯渲染组件，可嵌入任何布局',
              icon: Icons.code,
              onTap: () => _showEmbeddedDemo(context),
            ),

            const SizedBox(height: 32),

            // 使用说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '使用说明',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 窗口模式：保持原有使用方式不变\n'
                      '• 页面模式：新增的全屏显示方式\n'
                      '• 嵌入模式：可集成到自定义布局中\n'
                      '• 所有模式都支持 VFS 协议和完整功能',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  /// 演示窗口模式
  void _showWindowDemo(BuildContext context) {
    // 使用测试文档
    const testVfsPath = 'indexeddb://r6box/fs/docs/VFS_MARKDOWN_TEST.md';
    
    VfsMarkdownViewerWindow.show(
      context,
      vfsPath: testVfsPath,
      config: VfsFileOpenConfig.forText,
    );
  }

  /// 演示页面模式
  void _showPageDemo(BuildContext context) {
    const testVfsPath = 'indexeddb://r6box/fs/docs/VFS_MARKDOWN_RENDERER_USAGE.md';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VfsMarkdownViewerPage(
          vfsPath: testVfsPath,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// 演示嵌入模式
  void _showEmbeddedDemo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _EmbeddedModeDemo(),
      ),
    );
  }
}

/// 嵌入模式演示页面
class _EmbeddedModeDemo extends StatelessWidget {
  const _EmbeddedModeDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('嵌入模式演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // 左侧面板
          Container(
            width: 250,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '自定义布局示例',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('文档导航'),
                  dense: true,
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('书签'),
                  dense: true,
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('历史记录'),
                  dense: true,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '这是一个自定义布局，\nMarkdown 渲染器被嵌入\n到右侧面板中。',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // 右侧 Markdown 渲染器
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: VfsMarkdownRenderer(
                vfsPath: 'indexeddb://r6box/fs/docs/FRAMEWORK_README.md',
                config: MarkdownRendererConfig.embedded.copyWith(
                  showToolbar: true, // 显示简化工具栏
                  customToolbarActions: [
                    IconButton(
                      icon: const Icon(Icons.bookmark_add),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('添加书签功能演示')),
                        );
                      },
                      tooltip: '添加书签',
                    ),
                  ],
                ),
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('错误: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
