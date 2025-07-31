// This file has been processed by AI for internationalization
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/new_reactive_script_manager.dart';
import '../../../models/script_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

/// 脚本状态监控组件
/// 显示详细的脚本执行状态、线程信息和系统指标
class ScriptStatusMonitor extends StatefulWidget {
  final NewReactiveScriptManager scriptManager;
  final bool showDetailed;

  const ScriptStatusMonitor({
    super.key,
    required this.scriptManager,
    this.showDetailed = false,
  });

  @override
  State<ScriptStatusMonitor> createState() => _ScriptStatusMonitorState();
}

class _ScriptStatusMonitorState extends State<ScriptStatusMonitor>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.scriptManager,
      builder: (context, child) {
        return widget.showDetailed
            ? _buildDetailedStatus()
            : _buildCompactStatus();
      },
    );
  }

  /// 构建详细状态视图
  Widget _buildDetailedStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 16),
            _buildSystemMetrics(),
            const SizedBox(height: 16),
            _buildRunningScripts(),
            const SizedBox(height: 16),
            _buildRecentExecutions(),
          ],
        ),
      ),
    );
  }

  /// 构建紧凑状态视图
  Widget _buildCompactStatus() {
    final scripts = widget.scriptManager.scripts;
    final statuses = widget.scriptManager.scriptStatuses;
    final runningCount = statuses.values
        .where((s) => s == ScriptStatus.running)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 系统状态指示器
          _buildSystemStatusIndicator(),
          const SizedBox(width: 12),

          // 运行中脚本指示器
          if (runningCount > 0) ...[
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Text(
              LocalizationService.instance.current.runningScriptsCount(
                runningCount,
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
          ] else ...[
            Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Text(
              LocalizationService.instance.current.idleStatus_7421,
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],

          const SizedBox(width: 12),

          // 脚本总数
          Text(
            LocalizationService.instance.current.scriptCount(scripts.length),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态头部
  Widget _buildStatusHeader() {
    return Row(
      children: [
        Icon(Icons.monitor_heart, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          LocalizationService
              .instance
              .current
              .scriptEngineStatusMonitoring_7281,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        _buildSystemStatusIndicator(),
      ],
    );
  }

  /// 构建系统状态指示器
  Widget _buildSystemStatusIndicator() {
    final hasMapData = widget.scriptManager.hasMapData;
    final platform = kIsWeb ? 'Web Worker' : 'Isolate';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasMapData ? Colors.green : Colors.orange,
            boxShadow: [
              BoxShadow(
                color: (hasMapData ? Colors.green : Colors.orange).withValues(
                  alpha: 0.3,
                ),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.executionEngine_4821,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              platform,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建系统指标
  Widget _buildSystemMetrics() {
    final scripts = widget.scriptManager.scripts;
    final statuses = widget.scriptManager.scriptStatuses;

    final totalScripts = scripts.length;
    final enabledScripts = scripts.where((s) => s.isEnabled).length;
    final runningScripts = statuses.values
        .where((s) => s == ScriptStatus.running)
        .length;
    final errorScripts = statuses.values
        .where((s) => s == ScriptStatus.error)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.systemMetrics_4521,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildMetricChip(
              label:
                  LocalizationService.instance.current.totalScriptsLabel_4821,
              value: '$totalScripts',
              icon: Icons.code,
              color: Theme.of(context).colorScheme.primary,
            ),
            _buildMetricChip(
              label: LocalizationService.instance.current.enabledStatus_4821,
              value: '$enabledScripts',
              icon: Icons.toggle_on,
              color: Colors.green,
            ),
            _buildMetricChip(
              label: LocalizationService.instance.current.runningStatus_4821,
              value: '$runningScripts',
              icon: Icons.play_circle,
              color: Colors.orange,
              isAnimated: runningScripts > 0,
            ),
            if (errorScripts > 0)
              _buildMetricChip(
                label: LocalizationService.instance.current.errorLabel_4821,
                value: '$errorScripts',
                icon: Icons.error,
                color: Colors.red,
              ),
            _buildMetricChip(
              label: LocalizationService.instance.current.executionEngine_4521,
              value: kIsWeb ? 'Web Worker' : 'Isolate',
              icon: kIsWeb ? Icons.web : Icons.desktop_windows,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ],
    );
  }

  /// 构建指标芯片
  Widget _buildMetricChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isAnimated = false,
  }) {
    Widget chipContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isAnimated) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: chipContent,
          );
        },
      );
    }

    return chipContent;
  }

  /// 构建运行中的脚本列表
  Widget _buildRunningScripts() {
    final scripts = widget.scriptManager.scripts;
    final statuses = widget.scriptManager.scriptStatuses;

    final runningScripts = scripts
        .where((script) => statuses[script.id] == ScriptStatus.running)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.runningScriptsCount(
            runningScripts.length,
          ),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (runningScripts.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  LocalizationService.instance.current.noRunningScripts_7421,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...runningScripts.map((script) => _buildRunningScriptItem(script)),
        ],
      ],
    );
  }

  /// 构建运行中脚本项
  Widget _buildRunningScriptItem(ScriptData script) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  script.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (script.description.isNotEmpty)
                  Text(
                    script.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.scriptManager.stopScript(script.id),
            icon: const Icon(Icons.stop, color: Colors.red),
            tooltip: LocalizationService.instance.current.stopScript_7421,
          ),
        ],
      ),
    );
  }

  /// 构建最近执行记录
  Widget _buildRecentExecutions() {
    final scripts = widget.scriptManager.scripts;
    final lastResults = widget.scriptManager.lastResults;

    // 获取有执行结果的脚本，按时间排序
    final recentExecutions =
        scripts.where((script) => lastResults.containsKey(script.id)).toList()
          ..sort((a, b) {
            final aTime = a.lastRunAt ?? DateTime(0);
            final bTime = b.lastRunAt ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.recentExecutionRecords_4821,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (recentExecutions.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  LocalizationService.instance.current.noExecutionRecords_4521,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...recentExecutions
              .take(5)
              .map(
                (script) =>
                    _buildExecutionHistoryItem(script, lastResults[script.id]!),
              ),
        ],
      ],
    );
  }

  /// 构建执行历史项
  Widget _buildExecutionHistoryItem(
    ScriptData script,
    ScriptExecutionResult result,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: result.success
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: result.success
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            result.success ? Icons.check_circle : Icons.error,
            size: 16,
            color: result.success ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  script.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${result.executionTime.inMilliseconds}ms | ${_formatTime(script.lastRunAt)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!result.success && result.error != null)
            Tooltip(
              message: result.error!,
              child: Icon(Icons.info_outline, size: 14, color: Colors.red),
            ),
        ],
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null)
      return LocalizationService.instance.current.unknownTime_4821;

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return LocalizationService.instance.current.justNow_4821;
    } else if (diff.inHours < 1) {
      return LocalizationService.instance.current.minutesAgo_7421(
        diff.inMinutes,
      );
    } else if (diff.inDays < 1) {
      return LocalizationService.instance.current.hoursAgo_7281(diff.inHours);
    } else {
      return '${diff.inDays}' +
          LocalizationService.instance.current.daysAgo_7283;
    }
  }
}
