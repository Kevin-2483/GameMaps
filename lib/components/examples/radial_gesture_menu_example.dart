// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../common/radial_gesture_menu.dart';
import '../../../services/notification/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// 轮盘手势菜单示例
class RadialGestureMenuExample extends StatefulWidget {
  const RadialGestureMenuExample({super.key});

  @override
  State<RadialGestureMenuExample> createState() =>
      _RadialGestureMenuExampleState();
}

class _RadialGestureMenuExampleState extends State<RadialGestureMenuExample> {
  String _selectedAction = '无选择';
  bool _debugMode = false;

  // 定义菜单项
  late List<RadialMenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _initializeMenuItems();
  }

  void _initializeMenuItems() {
    _menuItems = [
      // 画笔 (顶部)
      RadialMenuItem(
        id: 'brush',
        label: '画笔',
        icon: Icons.brush,
        color: Colors.red,
        subItems: [
          RadialMenuItem(
            id: 'brush_small',
            label: LocalizationService.instance.current.smallBrush_4821,
            icon: Icons.brush,
            color: Colors.red.shade300,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.smallBrush_4821,
            ),
          ),
          RadialMenuItem(
            id: 'brush_medium',
            label: LocalizationService.instance.current.mediumBrush_4821,
            icon: Icons.brush,
            color: Colors.red.shade500,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.mediumBrush_4821,
            ),
          ),
          RadialMenuItem(
            id: 'brush_large',
            label: LocalizationService.instance.current.largeBrush_4821,
            icon: Icons.brush,
            color: Colors.red.shade700,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.largeBrush_4821,
            ),
          ),
          RadialMenuItem(
            id: 'eraser',
            label: LocalizationService.instance.current.eraserTool_4821,
            icon: Icons.auto_fix_high,
            color: Colors.grey,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.eraserItem_4821,
            ),
          ),
        ],
        onTap: () => _onItemSelected(
          LocalizationService.instance.current.brushTool_4821,
        ),
      ),

      // 图层 (左侧)
      RadialMenuItem(
        id: 'layer',
        label: '图层',
        icon: Icons.layers,
        color: Colors.blue,
        subItems: [
          RadialMenuItem(
            id: 'layer_new',
            label: LocalizationService.instance.current.createNewLayer_4821,
            icon: Icons.add,
            color: Colors.blue.shade300,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.createNewLayer_4821,
            ),
          ),
          RadialMenuItem(
            id: 'layer_duplicate',
            label: LocalizationService.instance.current.duplicateLayer_4821,
            icon: Icons.copy,
            color: Colors.blue.shade500,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.copyLayer_4821,
            ),
          ),
          RadialMenuItem(
            id: 'layer_delete',
            label: LocalizationService.instance.current.deleteLayer_4821,
            icon: Icons.delete,
            color: Colors.blue.shade700,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.deleteLayer_4821,
            ),
          ),
          RadialMenuItem(
            id: 'layer_merge',
            label: LocalizationService.instance.current.mergeLayers_7281,
            icon: Icons.merge,
            color: Colors.blue.shade900,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.mergeLayers_7281,
            ),
          ),
        ],
        onTap: () =>
            _onItemSelected(LocalizationService.instance.current.layer_4821),
      ),

      // 图层组 (右侧)
      RadialMenuItem(
        id: 'layer_group',
        label: LocalizationService.instance.current.layerGroup_7281,
        icon: Icons.folder,
        color: Colors.green,
        subItems: [
          RadialMenuItem(
            id: 'group_create',
            label: LocalizationService.instance.current.createGroup_4821,
            icon: Icons.create_new_folder,
            color: Colors.green.shade300,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.createLayerGroup_7532,
            ),
          ),
          RadialMenuItem(
            id: 'group_ungroup',
            label: LocalizationService.instance.current.ungroupAction_4821,
            icon: Icons.folder_open,
            color: Colors.green.shade500,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.ungroupAction_4821,
            ),
          ),
          RadialMenuItem(
            id: 'group_rename',
            label: LocalizationService.instance.current.renameGroup_4821,
            icon: Icons.edit,
            color: Colors.green.shade700,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.renameLayerGroup_7539,
            ),
          ),
        ],
        onTap: () => _onItemSelected(
          LocalizationService.instance.current.layerGroup_7281,
        ),
      ),

      // 便签 (底部)
      RadialMenuItem(
        id: 'note',
        label: '便签',
        icon: Icons.note,
        color: Colors.orange,
        subItems: [
          RadialMenuItem(
            id: 'note_text',
            label: LocalizationService.instance.current.textNoteLabel_4821,
            icon: Icons.text_fields,
            color: Colors.orange.shade300,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.textNoteLabel_4821,
            ),
          ),
          RadialMenuItem(
            id: 'note_image',
            label: LocalizationService.instance.current.imageNoteLabel_4821,
            icon: Icons.image,
            color: Colors.orange.shade500,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.imageNoteLabel_4821,
            ),
          ),
          RadialMenuItem(
            id: 'note_voice',
            label: LocalizationService.instance.current.voiceNoteLabel_7281,
            icon: Icons.mic,
            color: Colors.orange.shade700,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.voiceNote_7281,
            ),
          ),
          RadialMenuItem(
            id: 'note_delete',
            label: LocalizationService.instance.current.deleteNoteLabel_4821,
            icon: Icons.delete_outline,
            color: Colors.orange.shade900,
            onTap: () => _onItemSelected(
              LocalizationService.instance.current.deleteNote_7421,
            ),
          ),
        ],
        onTap: () =>
            _onItemSelected(LocalizationService.instance.current.noteItem_4821),
      ),
    ];
  }

  void _onItemSelected(String action) {
    setState(() {
      _selectedAction = action;
    });

    // 显示选择结果
    context.showInfoSnackBar(
      LocalizationService.instance.current.selectedAction_7421(action),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.current.rouletteGestureMenuExample_4271,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _debugMode ? Icons.bug_report : Icons.bug_report_outlined,
            ),
            onPressed: () {
              setState(() {
                _debugMode = !_debugMode;
              });
            },
            tooltip: LocalizationService.instance.current.toggleDebugMode_4721,
          ),
        ],
      ),
      body: RadialGestureMenu(
        menuItems: _menuItems,
        radius: 140.0,
        centerRadius: 40.0,
        opacity: 1.0,
        plateColor: Colors.black,
        animationDuration: const Duration(milliseconds: 300),
        debugMode: _debugMode,
        onItemSelected: (item) {
          print(
            LocalizationService.instance.current.menuSelection_7281(item.label),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                LocalizationService.instance.current.wheelMenuInstruction_4521,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .currentSelection_4821,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAction,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          LocalizationService
                              .instance
                              .current
                              .usageInstructions_4521,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .radialMenuInstructions_7281,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
