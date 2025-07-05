import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';

/// 主页设置板块
class HomePageSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const HomePageSettingsSection({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserPreferencesProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home),
                const SizedBox(width: 8),
                Text(
                  '主页设置',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 标题设置
            _buildTitleSettings(context, provider),
            const SizedBox(height: 16),

            // 显示区域设置
            _buildDisplaySettings(context, provider),
            const SizedBox(height: 16),

            // 性能设置
            _buildPerformanceSettings(context, provider),
            const SizedBox(height: 16),

            // 视觉效果设置
            _buildVisualSettings(context, provider),
          ],
        ),
      ),
    );
  }

  /// 标题设置
  Widget _buildTitleSettings(BuildContext context, UserPreferencesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标题设置',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        
        // 标题文字
        TextFormField(
          initialValue: preferences.homePage.titleText,
          decoration: const InputDecoration(
            labelText: '标题文字',
            hintText: '输入主页标题文字',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(titleText: value),
            );
          },
        ),
        const SizedBox(height: 12),

        // 标题字体大小
        Row(
          children: [
            Expanded(
              child: Text('标题字体大小倍数: ${(preferences.homePage.titleFontSizeMultiplier * 100).toStringAsFixed(1)}%'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.titleFontSizeMultiplier,
          min: 0.05,
          max: 0.25,
          divisions: 40,
          label: '${(preferences.homePage.titleFontSizeMultiplier * 100).toStringAsFixed(1)}%',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(titleFontSizeMultiplier: value),
            );
          },
        ),
      ],
    );
  }

  /// 显示区域设置
  Widget _buildDisplaySettings(BuildContext context, UserPreferencesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '显示区域设置',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),

        // 显示区域倍数
        Row(
          children: [
            Expanded(
              child: Text('显示区域倍数: ${preferences.homePage.displayAreaMultiplier.toStringAsFixed(1)}x'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.displayAreaMultiplier,
          min: 0.3,
          max: 3.0,
          divisions: 27,
          label: '${preferences.homePage.displayAreaMultiplier.toStringAsFixed(1)}x',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(displayAreaMultiplier: value),
            );
          },
        ),
        const SizedBox(height: 8),

        // 窗口随动系数
        Row(
          children: [
            Expanded(
              child: Text('窗口大小随动系数: ${preferences.homePage.windowScalingFactor.toStringAsFixed(2)}'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.windowScalingFactor,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: preferences.homePage.windowScalingFactor.toStringAsFixed(2),
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(windowScalingFactor: value),
            );
          },
        ),
      ],
    );
  }

  /// 性能设置
  Widget _buildPerformanceSettings(BuildContext context, UserPreferencesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性能设置',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),

        // 基础网格间距
        Row(
          children: [
            Expanded(
              child: Text('基础网格间距: ${preferences.homePage.baseNodeSpacing.toStringAsFixed(0)}px'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.baseNodeSpacing,
          min: 80.0,
          max: 400.0,
          divisions: 32,
          label: '${preferences.homePage.baseNodeSpacing.toStringAsFixed(0)}px',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(baseNodeSpacing: value),
            );
          },
        ),
        const SizedBox(height: 8),

        // 基础图标大小
        Row(
          children: [
            Expanded(
              child: Text('基础图标大小: ${preferences.homePage.baseSvgRenderSize.toStringAsFixed(0)}px'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.baseSvgRenderSize,
          min: 40.0,
          max: 300.0,
          divisions: 26,
          label: '${preferences.homePage.baseSvgRenderSize.toStringAsFixed(0)}px',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(baseSvgRenderSize: value),
            );
          },
        ),
        const SizedBox(height: 8),

        // 摄像机移动速度
        Row(
          children: [
            Expanded(
              child: Text('摄像机移动速度: ${preferences.homePage.cameraSpeed.toStringAsFixed(0)}px/s'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.cameraSpeed,
          min: 10.0,
          max: 200.0,
          divisions: 19,
          label: '${preferences.homePage.cameraSpeed.toStringAsFixed(0)}px/s',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(cameraSpeed: value),
            );
          },
        ),
      ],
    );
  }

  /// 视觉效果设置
  Widget _buildVisualSettings(BuildContext context, UserPreferencesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '视觉效果设置',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),

        // 启用主题颜色滤镜
        SwitchListTile(
          title: const Text('启用主题颜色滤镜'),
          subtitle: const Text('让图标颜色适应当前主题'),
          value: preferences.homePage.enableThemeColorFilter,
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(enableThemeColorFilter: value),
            );
          },
        ),
        const SizedBox(height: 8),

        // 缓冲区倍数
        Row(
          children: [
            Expanded(
              child: Text('基础缓冲区倍数: ${preferences.homePage.baseBufferMultiplier.toStringAsFixed(1)}x'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.baseBufferMultiplier,
          min: 1.1,
          max: 3.0,
          divisions: 19,
          label: '${preferences.homePage.baseBufferMultiplier.toStringAsFixed(1)}x',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(baseBufferMultiplier: value),
            );
          },
        ),
        const SizedBox(height: 8),

        // 透视缓冲调节系数
        Row(
          children: [
            Expanded(
              child: Text('透视缓冲调节系数: ${preferences.homePage.perspectiveBufferFactor.toStringAsFixed(1)}x'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.perspectiveBufferFactor,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          label: '${preferences.homePage.perspectiveBufferFactor.toStringAsFixed(1)}x',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(perspectiveBufferFactor: value),
            );
          },
        ),
        const SizedBox(height: 8),

        // 图标放大系数
        Row(
          children: [
            Expanded(
              child: Text('图标放大系数: ${preferences.homePage.iconEnlargementFactor.toStringAsFixed(1)}x'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.iconEnlargementFactor,
          min: 0.5,
          max: 2.5,
          divisions: 20,
          label: '${preferences.homePage.iconEnlargementFactor.toStringAsFixed(1)}x',
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(iconEnlargementFactor: value),
            );
          },
        ),
        const SizedBox(height: 8),

        // 最近使用SVG记录数量
        Row(
          children: [
            Expanded(
              child: Text('SVG分布记录数量: ${preferences.homePage.recentSvgHistorySize}'),
            ),
          ],
        ),
        Slider(
          value: preferences.homePage.recentSvgHistorySize.toDouble(),
          min: 5,
          max: 50,
          divisions: 45,
          label: preferences.homePage.recentSvgHistorySize.toString(),
          onChanged: (value) {
            _updateHomePageSettings(
              provider,
              preferences.homePage.copyWith(recentSvgHistorySize: value.toInt()),
            );
          },
        ),
      ],
    );
  }

  /// 更新主页设置
  void _updateHomePageSettings(UserPreferencesProvider provider, HomePagePreferences newSettings) {
    provider.updateHomePage(newSettings);
  }
}
