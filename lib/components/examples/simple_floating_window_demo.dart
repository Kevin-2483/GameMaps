// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../common/floating_window.dart';
import '../../../services/notification/notification_service.dart';

import '../../services/localization_service.dart';

/// 演示如何使用浮动窗口组件的简单示例
class SimpleFloatingWindowDemo extends StatelessWidget {
  const SimpleFloatingWindowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.current.floatingWindowDemo_4271,
        ),
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
              label: Text(
                LocalizationService.instance.current.simpleWindow_7421,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _showSettingsWindow(context),
              icon: const Icon(Icons.settings),
              label: Text(
                LocalizationService.instance.current.settingsWindow_4271,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _showDraggableWindow(context),
              icon: const Icon(Icons.open_with),
              label: Text(
                LocalizationService.instance.current.draggableWindow_4271,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _showFileManagerWindow(context),
              icon: const Icon(Icons.folder),
              label: Text(
                LocalizationService.instance.current.fileManagerStyle_4821,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              LocalizationService.instance.current.floatingWindowTip_7281,
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.welcomeFloatingWidget_7421,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              LocalizationService.instance.current.floatingWindowExample_4521,
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
      title: LocalizationService.instance.current.appSettings_4821,
      subtitle: LocalizationService.instance.current.configurePreferences_5732,
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.touch_app, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.dragDemoTitle_4821,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.windowDragHint_4721 +
                  LocalizationService.instance.current.windowAutoSnapHint_4721,
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  LocalizationService.instance.current.dragToMoveHint_7281,
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
        .title(LocalizationService.instance.current.fileManager_1234)
        .icon(Icons.folder_special)
        .subtitle(LocalizationService.instance.current.vfsFilePickerStyle_4821)
        .size(widthRatio: 0.85, heightRatio: 0.8)
        .headerActions([
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.showInfoSnackBar(
                LocalizationService.instance.current.refreshFileList_4821,
              );
            },
            tooltip: LocalizationService.instance.current.refresh_4822,
          ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              context.showInfoSnackBar(
                LocalizationService.instance.current.switchView_4821,
              );
            },
            tooltip: LocalizationService.instance.current.view_4822,
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
                _buildSwitchTile(
                  LocalizationService.instance.current.pushNotifications_4821,
                  Icons.notifications,
                  _notifications,
                  (value) => setState(() => _notifications = value),
                ),
                _buildSwitchTile(
                  LocalizationService.instance.current.darkModeTitle_4721,
                  Icons.dark_mode,
                  _darkMode,
                  (value) => setState(() => _darkMode = value),
                ),
                _buildSwitchTile(
                  LocalizationService.instance.current.autoSaveSetting_7421,
                  Icons.save,
                  _autoSave,
                  (value) => setState(() => _autoSave = value),
                ),
                const SizedBox(height: 16),
                Text(
                  LocalizationService.instance.current.volumePercentage(
                    _volume.round(),
                  ),
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
                child: Text(
                  LocalizationService.instance.current.cancelButton_4271,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  LocalizationService.instance.current.saveButton_7421,
                ),
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
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LocalizationService.instance.current.breadcrumbPath,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                      ? LocalizationService.instance.current.folderLabel_5421
                      : LocalizationService.instance.current
                            .fileInfoWithSizeAndDate_5421(
                              file['size'],
                              file['date'],
                            ),
                ),
                onTap: () {
                  context.showInfoSnackBar(
                    LocalizationService.instance.current.selectedFile(
                      file['name'],
                    ),
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
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {},
                child: Text(
                  LocalizationService.instance.current.createNewFolder_4821,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  LocalizationService.instance.current.selectOption_4271,
                ),
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
    'name': LocalizationService.instance.current.documentName_4821,
    'isDirectory': true,
    'size': '',
    'date': '2024-01-15',
  },
  {
    'name': LocalizationService.instance.current.image_4821,
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
  {'name': 'assets', 'isDirectory': true, 'size': '', 'date': '2024-01-10'},
];
