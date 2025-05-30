import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../providers/theme_provider.dart';

class ThemeSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const ThemeSettingsSection({super.key, required this.preferences});

  // 将字符串主题模式转换为 AppThemeMode 枚举
  AppThemeMode _getThemeModeFromString(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  // 将 AppThemeMode 枚举转换为字符串
  String _getStringFromThemeMode(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<UserPreferencesProvider>();
    final currentThemeMode = _getThemeModeFromString(
      preferences.theme.themeMode,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.theme,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 主题模式选择
            Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<AppThemeMode>(
              segments: [
                ButtonSegment(
                  value: AppThemeMode.light,
                  label: Text(l10n.lightMode),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  label: Text(l10n.darkMode),
                  icon: const Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text(l10n.systemMode),
                  icon: const Icon(Icons.settings),
                ),
              ],
              selected: {currentThemeMode},
              onSelectionChanged: (Set<AppThemeMode> selected) {
                final selectedMode = _getStringFromThemeMode(selected.first);
                provider.updateTheme(themeMode: selectedMode);
              },
            ),

            const SizedBox(height: 16),

            // 主色调选择
            Text('主色调', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                        Colors.blue,
                        Colors.green,
                        Colors.purple,
                        Colors.red,
                        Colors.orange,
                        Colors.teal,
                        Colors.indigo,
                        Colors.pink,
                      ]
                      .map(
                        (color) => _ColorButton(
                          color: color,
                          isSelected:
                              preferences.theme.primaryColor == color.value,
                          onTap: () =>
                              provider.updateTheme(primaryColor: color.value),
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 16),

            // Material You 设置
            SwitchListTile(
              title: Text('Material You'),
              subtitle: Text('使用系统颜色主题'),
              value: preferences.theme.useMaterialYou,
              onChanged: (value) => provider.updateTheme(useMaterialYou: value),
            ),

            const SizedBox(height: 8),

            // 字体大小设置
            Text('字体大小', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Slider(
              value: preferences.theme.fontScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: '${(preferences.theme.fontScale * 100).round()}%',
              onChanged: (value) => provider.updateTheme(fontScale: value),
            ),

            const SizedBox(height: 8),

            // 高对比度设置
            SwitchListTile(
              title: Text('高对比度'),
              subtitle: Text('提高文本和背景的对比度'),
              value: preferences.theme.highContrast,
              onChanged: (value) => provider.updateTheme(highContrast: value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                )
              : Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
