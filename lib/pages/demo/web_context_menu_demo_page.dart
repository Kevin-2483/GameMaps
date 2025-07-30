// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../components/web/web_context_menu_handler.dart';
import '../../components/layout/main_layout.dart';
import '../../../services/notification/notification_service.dart';
import '../../services/localization_service.dart';

/// Web右键菜单测试页面
class WebContextMenuDemoPage extends BasePage {
  const WebContextMenuDemoPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _WebContextMenuDemoContent();
  }
}

class _WebContextMenuDemoContent extends StatefulWidget {
  const _WebContextMenuDemoContent();

  @override
  State<_WebContextMenuDemoContent> createState() =>
      _WebContextMenuDemoContentState();
}

class _WebContextMenuDemoContentState
    extends State<_WebContextMenuDemoContent> {
  int _selectedItemIndex = -1;
  final List<String> _items = List.generate(
    10,
    (index) => LocalizationService.instance.current.projectItem(index + 1),
  );

  @override
  Widget build(BuildContext context) {
    return WebContextMenuHandler(
      preventWebContextMenu: kIsWeb,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocalizationService.instance.current.webRightClickDemo_4821,
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文字
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationService
                            .instance
                            .current
                            .webPlatformRightClickMenuDescription_4821,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocalizationService.instance.current.currentPlatform(
                          kIsWeb
                              ? LocalizationService
                                    .instance
                                    .current
                                    .webBrowser_5732
                              : LocalizationService
                                    .instance
                                    .current
                                    .desktopMobile_6943,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kIsWeb ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocalizationService
                                .instance
                                .current
                                .webPlatformFeatures_4821 +
                            '\n' +
                            LocalizationService
                                .instance
                                .current
                                .browserContextMenuDisabled_4821 +
                            '\n' +
                            LocalizationService
                                .instance
                                .current
                                .flutterCustomContextMenu_4821 +
                            '\n' +
                            LocalizationService
                                .instance
                                .current
                                .consistentDesktopExperience_4821 +
                            '\n\n' +
                            LocalizationService
                                .instance
                                .current
                                .desktopMobilePlatforms_4821 +
                            '\n' +
                            LocalizationService
                                .instance
                                .current
                                .nativeContextMenuStyle_4821 +
                            '\n' +
                            LocalizationService
                                .instance
                                .current
                                .nativeInteractionExperience_4821,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 演示区域
              Expanded(
                child: Row(
                  children: [
                    // 左侧：简单右键菜单演示
                    Expanded(child: _buildSimpleDemo()),
                    const SizedBox(width: 16),

                    // 右侧：列表右键菜单演示
                    Expanded(child: _buildListDemo()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.simpleRightClickMenu_7281,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // 可右键的区域
            Expanded(
              child: ContextMenuWrapper(
                menuBuilder: (context) => [
                  ContextMenuItem(
                    label: '新建',
                    icon: Icons.add,
                    onTap: () => _showMessage(
                      LocalizationService
                          .instance
                          .current
                          .createNewProject_7281,
                    ),
                  ),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.open_7281,
                    icon: Icons.folder_open,
                    onTap: () => _showMessage(
                      LocalizationService.instance.current.openFile_7282,
                    ),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.copy_4821,
                    icon: Icons.copy,
                    onTap: () => _showMessage(
                      LocalizationService.instance.current.copiedMessage_7532,
                    ),
                  ),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.paste_4821,
                    icon: Icons.paste,
                    onTap: () => _showMessage(
                      LocalizationService.instance.current.pastedMessage_4821,
                    ),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.properties_4821,
                    icon: Icons.settings,
                    onTap: () => _showMessage(
                      LocalizationService.instance.current.showProperties_4821,
                    ),
                  ),
                ],
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mouse, size: 48),
                        SizedBox(height: 8),
                        Text(
                          LocalizationService
                              .instance
                              .current
                              .rightClickHere_7281,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          LocalizationService
                              .instance
                              .current
                              .tryRightClickMenu_4821,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.listItemContextMenu_4821,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // 列表
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isSelected = _selectedItemIndex == index;

                  return ContextMenuWrapper(
                    menuBuilder: (context) => [
                      ContextMenuItem(
                        label: '查看详情',
                        icon: Icons.visibility,
                        onTap: () => _showMessage(
                          LocalizationService.instance.current
                              .viewItemDetails_7421(item),
                        ),
                      ),
                      ContextMenuItem(
                        label:
                            LocalizationService.instance.current.editLabel_5421,
                        icon: Icons.edit,
                        onTap: () => _showMessage(
                          LocalizationService.instance.current
                              .editItemMessage_5421(item),
                        ),
                      ),
                      ContextMenuItem(
                        label: LocalizationService.instance.current.rename_7421,
                        icon: Icons.edit,
                        onTap: () => _showRenameDialog(index),
                      ),
                      const ContextMenuItem.divider(),
                      ContextMenuItem(
                        label: LocalizationService.instance.current.copy_4821,
                        icon: Icons.copy,
                        onTap: () => _copyItem(index),
                      ),
                      ContextMenuItem(
                        label: '移动',
                        icon: Icons.move_up,
                        onTap: () => _showMessage(
                          LocalizationService.instance.current.moveItem_7421(
                            item,
                          ),
                        ),
                      ),
                      const ContextMenuItem.divider(),
                      ContextMenuItem(
                        label: LocalizationService.instance.current.delete_7281,
                        icon: Icons.delete,
                        onTap: () => _deleteItem(index),
                      ),
                    ],
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        selected: isSelected,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        title: Text(item),
                        subtitle: Text(
                          LocalizationService.instance.current
                              .rightClickOptionsWithMode_7421(
                                kIsWeb
                                    ? LocalizationService
                                          .instance
                                          .current
                                          .webMode_1589
                                    : LocalizationService
                                          .instance
                                          .current
                                          .desktopMode_2634,
                              ),
                        ),
                        trailing: const Icon(Icons.more_vert),
                        onTap: () {
                          setState(() {
                            _selectedItemIndex = index;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    context.showInfoSnackBar(message);
  }

  void _copyItem(int index) {
    setState(() {
      _items.insert(
        index + 1,
        '${_items[index]} ' +
            LocalizationService.instance.current.copySuffix_7281,
      );
    });
    _showMessage(LocalizationService.instance.current.projectCopied_4821);
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.confirmDelete_7281),
        content: Text(
          LocalizationService.instance.current.confirmDeleteItem_7421(
            _items[index],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_7421),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _items.removeAt(index);
                if (_selectedItemIndex == index) {
                  _selectedItemIndex = -1;
                } else if (_selectedItemIndex > index) {
                  _selectedItemIndex--;
                }
              });
              _showMessage(
                LocalizationService.instance.current.projectDeleted_7281,
              );
            },
            child: Text(LocalizationService.instance.current.delete_4821),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(int index) {
    final TextEditingController controller = TextEditingController(
      text: _items[index],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.rename_4821),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: LocalizationService.instance.current.newNameLabel_4521,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_7281),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _items[index] = controller.text.trim();
                });
                _showMessage(
                  LocalizationService.instance.current.renamedSuccessfully_7281,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(
              LocalizationService.instance.current.confirmButton_7281,
            ),
          ),
        ],
      ),
    );
  }
}
