import 'package:flutter/material.dart';
import '../common/floating_window.dart';

/// 演示如何使用浮动窗口组件的简单示例
class SimpleFloatingWindowDemo extends StatelessWidget {
  const SimpleFloatingWindowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('浮动窗口演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 演示按钮组
            ElevatedButton.icon(
              onPressed: () => _showSimpleWindow(context),
              icon: const Icon(Icons.window),
              label: const Text('简单窗口'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showSettingsWindow(context),
              icon: const Icon(Icons.settings),
              label: const Text('设置窗口'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showDraggableWindow(context),
              icon: const Icon(Icons.open_with),
              label: const Text('可拖拽窗口'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showFileManagerWindow(context),
              icon: const Icon(Icons.folder),
              label: const Text('文件管理器风格'),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              '点击按钮体验不同类型的浮动窗口',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示简单的浮动窗口
  void _showSimpleWindow(BuildContext context) {
    context.showFloatingWindow(
      title: '简单浮动窗口',
      icon: Icons.info,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              '欢迎使用浮动窗口组件！',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '这是一个简单的浮动窗口示例，模仿了VFS文件选择器的设计风格。',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示设置窗口
  void _showSettingsWindow(BuildContext context) {
    FloatingWindow.show(
      context,
      title: '应用设置',
      subtitle: '配置您的首选项',
      icon: Icons.settings,
      widthRatio: 0.7,
      heightRatio: 0.6,
      child: _SettingsContent(),
    );
  }

  /// 显示可拖拽窗口
  void _showDraggableWindow(BuildContext context) {
    FloatingWindow.show(
      context,
      title: '可拖拽窗口',
      subtitle: '拖拽标题栏移动窗口',
      icon: Icons.open_with,
      draggable: true,
      widthRatio: 0.6,
      heightRatio: 0.5,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.touch_app, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              '拖拽功能演示',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '您可以通过拖拽标题栏来移动这个窗口。'
              '窗口会自动保持在屏幕可见区域内。',
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '💡 提示：在标题栏区域按住鼠标并拖拽',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示模仿VFS文件管理器风格的窗口
  void _showFileManagerWindow(BuildContext context) {
    FloatingWindowBuilder()
        .title('文件管理器')
        .icon(Icons.folder_special)
        .subtitle('VFS文件选择器风格')
        .size(widthRatio: 0.85, heightRatio: 0.8)
        .headerActions([
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('刷新文件列表')),
              );
            },
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('切换视图')),
              );
            },
            tooltip: '视图',
          ),
        ])
        .child(_FileManagerContent())
        .show(context);
  }
}

/// 设置内容组件
class _SettingsContent extends StatefulWidget {
  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _autoSave = true;
  double _volume = 50.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSwitchTile('推送通知', Icons.notifications, _notifications,
                    (value) => setState(() => _notifications = value)),
                _buildSwitchTile('深色模式', Icons.dark_mode, _darkMode,
                    (value) => setState(() => _darkMode = value)),
                _buildSwitchTile('自动保存', Icons.save, _autoSave,
                    (value) => setState(() => _autoSave = value)),
                const SizedBox(height: 16),
                Text(
                  '音量: ${_volume.round()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _volume,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  onChanged: (value) => setState(() => _volume = value),
                ),
              ],
            ),
          ),
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
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// 文件管理器内容组件
class _FileManagerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 路径导航栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '/ 根目录 / 文档 / 项目文件',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 文件列表
        Expanded(
          child: ListView.builder(
            itemCount: _sampleFiles.length,
            itemBuilder: (context, index) {
              final file = _sampleFiles[index];
              return ListTile(
                leading: Icon(
                  file['isDirectory'] ? Icons.folder : Icons.insert_drive_file,
                  color: file['isDirectory'] ? Colors.amber : null,
                ),
                title: Text(file['name']),
                subtitle: Text(
                  file['isDirectory']
                      ? '文件夹'
                      : '${file['size']} • ${file['date']}',
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('选择了: ${file['name']}')),
                  );
                },
              );
            },
          ),
        ),
        
        // 底部操作栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('新建文件夹'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('选择'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 示例文件数据
final List<Map<String, dynamic>> _sampleFiles = [
  {
    'name': '文档',
    'isDirectory': true,
    'size': '',
    'date': '2024-01-15',
  },
  {
    'name': '图片',
    'isDirectory': true,
    'size': '',
    'date': '2024-01-14',
  },
  {
    'name': 'readme.txt',
    'isDirectory': false,
    'size': '2.5 KB',
    'date': '2024-01-13',
  },
  {
    'name': 'config.json',
    'isDirectory': false,
    'size': '1.2 KB',
    'date': '2024-01-12',
  },
  {
    'name': 'project.dart',
    'isDirectory': false,
    'size': '15.6 KB',
    'date': '2024-01-11',
  },
  {
    'name': 'assets',
    'isDirectory': true,
    'size': '',
    'date': '2024-01-10',
  },
];
