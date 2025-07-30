// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../common/floating_window.dart';
import '../../../services/notification/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// 浮动窗口使用示例
class FloatingWindowExamples extends StatelessWidget {
  const FloatingWindowExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.current.floatingWindowExample_4271,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 基础浮动窗口示例
            _buildExampleCard(
              context,
              title: LocalizationService
                  .instance
                  .current
                  .basicFloatingWindowTitle_4821,
              description: LocalizationService
                  .instance
                  .current
                  .basicFloatingWindowDescription_4821,
              onPressed: () => _showBasicFloatingWindow(context),
            ),

            const SizedBox(height: 16),

            // 带图标和副标题的浮动窗口
            _buildExampleCard(
              context,
              title: LocalizationService
                  .instance
                  .current
                  .cardWithIconAndSubtitle_4821,
              description: LocalizationService
                  .instance
                  .current
                  .floatingWindowWithIconAndTitle_4821,
              onPressed: () => _showFloatingWindowWithIcon(context),
            ),

            const SizedBox(height: 16),

            // 自定义尺寸的浮动窗口
            _buildExampleCard(
              context,
              title: LocalizationService.instance.current.customSizeTitle_4821,
              description: LocalizationService
                  .instance
                  .current
                  .customSizeDescription_4821,
              onPressed: () => _showCustomSizeFloatingWindow(context),
            ),

            const SizedBox(height: 16),

            // 带操作按钮的浮动窗口
            _buildExampleCard(
              context,
              title: LocalizationService
                  .instance
                  .current
                  .cardWithActionsTitle_4821,
              description: LocalizationService
                  .instance
                  .current
                  .floatingWindowWithActionsDesc_4821,
              onPressed: () => _showFloatingWindowWithActions(context),
            ),

            const SizedBox(height: 16),

            // 可拖拽的浮动窗口
            _buildExampleCard(
              context,
              title: LocalizationService
                  .instance
                  .current
                  .draggableWindowTitle_4821,
              description: LocalizationService
                  .instance
                  .current
                  .draggableWindowDescription_4821,
              onPressed: () => _showDraggableFloatingWindow(context),
            ),

            const SizedBox(height: 16),

            // 使用构建器模式
            _buildExampleCard(
              context,
              title:
                  LocalizationService.instance.current.builderPatternTitle_3821,
              description: LocalizationService
                  .instance
                  .current
                  .builderPatternDescription_3821,
              onPressed: () => _showFloatingWindowWithBuilder(context),
            ),

            const SizedBox(height: 16),

            // 使用扩展方法
            _buildExampleCard(
              context,
              title: LocalizationService
                  .instance
                  .current
                  .extensionMethodsTitle_4821,
              description: LocalizationService
                  .instance
                  .current
                  .extensionMethodsDescription_4821,
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
                child: Text(LocalizationService.instance.current.demoText_4271),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService
                  .instance
                  .current
                  .basicFloatingWindowExample_4821,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text(
              LocalizationService
                      .instance
                      .current
                      .windowContentDescription_4821 +
                  LocalizationService
                      .instance
                      .current
                      .windowSizeDescription_5739,
            ),
            SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText:
                    LocalizationService.instance.current.exampleInputField_4521,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: null,
                  child: Text(
                    LocalizationService.instance.current.cancelButton_7284,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: null,
                  child: Text(
                    LocalizationService.instance.current.confirmButton_4821,
                  ),
                ),
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
            _buildSettingItem(
              LocalizationService.instance.current.notifications_4821,
              Icons.notifications,
              true,
            ),
            _buildSettingItem(
              LocalizationService.instance.current.darkMode_7285,
              Icons.dark_mode,
              false,
            ),
            _buildSettingItem(
              LocalizationService.instance.current.autoSave_7421,
              Icons.save,
              true,
            ),
            _buildSettingItem(
              LocalizationService.instance.current.dataSync_7284,
              Icons.sync,
              false,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    LocalizationService.instance.current.cancelButton_7281,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.operationSuccess_4821,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              LocalizationService
                  .instance
                  .current
                  .operationCompletedSuccessfully_7281,
              style: TextStyle(color: Colors.grey),
            ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocalizationService.instance.current.refreshOperation_7284,
                ),
              ),
            );
          },
          tooltip: '刷新',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocalizationService.instance.current.settingsOperation_4251,
                ),
              ),
            );
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
                    title: Text(
                      '${LocalizationService.instance.current.fileNameWithIndex(index + 1)}',
                    ),
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
                OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    LocalizationService.instance.current.createNewFile_7281,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    LocalizationService.instance.current.uploadButton_7284,
                  ),
                ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.dragFeature_4521,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.windowDragHint_4821 +
                  LocalizationService.instance.current.windowBoundaryHint_4821,
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.instance.current.usageHint_4521,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .clickAndDragWindowTitle_4821,
                    ),
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .windowStayVisibleArea_4821,
                    ),
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .releaseMouseToCompleteMove_7281,
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

  /// 使用构建器模式的浮动窗口
  void _showFloatingWindowWithBuilder(BuildContext context) {
    FloatingWindowBuilder()
        .title(LocalizationService.instance.current.builderPatternWindow_4821)
        .icon(Icons.build)
        .subtitle(
          LocalizationService.instance.current.windowConfigChainCall_7284,
        )
        .size(widthRatio: 0.8, heightRatio: 0.7)
        .constraints(minSize: const Size(600, 400))
        .draggable()
        .headerActions([
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              context.showInfoSnackBar(
                LocalizationService.instance.current.helpInfo_4821,
              );
            },
            tooltip: LocalizationService.instance.current.help_5732,
          ),
        ])
        .borderRadius(20)
        .child(
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationService.instance.current.builderPattern_4821,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  LocalizationService
                      .instance
                      .current
                      .floatingWindowBuilderDescription_4821,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationService.instance.current.codeExample_7281,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'FloatingWindowBuilder()\n'
                          '  .title("${LocalizationService.instance.current.windowTitle_7421}")\n'
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, color: Colors.orange, size: 64),
            SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.quickCreate_7421,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              LocalizationService
                  .instance
                  .current
                  .buildContextExtensionTip_7281,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              'context.showFloatingWindow(\n'
              '  title: LocalizationService.instance.current.windowTitle_7281,\n'
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
