import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config/config_manager.dart';
import '../platform/windows/windows_component.dart';
import '../platform/macos/macos_component.dart';
import '../platform/linux/linux_component.dart';
import '../platform/android/android_component.dart';
import '../platform/ios/ios_component.dart';
import '../platform/web/web_component.dart';

class PlatformAwareComponent extends StatelessWidget {
  const PlatformAwareComponent({super.key});
  @override
  Widget build(BuildContext context) {
    final configManager = ConfigManager.instance;
    final currentPlatform = configManager.getCurrentPlatform();
    
    // 检查当前平台是否在配置中启用
    if (!configManager.isPlatformConfigured(currentPlatform)) {
      return _buildDefaultComponent(context);
    }
    
    // 根据当前平台返回对应组件
    switch (currentPlatform) {
      case 'Windows':
        return const WindowsComponent();
      case 'MacOS':
        return const MacOSComponent();
      case 'Linux':
        return const LinuxComponent();
      case 'Android':
        return const AndroidComponent();
      case 'iOS':
        return const IOSComponent();
      case 'Web':
        return const WebComponent();
      default:
        return _buildDefaultComponent(context);
    }
  }

  Widget _buildDefaultComponent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Platform: ${defaultTargetPlatform.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This platform is not configured or enabled.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
