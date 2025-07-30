// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../../../services/reactive_version/reactive_version_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

/// 响应式版本管理标签页组件
class ReactiveVersionTabBar extends StatelessWidget {
  // 静态变量来跟踪未保存的版本状态
  static bool _hasAnyUnsavedVersions = false;
  static List<String> _unsavedVersionIds = [];
  final List<ReactiveVersionState> versions;
  final String? currentVersionId;
  final Function(String versionId) onVersionSelected;
  final Function(String name) onVersionCreated;
  final Function(String versionId) onVersionDeleted;
  final bool isPreviewMode;

  const ReactiveVersionTabBar({
    super.key,
    required this.versions,
    required this.currentVersionId,
    required this.onVersionSelected,
    required this.onVersionCreated,
    required this.onVersionDeleted,
    this.isPreviewMode = false,
  });

  /// 更新未保存版本状态
  void _updateUnsavedVersionsState() {
    final unsavedVersions = versions.where((v) => v.hasUnsavedChanges).toList();
    _hasAnyUnsavedVersions = unsavedVersions.isNotEmpty;
    _unsavedVersionIds = unsavedVersions.map((v) => v.versionId).toList();
  }

  /// 获取是否有未保存的版本
  static bool get hasAnyUnsavedVersions => _hasAnyUnsavedVersions;

  /// 获取未保存的版本ID列表
  static List<String> get unsavedVersionIds => List.from(_unsavedVersionIds);

  /// 重置未保存版本状态（用于清理）
  static void resetUnsavedState() {
    _hasAnyUnsavedVersions = false;
    _unsavedVersionIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    // 更新未保存版本状态
    _updateUnsavedVersionsState();

    // 添加调试信息
    debugPrint(
      LocalizationService.instance.current.responsiveVersionTabDebug(
        versions.length,
        currentVersionId ?? 'null',
        _hasAnyUnsavedVersions,
      ),
    );

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 版本标签
          Expanded(
            child: versions.isEmpty
                ? _buildEmptyVersions(context)
                : _buildVersionTabs(context),
          ),

          // 创建版本按钮
          if (!isPreviewMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => _showCreateVersionDialog(context),
                icon: const Icon(Icons.add),
                tooltip:
                    LocalizationService.instance.current.createNewVersion_4821,
                iconSize: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyVersions(BuildContext context) {
    return Center(
      child: Text(
        LocalizationService.instance.current.noVersionAvailable_7281,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildVersionTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: versions.map((version) {
          final isSelected = version.versionId == currentVersionId;
          return _buildVersionTab(context, version, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildVersionTab(
    BuildContext context,
    ReactiveVersionState version,
    bool isSelected,
  ) {
    final isDeletable = version.versionId != 'default';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => onVersionSelected(version.versionId),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : Border.all(color: Theme.of(context).dividerColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 版本名称
                Text(
                  version.versionName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),

                // 未保存更改指示器
                if (version.hasUnsavedChanges) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.circle, size: 6, color: Colors.orange),
                ],

                // 删除按钮
                if (isDeletable && !isPreviewMode) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showDeleteVersionDialog(context, version),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateVersionDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.createNewVersion_4271),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText:
                    LocalizationService.instance.current.versionNameLabel_4821,
                hintText:
                    LocalizationService.instance.current.versionNameHint_4822,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_7421),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop();
                onVersionCreated(name);
              }
            },
            child: Text(LocalizationService.instance.current.createButton_7421),
          ),
        ],
      ),
    );
  }

  void _showDeleteVersionDialog(
    BuildContext context,
    ReactiveVersionState version,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.deleteVersion_4271),
        content: Text(
          LocalizationService.instance.current.confirmDeleteVersion(
            version.versionName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_4271),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onVersionDeleted(version.versionId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizationService.instance.current.delete_4821),
          ),
        ],
      ),
    );
  }
}
