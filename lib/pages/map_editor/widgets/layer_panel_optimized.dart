import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../utils/image_utils.dart';
import 'dart:async';

class LayerPanel extends StatefulWidget {
  final List<MapLayer> layers;
  final MapLayer? selectedLayer;
  final bool isPreviewMode;
  final Function(MapLayer) onLayerSelected;
  final Function(MapLayer) onLayerUpdated;
  final Function(MapLayer) onLayerDeleted;
  final VoidCallback onLayerAdded;
  final Function(int oldIndex, int newIndex) onLayersReordered;
  final Function(String)? onError;
  final Function(String)? onSuccess;
  // 新增：实时透明度预览回调
  final Function(String layerId, double opacity)? onOpacityPreview;

  const LayerPanel({
    super.key,
    required this.layers,
    this.selectedLayer,
    required this.isPreviewMode,
    required this.onLayerSelected,
    required this.onLayerUpdated,
    required this.onLayerDeleted,
    required this.onLayerAdded,
    required this.onLayersReordered,
    this.onError,
    this.onSuccess,
    this.onOpacityPreview,
  });

  @override
  State<LayerPanel> createState() => _LayerPanelState();
}

class _LayerPanelState extends State<LayerPanel> {
  // 用于存储临时的透明度值，避免频繁更新数据
  final Map<String, double> _tempOpacityValues = {};
  final Map<String, Timer?> _opacityTimers = {};

  @override
  void dispose() {
    // 清理所有定时器
    for (final timer in _opacityTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图层列表
          Expanded(
            child: widget.layers.isEmpty
                ? const Center(
                    child: Text(
                      '暂无图层',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: widget.layers.length,
                    onReorder: widget.onLayersReordered,
                    itemBuilder: (context, index) {
                      final layer = widget.layers[index];
                      return _buildLayerTile(context, layer, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTile(BuildContext context, MapLayer layer, int index) {
    final isSelected = widget.selectedLayer?.id == layer.id;

    return Container(
      key: ValueKey(layer.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () => widget.onLayerSelected(layer),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一排：可见性按钮 + 图层名称输入框 + 操作按钮
              Row(
                children: [
                  // 可见性按钮
                  IconButton(
                    icon: Icon(
                      layer.isVisible ? Icons.visibility : Icons.visibility_off,
                      size: 18,
                      color: layer.isVisible ? null : Colors.grey,
                    ),
                    onPressed: widget.isPreviewMode
                        ? null
                        : () {
                            final updatedLayer = layer.copyWith(
                              isVisible: !layer.isVisible,
                              updatedAt: DateTime.now(),
                            );
                            widget.onLayerUpdated(updatedLayer);
                          },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),

                  // 图层名称输入框
                  Expanded(
                    child: _buildLayerNameEditor(layer),
                  ),

                  // 操作按钮
                  if (!widget.isPreviewMode) ...[
                    // 图片管理按钮
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.image, size: 16),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'upload',
                          child: Row(
                            children: [
                              Icon(
                                layer.imageData != null ? Icons.edit : Icons.upload,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(layer.imageData != null ? '更换图片' : '上传图片'),
                            ],
                          ),
                        ),
                        if (layer.imageData != null)
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 16),
                                SizedBox(width: 8),
                                Text('移除图片'),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'upload':
                            await _handleImageUpload(layer);
                            break;
                          case 'remove':
                            _removeLayerImage(layer);
                            break;
                        }
                      },
                    ),

                    // 删除按钮
                    if (widget.layers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('删除图层'),
                              content: Text('确定要删除图层 "${layer.name}" 吗？此操作不可撤销。'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onLayerDeleted(layer);
                                  },
                                  child: const Text('删除'),
                                ),
                              ],
                            ),
                          );
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ],
              ),
              
              // 第二排：透明度滑块
              const SizedBox(height: 8),
              _buildOpacitySlider(layer),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建优化的透明度滑块
  Widget _buildOpacitySlider(MapLayer layer) {
    // 获取当前显示的透明度值（临时值或实际值）
    final currentOpacity = _tempOpacityValues[layer.id] ?? layer.opacity;
    
    return Row(
      children: [
        const Text('不透明度:', style: TextStyle(fontSize: 11)),
        const SizedBox(width: 8),
        Expanded(
          child: Slider(
            value: currentOpacity,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: widget.isPreviewMode
                ? null
                : (opacity) => _handleOpacityChange(layer, opacity),
            onChangeEnd: widget.isPreviewMode
                ? null
                : (opacity) => _handleOpacityChangeEnd(layer, opacity),
          ),
        ),
        Text(
          '${(currentOpacity * 100).round()}%',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  /// 处理透明度变化（拖动时）
  void _handleOpacityChange(MapLayer layer, double opacity) {
    setState(() {
      _tempOpacityValues[layer.id] = opacity;
    });
    
    // 立即通知画布进行预览
    widget.onOpacityPreview?.call(layer.id, opacity);
  }

  /// 处理透明度变化结束（松开滑块时）
  void _handleOpacityChangeEnd(MapLayer layer, double opacity) {
    // 取消之前的定时器
    _opacityTimers[layer.id]?.cancel();
    
    // 设置一个短延迟，避免频繁更新
    _opacityTimers[layer.id] = Timer(const Duration(milliseconds: 100), () {
      // 更新实际数据
      final updatedLayer = layer.copyWith(
        opacity: opacity,
        updatedAt: DateTime.now(),
      );
      widget.onLayerUpdated(updatedLayer);
      
      // 清除临时值
      setState(() {
        _tempOpacityValues.remove(layer.id);
      });
    });
  }

  /// 构建图层名称编辑器
  Widget _buildLayerNameEditor(MapLayer layer) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade50,
      ),
      child: TextFormField(
        key: ValueKey('layer_name_${layer.id}'),
        initialValue: layer.name,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          border: InputBorder.none,
          hintText: '输入图层名称',
          hintStyle: TextStyle(fontSize: 14),
          isDense: true,
        ),
        enabled: !widget.isPreviewMode,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (newName) {
          if (newName.trim().isNotEmpty && newName.trim() != layer.name) {
            final updatedLayer = layer.copyWith(
              name: newName.trim(),
              updatedAt: DateTime.now(),
            );
            widget.onLayerUpdated(updatedLayer);
          }
        },
      ),
    );
  }

  /// 处理图片上传
  Future<void> _handleImageUpload(MapLayer layer) async {
    try {
      final imageData = await ImageUtils.pickAndEncodeImage();
      if (imageData != null) {
        final updatedLayer = layer.copyWith(
          imageData: imageData,
          updatedAt: DateTime.now(),
        );
        widget.onLayerUpdated(updatedLayer);
        widget.onSuccess?.call('图片上传成功');
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      widget.onError?.call(errorMessage);
      debugPrint('上传图片失败: $e');
    }
  }

  /// 移除图层图片
  void _removeLayerImage(MapLayer layer) {
    final updatedLayer = layer.copyWith(
      imageData: null,
      updatedAt: DateTime.now(),
    );
    widget.onLayerUpdated(updatedLayer);
    widget.onSuccess?.call('图片已移除');
  }
}
