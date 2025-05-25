import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../features/feature_registry.dart';
import '../../config/config_manager.dart';

/// 系统信息功能模块
class SystemInfoFeature implements FeatureModule {
  // 功能标识符
  static const String featureId = 'DebugMode';

  @override
  String get name => 'system_info';

  @override
  String get description => 'System Information Display';

  @override
  IconData get icon => Icons.info;

  @override
  bool get isEnabled {
    // 检查功能是否在当前平台启用
    return ConfigManager.instance.isCurrentPlatformFeatureEnabled(featureId);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return const SystemInfoWidget();
  }
}

/// 系统信息组件
class SystemInfoWidget extends StatelessWidget {
  const SystemInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, size: 24),
                const SizedBox(width: 8),
                Text(
                  'System Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Platform', _getPlatformInfo()),
            _buildInfoRow('Debug Mode', kDebugMode ? 'Yes' : 'No'),
            _buildInfoRow('Profile Mode', kProfileMode ? 'Yes' : 'No'),
            _buildInfoRow('Release Mode', kReleaseMode ? 'Yes' : 'No'),
            if (!kIsWeb) _buildInfoRow('OS', Platform.operatingSystem),
            _buildInfoRow('App Version', ConfigManager.instance.config.build.version),
            _buildInfoRow('Build Number', ConfigManager.instance.config.build.buildNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _getPlatformInfo() {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }
}
