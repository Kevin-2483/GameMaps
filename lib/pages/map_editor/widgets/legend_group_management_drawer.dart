import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/map_layer.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../components/vfs/vfs_file_picker_window.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../components/common/tags_manager.dart';

/// 图例组管理抽屉
class LegendGroupManagementDrawer extends StatefulWidget {
  final LegendGroup legendGroup;
  final List<legend_db.LegendItem> availableLegends;
  final Function(LegendGroup) onLegendGroupUpdated;
  final bool isPreviewMode;
  final VoidCallback onClose; // 关闭回调
  final Function(String)? onLegendItemSelected; // 图例项选中回调
  final List<MapLayer>? allLayers; // 所有图层，用于智能隐藏功能
  final MapLayer? selectedLayer; // 当前选中的图层
  final List<MapLayer>? selectedLayerGroup; // 当前选中的图层组
  final String? initialSelectedLegendItemId; // 初始选中的图例项ID
  final String? selectedElementId; // 外部传入的选中元素ID，用于同步状态

  const LegendGroupManagementDrawer({
    super.key,
    required this.legendGroup,
    required this.availableLegends,
    required this.onLegendGroupUpdated,
    this.isPreviewMode = false,
    required this.onClose,
    this.onLegendItemSelected,
    this.allLayers,
    this.selectedLayer,
    this.selectedLayerGroup,
    this.initialSelectedLegendItemId,
    this.selectedElementId,
  });

  @override
  State<LegendGroupManagementDrawer> createState() =>
      _LegendGroupManagementDrawerState();
}

class _LegendGroupManagementDrawerState
    extends State<LegendGroupManagementDrawer> {
  late LegendGroup _currentGroup;
  String? _selectedLegendItemId; // 当前选中的图例项ID
  bool _isSmartHidingEnabled = false; // 智能隐藏开关状态  @override
  void initState() {
    super.initState();
    _currentGroup = widget.legendGroup;
    // 设置初始选中的图例项
    _selectedLegendItemId = widget.initialSelectedLegendItemId;
    // 延迟执行检查，避免在初始化期间调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSmartHiding();
    });
  }

  @override
  void didUpdateWidget(LegendGroupManagementDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果传入的图例组发生变化，更新当前组
    if (oldWidget.legendGroup.id != widget.legendGroup.id) {
      _currentGroup = widget.legendGroup;
      // 清除选中的图例项，因为切换到了新的图例组
      _selectedLegendItemId = null;
      // 延迟执行检查，确保新图例组的智能隐藏逻辑正确应用
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkSmartHiding();
      });
    }

    // 如果选中的图层发生变化，检查并清除不兼容的图例选择
    if (oldWidget.selectedLayer?.id != widget.selectedLayer?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        clearIncompatibleLegendSelection();
      });
    }
    if (oldWidget.allLayers != widget.allLayers) {
      // 延迟执行检查，避免在build期间调用setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkSmartHiding();
        // 同时检查图例选择的兼容性
        clearIncompatibleLegendSelection();
      });
    }

    // 如果外部选中元素ID发生变化，同步内部状态
    if (oldWidget.selectedElementId != widget.selectedElementId) {
      // 如果外部清除了选择（selectedElementId为null），同时清除内部选择
      if (widget.selectedElementId == null && _selectedLegendItemId != null) {
        setState(() {
          _selectedLegendItemId = null;
        });
      }
      // 如果外部选择了新元素，且该元素是图例项，同步选择
      else if (widget.selectedElementId != null) {
        // 检查选中的元素是否是当前图例组中的图例项
        final isLegendItemInCurrentGroup = _currentGroup.legendItems.any(
          (item) => item.id == widget.selectedElementId,
        );

        if (isLegendItemInCurrentGroup) {
          setState(() {
            _selectedLegendItemId = widget.selectedElementId;
          });
        }
      }
    }
  }

  /// 外部调用：当图层状态发生变化时，检查智能隐藏逻辑
  void checkSmartHidingOnLayerChange() {
    // 延迟执行检查，确保不会在build期间调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSmartHiding();
    });
  }

  /// 外部调用：清除不兼容的图例选择
  void clearIncompatibleLegendSelection() {
    // 如果没有选中的图例项，直接返回
    if (_selectedLegendItemId == null) return;

    // 检查当前选择是否仍然有效
    if (!_canSelectLegendItem()) {
      setState(() {
        _selectedLegendItemId = null;
      });
      // 通知父组件选中状态变化
      widget.onLegendItemSelected?.call('');
    }
  }

  // 检查图例项是否被选中
  bool _isLegendItemSelected(LegendItem item) {
    return _selectedLegendItemId == item.id;
  }

  // 选中图例项
  void _selectLegendItem(LegendItem item) {
    // 在选中前检查是否满足条件
    if (!_canSelectLegendItem()) {
      _showSelectionNotAllowedDialog();
      return;
    }

    setState(() {
      _selectedLegendItemId = _selectedLegendItemId == item.id ? null : item.id;
    });
    // 通知父组件选中状态变化，用于高亮显示地图上的图例项
    widget.onLegendItemSelected?.call(_selectedLegendItemId ?? '');
  }

  /// 判断是否可以选择图例项
  /// 灵活的选择条件：
  /// 1. 图例组可见
  /// 2. 如果有绑定图层被直接选中，允许选择
  /// 3. 如果没有绑定图层被直接选中，但选中的图层组包含绑定图层，允许选择
  /// 4. 如果没有选中任何图层或图层组，基于最高优先级图层组的绑定图层允许选择
  bool _canSelectLegendItem() {
    // 检查图例组是否可见
    if (!_currentGroup.isVisible) {
      return false;
    }

    // 如果没有提供图层信息，允许选择（兼容性）
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return true;
    }

    // 获取绑定的图层
    final boundLayers = _getBoundLayers();
    if (boundLayers.isEmpty) {
      return true; // 如果没有绑定图层，允许选择
    }

    // 条件2：检查绑定的图层中是否有被直接选中的
    if (widget.selectedLayer != null) {
      if (boundLayers.any((layer) => layer.id == widget.selectedLayer!.id)) {
        return true;
      }
    }

    // 条件3：检查选中的图层组是否包含绑定图层
    if (widget.selectedLayer != null ||
        (widget.allLayers != null && _getSelectedLayerGroup().isNotEmpty)) {
      final selectedGroup = _getSelectedLayerGroup();
      if (selectedGroup.isNotEmpty) {
        // 检查选中的图层组中是否包含绑定图层
        final selectedGroupIds = selectedGroup.map((l) => l.id).toSet();
        final boundLayerIds = boundLayers.map((l) => l.id).toSet();
        if (selectedGroupIds.intersection(boundLayerIds).isNotEmpty) {
          return true;
        }
      }
    }

    // 条件4：如果没有选中任何图层或图层组，基于最高优先级图层组的绑定图层允许选择
    if (widget.selectedLayer == null && _getSelectedLayerGroup().isEmpty) {
      final highestPriorityLayers = _getHighestPriorityLayers();
      if (highestPriorityLayers.isNotEmpty) {
        final highestPriorityIds = highestPriorityLayers
            .map((l) => l.id)
            .toSet();
        final boundLayerIds = boundLayers.map((l) => l.id).toSet();
        if (highestPriorityIds.intersection(boundLayerIds).isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  /// 获取选中的图层组
  List<MapLayer> _getSelectedLayerGroup() {
    // 使用传入的选中图层组信息
    if (widget.selectedLayerGroup != null &&
        widget.selectedLayerGroup!.isNotEmpty) {
      return widget.selectedLayerGroup!;
    }

    // 如果没有传入选中的图层组，返回基于显示顺序推断的最高优先级图层
    return _getHighestPriorityLayers();
  }

  /// 获取最高优先级的图层组（基于显示顺序或其他逻辑）
  List<MapLayer> _getHighestPriorityLayers() {
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return [];
    }

    // 按 order 字段排序，获取最高优先级的图层
    final sortedLayers = List<MapLayer>.from(widget.allLayers!)
      ..sort((a, b) => b.order.compareTo(a.order)); // 降序排列，最高优先级在前

    // 返回前几个可见的图层作为最高优先级图层
    return sortedLayers.where((layer) => layer.isVisible).take(3).toList();
  }

  /// 显示不允许选择的提示对话框
  void _showSelectionNotAllowedDialog() {
    String message = '';

    if (!_currentGroup.isVisible) {
      message = '无法选择图例：图例组当前不可见，请先显示图例组';
    } else {
      message = '无法选择图例：请先选择一个绑定了此图例组的图层';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择受限'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 更新图例项
  void _updateLegendItem(LegendItem updatedItem) {
    final updatedItems = _currentGroup.legendItems.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    _updateGroup(_currentGroup.copyWith(legendItems: updatedItems));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // 管理图例组宽度
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.legend_toggle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentGroup.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    // if (!widget.isPreviewMode)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: _showEditNameDialog,
                      tooltip: '编辑名称',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '管理图例组中的图例',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1), // 图例组设置
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 可见性和透明度控制
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _currentGroup.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                      ),
                      onPressed: () => _updateGroup(
                        _currentGroup.copyWith(
                          isVisible: !_currentGroup.isVisible,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('透明度:', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: _currentGroup.opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(_currentGroup.opacity * 100).round()}%',
                        onChanged: (value) => _updateGroup(
                          _currentGroup.copyWith(opacity: value),
                        ),
                      ),
                    ),
                  ],
                ),

                // 智能隐藏设置
                if (widget.allLayers != null &&
                    widget.allLayers!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha((0.3 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
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
                            Expanded(
                              child: Text(
                                '智能隐藏',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Switch(
                              value: _isSmartHidingEnabled,
                              onChanged: _toggleSmartHiding,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildSmartHidingDescription(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 标签管理
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.label,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '图例组标签',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.isPreviewMode)
                      TextButton.icon(
                        onPressed: _showTagsManagerDialog,
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('管理', style: TextStyle(fontSize: 12)),
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
                const SizedBox(height: 8),
                _buildTagsDisplay(),
              ],
            ),
          ),

          const Divider(),

          // 图例列表
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '图例列表 (${_currentGroup.legendItems.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // if (!widget.isPreviewMode)
                      ElevatedButton.icon(
                        onPressed: _showAddLegendDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('添加图例'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _currentGroup.legendItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.legend_toggle_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '此图例组暂无图例',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _currentGroup.legendItems.length,
                          itemBuilder: (context, index) {
                            return _buildLegendItemTile(
                              _currentGroup.legendItems[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItemTile(LegendItem item) {
    final legend = widget.availableLegends.firstWhere(
      (l) => l.id.toString() == item.legendId,
      orElse: () => legend_db.LegendItem(
        title: '未知图例',
        centerX: 0.0,
        centerY: 0.0,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isLegendItemSelected(item)
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha((0.3 * 255).toInt())
            : null,
        borderRadius: BorderRadius.circular(12),
        border: _isLegendItemSelected(item)
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _selectLegendItem(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图例标题和操作按钮
                Row(
                  children: [
                    // 图例图片预览
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isLegendItemSelected(item)
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: _isLegendItemSelected(item) ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: legend.hasImageData
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                legend.imageData!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              size: 24,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(width: 12),
                    // 标题和信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            legend.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isLegendItemSelected(item)
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '位置: (${item.position.dx.toStringAsFixed(2)}, ${item.position.dy.toStringAsFixed(2)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 可见性切换
                    IconButton(
                      icon: Icon(
                        item.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                        color: item.isVisible ? null : Colors.grey,
                      ),
                      onPressed: () => _updateLegendItem(
                        item.copyWith(isVisible: !item.isVisible),
                      ),
                      // onPressed: widget.isPreviewMode
                      //     ? null
                      //     : () => _updateLegendItem(
                      //         item.copyWith(isVisible: !item.isVisible),
                      //       ),
                      tooltip: item.isVisible ? '隐藏' : '显示',
                    ),
                    // 更多操作
                    // if (!widget.isPreviewMode)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 16),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 14, color: Colors.red),
                              SizedBox(width: 8),
                              Text('删除', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteLegendItem(item);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 控制滑块
                // if (!widget.isPreviewMode)
                ...[
                  // 大小控制
                  _buildSliderControl(
                    label: '大小',
                    value: item.size,
                    min: 0.1,
                    max: 3.0,
                    divisions: 29,
                    displayValue: '${item.size.toStringAsFixed(1)}x',
                    onChanged: (value) =>
                        _updateLegendItem(item.copyWith(size: value)),
                  ),

                  const SizedBox(height: 8),

                  // 旋转角度控制
                  _buildSliderControl(
                    label: '旋转',
                    value: item.rotation,
                    min: 0.0,
                    max: 360.0,
                    divisions: 72,
                    displayValue: '${item.rotation.toStringAsFixed(0)}°',
                    onChanged: (value) =>
                        _updateLegendItem(item.copyWith(rotation: value)),
                  ),
                  const SizedBox(height: 8),

                  // 透明度控制
                  _buildSliderControl(
                    label: '透明度',
                    value: item.opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    displayValue: '${(item.opacity * 100).round()}%',
                    onChanged: (value) =>
                        _updateLegendItem(item.copyWith(opacity: value)),
                  ),

                  const SizedBox(height: 12),

                  // URL编辑字段
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '链接设置',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: '图例链接 (可选)',
                            hintText: '输入网络链接或选择VFS文件',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.url != null && item.url!.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      size: 16,
                                    ),
                                    tooltip: '打开链接',
                                    onPressed: () => _openUrl(item.url!),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.folder, size: 16),
                                  tooltip: '选择VFS文件',
                                  onPressed: () async {
                                    final selectedFile =
                                        await _showVfsFilePicker();
                                    if (selectedFile != null) {
                                      _updateLegendItem(
                                        item.copyWith(url: selectedFile),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          controller: TextEditingController(
                            text: item.url ?? '',
                          ),
                          onChanged: (value) {
                            _updateLegendItem(
                              item.copyWith(
                                url: value.trim().isEmpty ? null : value.trim(),
                              ),
                            );
                          },
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 标签管理
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.label,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '标签',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _editLegendItemTags(item),
                              icon: const Icon(Icons.edit, size: 12),
                              label: const Text(
                                '编辑',
                                style: TextStyle(fontSize: 10),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildLegendItemTagsDisplay(item.tags ?? []),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            displayValue,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _updateGroup(LegendGroup updatedGroup) {
    setState(() {
      _currentGroup = updatedGroup.copyWith(updatedAt: DateTime.now());
    });
    widget.onLegendGroupUpdated(_currentGroup);

    // 延迟执行检查，避免在setState期间再次调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSmartHiding();
    });
  }

  /// 应用智能隐藏逻辑
  void _applySmartHidingLogic() {
    if (!_isSmartHidingEnabled) return; // 只有启用智能隐藏才应用逻辑
    if (!mounted) return; // 确保组件仍然挂载

    final shouldHide = _shouldSmartHideGroup();
    final shouldShow = _shouldSmartShowGroup();

    // 双向智能控制：
    // 1. 当所有绑定图层都隐藏时，自动隐藏图例组
    if (shouldHide && _currentGroup.isVisible) {
      setState(() {
        _currentGroup = _currentGroup.copyWith(
          isVisible: false,
          updatedAt: DateTime.now(),
        );
      });
      widget.onLegendGroupUpdated(_currentGroup);
    }
    // 2. 当有绑定图层重新显示时，自动显示图例组
    else if (shouldShow && !_currentGroup.isVisible) {
      setState(() {
        _currentGroup = _currentGroup.copyWith(
          isVisible: true,
          updatedAt: DateTime.now(),
        );
      });
      widget.onLegendGroupUpdated(_currentGroup);
    }
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _currentGroup.name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑图例组名称'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '图例组名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _updateGroup(
                  _currentGroup.copyWith(name: nameController.text.trim()),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddLegendDialog() {
    if (widget.availableLegends.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂无可用图例，请先在图例管理页面添加图例')));
      return;
    }
    legend_db.LegendItem? selectedLegend;
    // 设置更合理的默认位置 - 避免总是在中心，使用较为随机的初始位置
    final baseX = 0.2; // 左侧起始位置
    final baseY = 0.2; // 顶部起始位置
    final offsetX = (_currentGroup.legendItems.length * 0.1) % 0.6; // 水平偏移
    final offsetY =
        ((_currentGroup.legendItems.length ~/ 6) * 0.1) % 0.6; // 垂直偏移

    double positionX = (baseX + offsetX).clamp(0.1, 0.9);
    double positionY = (baseY + offsetY).clamp(0.1, 0.9);
    double size = 1.0;
    double rotation = 0.0;
    String url = ''; // 图例链接URL
    List<String> itemTags = []; // 图例项标签
    final urlController = TextEditingController(text: url);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加图例'),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<legend_db.LegendItem>(
                  value: selectedLegend,
                  decoration: const InputDecoration(
                    labelText: '选择图例',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.availableLegends.map((legend) {
                    return DropdownMenuItem(
                      value: legend,
                      child: Text(legend.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedLegend = value);
                  },
                ),
                const SizedBox(height: 16),

                // URL输入字段
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: '图例链接 (可选)',
                    hintText: '输入网络链接或选择VFS文件',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder),
                      tooltip: '选择VFS文件',
                      onPressed: () async {
                        final selectedFile = await _showVfsFilePicker();
                        if (selectedFile != null) {
                          setState(() {
                            url = selectedFile;
                            urlController.text = selectedFile;
                          });
                        }
                      },
                    ),
                  ),
                  onChanged: (value) {
                    url = value;
                  },
                ),
                const SizedBox(height: 16),

                // 标签管理
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.label,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '图例项标签',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _showLegendItemTagsDialog(itemTags)
                                .then((newTags) {
                                  if (newTags != null) {
                                    setState(() {
                                      itemTags = newTags;
                                    });
                                  }
                                }),
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text(
                              '管理',
                              style: TextStyle(fontSize: 12),
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
                      const SizedBox(height: 8),
                      _buildLegendItemTagsDisplay(itemTags),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'X坐标',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: positionX.toString(),
                        ),
                        onChanged: (value) {
                          positionX = double.tryParse(value) ?? positionX;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Y坐标',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: positionY.toString(),
                        ),
                        onChanged: (value) {
                          positionY = double.tryParse(value) ?? positionY;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '大小',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: size.toString(),
                        ),
                        onChanged: (value) {
                          size = double.tryParse(value) ?? size;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '旋转角度',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: rotation.toString(),
                        ),
                        onChanged: (value) {
                          rotation = double.tryParse(value) ?? rotation;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: selectedLegend != null
                  ? () {
                      final newItem = LegendItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        legendId: selectedLegend!.id.toString(),
                        position: Offset(positionX, positionY),
                        size: size,
                        rotation: rotation,
                        url: url.trim().isEmpty ? null : url.trim(), // 添加URL字段
                        tags: itemTags.isNotEmpty ? itemTags : null, // 添加标签字段
                        createdAt: DateTime.now(),
                      );

                      final updatedGroup = _currentGroup.copyWith(
                        legendItems: [..._currentGroup.legendItems, newItem],
                      );
                      _updateGroup(updatedGroup);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLegendItem(LegendItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图例'),
        content: const Text('确定要删除此图例吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedItems = _currentGroup.legendItems
                  .where((i) => i.id != item.id)
                  .toList();
              final updatedGroup = _currentGroup.copyWith(
                legendItems: updatedItems,
              );
              _updateGroup(updatedGroup);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 智能隐藏相关方法
  /// 检查智能隐藏状态
  void _checkSmartHiding() {
    // 智能隐藏开关状态不会自动改变，只能由用户手动控制
    // 这里只是检查如果启用了智能隐藏，是否需要应用智能隐藏逻辑
    if (_isSmartHidingEnabled) {
      _applySmartHidingLogic();
    }
  }

  /// 判断是否应该智能隐藏该图例组
  /// 条件：当所有绑定到该图例组的图层都隐藏时，返回true
  bool _shouldSmartHideGroup() {
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return false;
    }

    // 找到所有绑定了当前图例组的图层
    final boundLayers = widget.allLayers!.where((layer) {
      return layer.legendGroupIds.contains(_currentGroup.id);
    }).toList();

    // 如果没有图层绑定到这个图例组，不智能隐藏
    if (boundLayers.isEmpty) {
      return false;
    }

    // 检查所有绑定的图层是否都隐藏了
    return boundLayers.every((layer) => !layer.isVisible);
  }

  /// 判断是否应该智能显示该图例组
  /// 条件：当有任意绑定到该图例组的图层显示时，返回true
  bool _shouldSmartShowGroup() {
    if (widget.allLayers == null || widget.allLayers!.isEmpty) {
      return false;
    }

    // 找到所有绑定了当前图例组的图层
    final boundLayers = widget.allLayers!.where((layer) {
      return layer.legendGroupIds.contains(_currentGroup.id);
    }).toList();

    // 如果没有图层绑定到这个图例组，不智能显示
    if (boundLayers.isEmpty) {
      return false;
    }

    // 检查是否有任意绑定的图层是可见的
    return boundLayers.any((layer) => layer.isVisible);
  }

  /// 获取绑定了当前图例组的图层列表
  List<MapLayer> _getBoundLayers() {
    if (widget.allLayers == null) return [];
    return widget.allLayers!.where((layer) {
      return layer.legendGroupIds.contains(_currentGroup.id);
    }).toList();
  }

  /// 切换智能隐藏开关
  void _toggleSmartHiding(bool enabled) {
    setState(() {
      _isSmartHidingEnabled = enabled;
    });

    // 如果启用智能隐藏，立即应用双向逻辑
    if (enabled) {
      final shouldHide = _shouldSmartHideGroup();
      final shouldShow = _shouldSmartShowGroup();

      if (shouldHide && _currentGroup.isVisible) {
        _updateGroup(_currentGroup.copyWith(isVisible: false));
      } else if (shouldShow && !_currentGroup.isVisible) {
        _updateGroup(_currentGroup.copyWith(isVisible: true));
      }
    }
    // 如果禁用智能隐藏，不改变当前显示状态，让用户手动控制
  }

  /// 构建智能隐藏的描述文本
  String _buildSmartHidingDescription() {
    final boundLayers = _getBoundLayers();

    if (boundLayers.isEmpty) {
      return '当前图例组未绑定任何图层';
    }

    final hiddenLayersCount = boundLayers
        .where((layer) => !layer.isVisible)
        .length;
    final totalLayersCount = boundLayers.length;

    if (_isSmartHidingEnabled) {
      if (hiddenLayersCount == totalLayersCount) {
        return '已启用：绑定的 $totalLayersCount 个图层均已隐藏，图例组已自动隐藏';
      } else {
        final visibleLayersCount = totalLayersCount - hiddenLayersCount;
        return '已启用：绑定的 $totalLayersCount 个图层中有 $visibleLayersCount 个可见，图例组已自动显示';
      }
    } else {
      return '启用后，根据绑定图层的可见性自动控制图例组显示/隐藏（共 $totalLayersCount 个图层）';
    }
  }

  /// 显示VFS文件选择器
  Future<String?> _showVfsFilePicker() async {
    try {
      final selectedFile = await VfsFileManagerWindow.showFilePicker(
        context,
        allowDirectorySelection: false,
        selectionType: SelectionType.filesOnly,
      );
      return selectedFile;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('文件选择失败: $e')));
      return null;
    }
  }

  /// 打开URL链接
  Future<void> _openUrl(String url) async {
    try {
      if (url.startsWith('indexeddb://')) {
        // VFS协议链接，使用VFS文件打开服务
        await VfsFileOpenerService.openFile(context, url);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        // 网络链接，使用系统默认浏览器
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showErrorMessage('无法打开链接: $url');
        }
      } else {
        _showErrorMessage('不支持的链接格式: $url');
      }
    } catch (e) {
      _showErrorMessage('打开链接失败: $e');
    }
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 显示图例组标签管理对话框
  void _showTagsManagerDialog() async {
    final currentTags = _currentGroup.tags ?? [];

    final result = await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理图例组标签 - ${_currentGroup.name}',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getLegendGroupSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );

    if (result != null) {
      final updatedGroup = _currentGroup.copyWith(
        tags: result,
        updatedAt: DateTime.now(),
      );
      _updateGroup(updatedGroup);

      if (result.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已清空图例组标签')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图例组标签已更新 (${result.length}个标签)')),
        );
      }
    }
  }

  /// 构建图例组标签显示
  Widget _buildTagsDisplay() {
    final tags = _currentGroup.tags ?? [];

    if (tags.isEmpty) {
      return Text(
        '暂无标签',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// 获取图例组建议标签
  List<String> _getLegendGroupSuggestedTags() {
    return [
      '建筑',
      '房间',
      '入口',
      '装置',
      '掩体',
      '路径',
      '标记',
      '战术',
      '重要',
      '可破坏',
      '陷阱',
      '监控',
    ];
  }

  /// 显示图例项标签管理对话框
  Future<List<String>?> _showLegendItemTagsDialog(
    List<String> currentTags,
  ) async {
    return await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理图例项标签',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getLegendItemSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );
  }

  /// 构建图例项标签显示
  Widget _buildLegendItemTagsDisplay(List<String> tags) {
    if (tags.isEmpty) {
      return Text(
        '暂无标签',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// 获取图例项建议标签
  List<String> _getLegendItemSuggestedTags() {
    return [
      '入口',
      '楼梯',
      '电梯',
      '窗户',
      '门',
      '墙',
      '掩体',
      '装置',
      '摄像头',
      '陷阱',
      '可破坏',
      '重要',
    ];
  }

  /// 编辑图例项标签
  void _editLegendItemTags(LegendItem item) async {
    final currentTags = item.tags ?? [];

    final result = await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理图例项标签',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getLegendItemSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );

    if (result != null) {
      final updatedItem = item.copyWith(
        tags: result.isNotEmpty ? result : null,
      );
      _updateLegendItem(updatedItem);

      if (result.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已清空图例项标签')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图例项标签已更新 (${result.length}个标签)')),
        );
      }
    }
  }
}
