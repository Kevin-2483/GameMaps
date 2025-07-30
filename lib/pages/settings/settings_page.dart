// This file has been processed by AI for internationalization
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';
import '../../components/layout/main_layout.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

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
    final l10n = LocalizationService.instance.current!;

    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(title: l10n.settings, icon: Icons.settings),
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
              subtitle: Text(
                LocalizationService
                    .instance
                    .current
                    .personalSettingsManagement_4821,
              ),
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
              title: Text(
                LocalizationService
                    .instance
                    .current
                    .externalResourceManagement_7421,
              ),
              subtitle: Text(
                LocalizationService
                    .instance
                    .current
                    .importExportBrowseData_4821,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go('/external-resources'),
            ),
            const Divider(),
            // WebDAV管理 - 仅在非web平台显示
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.cloud),
                title: Text(
                  LocalizationService.instance.current.webDavManagement_4271,
                ),
                subtitle: Text(
                  LocalizationService.instance.current.webDavConfigTitle_7281,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/webdav-manager'),
              ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: Text(
                LocalizationService
                    .instance
                    .current
                    .websocketConnectionManagement_4821,
              ),
              subtitle: Text(
                LocalizationService.instance.current.websocketClientConfig_4821,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go('/websocket-manager'),
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
              LocalizationService.instance.current.about_5421,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(LocalizationService.instance.current.aboutR6box_7281),
              subtitle: Text(
                LocalizationService
                    .instance
                    .current
                    .softwareInfoLicenseAcknowledgements_4821,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go('/about'),
            ),
          ],
        ),
      ),
    );
  }
}
