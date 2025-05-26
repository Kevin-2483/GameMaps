import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class WindowsComponent extends StatelessWidget {
  const WindowsComponent({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.desktop_windows,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.windowsPlatform,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.windowsSpecificFeatures,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(l10n.windowsFeatures),
                  const SizedBox(height: 8),
                  _buildFeatureItem(l10n.nativeWindowsUI),
                  _buildFeatureItem(l10n.fileSystemAccess),
                  _buildFeatureItem(l10n.systemTrayIntegration),
                  _buildFeatureItem(l10n.windowsNotifications),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(feature),
        ],
      ),
    );
  }
}
