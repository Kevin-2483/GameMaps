import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/common/radial_gesture_menu.dart';
import '../../../models/map_item.dart';
import '../../../models/map_layer.dart';
import '../../../models/sticky_note.dart';
import '../../../providers/user_preferences_provider.dart';

/// 地图编辑器径向菜单集成组件
class MapEditorRadialMenu extends StatefulWidget {
  final Widget child;
  final MapItem currentMap;
  final DrawingElementType? selectedDrawingTool;
  final MapLayer? selectedLayer;
  final List<MapLayer>? selectedLayerGroup;
  final StickyNote? selectedStickyNote;
  final Function(DrawingElementType?) onDrawingToolSelected;
  final Function(MapLayer?) onLayerSelected;
  final Function(List<MapLayer>?) onLayerGroupSelected;
  final Function(StickyNote?) onStickyNoteSelected;
  final Function(Color) onColorSelected;
  final VoidCallback? onCancel;
  final Offset? position;

  const MapEditorRadialMenu({
    super.key,
    required this.child,
    required this.currentMap,
    this.selectedDrawingTool,
    this.selectedLayer,
    this.selectedLayerGroup,
    this.selectedStickyNote,
    required this.onDrawingToolSelected,
    required this.onLayerSelected,
    required this.onLayerGroupSelected,
    required this.onStickyNoteSelected,
    required this.onColorSelected,
    this.onCancel,
    this.position,
  });

  @override
  State<MapEditorRadialMenu> createState() => _MapEditorRadialMenuState();
}

class _MapEditorRadialMenuState extends State<MapEditorRadialMenu> {
  /// 获取绘图工具菜单项
  List<RadialMenuItem> _getDrawingToolItems() {
    return [
      RadialMenuItem(
        id: 'clear_drawing_tool',
        icon: Icons.clear,
        label: '',
        onTap: () => widget.onDrawingToolSelected(null),
      ),
      RadialMenuItem(
        id: 'line',
        icon: Icons.remove,
        label: '',
        onTap: () => widget.onDrawingToolSelected(DrawingElementType.line),
      ),
      RadialMenuItem(
        id: 'dashed_line',
        icon: Icons.more_horiz,
        label: '',
        onTap: () =>
            widget.onDrawingToolSelected(DrawingElementType.dashedLine),
      ),
      RadialMenuItem(
        id: 'arrow',
        icon: Icons.arrow_forward,
        label: '',
        onTap: () => widget.onDrawingToolSelected(DrawingElementType.arrow),
      ),
      RadialMenuItem(
        id: 'rectangle',
        icon: Icons.rectangle,
        label: '',
        onTap: () => widget.onDrawingToolSelected(DrawingElementType.rectangle),
      ),
      RadialMenuItem(
        id: 'hollow_rectangle',
        icon: Icons.rectangle_outlined,
        label: '',
        onTap: () =>
            widget.onDrawingToolSelected(DrawingElementType.hollowRectangle),
      ),
      RadialMenuItem(
        id: 'text',
        icon: Icons.text_fields,
        label: '',
        onTap: () => widget.onDrawingToolSelected(DrawingElementType.text),
      ),
      RadialMenuItem(
        id: 'eraser',
        icon: Icons.content_cut,
        label: '',
        onTap: () => widget.onDrawingToolSelected(DrawingElementType.eraser),
      ),
      RadialMenuItem(
        id: 'free_drawing',
        icon: Icons.gesture,
        label: '',
        onTap: () =>
            widget.onDrawingToolSelected(DrawingElementType.freeDrawing),
      ),
    ];
  }

  /// 获取图层组菜单项
  List<RadialMenuItem> _getLayerGroupItems() {
    final List<RadialMenuItem> items = [
      RadialMenuItem(
        id: 'clear_layer_group',
        icon: Icons.clear,
        label: '',
        color: Colors.red,
        onTap: () => widget.onLayerGroupSelected(null),
      ),
    ];

    // 获取所有图层组
    final groups = _groupLinkedLayers();

    // 计算图层组在列表中的位置（最上层的组序号最大）
    int currentValidIndex = 0;
    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      if (group.length > 1) {
        currentValidIndex++;
        // 计算在列表中的位置序号（最上层的组序号最大）
        final positionIndex = currentValidIndex;

        // 只显示序号1-9的图层组
        if (positionIndex <= 9) {
          items.add(
            RadialMenuItem(
              id: 'layer_group_$i',
              icon: _getNumberIcon(positionIndex),
              label: '', // 不显示文字
              onTap: () => widget.onLayerGroupSelected(group),
            ),
          );
        }
      }
    }

    if (items.length == 1) {
      items.add(
        RadialMenuItem(
          id: 'no_layer_groups',
          icon: Icons.info_outline,
          label: '暂无图层组',
          onTap: () {},
        ),
      );
    }

    return items;
  }

  /// 获取图层菜单项
  List<RadialMenuItem> _getLayerItems() {
    final List<RadialMenuItem> items = [
      RadialMenuItem(
        id: 'clear_layer',
        icon: Icons.clear,
        label: '',
        color: Colors.red,
        onTap: () => widget.onLayerSelected(null),
      ),
    ];

    // 根据选中的图层组过滤图层
    List<MapLayer> layersToShow;
    if (widget.selectedLayerGroup != null &&
        widget.selectedLayerGroup!.isNotEmpty) {
      // 如果选中了图层组，只显示该组的图层
      final selectedGroupLayerIds = widget.selectedLayerGroup!
          .map((l) => l.id)
          .toSet();
      layersToShow = widget.currentMap.layers
          .where((layer) => selectedGroupLayerIds.contains(layer.id))
          .toList();
    } else {
      // 如果没有选中图层组，显示所有图层
      layersToShow = widget.currentMap.layers;
    }

    // 获取图层组信息用于颜色划分
    final groups = _groupLinkedLayers();
    final groupColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.lime,
    ];

    for (int i = 0; i < layersToShow.length; i++) {
      final layer = layersToShow[i];

      IconData? iconToUse;
      String labelToUse = layer.name.isNotEmpty ? layer.name : '未命名图层';
      Color? layerColor;

      if (widget.selectedLayerGroup != null &&
          widget.selectedLayerGroup!.isNotEmpty) {
        // 选中图层组时，使用 looks 系列图标（最多6个）
        if (i < 6) {
          iconToUse = _getLooksIcon(i + 1);
        }
        // 超过6个图层时，iconToUse 保持为 null，不显示图标
      } else {
        // 没有选中图层组时，按图层组进行颜色划分
        // 查找图层所属的组
        int groupIndex = -1;
        for (int j = 0; j < groups.length; j++) {
          if (groups[j].any((groupLayer) => groupLayer.id == layer.id)) {
            groupIndex = j;
            break;
          }
        }

        if (groupIndex >= 0 && groups[groupIndex].length > 1) {
          // 属于图层组，使用组对应的颜色
          layerColor = groupColors[groupIndex % groupColors.length];
        } else {
          // 不属于组，使用父菜单颜色（橙色）
          layerColor = Colors.orange;
        }

        if (layersToShow.length <= 6) {
          // 不超过6个图层时，显示数字序号图标，不显示文字
          iconToUse = _getLooksIcon(i + 1);
          labelToUse = ''; // 不显示文字
        } else {
          // 超过6个图层时，不显示图标，名称显示为编号
          iconToUse = null; // 不显示图标
          labelToUse = '${i + 1}'; // 名称显示为编号
        }
      }

      items.add(
        RadialMenuItem(
          id: 'layer_${layer.id}',
          icon: iconToUse,
          label: labelToUse,
          color: layerColor,
          onTap: () => widget.onLayerSelected(layer),
        ),
      );
    }

    return items;
  }

  /// 获取最近使用颜色菜单项
  List<RadialMenuItem> _getRecentColorItems() {
    final userPrefs = context.read<UserPreferencesProvider>();
    final recentColors = userPrefs.tools.recentColors;

    final List<RadialMenuItem> items = [];

    for (int i = 0; i < recentColors.length && i < 6; i++) {
      final colorValue = recentColors[i];
      final color = Color(colorValue);

      items.add(
        RadialMenuItem(
          id: 'recent_color_$i',
          icon: null,
          color: color,
          label: '',
          onTap: () => widget.onColorSelected(color),
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        RadialMenuItem(
          id: 'no_recent_colors',
          icon: Icons.info_outline,
          label: '暂无最近颜色',
          onTap: () {},
        ),
      );
    }

    return items;
  }

  /// 获取便签菜单项
  List<RadialMenuItem> _getStickyNoteItems() {
    final List<RadialMenuItem> items = [
      RadialMenuItem(
        id: 'clear_sticky_note',
        icon: Icons.clear,
        label: '',
        color: Colors.red,
        onTap: () => widget.onStickyNoteSelected(null),
      ),
    ];

    for (final note in widget.currentMap.stickyNotes) {
      // 优先显示标题，如果标题为空则显示内容，都为空则显示"空便签"
      String displayText;
      if (note.title.isNotEmpty) {
        displayText = note.title.length > 10
            ? '${note.title.substring(0, 10)}...'
            : note.title;
      } else if (note.content.isNotEmpty) {
        displayText = note.content.length > 10
            ? '${note.content.substring(0, 10)}...'
            : note.content;
      } else {
        displayText = '空便签';
      }
      
      items.add(
        RadialMenuItem(
          id: 'sticky_note_${note.id}',
          icon: Icons.sticky_note_2,
          label: displayText,
          onTap: () => widget.onStickyNoteSelected(note),
        ),
      );
    }

    return items;
  }

  /// 获取数字图标
  IconData _getNumberIcon(int number) {
    switch (number) {
      case 1:
        return Icons.filter_1;
      case 2:
        return Icons.filter_2;
      case 3:
        return Icons.filter_3;
      case 4:
        return Icons.filter_4;
      case 5:
        return Icons.filter_5;
      case 6:
        return Icons.filter_6;
      case 7:
        return Icons.filter_7;
      case 8:
        return Icons.filter_8;
      case 9:
        return Icons.filter_9;
      default:
        return Icons.layers;
    }
  }

  /// 获取 looks 系列图标
  IconData _getLooksIcon(int number) {
    switch (number) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.looks_4;
      case 5:
        return Icons.looks_5;
      case 6:
        return Icons.looks_6;
      default:
        return Icons.layers;
    }
  }

  /// 将图层分组为链接组
  List<List<MapLayer>> _groupLinkedLayers() {
    final groups = <List<MapLayer>>[];
    List<MapLayer> currentGroup = [];

    for (int i = 0; i < widget.currentMap.layers.length; i++) {
      final layer = widget.currentMap.layers[i];
      currentGroup.add(layer);

      // 安全访问 isLinkedToNext 属性
      final isLinked = layer.isLinkedToNext;

      // 如果当前图层不链接到下一个，或者是最后一个图层，结束当前组
      if (!isLinked || i == widget.currentMap.layers.length - 1) {
        groups.add(List.from(currentGroup));
        currentGroup.clear();
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = context.read<UserPreferencesProvider>();
    final radialMenuPrefs = userPrefs.mapEditor;

    return RadialGestureMenu(
      child: widget.child,
      menuItems: [
        RadialMenuItem(
          id: 'drawing_tools',
          icon: Icons.brush,
          label: '绘图工具',
          color: Colors.blue,
          subItems: _getDrawingToolItems(),
        ),
        RadialMenuItem(
          id: 'recent_colors',
          icon: Icons.palette,
          label: '最近颜色',
          color: Colors.purple,
          subItems: _getRecentColorItems(),
        ),
        RadialMenuItem(
          id: 'layer_groups',
          icon: Icons.layers,
          label: '图层组',
          color: Colors.green,
          subItems: _getLayerGroupItems(),
        ),
        RadialMenuItem(
          id: 'layers',
          icon: Icons.layers,
          label: '图层',
          color: Colors.orange,
          subItems: _getLayerItems(),
        ),
        RadialMenuItem(
          id: 'sticky_notes',
          icon: Icons.sticky_note_2,
          label: '便签',
          color: Colors.brown,
          subItems: _getStickyNoteItems(),
        ),
      ],
      onItemSelected: (item) {
        // 处理菜单项选择
      },
      radius: radialMenuPrefs.radialMenuRadius,
      centerRadius: radialMenuPrefs.radialMenuCenterRadius,
      opacity: radialMenuPrefs.radialMenuBackgroundOpacity,
      animationDuration: Duration(
        milliseconds: radialMenuPrefs.radialMenuAnimationDuration,
      ),
      plateColor: Theme.of(context).colorScheme.surface.withOpacity(
        radialMenuPrefs.radialMenuObjectOpacity,
      ),
      borderColor: Theme.of(context).colorScheme.outline,
      menuButton: radialMenuPrefs.radialMenuButton,
      returnDelay: Duration(
        milliseconds: radialMenuPrefs.radialMenuReturnDelay,
      ),
      subMenuDelay: Duration(
        milliseconds: radialMenuPrefs.radialMenuSubMenuDelay,
      ),
    );
  }
}
