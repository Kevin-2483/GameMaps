import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
    if (!kIsWeb || !showBanner) {
      return child;
    }

    return Banner(
      message: '只读模式',
      location: BannerLocation.topEnd,
      color: Colors.orange.withOpacity(0.8),
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
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 8),
            Text('只读模式'),
          ],
        ),
        content: Text('Web版本为只读模式，无法执行"$operation"操作。\n\n如需编辑功能，请使用桌面版本。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
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
        child: IgnorePointer(
          ignoring: true,
          child: child,
        ),
      ),
    );
  }
}
