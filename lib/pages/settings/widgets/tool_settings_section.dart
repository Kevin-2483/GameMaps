// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../components/color_picker_dialog.dart';
import '../../../components/common/tags_manager.dart';
import '../../../services/tts_service.dart';
import '../../../services/notification/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

class ToolSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const ToolSettingsSection({super.key, required this.preferences});
  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserPreferencesProvider>();
    final tools = preferences.tools;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.toolSettings_4821,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 最近使用的颜色
            Text(
              LocalizationService.instance.current.recentlyUsedColors_4821,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tools.recentColors.length,
                itemBuilder: (context, index) {
                  final color = Color(tools.recentColors[index]);
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _showColorOptions(context, provider, index),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () =>
                                _removeRecentColor(provider, index),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addNewColor(context, provider),
                  icon: Icon(Icons.add),
                  label: Text(
                    LocalizationService.instance.current.addColor_7421,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _clearRecentColors(context, provider),
                  icon: Icon(Icons.clear_all),
                  label: Text(
                    LocalizationService.instance.current.clearText_4821,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 自定义颜色
            Text(
              LocalizationService.instance.current.customColor_7421,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tools.customColors.length,
                itemBuilder: (context, index) {
                  final color = Color(tools.customColors[index]);
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          _showCustomColorOptions(context, provider, index),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () =>
                                _removeCustomColor(provider, index),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addNewCustomColor(context, provider),
                  icon: Icon(Icons.add),
                  label: Text(
                    LocalizationService.instance.current.addCustomColor_4271,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _clearCustomColors(context, provider),
                  icon: Icon(Icons.clear_all),
                  label: Text(
                    LocalizationService.instance.current.clearButton_7421,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // 常用线条宽度
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.current.commonLineWidth_4521,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${tools.favoriteStrokeWidths.length}/5',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: tools.favoriteStrokeWidths.asMap().entries.map((entry) {
                final index = entry.key;
                final width = entry.value;
                return Chip(
                  label: Text('${width.round()}px'),
                  deleteIcon: Icon(Icons.close, size: 16),
                  onDeleted: () => _removeFavoriteStrokeWidth(provider, index),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _addStrokeWidth(context, provider),
              icon: Icon(Icons.add),
              label: Text(
                LocalizationService.instance.current.addLineWidth_4821,
              ),
            ),

            const SizedBox(height: 16),

            // 工具栏布局
            Text(
              LocalizationService.instance.current.toolbarLayout_4521,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tools.toolbarLayout.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final newLayout = List<String>.from(tools.toolbarLayout);
                  final item = newLayout.removeAt(oldIndex);
                  newLayout.insert(newIndex, item);
                  provider.updateTools(toolbarLayout: newLayout);
                },
                itemBuilder: (context, index) {
                  final tool = tools.toolbarLayout[index];
                  return ListTile(
                    key: ValueKey(tool),
                    leading: Icon(_getToolIcon(tool)),
                    title: Text(_getToolDisplayName(tool)),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: Icon(Icons.drag_handle),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 显示高级工具
            SwitchListTile(
              title: Text(
                LocalizationService.instance.current.showAdvancedTools_4271,
              ),
              subtitle: Text(
                LocalizationService.instance.current.showProToolsInToolbar_4271,
              ),
              value: tools.showAdvancedTools,
              onChanged: (value) =>
                  provider.updateTools(showAdvancedTools: value),
            ),

            const SizedBox(height: 16),

            // 拖动控制柄大小
            Text(
              LocalizationService.instance.current.dragHandleSizeHint_4821,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(LocalizationService.instance.current.handleSize_4821),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService
                        .instance
                        .current
                        .adjustDrawingElementHandleSize_7281,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('4px'),
                      Expanded(
                        child: Slider(
                          value: tools.handleSize.clamp(4.0, 32.0),
                          min: 4.0,
                          max: 32.0,
                          divisions: 28,
                          label: '${tools.handleSize.round()}px',
                          onChanged: (value) =>
                              provider.updateTools(handleSize: value),
                        ),
                      ),
                      Text('32px'),
                    ],
                  ),
                  Text(
                    LocalizationService.instance.current.currentSize_7421(
                      tools.handleSize.round(),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 重置工具设置
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resetToolSettings(context, provider),
                    icon: Icon(Icons.restore),
                    label: Text(
                      LocalizationService
                          .instance
                          .current
                          .resetToolSettings_4271,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 自定义标签管理
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.current.customLabel_7281,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  LocalizationService.instance.current.tagCount(
                    tools.customTags.length,
                  ),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 自定义标签预览
            if (tools.customTags.isNotEmpty) ...[
              Container(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tools.customTags.length,
                  itemBuilder: (context, index) {
                    final tag = tools.customTags[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => _removeCustomTag(provider, tag),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    LocalizationService.instance.current.noCustomTags_7281,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 自定义标签操作按钮
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showTagsManager(context, provider),
                  icon: const Icon(Icons.label),
                  label: Text(
                    LocalizationService.instance.current.manageTags_4271,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _addCustomTag(context, provider),
                  icon: const Icon(Icons.add),
                  label: Text(
                    LocalizationService.instance.current.addLabel_4271,
                  ),
                ),
                const SizedBox(width: 8),
                if (tools.customTags.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _clearCustomTags(context, provider),
                    icon: const Icon(Icons.clear_all),
                    label: Text(
                      LocalizationService.instance.current.clearText_4821,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // TTS 设置
            Text(
              LocalizationService.instance.current.ttsSettingsTitle_4821,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // TTS 启用开关
            SwitchListTile(
              title: Text(
                LocalizationService.instance.current.enableSpeechSynthesis_4271,
              ),
              subtitle: Text(
                LocalizationService
                    .instance
                    .current
                    .enableVoiceReadingFeature_4821,
              ),
              value: tools.tts.enabled,
              onChanged: (value) {
                provider.updateTools(tts: tools.tts.copyWith(enabled: value));
              },
            ),

            // 仅在 TTS 启用时显示其他设置
            if (tools.tts.enabled) ...[
              const SizedBox(height: 8),
              // 语言设置
              _TtsLanguageSelector(
                currentLanguage: tools.tts.language,
                onLanguageChanged: (value) {
                  provider.updateTools(
                    tts: tools.tts.copyWith(language: value),
                  );
                },
              ),

              // 语音速度
              ListTile(
                title: Text(
                  LocalizationService.instance.current.voiceSpeed_4251,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .adjustVoiceSpeed_4271,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(LocalizationService.instance.current.slow_7284),
                        Expanded(
                          child: Slider(
                            value: tools.tts.speechRate.clamp(0.1, 1.0),
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: '${(tools.tts.speechRate * 100).round()}%',
                            onChanged: (value) {
                              provider.updateTools(
                                tts: tools.tts.copyWith(speechRate: value),
                              );
                            },
                          ),
                        ),
                        Text(LocalizationService.instance.current.fast_4821),
                      ],
                    ),
                    Text(
                      LocalizationService.instance.current.currentSpeechRate(
                        (tools.tts.speechRate * 100).round(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // 音量
              ListTile(
                title: Text(
                  LocalizationService.instance.current.volumeTitle_4821,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .adjustVoiceVolume_4251,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.volume_mute, size: 16),
                        Expanded(
                          child: Slider(
                            value: tools.tts.volume.clamp(0.0, 1.0),
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: '${(tools.tts.volume * 100).round()}%',
                            onChanged: (value) {
                              provider.updateTools(
                                tts: tools.tts.copyWith(volume: value),
                              );
                            },
                          ),
                        ),
                        Icon(Icons.volume_up, size: 16),
                      ],
                    ),
                    Text(
                      LocalizationService.instance.current.currentVolume(
                        (tools.tts.volume * 100).round(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // 音调
              ListTile(
                title: Text(
                  LocalizationService.instance.current.toneTitle_4821,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .adjustVoicePitch_4271,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(LocalizationService.instance.current.low_7284),
                        Expanded(
                          child: Slider(
                            value: tools.tts.pitch.clamp(0.5, 2.0),
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: '${tools.tts.pitch.toStringAsFixed(1)}',
                            onChanged: (value) {
                              provider.updateTools(
                                tts: tools.tts.copyWith(pitch: value),
                              );
                            },
                          ),
                        ),
                        Text(LocalizationService.instance.current.high_7281),
                      ],
                    ),
                    Text(
                      LocalizationService.instance.current.currentPitch(
                        tools.tts.pitch.toStringAsFixed(1),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // 语音选择
              _TtsVoiceSelector(
                currentVoice: tools.tts.voice,
                currentLanguage: tools.tts.language,
                onVoiceChanged: (value) {
                  provider.updateTools(tts: tools.tts.copyWith(voice: value));
                },
              ),

              // TTS 测试按钮
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _testTts(context),
                    icon: Icon(Icons.play_arrow),
                    label: Text(
                      LocalizationService.instance.current.testVoice_7281,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _resetTtsSettings(context, provider),
                    icon: Icon(Icons.restore),
                    label: Text(
                      LocalizationService
                          .instance
                          .current
                          .resetTtsSettings_4271,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showColorOptions(
    BuildContext context,
    UserPreferencesProvider provider,
    int index,
  ) {
    // 显示颜色选项对话框的实现
  }

  void _removeRecentColor(UserPreferencesProvider provider, int index) {
    final newColors = List<int>.from(preferences.tools.recentColors);
    newColors.removeAt(index);
    provider.updateTools(recentColors: newColors);
  }

  void _addNewColor(BuildContext context, UserPreferencesProvider provider) {
    ColorPicker.showColorPicker(
      context: context,
      initialColor: Colors.blue,
      title: LocalizationService.instance.current.addRecentColorsTitle_7421,
      enableAlpha: true,
    ).then((selectedColor) {
      if (selectedColor != null) {
        provider.addRecentColor(selectedColor.value);
      }
    });
  }

  void _clearRecentColors(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationService.instance.current.clearRecentColors_4271,
        ),
        content: Text(
          LocalizationService.instance.current.confirmClearRecentColors_4821,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateTools(recentColors: []);
              Navigator.of(context).pop();
            },
            child: Text(LocalizationService.instance.current.clearText_4821),
          ),
        ],
      ),
    );
  }

  void _removeFavoriteStrokeWidth(UserPreferencesProvider provider, int index) {
    final newWidths = List<double>.from(preferences.tools.favoriteStrokeWidths);
    newWidths.removeAt(index);
    provider.updateTools(favoriteStrokeWidths: newWidths);
  }

  void _addStrokeWidth(BuildContext context, UserPreferencesProvider provider) {
    final currentWidths = preferences.tools.favoriteStrokeWidths;

    // 检查是否已达到最大数量限制
    if (currentWidths.length >= 5) {
      context.showInfoSnackBar(
        LocalizationService.instance.current.maxLineWidthLimit_4821,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        double newWidth = 1.0;
        return AlertDialog(
          title: Text(LocalizationService.instance.current.addLineWidth_4821),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocalizationService.instance.current.widthWithPx_7421(
                    newWidth.round(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocalizationService.instance.current.currentCount(
                    currentWidths.length,
                  ),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: newWidth,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  onChanged: (value) => setState(() => newWidth = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocalizationService.instance.current.cancel_4821),
            ),
            ElevatedButton(
              onPressed: () {
                final newWidths = List<double>.from(currentWidths);
                if (!newWidths.contains(newWidth)) {
                  if (newWidths.length >= 5) {
                    context.showInfoSnackBar(
                      LocalizationService
                          .instance
                          .current
                          .maxLineWidthLimit_4821,
                    );
                    return;
                  }
                  newWidths.add(newWidth);
                  newWidths.sort();
                  provider.updateTools(favoriteStrokeWidths: newWidths);
                  Navigator.of(context).pop();

                  context.showSuccessSnackBar(
                    LocalizationService.instance.current.lineWidthAdded(
                      newWidth.round(),
                    ),
                  );
                } else {
                  context.showInfoSnackBar(
                    LocalizationService.instance.current.lineWidthExists_4821,
                  );
                }
              },
              child: Text(LocalizationService.instance.current.addButton_7421),
            ),
          ],
        );
      },
    );
  }

  IconData _getToolIcon(String tool) {
    switch (tool) {
      case 'pen':
        return Icons.edit;
      case 'brush':
        return Icons.brush;
      case 'line':
        return Icons.remove;
      case 'dashedLine':
        return Icons.more_horiz;
      case 'arrow':
        return Icons.arrow_forward;
      case 'rectangle':
        return Icons.rectangle;
      case 'hollowRectangle':
        return Icons.rectangle_outlined;
      case 'diagonalLines':
        return Icons.line_style;
      case 'crossLines':
        return Icons.grid_3x3;
      case 'dotGrid':
        return Icons.grid_on;
      case 'freeDrawing':
        return Icons.gesture;
      case 'circle':
        return Icons.circle_outlined;
      case 'text':
        return Icons.text_fields;
      case 'eraser':
        return Icons.content_cut;
      case 'imageArea':
        return Icons.photo_size_select_actual;
      default:
        return Icons.build;
    }
  }

  String _getToolDisplayName(String tool) {
    switch (tool) {
      case 'pen':
        return LocalizationService.instance.current.penTool_1234;
      case 'brush':
        return LocalizationService.instance.current.brushTool_5678;
      case 'line':
        return LocalizationService.instance.current.lineTool_9012;
      case 'dashedLine':
        return LocalizationService.instance.current.dashedLineTool_3456;
      case 'arrow':
        return LocalizationService.instance.current.arrowTool_7890;
      case 'rectangle':
        return LocalizationService.instance.current.solidRectangleTool_1235;
      case 'hollowRectangle':
        return LocalizationService.instance.current.hollowRectangleTool_5679;
      case 'diagonalLines':
        return LocalizationService.instance.current.diagonalLinesTool_9023;
      case 'crossLines':
        return LocalizationService.instance.current.crossLinesTool_3467;
      case 'dotGrid':
        return LocalizationService.instance.current.dotGridTool_7901;
      case 'freeDrawing':
        return LocalizationService.instance.current.pixelPenTool_1245;
      case 'circle':
        return LocalizationService.instance.current.circleTool_5689;
      case 'text':
        return LocalizationService.instance.current.textTool_9034;
      case 'eraser':
        return LocalizationService.instance.current.eraserTool_3478;
      case 'imageArea':
        return LocalizationService.instance.current.imageSelectionTool_7912;
      default:
        return tool;
    }
  }

  void _resetToolSettings(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationService.instance.current.resetToolSettings_4271,
        ),
        content: Text(
          LocalizationService
              .instance
              .current
              .resetToolSettingsConfirmation_4821,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          ElevatedButton(
            onPressed: () {
              final defaultTools = ToolPreferences.createDefault();
              provider.updateTools(
                recentColors: defaultTools.recentColors,
                customColors: defaultTools.customColors,
                favoriteStrokeWidths: defaultTools.favoriteStrokeWidths,
                toolbarLayout: defaultTools.toolbarLayout,
                showAdvancedTools: defaultTools.showAdvancedTools,
              );
              Navigator.of(context).pop();
              context.showSuccessSnackBar(
                LocalizationService.instance.current.toolSettingsReset_4821,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizationService.instance.current.resetButton_5421),
          ),
        ],
      ),
    );
  }

  void _showCustomColorOptions(
    BuildContext context,
    UserPreferencesProvider provider,
    int index,
  ) {
    // 显示自定义颜色选项对话框的实现
  }

  void _removeCustomColor(UserPreferencesProvider provider, int index) {
    final newColors = List<int>.from(preferences.tools.customColors);
    newColors.removeAt(index);
    provider.updateTools(customColors: newColors);
  }

  void _addNewCustomColor(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    ColorPicker.showColorPicker(
      context: context,
      initialColor: Colors.purple,
      title: LocalizationService.instance.current.addCustomColor_7421,
      enableAlpha: true,
    ).then((selectedColor) {
      if (selectedColor != null) {
        provider.addCustomColor(selectedColor.value);
      }
    });
  }

  void _clearCustomColors(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationService.instance.current.clearCustomColors_4271,
        ),
        content: Text(
          LocalizationService.instance.current.confirmClearCustomColors_7421,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateTools(customColors: []);
              Navigator.of(context).pop();
            },
            child: Text(LocalizationService.instance.current.clearText_4821),
          ),
        ],
      ),
    );
  }

  // 自定义标签管理方法

  /// 移除自定义标签
  void _removeCustomTag(UserPreferencesProvider provider, String tag) {
    provider.removeCustomTag(tag);
  }

  /// 显示标签管理器
  void _showTagsManager(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    await TagsManagerUtils.showCustomTagsManagerDialog(context, provider);
  }

  /// 添加自定义标签
  void _addCustomTag(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _AddCustomTagDialog(provider: provider),
    );
  }

  /// 清空自定义标签
  void _clearCustomTags(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.clearCustomTags_4271),
        content: Text(
          LocalizationService.instance.current.confirmClearAllTags_7281,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateCustomTags([]);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              LocalizationService.instance.current.clearText_4821,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 测试 TTS 功能
  void _testTts(BuildContext context) async {
    try {
      // 使用 TTS 服务
      final tts = TtsService();
      await tts.initialize();

      // 首先停止所有当前播放，包括测试播放
      await tts.stopBySource('settings_test');
      await tts.stop(); // 停止所有播放

      // 获取当前用户设置
      final ttsSettings = preferences.tools.tts;

      // 测试语音播放，使用当前设置的语言
      final currentLanguage = ttsSettings.language;
      String testText = LocalizationService.instance.current.ttsTestText_4821;

      // 根据语言调整测试文本
      if (currentLanguage != null) {
        switch (currentLanguage.toLowerCase().split('-')[0]) {
          case 'en':
            testText =
                'This is a text-to-speech test. Current settings have been applied.';
            break;
          case 'ja':
            testText = 'これは音声合成のテストです。現在の設定が適用されています。';
            break;
          case 'ko':
            testText = '이것은 음성 합성 테스트입니다. 현재 설정이 적용되었습니다.';
            break;
          case 'fr':
            testText =
                'Ceci est un test de synthèse vocale. Les paramètres actuels ont été appliqués.';
            break;
          case 'de':
            testText =
                'Dies ist ein Text-zu-Sprache-Test. Die aktuellen Einstellungen wurden angewendet.';
            break;
          case 'es':
            testText =
                'Esta es una prueba de síntesis de voz. Se han aplicado los ajustes actuales.';
            break;
          case 'it':
            testText =
                'Questo è un test di sintesi vocale. Le impostazioni correnti sono state applicate.';
            break;
          case 'pt':
            testText =
                'Este é um teste de síntese de voz. As configurações atuais foram aplicadas.';
            break;
          case 'ru':
            testText = 'Это тест синтеза речи. Текущие настройки применены.';
            break;
          case 'ar':
            testText =
                'هذا اختبار لتحويل النص إلى كلام. تم تطبيق الإعدادات الحالية.';
            break;
          case 'th':
            testText =
                'นี่คือการทดสอบการสังเคราะห์เสียงพูด การตั้งค่าปัจจุบันได้ถูกนำไปใช้แล้ว';
            break;
          case 'vi':
            testText =
                'Đây là bài kiểm tra chuyển văn bản thành giọng nói. Các cài đặt hiện tại đã được áp dụng.';
            break;
          case 'hi':
            testText =
                'यह टेक्स्ट-टू-स्पीच परीक्षण है। वर्तमान सेटिंग्स लागू की गई हैं।';
            break;
          default:
            testText = LocalizationService.instance.current.ttsTestText_4821;
        }
      }

      // 直接调用 TTS，使用当前设置的所有参数
      await tts.speak(
        testText,
        language: ttsSettings.language,
        speechRate: ttsSettings.speechRate,
        volume: ttsSettings.volume,
        pitch: ttsSettings.pitch,
        voice: ttsSettings.voice,
        sourceId: 'settings_test',
      );

      if (context.mounted) {
        context.showSuccessSnackBar(
          LocalizationService.instance.current.ttsTestStartedPlaying(
            _getLanguageDisplayName(currentLanguage ?? 'zh-CN'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(
          LocalizationService.instance.current.ttsTestFailed(e.toString()),
        );
      }
    }
  }

  /// 获取语言显示名称 (用于测试反馈)
  String _getLanguageDisplayName(String languageCode) {
    Map<String, String> languageMap = {
      'zh': LocalizationService.instance.current.chinese_4821,
      'zh-CN': LocalizationService.instance.current.chineseSimplified_4822,
      'zh-TW': LocalizationService.instance.current.chineseTraditional_4823,
      'en': LocalizationService.instance.current.english_4824,
      'en-US': LocalizationService.instance.current.englishUS_4825,
      'en-GB': LocalizationService.instance.current.englishUK_4826,
      'ja': LocalizationService.instance.current.japanese_4827,
      'ja-JP': LocalizationService.instance.current.japanese_4827,
      'ko': LocalizationService.instance.current.korean_4828,
      'ko-KR': LocalizationService.instance.current.korean_4828,
      'fr': LocalizationService.instance.current.french_4829,
      'fr-FR': LocalizationService.instance.current.french_4829,
      'de': LocalizationService.instance.current.german_4830,
      'de-DE': LocalizationService.instance.current.german_4830,
      'es': LocalizationService.instance.current.spanish_4831,
      'es-ES': LocalizationService.instance.current.spanish_4831,
      'it': LocalizationService.instance.current.italian_4832,
      'it-IT': LocalizationService.instance.current.italian_4832,
      'pt': LocalizationService.instance.current.portuguese_4833,
      'pt-BR': LocalizationService.instance.current.portugueseBrazil_4834,
      'ru': LocalizationService.instance.current.russian_4835,
      'ru-RU': LocalizationService.instance.current.russian_4835,
      'ar': LocalizationService.instance.current.arabic_4836,
      'ar-SA': LocalizationService.instance.current.arabic_4836,
      'th': LocalizationService.instance.current.thai_4837,
      'th-TH': LocalizationService.instance.current.thai_4837,
      'vi': LocalizationService.instance.current.vietnamese_4838,
      'vi-VN': LocalizationService.instance.current.vietnamese_4838,
      'hi': LocalizationService.instance.current.hindi_4839,
      'hi-IN': LocalizationService.instance.current.hindi_4839,
    };
    return languageMap[languageCode] ?? languageCode;
  }

  /// 重置 TTS 设置
  void _resetTtsSettings(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.resetTtsSettings_4271),
        content: Text(
          LocalizationService.instance.current.confirmResetTtsSettings_4821,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_4271),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.updateTools(tts: TtsPreferences.createDefault());
              context.showSuccessSnackBar(
                LocalizationService.instance.current.ttsSettingsReset_4821,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizationService.instance.current.resetButton_7421),
          ),
        ],
      ),
    );
  }
}

/// 添加自定义标签对话框
class _AddCustomTagDialog extends StatefulWidget {
  final UserPreferencesProvider provider;

  const _AddCustomTagDialog({required this.provider});

  @override
  State<_AddCustomTagDialog> createState() => _AddCustomTagDialogState();
}

class _AddCustomTagDialogState extends State<_AddCustomTagDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() async {
    final tag = _controller.text.trim();

    // 验证标签
    final error = TagsManagerUtils.defaultTagValidator(tag);
    if (error != null) {
      setState(() {
        _errorText = error;
      });
      return;
    }

    // 检查是否已存在
    if (widget.provider.tools.customTags.contains(tag)) {
      setState(() {
        _errorText = LocalizationService.instance.current.tagAlreadyExists_7281;
      });
      return;
    }

    // 添加标签
    await widget.provider.addCustomTag(tag);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocalizationService.instance.current.addCustomTag_4271),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: LocalizationService.instance.current.labelName_4821,
          hintText: LocalizationService.instance.current.hintLabelName_7532,
          border: const OutlineInputBorder(),
          errorText: _errorText,
        ),
        onChanged: (value) {
          if (_errorText != null) {
            setState(() {
              _errorText = null;
            });
          }
        },
        onSubmitted: (_) => _addTag(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancelButton_7421),
        ),
        ElevatedButton(
          onPressed: _addTag,
          child: Text(LocalizationService.instance.current.addButton_7284),
        ),
      ],
    );
  }
}

/// TTS 语言选择器组件
class _TtsLanguageSelector extends StatefulWidget {
  final String? currentLanguage;
  final ValueChanged<String?> onLanguageChanged;

  const _TtsLanguageSelector({
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<_TtsLanguageSelector> createState() => _TtsLanguageSelectorState();
}

class _TtsLanguageSelectorState extends State<_TtsLanguageSelector> {
  List<dynamic>? _availableLanguages;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableLanguages();
  }

  Future<void> _loadAvailableLanguages() async {
    try {
      final tts = TtsService();
      await tts.initialize();
      setState(() {
        _availableLanguages = tts.availableLanguages;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    // 将语言代码转换为显示名称，使用本地化服务
    final localization = LocalizationService.instance.current;

    switch (languageCode) {
      // 中文系列
      case 'zh':
        return localization.chinese_4821;
      case 'zh-CN':
        return localization.chineseSimplified_4822;
      case 'zh-TW':
        return localization.chineseTraditional_4823;
      case 'zh-HK':
        return localization.chineseHK_4894;
      case 'zh-SG':
        return localization.chineseSG_4895;

      // 英语系列
      case 'en':
        return localization.english_4824;
      case 'en-US':
        return localization.englishUS_4825;
      case 'en-GB':
        return localization.englishUK_4826;
      case 'en-AU':
        return localization.englishAU_4896;
      case 'en-CA':
        return localization.englishCA_4897;
      case 'en-IN':
        return localization.englishIN_4898;

      // 日语
      case 'ja':
        return localization.japanese_4827;
      case 'ja-JP':
        return localization.japaneseJP_4899;

      // 韩语
      case 'ko':
        return localization.korean_4828;
      case 'ko-KR':
        return localization.koreanKR_4900;

      // 欧洲语言
      case 'fr':
        return localization.french_4829;
      case 'fr-FR':
        return localization.frenchFR_4882;
      case 'fr-CA':
        return localization.frenchCA_4883;
      case 'de':
        return localization.german_4830;
      case 'de-DE':
        return localization.germanDE_4884;
      case 'es':
        return localization.spanish_4831;
      case 'es-ES':
        return localization.spanishES_4885;
      case 'es-MX':
        return localization.spanishMX_4886;
      case 'it':
        return localization.italian_4832;
      case 'it-IT':
        return localization.italianIT_4887;
      case 'pt':
        return localization.portuguese_4833;
      case 'pt-BR':
        return localization.portugueseBrazil_4834;
      case 'pt-PT':
        return localization.portuguesePT_4888;
      case 'ru':
        return localization.russian_4835;
      case 'ru-RU':
        return localization.russianRU_4889;
      case 'nl':
        return localization.dutch_4840;
      case 'nl-NL':
        return localization.dutchNL_4841;

      // 北欧语言
      case 'sv':
        return localization.swedish_4842;
      case 'sv-SE':
        return localization.swedishSE_4843;
      case 'da':
        return localization.danish_4844;
      case 'da-DK':
        return localization.danishDK_4845;
      case 'no':
        return localization.norwegian_4846;
      case 'no-NO':
        return localization.norwegianNO_4847;
      case 'fi':
        return localization.finnish_4848;
      case 'fi-FI':
        return localization.finnishFI_4849;

      // 东欧语言
      case 'pl':
        return localization.polish_4850;
      case 'pl-PL':
        return localization.polishPL_4851;
      case 'cs':
        return localization.czech_4852;
      case 'cs-CZ':
        return localization.czechCZ_4853;
      case 'hu':
        return localization.hungarian_4854;
      case 'hu-HU':
        return localization.hungarianHU_4855;
      case 'ro':
        return localization.romanian_4856;
      case 'ro-RO':
        return localization.romanianRO_4857;
      case 'bg':
        return localization.bulgarian_4858;
      case 'bg-BG':
        return localization.bulgarianBG_4859;
      case 'hr':
        return localization.croatian_4860;
      case 'hr-HR':
        return localization.croatianHR_4861;
      case 'sk':
        return localization.slovak_4862;
      case 'sk-SK':
        return localization.slovakSK_4863;
      case 'sl':
        return localization.slovenian_4864;
      case 'sl-SI':
        return localization.slovenianSI_4865;
      case 'et':
        return localization.estonian_4866;
      case 'et-EE':
        return localization.estonianEE_4867;
      case 'lv':
        return localization.latvian_4868;
      case 'lv-LV':
        return localization.latvianLV_4869;
      case 'lt':
        return localization.lithuanian_4870;
      case 'lt-LT':
        return localization.lithuanianLT_4871;

      // 其他语言
      case 'ar':
        return localization.arabic_4836;
      case 'ar-SA':
        return localization.arabicSA_4890;
      case 'th':
        return localization.thai_4837;
      case 'th-TH':
        return localization.thaiTH_4891;
      case 'vi':
        return localization.vietnamese_4838;
      case 'vi-VN':
        return localization.vietnameseVN_4892;
      case 'hi':
        return localization.hindi_4839;
      case 'hi-IN':
        return localization.hindiIN_4893;
      case 'tr':
        return localization.turkish_4872;
      case 'tr-TR':
        return localization.turkishTR_4873;
      case 'he':
        return localization.hebrew_4874;
      case 'he-IL':
        return localization.hebrewIL_4875;
      case 'id':
        return localization.indonesian_4876;
      case 'id-ID':
        return localization.indonesianID_4877;
      case 'ms':
        return localization.malay_4878;
      case 'ms-MY':
        return localization.malayMY_4879;
      case 'tl':
        return localization.filipino_4880;
      case 'tl-PH':
        return localization.filipinoPH_4881;

      default:
        return languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(LocalizationService.instance.current.languageSetting_4821),
      subtitle: Text(
        widget.currentLanguage != null
            ? _getLanguageDisplayName(widget.currentLanguage!)
            : LocalizationService.instance.current.defaultLanguage_7421,
      ),
      trailing: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : DropdownButton<String>(
              value: widget.currentLanguage,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    LocalizationService.instance.current.defaultOption_7281,
                  ),
                ),
                if (_availableLanguages != null)
                  ..._availableLanguages!.map<DropdownMenuItem<String>>((lang) {
                    final languageCode = lang.toString();
                    return DropdownMenuItem<String>(
                      value: languageCode,
                      child: Text(_getLanguageDisplayName(languageCode)),
                    );
                  }).toList(),
              ],
              onChanged: widget.onLanguageChanged,
              isExpanded: false,
            ),
    );
  }
}

/// TTS 语音选择器组件
class _TtsVoiceSelector extends StatefulWidget {
  final Map<String, String>? currentVoice;
  final String? currentLanguage;
  final ValueChanged<Map<String, String>?> onVoiceChanged;

  const _TtsVoiceSelector({
    required this.currentVoice,
    required this.currentLanguage,
    required this.onVoiceChanged,
  });

  @override
  State<_TtsVoiceSelector> createState() => _TtsVoiceSelectorState();
}

class _TtsVoiceSelectorState extends State<_TtsVoiceSelector> {
  List<dynamic>? _availableVoices;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableVoices();
  }

  @override
  void didUpdateWidget(_TtsVoiceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当语言改变时，重新加载语音选项
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _loadAvailableVoices();
    }
  }

  Future<void> _loadAvailableVoices() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final tts = TtsService();
      await tts.initialize();
      setState(() {
        _availableVoices = tts.availableVoices;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredVoices() {
    if (_availableVoices == null) return [];

    try {
      final voices = <Map<String, dynamic>>[];

      for (final voice in _availableVoices!) {
        if (voice is Map) {
          // 转换为 Map<String, dynamic>
          final voiceMap = <String, dynamic>{};
          voice.forEach((key, value) {
            voiceMap[key.toString()] = value;
          });
          voices.add(voiceMap);
        }
      }

      // 如果指定了语言，过滤匹配的语音
      if (widget.currentLanguage != null) {
        final targetLanguage = widget.currentLanguage!.toLowerCase();
        return voices.where((voice) {
          final voiceLocale = voice['locale']?.toString().toLowerCase();
          if (voiceLocale == null) return false;

          // 支持完全匹配或语言前缀匹配
          return voiceLocale == targetLanguage ||
              voiceLocale.startsWith('${targetLanguage.split('-')[0]}-');
        }).toList();
      }

      return voices;
    } catch (e) {
      return [];
    }
  }

  String _getVoiceDisplayName(Map<String, dynamic> voice) {
    final name = voice['name']?.toString() ?? '';
    final locale = voice['locale']?.toString() ?? '';

    if (name.isNotEmpty && locale.isNotEmpty) {
      return '$name ($locale)';
    } else if (name.isNotEmpty) {
      return name;
    } else if (locale.isNotEmpty) {
      return locale;
    }

    return LocalizationService.instance.current.unknownVoice_4821;
  }

  String _getCurrentVoiceDisplayName() {
    if (widget.currentVoice == null)
      return LocalizationService.instance.current.defaultVoice_4821;

    final name = widget.currentVoice!['name'] ?? '';
    final locale = widget.currentVoice!['locale'] ?? '';

    if (name.isNotEmpty && locale.isNotEmpty) {
      return '$name ($locale)';
    } else if (name.isNotEmpty) {
      return name;
    }

    return LocalizationService.instance.current.customVoice_5732;
  }

  @override
  Widget build(BuildContext context) {
    final filteredVoices = _getFilteredVoices();
    final currentVoiceId = _getCurrentVoiceId();

    return ListTile(
      title: Text(LocalizationService.instance.current.voiceTitle_4271),
      subtitle: Text(_getCurrentVoiceDisplayName()),
      trailing: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : DropdownButton<String>(
              value: currentVoiceId,
              items: [
                DropdownMenuItem<String>(
                  value: 'default',
                  child: Text(
                    LocalizationService.instance.current.defaultText_1234,
                  ),
                ),
                ...filteredVoices.asMap().entries.map<DropdownMenuItem<String>>(
                  (entry) {
                    final index = entry.key;
                    final voice = entry.value;
                    final voiceId = 'voice_$index';
                    return DropdownMenuItem<String>(
                      value: voiceId,
                      child: Text(_getVoiceDisplayName(voice)),
                    );
                  },
                ).toList(),
              ],
              onChanged: (String? selectedVoiceId) {
                if (selectedVoiceId == null || selectedVoiceId == 'default') {
                  widget.onVoiceChanged(null);
                } else {
                  // 从 voice_1, voice_2 等格式中提取索引
                  final indexStr = selectedVoiceId.replaceFirst('voice_', '');
                  final index = int.tryParse(indexStr);
                  if (index != null && index < filteredVoices.length) {
                    final selectedVoice = filteredVoices[index];
                    final voiceMap = Map<String, String>.from(
                      selectedVoice.map(
                        (key, value) => MapEntry(key, value?.toString() ?? ''),
                      ),
                    );
                    widget.onVoiceChanged(voiceMap);
                  }
                }
              },
              isExpanded: false,
            ),
    );
  }

  // 获取当前语音的ID用于选择
  String? _getCurrentVoiceId() {
    if (widget.currentVoice == null) return 'default';

    final filteredVoices = _getFilteredVoices();
    final currentName = widget.currentVoice!['name'] ?? '';
    final currentLocale = widget.currentVoice!['locale'] ?? '';

    for (int i = 0; i < filteredVoices.length; i++) {
      final voice = filteredVoices[i];
      final voiceName = voice['name']?.toString() ?? '';
      final voiceLocale = voice['locale']?.toString() ?? '';

      if (voiceName == currentName && voiceLocale == currentLocale) {
        return 'voice_$i';
      }
    }

    return 'default';
  }
}
