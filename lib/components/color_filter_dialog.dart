// This file has been processed by AI for internationalization
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';

import '../services/localization_service.dart';

/// 色彩滤镜类型
enum ColorFilterType {
  none, // 无滤镜
  grayscale, // 灰度
  sepia, // 棕褐色
  invert, // 反色
  brightness, // 亮度调整
  contrast, // 对比度调整
  saturation, // 饱和度调整
  hue, // 色相调整
}

/// 色彩滤镜设置
class ColorFilterSettings {
  final ColorFilterType type;
  final double intensity; // 滤镜强度 0.0-1.0
  final double brightness; // 亮度调整 -1.0 到 1.0
  final double contrast; // 对比度调整 0.0 到 2.0
  final double saturation; // 饱和度调整 0.0 到 2.0
  final double hue; // 色相调整 0.0 到 360.0

  const ColorFilterSettings({
    this.type = ColorFilterType.none,
    this.intensity = 1.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.hue = 0.0,
  });

  ColorFilterSettings copyWith({
    ColorFilterType? type,
    double? intensity,
    double? brightness,
    double? contrast,
    double? saturation,
    double? hue,
  }) {
    return ColorFilterSettings(
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      hue: hue ?? this.hue,
    );
  }

  /// 生成Flutter ColorFilter
  ColorFilter? toColorFilter() {
    if (type == ColorFilterType.none || intensity == 0.0) {
      return null;
    }

    switch (type) {
      case ColorFilterType.none:
        return null;
      case ColorFilterType.grayscale:
        return ColorFilter.matrix(_createGrayscaleMatrix(intensity));
      case ColorFilterType.sepia:
        return ColorFilter.matrix(_createSepiaMatrix(intensity));
      case ColorFilterType.invert:
        return ColorFilter.matrix(_createInvertMatrix(intensity));
      case ColorFilterType.brightness:
        return ColorFilter.matrix(_createBrightnessMatrix(brightness));
      case ColorFilterType.contrast:
        return ColorFilter.matrix(_createContrastMatrix(contrast));
      case ColorFilterType.saturation:
        return ColorFilter.matrix(_createSaturationMatrix(saturation));
      case ColorFilterType.hue:
        return ColorFilter.matrix(_createHueMatrix(hue));
    }
  }

  /// 创建灰度矩阵
  List<double> _createGrayscaleMatrix(double intensity) {
    final gray = 1.0 - intensity;
    return [
      0.299 + gray * 0.701,
      0.587 - gray * 0.587,
      0.114 - gray * 0.114,
      0,
      0,
      0.299 - gray * 0.299,
      0.587 + gray * 0.413,
      0.114 - gray * 0.114,
      0,
      0,
      0.299 - gray * 0.299,
      0.587 - gray * 0.587,
      0.114 + gray * 0.886,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// 创建棕褐色矩阵
  List<double> _createSepiaMatrix(double intensity) {
    final sepia = intensity;
    final inv = 1.0 - sepia;
    return [
      inv + sepia * 0.393,
      sepia * 0.769,
      sepia * 0.189,
      0,
      0,
      sepia * 0.349,
      inv + sepia * 0.686,
      sepia * 0.168,
      0,
      0,
      sepia * 0.272,
      sepia * 0.534,
      inv + sepia * 0.131,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// 创建反色矩阵
  List<double> _createInvertMatrix(double intensity) {
    final inv = 1.0 - intensity;
    final neg = -intensity;
    return [
      inv + neg,
      0,
      0,
      0,
      intensity * 255,
      0,
      inv + neg,
      0,
      0,
      intensity * 255,
      0,
      0,
      inv + neg,
      0,
      intensity * 255,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// 创建亮度矩阵
  List<double> _createBrightnessMatrix(double brightness) {
    final b = brightness * 255;
    return [1, 0, 0, 0, b, 0, 1, 0, 0, b, 0, 0, 1, 0, b, 0, 0, 0, 1, 0];
  }

  /// 创建对比度矩阵
  List<double> _createContrastMatrix(double contrast) {
    final c = contrast;
    final offset = (1.0 - c) * 128;
    return [
      c,
      0,
      0,
      0,
      offset,
      0,
      c,
      0,
      0,
      offset,
      0,
      0,
      c,
      0,
      offset,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// 创建饱和度矩阵
  List<double> _createSaturationMatrix(double saturation) {
    final s = saturation;
    final sr = (1 - s) * 0.299;
    final sg = (1 - s) * 0.587;
    final sb = (1 - s) * 0.114;
    return [
      sr + s,
      sg,
      sb,
      0,
      0,
      sr,
      sg + s,
      sb,
      0,
      0,
      sr,
      sg,
      sb + s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// 创建色相矩阵
  List<double> _createHueMatrix(double hue) {
    final h = hue * 3.14159 / 180; // 转换为弧度
    final cosH = cos(h);
    final sinH = sin(h);
    return [
      0.213 + cosH * 0.787 - sinH * 0.213,
      0.715 - cosH * 0.715 - sinH * 0.715,
      0.072 - cosH * 0.072 + sinH * 0.928,
      0,
      0,
      0.213 - cosH * 0.213 + sinH * 0.143,
      0.715 + cosH * 0.285 + sinH * 0.140,
      0.072 - cosH * 0.072 - sinH * 0.283,
      0,
      0,
      0.213 - cosH * 0.213 - sinH * 0.787,
      0.715 - cosH * 0.715 + sinH * 0.715,
      0.072 + cosH * 0.928 + sinH * 0.072,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

/// 色彩滤镜设置对话框
class ColorFilterDialog extends StatefulWidget {
  final ColorFilterSettings initialSettings;
  final String title;
  final String? layerId; // 图层ID

  ColorFilterDialog({
    super.key,
    this.initialSettings = const ColorFilterSettings(),
    String? title,
    this.layerId,
  }) : title =
           title ??
           LocalizationService.instance.current.colorFilterSettingsTitle_4287;

  @override
  State<ColorFilterDialog> createState() => _ColorFilterDialogState();
}

class _ColorFilterDialogState extends State<ColorFilterDialog> {
  late ColorFilterSettings _settings;
  bool _isThemeAdaptationActive = false;
  ColorFilterSettings? _autoAppliedSettings;
  String? _layerId; // 添加图层ID以便与管理器交互
  bool _isUsingThemeFilter = false; // 标记当前是否正在使用主题滤镜

  @override
  void initState() {
    super.initState();
    _layerId = widget.layerId;

    // 如果有图层ID，检查是否有主题适配滤镜
    if (_layerId != null) {
      final userFilter = ColorFilterSessionManager().getUserLayerFilter(
        _layerId!,
      );
      final themeFilter = ColorFilterSessionManager().getThemeAdaptationFilter(
        _layerId!,
      );

      // 优先使用用户设置的滤镜，如果没有则使用主题适配滤镜
      _settings = userFilter ?? themeFilter ?? widget.initialSettings;
      // 如果使用的是主题滤镜（没有用户滤镜但有主题滤镜），设置标记
      _isUsingThemeFilter = userFilter == null && themeFilter != null;
    } else {
      _settings = widget.initialSettings;
      _isUsingThemeFilter = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkThemeAdaptation();
  }

  /// 检查主题适配设置并自动应用滤镜
  void _checkThemeAdaptation() {
    final userPreferences = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    final themePreferences = userPreferences.theme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _isThemeAdaptationActive =
        themePreferences.canvasThemeAdaptation && isDarkMode;

    if (_isThemeAdaptationActive) {
      // 自动应用适合深色模式的滤镜设置
      _autoAppliedSettings = const ColorFilterSettings(
        type: ColorFilterType.brightness,
        intensity: 1.0,
        brightness: 0.5, // 增加亮度
      );

      // 如果有图层ID，检查是否应该应用主题适配滤镜
      if (_layerId != null) {
        final hasUserFilter = ColorFilterSessionManager().hasUserFilter(
          _layerId!,
        );
        final isUserDisabled = ColorFilterSessionManager()
            .isThemeAdaptationUserDisabled(_layerId!);

        // 只有在用户没有明确禁用主题适配且当前没有用户手动设置的滤镜时，才自动应用主题适配滤镜
        if (!hasUserFilter && !isUserDisabled) {
          // 设置或更新主题适配滤镜
          ColorFilterSessionManager().setThemeAdaptationFilter(
            _layerId!,
            _autoAppliedSettings!,
          );
          setState(() {
            _settings = _autoAppliedSettings!;
            _isUsingThemeFilter = true; // 标记当前使用主题滤镜
          });
        }
      } else if (_settings.type == ColorFilterType.none) {
        // 如果没有图层ID但当前没有滤镜，也显示主题适配设置
        setState(() {
          _settings = _autoAppliedSettings!;
          _isUsingThemeFilter = false; // 没有图层ID时不算主题滤镜
        });
      }
    } else {
      _autoAppliedSettings = null;
    }
  }

  void _updateSettings(ColorFilterSettings newSettings) {
    setState(() {
      _settings = newSettings;
      _isUsingThemeFilter = false; // 用户手动修改设置时清除主题滤镜标记
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isThemeAdaptationActive) ...[
              _buildThemeAdaptationInfo(),
              const SizedBox(height: 16),
            ],
            _buildFilterTypeSelector(),
            const SizedBox(height: 16),
            if (_settings.type != ColorFilterType.none) ...[
              _buildPreview(),
              const SizedBox(height: 16),
              _buildFilterControls(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancelButton_4271),
        ),
        ElevatedButton(
          onPressed: () {
            if (_layerId != null) {
              // 如果用户选择了无滤镜，需要移除主题适配滤镜
              if (_settings.type == ColorFilterType.none) {
                ColorFilterSessionManager().removeThemeAdaptationFilter(
                  _layerId!,
                );
              } else if (_isUsingThemeFilter) {
                // 如果当前使用的是主题滤镜，不要将其保存为用户滤镜
                // 直接关闭对话框，不返回设置（界面更新由调用方处理）
                Navigator.of(context).pop();
                return;
              }
            }
            Navigator.of(context).pop(_settings);
          },
          child: Text(LocalizationService.instance.current.confirmButton_7281),
        ),
      ],
    );
  }

  /// 主题适配信息提示
  Widget _buildThemeAdaptationInfo() {
    final hasUserFilter =
        _layerId != null &&
        ColorFilterSessionManager().hasUserFilter(_layerId!);
    // final hasThemeFilter =
    //     _layerId != null &&
    //     ColorFilterSessionManager().hasThemeAdaptationFilter(_layerId!);
    final themeFilter = _layerId != null
        ? ColorFilterSessionManager().getThemeAdaptationFilter(_layerId!)
        : null;
    final isUserDisabled =
        _layerId != null &&
        ColorFilterSessionManager().isThemeAdaptationUserDisabled(_layerId!);

    // 检查当前设置是否与主题滤镜一致
    final isUsingThemeFilter =
        themeFilter != null &&
        _settings.type == themeFilter.type &&
        _settings.intensity == themeFilter.intensity &&
        _settings.hue == themeFilter.hue &&
        _settings.saturation == themeFilter.saturation &&
        _settings.brightness == themeFilter.brightness;

    String statusText;
    if (isUserDisabled) {
      statusText = LocalizationService.instance.current.layerThemeDisabled_4821;
    } else if (hasUserFilter && !isUsingThemeFilter) {
      statusText =
          LocalizationService.instance.current.darkModeAutoInvertApplied_4821;
    } else if (isUsingThemeFilter) {
      statusText =
          LocalizationService.instance.current.darkModeFilterApplied_4821;
    } else if (_settings.type == ColorFilterType.none) {
      statusText = LocalizationService.instance.current.noFilterApplied_4821;
    } else {
      statusText =
          LocalizationService.instance.current.darkModeColorInversion_4821;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                LocalizationService
                    .instance
                    .current
                    .canvasThemeAdaptationEnabled_7421,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isUserDisabled || (hasUserFilter && !isUsingThemeFilter)) ...[
                TextButton.icon(
                  onPressed: _resetToAutoSettings,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(
                    LocalizationService
                        .instance
                        .current
                        .reapplyThemeFilter_7281,
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (isUsingThemeFilter) ...[
                TextButton.icon(
                  onPressed: _resetToAutoSettings,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(
                    LocalizationService
                        .instance
                        .current
                        .resetToAutoSettings_4821,
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.clear, size: 16),
                label: Text(
                  LocalizationService.instance.current.clearAllFilters_4271,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 重置为自动设置（移除用户自定义滤镜，保留主题适配滤镜）
  void _resetToAutoSettings() {
    if (_layerId != null) {
      ColorFilterSessionManager().removeUserLayerFilter(_layerId!);
      ColorFilterSessionManager().enableThemeAdaptation(_layerId!); // 重新启用主题适配

      // 获取或创建主题适配滤镜
      var themeFilter = ColorFilterSessionManager().getThemeAdaptationFilter(
        _layerId!,
      );
      if (themeFilter == null && _autoAppliedSettings != null) {
        // 如果没有主题滤镜但有自动应用的设置，使用自动应用的设置
        themeFilter = _autoAppliedSettings!;
        ColorFilterSessionManager().setThemeAdaptationFilter(
          _layerId!,
          themeFilter,
        );
      } else if (themeFilter == null) {
        // 如果都没有，创建默认的亮度滤镜（主题适配的默认行为）
        themeFilter = const ColorFilterSettings(
          type: ColorFilterType.brightness,
          intensity: 1.0,
          brightness: 0.5, // 提高亮度
        );
        ColorFilterSessionManager().setThemeAdaptationFilter(
          _layerId!,
          themeFilter,
        );
      }

      setState(() {
        _settings = themeFilter!;
        _isUsingThemeFilter = true; // 标记当前使用主题滤镜
      });
    } else if (_autoAppliedSettings != null) {
      _updateSettings(_autoAppliedSettings!);
    }
  }

  /// 清除所有滤镜（包括用户自定义和主题适配）
  void _clearAllFilters() {
    if (_layerId != null) {
      ColorFilterSessionManager().removeUserLayerFilter(_layerId!);
      ColorFilterSessionManager().removeThemeAdaptationFilter(_layerId!);
    }
    _updateSettings(const ColorFilterSettings());
    _isUsingThemeFilter = false; // 清除主题滤镜标记
  }

  /// 滤镜类型选择器
  Widget _buildFilterTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.filterType_4821,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ColorFilterType.values.map((type) {
            return _buildFilterTypeButton(type);
          }).toList(),
        ),
      ],
    );
  }

  /// 构建单个滤镜类型按钮
  Widget _buildFilterTypeButton(ColorFilterType type) {
    final isSelected = _settings.type == type;
    final name = _getFilterTypeName(type);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _updateSettings(_settings.copyWith(type: type)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? colorScheme.primary.withAlpha((0.1 * 255).toInt())
              : Colors.transparent,
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// 预览区域
  Widget _buildPreview() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColorFiltered(
          colorFilter:
              _settings.toColorFilter() ??
              const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.green, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                LocalizationService.instance.current.filterPreview_4821,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 滤镜控制器
  Widget _buildFilterControls() {
    switch (_settings.type) {
      case ColorFilterType.none:
        return const SizedBox.shrink();
      case ColorFilterType.grayscale:
      case ColorFilterType.sepia:
      case ColorFilterType.invert:
        return _buildIntensitySlider();
      case ColorFilterType.brightness:
        return _buildBrightnessSlider();
      case ColorFilterType.contrast:
        return _buildContrastSlider();
      case ColorFilterType.saturation:
        return _buildSaturationSlider();
      case ColorFilterType.hue:
        return _buildHueSlider();
    }
  }

  /// 强度滑块
  Widget _buildIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.intensityPercentage(
            (_settings.intensity * 100).round(),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _settings.intensity,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          onChanged: (value) =>
              _updateSettings(_settings.copyWith(intensity: value)),
        ),
      ],
    );
  }

  /// 亮度滑块
  Widget _buildBrightnessSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.brightnessPercentage(
            (_settings.brightness * 100).round(),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _settings.brightness,
          min: -1.0,
          max: 1.0,
          divisions: 200,
          onChanged: (value) =>
              _updateSettings(_settings.copyWith(brightness: value)),
        ),
      ],
    );
  }

  /// 对比度滑块
  Widget _buildContrastSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.contrastPercentage(
            (_settings.contrast * 100).round(),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _settings.contrast,
          min: 0.0,
          max: 2.0,
          divisions: 200,
          onChanged: (value) =>
              _updateSettings(_settings.copyWith(contrast: value)),
        ),
      ],
    );
  }

  /// 饱和度滑块
  Widget _buildSaturationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.saturationPercentage(
            (_settings.saturation * 100).round(),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _settings.saturation,
          min: 0.0,
          max: 2.0,
          divisions: 200,
          onChanged: (value) =>
              _updateSettings(_settings.copyWith(saturation: value)),
        ),
      ],
    );
  }

  /// 色相滑块
  Widget _buildHueSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.hueValue(_settings.hue.round()),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _settings.hue,
          min: 0.0,
          max: 360.0,
          divisions: 360,
          onChanged: (value) => _updateSettings(_settings.copyWith(hue: value)),
        ),
      ],
    );
  }

  /// 获取滤镜类型名称
  String _getFilterTypeName(ColorFilterType type) {
    switch (type) {
      case ColorFilterType.none:
        return LocalizationService.instance.current.noFilter_4821;
      case ColorFilterType.grayscale:
        return LocalizationService.instance.current.grayscale_4822;
      case ColorFilterType.sepia:
        return LocalizationService.instance.current.sepia_4823;
      case ColorFilterType.invert:
        return LocalizationService.instance.current.invert_4824;
      case ColorFilterType.brightness:
        return LocalizationService.instance.current.brightness_4825;
      case ColorFilterType.contrast:
        return LocalizationService.instance.current.contrast_4826;
      case ColorFilterType.saturation:
        return LocalizationService.instance.current.saturation_4827;
      case ColorFilterType.hue:
        return LocalizationService.instance.current.hue_4828;
    }
  }
}

/// 色彩滤镜会话管理器
class ColorFilterSessionManager {
  static final ColorFilterSessionManager _instance =
      ColorFilterSessionManager._internal();
  factory ColorFilterSessionManager() => _instance;
  ColorFilterSessionManager._internal();

  final Map<String, ColorFilterSettings> _layerFilters = {};
  final Map<String, ColorFilterSettings> _themeAdaptationFilters = {};
  final Set<String> _userDisabledThemeAdaptation = {}; // 用户明确禁用主题适配的图层

  /// 设置图层滤镜
  void setLayerFilter(String layerId, ColorFilterSettings settings) {
    if (settings.type == ColorFilterType.none) {
      _layerFilters.remove(layerId);
    } else {
      _layerFilters[layerId] = settings;
    }
  }

  /// 获取图层滤镜（包含主题适配）
  ColorFilterSettings? getLayerFilter(String layerId) {
    // 优先返回用户设置的滤镜，如果没有则返回主题适配滤镜
    return _layerFilters[layerId] ?? _themeAdaptationFilters[layerId];
  }

  /// 获取用户手动设置的滤镜（不包含主题适配）
  ColorFilterSettings? getUserLayerFilter(String layerId) {
    return _layerFilters[layerId];
  }

  /// 获取主题适配滤镜
  ColorFilterSettings? getThemeAdaptationFilter(String layerId) {
    return _themeAdaptationFilters[layerId];
  }

  /// 设置主题适配滤镜
  void setThemeAdaptationFilter(String layerId, ColorFilterSettings? settings) {
    if (settings == null || settings.type == ColorFilterType.none) {
      _themeAdaptationFilters.remove(layerId);
    } else {
      _themeAdaptationFilters[layerId] = settings;
    }
  }

  /// 检查图层是否有主题适配滤镜
  bool hasThemeAdaptationFilter(String layerId) {
    return _themeAdaptationFilters.containsKey(layerId);
  }

  /// 检查图层是否有用户手动设置的滤镜
  bool hasUserFilter(String layerId) {
    return _layerFilters.containsKey(layerId);
  }

  /// 移除图层滤镜
  void removeLayerFilter(String layerId) {
    _layerFilters.remove(layerId);
  }

  /// 移除用户手动设置的滤镜
  void removeUserLayerFilter(String layerId) {
    _layerFilters.remove(layerId);
  }

  /// 移除主题适配滤镜
  void removeThemeAdaptationFilter(String layerId) {
    _themeAdaptationFilters.remove(layerId);
    _userDisabledThemeAdaptation.add(layerId); // 记录用户明确禁用
  }

  /// 检查用户是否明确禁用了主题适配
  bool isThemeAdaptationUserDisabled(String layerId) {
    return _userDisabledThemeAdaptation.contains(layerId);
  }

  /// 重新启用主题适配（清除用户禁用标记）
  void enableThemeAdaptation(String layerId) {
    _userDisabledThemeAdaptation.remove(layerId);
  }

  /// 清除所有滤镜
  void clearAllFilters() {
    _layerFilters.clear();
    _themeAdaptationFilters.clear();
    _userDisabledThemeAdaptation.clear(); // 清除用户禁用状态
  }

  /// 获取所有滤镜
  Map<String, ColorFilterSettings> getAllFilters() {
    final result = Map<String, ColorFilterSettings>.from(
      _themeAdaptationFilters,
    );
    result.addAll(_layerFilters); // 用户滤镜覆盖主题适配滤镜
    return result;
  }

  /// 获取所有用户滤镜
  Map<String, ColorFilterSettings> getAllUserFilters() {
    return Map.from(_layerFilters);
  }

  /// 获取所有主题适配滤镜
  Map<String, ColorFilterSettings> getAllThemeAdaptationFilters() {
    return Map.from(_themeAdaptationFilters);
  }
}
