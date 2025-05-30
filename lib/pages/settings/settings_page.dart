import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../components/layout/main_layout.dart';
import '../../services/map_database_service.dart';

class SettingsPage extends BasePage {
  const SettingsPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _SettingsPageContent();
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();
  Future<void> _updateExternalResources(BuildContext context) async {
    try {
      final success = await MapDatabaseService().updateExternalResources();
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? l10n.updateSuccessful
                  : l10n.updateFailed('Unknown error'),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            ),            const SizedBox(height: 24),
            _buildUserPreferencesSection(context, l10n),
            const SizedBox(height: 16),
            _buildThemeSection(context, l10n),
            const SizedBox(height: 16),
            _buildLanguageSection(context, l10n),
            const SizedBox(height: 16),
            _buildResourceSection(context, l10n),
          ],
        ),
      ),
    );  }

  Widget _buildUserPreferencesSection(BuildContext context, AppLocalizations l10n) {
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

  static Widget _buildThemeSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    RadioListTile<AppThemeMode>(
                      title: Text(l10n.lightMode),
                      value: AppThemeMode.light,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setThemeMode(value);
                        }
                      },
                    ),
                    RadioListTile<AppThemeMode>(
                      title: Text(l10n.darkMode),
                      value: AppThemeMode.dark,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setThemeMode(value);
                        }
                      },
                    ),
                    RadioListTile<AppThemeMode>(
                      title: Text(l10n.systemMode),
                      value: AppThemeMode.system,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setThemeMode(value);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLanguageSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return Column(
                  children: [
                    RadioListTile<Locale?>(
                      title: Text(l10n.systemLanguage),
                      value: null,
                      groupValue: localeProvider.locale,
                      onChanged: (value) {
                        localeProvider.setLocale(value);
                      },
                    ),
                    ...LocaleProvider.supportedLocales.map(
                      (locale) => RadioListTile<Locale?>(
                        title: Text(localeProvider.getLanguageName(locale)),
                        value: locale,
                        groupValue: localeProvider.locale,
                        onChanged: (value) {
                          localeProvider.setLocale(value);
                        },
                      ),
                    ),
                  ],
                );
              },
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
              leading: const Icon(Icons.cloud_download),
              title: Text(l10n.updateExternalResources),
              subtitle: Text(l10n.updateExternalResourcesDescription),
              onTap: () => _updateExternalResources(context),
            ),
          ],
        ),
      ),
    );
  }
}
