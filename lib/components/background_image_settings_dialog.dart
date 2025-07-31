// This file has been processed by AI for internationalization
// background_image_settings_dialog.dart
import 'package:flutter/material.dart';
import '../models/map_layer.dart';

import '../services/localization_service.dart';

/// 背景图片设置结果
class BackgroundImageSettings {
  final double imageScale;
  final double xOffset;
  final double yOffset;
  final BoxFit imageFit;

  const BackgroundImageSettings({
    required this.imageScale,
    required this.xOffset,
    required this.yOffset,
    required this.imageFit,
  });
}

/// 背景图片设置对话框，支持横竖屏双模式布局
class BackgroundImageSettingsDialog extends StatefulWidget {
  final MapLayer layer;
  final String title;

  BackgroundImageSettingsDialog({super.key, required this.layer, String? title})
    : title =
          title ??
          LocalizationService.instance.current.backgroundImageSettings_7421;

  @override
  State<BackgroundImageSettingsDialog> createState() =>
      _BackgroundImageSettingsDialogState();
}

class _BackgroundImageSettingsDialogState
    extends State<BackgroundImageSettingsDialog> {
  late double _imageScale;
  late double _xOffset;
  late double _yOffset;
  late BoxFit _imageFit;

  @override
  void initState() {
    super.initState();
    _imageScale = widget.layer.imageScale;
    _xOffset = widget.layer.xOffset;
    _yOffset = widget.layer.yOffset;
    _imageFit = widget.layer.imageFit ?? BoxFit.contain;
  }

  void _updateImageScale(double value) {
    setState(() {
      _imageScale = value;
    });
  }

  void _updateXOffset(double value) {
    setState(() {
      _xOffset = value;
    });
  }

  void _updateYOffset(double value) {
    setState(() {
      _yOffset = value;
    });
  }

  void _updateImageFit(BoxFit fit) {
    setState(() {
      _imageFit = fit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.all(16),
      content: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancelButton_4271),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(
            BackgroundImageSettings(
              imageScale: _imageScale,
              xOffset: _xOffset,
              yOffset: _yOffset,
              imageFit: _imageFit,
            ),
          ),
          child: Text(LocalizationService.instance.current.confirmButton_7281),
        ),
      ],
    );
  }

  /// 横向布局（两列显示）
  Widget _buildLandscapeLayout() {
    return SizedBox(
      width: 600,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左列：图片预览
          SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImagePreview(),
                const SizedBox(height: 16),
                _buildCurrentValues(),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // 右列：控制项
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildScaleSlider(),
                const SizedBox(height: 16),
                _buildOffsetSliders(),
                const SizedBox(height: 16),
                _buildFitModeSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 竖向布局（单列显示）
  Widget _buildPortraitLayout() {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 16),
          _buildCurrentValues(),
          const SizedBox(height: 16),
          _buildScaleSlider(),
          const SizedBox(height: 16),
          _buildOffsetSliders(),
          const SizedBox(height: 16),
          _buildFitModeSelector(),
        ],
      ),
    );
  }

  /// 图片预览组件
  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.layer.imageData != null
            ? Stack(
                children: [
                  // 背景图片
                  Positioned.fill(
                    child: Image.memory(
                      widget.layer.imageData!,
                      fit: _imageFit,
                    ),
                  ),
                  // 中心点指示器
                  Positioned(
                    left: (_xOffset + 1.0) / 2.0 * 280 - 5,
                    top: (_yOffset + 1.0) / 2.0 * 200 - 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .noBackgroundImage_7421,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// 当前数值显示
  Widget _buildCurrentValues() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.instance.current.currentSettings_4521,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildValueDisplay(
                LocalizationService.instance.current.zoomLabel_4821,
                '${(_imageScale * 100).round()}%',
              ),
              _buildValueDisplay(
                LocalizationService.instance.current.xOffsetLabel_4821,
                '${(_xOffset * 100).round()}%',
              ),
              _buildValueDisplay(
                LocalizationService.instance.current.yOffsetLabel_4821,
                '${(_yOffset * 100).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                LocalizationService.instance.current.fillModeLabel_4821,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _getBoxFitDisplayName(_imageFit),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// 缩放滑块
  Widget _buildScaleSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.zoomPercentage(
            (_imageScale * 100).round(),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: _imageScale,
            min: 0.1,
            max: 3.0,
            divisions: 29,
            label: '${(_imageScale * 100).round()}%',
            onChanged: _updateImageScale,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '10%',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '300%',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 偏移滑块组
  Widget _buildOffsetSliders() {
    return Column(
      children: [
        // X轴偏移
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.xAxisOffset(
                (_xOffset * 100).round(),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: _xOffset,
                min: -1.0,
                max: 1.0,
                divisions: 200,
                label: '${(_xOffset * 100).round()}%',
                onChanged: _updateXOffset,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.current.leftText_4821,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  LocalizationService.instance.current.chineseCharacter_4821,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  LocalizationService.instance.current.rightDirection_4821,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Y轴偏移
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.yAxisOffset(
                (_yOffset * 100).round(),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: _yOffset,
                min: -1.0,
                max: 1.0,
                divisions: 200,
                label: '${(_yOffset * 100).round()}%',
                onChanged: _updateYOffset,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.current.upText_4821,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  LocalizationService.instance.current.chineseCharacter_4821,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  LocalizationService.instance.current.downText_4821,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 填充模式选择器
  Widget _buildFitModeSelector() {
    final boxFitOptions = [
      BoxFit.contain,
      BoxFit.cover,
      BoxFit.fill,
      BoxFit.fitWidth,
      BoxFit.fitHeight,
      BoxFit.none,
      BoxFit.scaleDown,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.current.fillMode_4821,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: boxFitOptions.map((fit) {
            return _buildFitModeButton(fit);
          }).toList(),
        ),
      ],
    );
  }

  /// 构建单个填充模式按钮
  Widget _buildFitModeButton(BoxFit fit) {
    final isSelected = _imageFit == fit;

    return InkWell(
      onTap: () => _updateImageFit(fit),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
        ),
        child: Text(
          _getBoxFitDisplayName(fit),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// 获取BoxFit的显示名称
  String _getBoxFitDisplayName(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return LocalizationService.instance.current.boxFitContain_4821;
      case BoxFit.cover:
        return LocalizationService.instance.current.boxFitCover_4822;
      case BoxFit.fill:
        return LocalizationService.instance.current.boxFitFill_4823;
      case BoxFit.fitWidth:
        return LocalizationService.instance.current.boxFitFitWidth_4824;
      case BoxFit.fitHeight:
        return LocalizationService.instance.current.boxFitFitHeight_4825;
      case BoxFit.none:
        return LocalizationService.instance.current.boxFitNone_4826;
      case BoxFit.scaleDown:
        return LocalizationService.instance.current.boxFitScaleDown_4827;
    }
  }
}
