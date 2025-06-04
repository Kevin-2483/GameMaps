import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../components/layout/main_layout.dart';

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 标题区域（移除了AppBar）
            Text(
              l10n.settings,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildUserPreferencesSection(context, l10n),
            const SizedBox(height: 16),
            _buildResourceSection(context, l10n),
          ],
        ),
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
}
