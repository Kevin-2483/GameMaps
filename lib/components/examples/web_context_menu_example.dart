// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../web/web_context_menu_handler.dart';
import '../../../services/notification/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// Web兼容的右键菜单组件示例
/// 用于演示如何在Web平台上实现与客户端一致的右键菜单体验
class WebCompatibleContextMenuExample extends StatelessWidget {
  const WebCompatibleContextMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return WebContextMenuHandler(
      preventWebContextMenu: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocalizationService.instance.current.webContextMenuExample_7281,
          ),
        ),
        body: Padding(
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
              const SizedBox(height: 16),
              Text(
                LocalizationService
                    .instance
                    .current
                    .webPlatformMenuDescription_4821,
              ),
              const SizedBox(height: 24),

              // 示例1：简单的右键菜单
              _buildContextMenuExample1(context),
              const SizedBox(height: 16),

              // 示例2：复杂的右键菜单
              _buildContextMenuExample2(context),
              const SizedBox(height: 16),

              // 示例3：列表项右键菜单
              _buildContextMenuExample3(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextMenuExample1(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.exampleRightClickMenu_4821,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ContextMenuWrapper(
              menuBuilder: (context) => [
                ContextMenuItem(
                  label: LocalizationService.instance.current.copy_4821,
                  icon: Icons.copy,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.copiedMessage_7421,
                  ),
                ),
                ContextMenuItem(
                  label: LocalizationService.instance.current.paste_4821,
                  icon: Icons.paste,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.pasted_4822,
                  ),
                ),
                const ContextMenuItem.divider(),
                ContextMenuItem(
                  label: LocalizationService.instance.current.delete_4821,
                  icon: Icons.delete,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.deletedMessage_7421,
                  ),
                ),
              ],
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    LocalizationService
                        .instance
                        .current
                        .rightClickHereHint_4821,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuExample2(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.imageEditMenuTitle_7421,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ContextMenuWrapper(
              menuBuilder: (context) => [
                ContextMenuItem(
                  label: LocalizationService.instance.current.editLabel_4521,
                  icon: Icons.edit,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.openEditorMessage_4521,
                  ),
                ),
                ContextMenuItem(
                  label: LocalizationService.instance.current.rotate_4822,
                  icon: Icons.rotate_right,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.imageRotated_4821,
                  ),
                ),
                ContextMenuItem(
                  label: LocalizationService.instance.current.zoom_4821,
                  icon: Icons.zoom_in,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.zoomImage_4821,
                  ),
                ),
                const ContextMenuItem.divider(),
                ContextMenuItem(
                  label: LocalizationService.instance.current.saveAs_7421,
                  icon: Icons.save_as,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.saveAs_7421,
                  ),
                ),
                ContextMenuItem(
                  label: LocalizationService.instance.current.exportLabel_7421,
                  icon: Icons.file_download,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.exporting_7421,
                  ),
                ),
                const ContextMenuItem.divider(),
                ContextMenuItem(
                  label: LocalizationService.instance.current.properties_4281,
                  icon: Icons.info,
                  onTap: () => _showSnackBar(
                    context,
                    LocalizationService.instance.current.showProperties_4281,
                  ),
                ),
              ],
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        LocalizationService
                            .instance
                            .current
                            .imageEditAreaRightClickOptions_4821,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuExample3(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.example3ListItemMenu_7421,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...List.generate(3, (index) {
              return ContextMenuWrapper(
                menuBuilder: (context) => [
                  ContextMenuItem(
                    label:
                        LocalizationService.instance.current.viewDetails_4821,
                    icon: Icons.visibility,
                    onTap: () => _showSnackBar(
                      context,
                      LocalizationService.instance.current.viewProjectDetails(
                        index + 1,
                      ),
                    ),
                  ),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.editLabel_4821,
                    icon: Icons.edit,
                    onTap: () => _showSnackBar(
                      context,
                      LocalizationService.instance.current.editItemMessage_4821(
                        index + 1,
                      ),
                    ),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.copyLink_4821,
                    icon: Icons.link,
                    onTap: () => _showSnackBar(
                      context,
                      LocalizationService.instance.current.copiedProjectLink(
                        index + 1,
                      ),
                    ),
                  ),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.share_4821,
                    icon: Icons.share,
                    onTap: () => _showSnackBar(
                      context,
                      LocalizationService.instance.current.shareProject(
                        index + 1,
                      ),
                    ),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: LocalizationService.instance.current.delete_4821,
                    icon: Icons.delete,
                    onTap: () => _showSnackBar(
                      context,
                      LocalizationService.instance.current.deleteItem_4822(
                        index + 1,
                      ),
                    ),
                  ),
                ],
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    LocalizationService.instance.current.listItemTitle(
                      index + 1,
                    ),
                  ),
                  subtitle: Text(
                    LocalizationService.instance.current.rightClickOptions_4821,
                  ),
                  trailing: const Icon(Icons.more_vert),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    context.showInfoSnackBar(message);
  }
}
