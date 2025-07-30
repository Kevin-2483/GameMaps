// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../services/localization_service.dart';

/// Web平台只读模式提示组件
class WebReadOnlyBanner extends StatelessWidget {
  final Widget child;
  final bool showBanner;

  const WebReadOnlyBanner({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBanner) {
      return child;
    }

    return Banner(
      message: LocalizationService.instance.current.readOnlyMode_4821,
      location: BannerLocation.topEnd,
      color: Colors.orange.withValues(alpha: 0.8),
      child: child,
    );
  }
}

/// Web平台只读模式提示对话框
class WebReadOnlyDialog {
  static void show(BuildContext context, String operation) {
    if (!kIsWeb) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.orange),
            const SizedBox(width: 8),
            Text(LocalizationService.instance.current.readOnlyMode_7421),
          ],
        ),
        content: Text(
          LocalizationService.instance.current
              .webReadOnlyModeWithOperation_7421(operation),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.learnMore_7421),
          ),
        ],
      ),
    );
  }
}

/// Web平台功能限制提示组件
class WebFeatureRestriction extends StatelessWidget {
  final Widget child;
  final String operationName;
  final bool enabled;

  const WebFeatureRestriction({
    super.key,
    required this.child,
    required this.operationName,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || enabled) {
      return child;
    }

    return GestureDetector(
      onTap: () => WebReadOnlyDialog.show(context, operationName),
      child: Opacity(
        opacity: 0.6,
        child: IgnorePointer(ignoring: true, child: child),
      ),
    );
  }
}
