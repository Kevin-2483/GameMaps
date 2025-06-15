import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';

class LayoutSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const LayoutSettingsSection({super.key, required this.preferences});
  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserPreferencesProvider>();
    final layout = preferences.layout;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '界面布局设置',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 面板折叠状态设置
            Text(
              '面板折叠状态',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...layout.panelCollapsedStates.entries.map(
              (entry) => SwitchListTile(
                title: Text(_getPanelDisplayName(entry.key)),
                subtitle: Text('面板默认${entry.value ? "折叠" : "展开"}状态'),
                value: entry.value,
                onChanged: (value) => provider.updateLayout(
                  panelCollapsedStates: {
                    ...layout.panelCollapsedStates,
                    entry.key: value,
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 面板自动关闭设置
            Text(
              '面板自动关闭',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...layout.panelAutoCloseStates.entries.map(
              (entry) => SwitchListTile(
                title: Text(_getPanelDisplayName(entry.key)),
                subtitle: Text('失去焦点时${entry.value ? "自动关闭" : "保持开启"}'),
                value: entry.value,
                onChanged: (value) => provider.updateLayout(
                  panelAutoCloseStates: {
                    ...layout.panelAutoCloseStates,
                    entry.key: value,
                  },
                ),
              ),
            ),

            const SizedBox(height: 16), // 面板状态恢复设置
            SwitchListTile(
              title: Text('保存面板状态变更'),
              subtitle: Text('退出地图编辑器时自动保存面板折叠/展开状态'),
              value: layout.autoRestorePanelStates,
              onChanged: (value) =>
                  provider.updateLayout(autoRestorePanelStates: value),
            ),

            const SizedBox(height: 16),

            // 侧边栏宽度
            ListTile(
              title: Text('侧边栏宽度'),
              subtitle: Slider(
                value: layout.sidebarWidth,
                min: 200.0,
                max: 500.0,
                divisions: 30,
                label: '${layout.sidebarWidth.round()}px',
                onChanged: (value) =>
                    provider.updateLayout(sidebarWidth: value),
              ),
            ),

            const SizedBox(height: 8),

            // 紧凑模式
            SwitchListTile(
              title: Text('紧凑模式'),
              subtitle: Text('减少界面元素间距，适合小屏幕'),
              value: layout.compactMode,
              onChanged: (value) => provider.updateLayout(compactMode: value),
            ),

            const SizedBox(height: 8),

            // 显示工具提示
            SwitchListTile(
              title: Text('显示工具提示'),
              subtitle: Text('鼠标悬停时显示帮助信息'),
              value: layout.showTooltips,
              onChanged: (value) => provider.updateLayout(showTooltips: value),
            ),

            const SizedBox(height: 8),

            // 动画设置
            SwitchListTile(
              title: Text('启用动画'),
              subtitle: Text('界面切换和过渡动画'),
              value: layout.enableAnimations,
              onChanged: (value) =>
                  provider.updateLayout(enableAnimations: value),
            ),

            if (layout.enableAnimations) ...[
              const SizedBox(height: 8),
              ListTile(
                title: Text('动画持续时间'),
                subtitle: Slider(
                  value: layout.animationDuration.toDouble(),
                  min: 100.0,
                  max: 1000.0,
                  divisions: 18,
                  label: '${layout.animationDuration}ms',
                  onChanged: (value) =>
                      provider.updateLayout(animationDuration: value.round()),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 重置布局按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resetLayoutSettings(context, provider),
                    icon: Icon(Icons.restore),
                    label: Text('重置布局设置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPanelDisplayName(String panelKey) {
    switch (panelKey) {
      case 'drawing':
        return '绘图面板';
      case 'layer':
        return '图层面板';
      case 'legend':
        return '图例面板';
      case 'stickyNote':
        return '便签面板';
      case 'script':
        return '脚本面板';
      case 'sidebar':
        return '侧边栏';
      case 'properties':
        return '属性面板';
      case 'toolbar':
        return '工具栏';
      default:
        return panelKey;
    }
  }

  void _resetLayoutSettings(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('重置布局设置'),
        content: Text('确定要将布局设置重置为默认值吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final defaultLayout = LayoutPreferences.createDefault();
              provider.updateLayout(
                panelCollapsedStates: defaultLayout.panelCollapsedStates,
                panelAutoCloseStates: defaultLayout.panelAutoCloseStates,
                sidebarWidth: defaultLayout.sidebarWidth,
                compactMode: defaultLayout.compactMode,
                showTooltips: defaultLayout.showTooltips,
                animationDuration: defaultLayout.animationDuration,
                enableAnimations: defaultLayout.enableAnimations,
                autoRestorePanelStates: defaultLayout.autoRestorePanelStates,
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('布局设置已重置'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('重置'),
          ),
        ],
      ),
    );
  }
}
