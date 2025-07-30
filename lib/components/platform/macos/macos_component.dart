import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

class MacOSComponent extends StatelessWidget {
  const MacOSComponent({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.instance.current!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.laptop_mac,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.macOSPlatform,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.macOSSpecificFeatures,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(l10n.macOSFeatures),
                  const SizedBox(height: 8),
                  _buildFeatureItem(l10n.nativeMacOSUI),
                  _buildFeatureItem(l10n.menuBarIntegration),
                  _buildFeatureItem(l10n.touchBarSupport),
                  _buildFeatureItem(l10n.macOSNotifications),
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
