// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';
import '../../components/layout/main_layout.dart';
import '../../providers/user_preferences_provider.dart';
import 'widgets/theme_settings_section.dart';
import 'widgets/home_page_settings_section.dart';
import 'widgets/map_editor_settings_section.dart';
import 'widgets/layout_settings_section.dart';
import 'widgets/tool_settings_section.dart';
import 'widgets/user_management_section.dart';
import 'widgets/extension_settings_section.dart';

import '../../components/common/draggable_title_bar.dart';
import '../../../services/notification/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

class UserPreferencesPage extends BasePage {
  const UserPreferencesPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _UserPreferencesPageContent();
  }

  @override
  bool get showTrayNavigation => true; // 确保显示导航栏
}

class _UserPreferencesPageContent extends StatefulWidget {
  const _UserPreferencesPageContent();

  @override
  State<_UserPreferencesPageContent> createState() =>
      _UserPreferencesPageContentState();
}

class _UserPreferencesPageContentState
    extends State<_UserPreferencesPageContent> {
  @override
  void initState() {
    super.initState();
    // 确保在页面加载时初始化用户偏好设置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserPreferencesProvider>();
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });
  }

  Future<void> _exportSettings() async {
    try {
      final provider = context.read<UserPreferencesProvider>();
      final jsonData = await provider.exportSettings();

      // 复制到剪贴板作为备选方案
      await Clipboard.setData(ClipboardData(text: jsonData));
      if (mounted) {
        final l10n = LocalizationService.instance.current!;
        context.showSuccessSnackBar(
          '${l10n.settingsExported} (${LocalizationService.instance.current.copiedToClipboard_4821})',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          LocalizationService.instance.current.exportFailed_7285(e.toString()),
        );
      }
    }
  }

  Future<void> _importSettings() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final jsonData = String.fromCharCodes(result.files.single.bytes!);
        final provider = context.read<UserPreferencesProvider>();
        await provider.importSettings(jsonData);

        if (mounted) {
          final l10n = LocalizationService.instance.current!;
          context.showSuccessSnackBar(l10n.settingsImported);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = LocalizationService.instance.current!;
        context.showErrorSnackBar(l10n.importFailed(e.toString()));
      }
    }
  }

  Future<void> _resetSettings() async {
    final l10n = LocalizationService.instance.current!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.confirmResetSettings),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.resetSettings),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final provider = context.read<UserPreferencesProvider>();
        await provider.resetToDefaults();

        if (mounted) {
          context.showSuccessSnackBar(l10n.settingsReset);
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(
            LocalizationService.instance.current.resetFailedWithError(
              e.toString(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.instance.current!;

    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(
            title: l10n.userPreferences,
            icon: Icons.tune,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'export':
                      _exportSettings();
                      break;
                    case 'import':
                      _importSettings();
                      break;
                    case 'reset':
                      _resetSettings();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        const Icon(Icons.download),
                        const SizedBox(width: 8),
                        Text(l10n.exportSettings),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        const Icon(Icons.upload),
                        const SizedBox(width: 8),
                        Text(l10n.importSettings),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        const Icon(Icons.restore, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          LocalizationService
                              .instance
                              .current
                              .resetAllSettings_4821,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 内容区域
          Expanded(
            child: Consumer<UserPreferencesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          LocalizationService.instance.current
                              .loadUserPreferencesFailed(provider.error.toString()),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.initialize(),
                          child: Text(
                            LocalizationService.instance.current.retry_7281,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // 主题设置
                    ThemeSettingsSection(
                      preferences: provider.currentPreferences!,
                    ),
                    const SizedBox(height: 16),

                    // 主页设置
                    HomePageSettingsSection(
                      preferences: provider.currentPreferences!,
                    ),
                    const SizedBox(height: 16),

                    // 地图编辑器设置
                    MapEditorSettingsSection(
                      preferences: provider.currentPreferences!,
                    ),
                    const SizedBox(height: 16),

                    // 界面布局设置
                    LayoutSettingsSection(
                      preferences: provider.currentPreferences!,
                    ),
                    const SizedBox(height: 16),

                    // 工具设置
                    ToolSettingsSection(
                      preferences: provider.currentPreferences!,
                    ),
                    const SizedBox(height: 16),

                    // 扩展设置
                    ExtensionSettingsSection(
                      preferences: provider.currentPreferences!,
                    ),
                    const SizedBox(height: 16),

                    // 用户管理
                    UserManagementSection(
                      preferences: provider.currentPreferences!,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
