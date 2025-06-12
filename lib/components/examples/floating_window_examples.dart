import 'package:flutter/material.dart';
import '../common/floating_window.dart';

/// 浮动窗口使用示例
class FloatingWindowExamples extends StatelessWidget {
  const FloatingWindowExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('浮动窗口示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 基础浮动窗口示例
            _buildExampleCard(
              context,
              title: '基础浮动窗口',
              description: '最简单的浮动窗口，包含标题和内容',
              onPressed: () => _showBasicFloatingWindow(context),
            ),

            const SizedBox(height: 16),

            // 带图标和副标题的浮动窗口
            _buildExampleCard(
              context,
              title: '带图标和副标题',
              description: '包含图标、主标题和副标题的浮动窗口',
              onPressed: () => _showFloatingWindowWithIcon(context),
            ),

            const SizedBox(height: 16),

            // 自定义尺寸的浮动窗口
            _buildExampleCard(
              context,
              title: '自定义尺寸',
              description: '指定具体宽高比例的浮动窗口',
              onPressed: () => _showCustomSizeFloatingWindow(context),
            ),

            const SizedBox(height: 16),

            // 带操作按钮的浮动窗口
            _buildExampleCard(
              context,
              title: '带操作按钮',
              description: '头部包含自定义操作按钮的浮动窗口',
              onPressed: () => _showFloatingWindowWithActions(context),
            ),

            const SizedBox(height: 16),

            // 可拖拽的浮动窗口
            _buildExampleCard(
              context,
              title: '可拖拽窗口',
              description: '支持拖拽移动的浮动窗口',
              onPressed: () => _showDraggableFloatingWindow(context),
            ),

            const SizedBox(height: 16),

            // 使用构建器模式
            _buildExampleCard(
              context,
              title: '构建器模式',
              description: '使用构建器模式创建复杂配置的浮动窗口',
              onPressed: () => _showFloatingWindowWithBuilder(context),
            ),

            const SizedBox(height: 16),

            // 使用扩展方法
            _buildExampleCard(
              context,
              title: '扩展方法',
              description: '使用BuildContext扩展方法快速创建浮动窗口',
              onPressed: () => _showFloatingWindowWithExtension(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onPressed,
                child: const Text('演示'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 基础浮动窗口示例
  void _showBasicFloatingWindow(BuildContext context) {
    FloatingWindow.show(
      context,
      title: '基础浮动窗口',
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '这是一个基础的浮动窗口示例',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text(
              '窗口内容可以是任何Widget，包括文本、按钮、表单等。'
              '窗口会自动适应屏幕大小，默认占用90%的屏幕宽度和高度。',
            ),
            SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: '示例输入框',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: null, child: Text('取消')),
                SizedBox(width: 8),
                ElevatedButton(onPressed: null, child: Text('确定')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 带图标和副标题的浮动窗口
  void _showFloatingWindowWithIcon(BuildContext context) {
    FloatingWindow.show(
      context,
      title: '设置管理',
      subtitle: '配置应用程序设置和首选项',
      icon: Icons.settings,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingItem('通知', Icons.notifications, true),
            _buildSettingItem('深色模式', Icons.dark_mode, false),
            _buildSettingItem('自动保存', Icons.save, true),
            _buildSettingItem('数据同步', Icons.sync, false),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, bool value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: (bool newValue) {
          // 设置切换逻辑
        },
      ),
    );
  }

  /// 自定义尺寸的浮动窗口
  void _showCustomSizeFloatingWindow(BuildContext context) {
    FloatingWindow.show(
      context,
      title: '小型对话框',
      icon: Icons.info,
      widthRatio: 0.6, // 60%宽度
      heightRatio: 0.4, // 40%高度
      minSize: const Size(400, 300), // 最小尺寸
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              '操作成功',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('您的操作已成功完成', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// 带操作按钮的浮动窗口
  void _showFloatingWindowWithActions(BuildContext context) {
    FloatingWindow.show(
      context,
      title: '文件管理',
      icon: Icons.folder,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('刷新操作')));
          },
          tooltip: '刷新',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('设置操作')));
          },
          tooltip: '设置',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text('文件 ${index + 1}.txt'),
                    subtitle: Text('${(index + 1) * 1024} bytes'),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('新建文件')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('上传')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 可拖拽的浮动窗口
  void _showDraggableFloatingWindow(BuildContext context) {
    FloatingWindow.show(
      context,
      title: '可拖拽窗口',
      subtitle: '拖拽标题栏可移动窗口',
      icon: Icons.open_with,
      draggable: true,
      widthRatio: 0.7,
      heightRatio: 0.6,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '拖拽功能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '这个窗口支持拖拽移动。您可以点击并拖拽标题栏来移动窗口位置。'
              '窗口会自动限制在屏幕边界内，但允许部分内容移出屏幕边缘。',
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使用提示：',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text('• 点击标题栏并拖拽移动窗口'),
                    Text('• 窗口会保持在屏幕可见区域内'),
                    Text('• 释放鼠标完成移动操作'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 使用构建器模式的浮动窗口
  void _showFloatingWindowWithBuilder(BuildContext context) {
    FloatingWindowBuilder()
        .title('构建器模式窗口')
        .icon(Icons.build)
        .subtitle('使用链式调用配置窗口属性')
        .size(widthRatio: 0.8, heightRatio: 0.7)
        .constraints(minSize: const Size(600, 400))
        .draggable()
        .headerActions([
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('帮助信息')));
            },
            tooltip: '帮助',
          ),
        ])
        .borderRadius(20)
        .child(
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '构建器模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'FloatingWindowBuilder提供了一种优雅的方式来配置浮动窗口的各种属性。'
                  '您可以使用链式调用来设置窗口的标题、图标、尺寸、拖拽支持等功能。',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '代码示例：',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'FloatingWindowBuilder()\n'
                          '  .title("窗口标题")\n'
                          '  .icon(Icons.build)\n'
                          '  .draggable()\n'
                          '  .size(widthRatio: 0.8)\n'
                          '  .child(content)\n'
                          '  .show(context);',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .show(context);
  }

  /// 使用扩展方法的浮动窗口
  void _showFloatingWindowWithExtension(BuildContext context) {
    context.showFloatingWindow(
      title: '扩展方法窗口',
      icon: Icons.extension,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, color: Colors.orange, size: 64),
            SizedBox(height: 16),
            Text(
              '快速创建',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '使用BuildContext扩展方法可以更快速地创建简单的浮动窗口',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              'context.showFloatingWindow(\n'
              '  title: "窗口标题",\n'
              '  child: content,\n'
              ');',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
