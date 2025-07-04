import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../components/layout/main_layout.dart';
import '../../components/common/draggable_title_bar.dart';

class SettingsPage extends BasePage {
  const SettingsPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _SettingsPageContent();
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(
            title: l10n.settings,
            icon: Icons.settings,
          ),
          Expanded(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildUserPreferencesSection(context, l10n),
                  const SizedBox(height: 16),
                  _buildResourceSection(context, l10n),
                  const SizedBox(height: 16),
                  _buildAboutSection(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPreferencesSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.userPreferences,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.tune),
              title: Text(l10n.userPreferences),
              subtitle: Text('管理主题、地图编辑器、界面布局等个人设置'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go('/user-preferences'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.resourceManagement,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text('外部资源管理'),
              subtitle: const Text('导入、导出和浏览应用数据'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go('/external-resources'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关于',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于 R6BOX'),
              subtitle: const Text('软件信息、许可证和开源项目致谢'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go('/about'),
            ),
          ],
        ),
      ),
    );
  }
}
