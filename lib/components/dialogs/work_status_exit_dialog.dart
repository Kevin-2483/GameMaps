// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../../services/work_status_service.dart';

import '../../services/localization_service.dart';

/// 工作状态退出确认对话框
/// 当应用处于工作状态时，用户尝试关闭应用会显示此对话框
class WorkStatusExitDialog extends StatelessWidget {
  final String workDescription;
  final VoidCallback? onForceExit;
  final VoidCallback? onCancel;

  const WorkStatusExitDialog({
    super.key,
    required this.workDescription,
    this.onForceExit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(LocalizationService.instance.current.programWorking_1234),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.instance.current.currentOperation_7281,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              workDescription.isNotEmpty
                  ? workDescription
                  : LocalizationService.instance.current.unknownTask_7421,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            LocalizationService.instance.current.forceExitWarning_4821,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(LocalizationService.instance.current.cancelButton_7421),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onForceExit?.call();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(LocalizationService.instance.current.confirmExit_7284),
        ),
      ],
    );
  }

  /// 显示工作状态退出确认对话框
  /// 返回 true 表示用户选择强制退出，false 表示取消
  static Future<bool?> show(
    BuildContext context, {
    String? workDescription,
    VoidCallback? onForceExit,
    VoidCallback? onCancel,
  }) {
    final workStatusService = WorkStatusService();
    final description = workDescription ?? workStatusService.workDescription;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 不允许点击外部关闭
      builder: (context) => WorkStatusExitDialog(
        workDescription: description,
        onForceExit: onForceExit,
        onCancel: onCancel,
      ),
    );
  }
}
