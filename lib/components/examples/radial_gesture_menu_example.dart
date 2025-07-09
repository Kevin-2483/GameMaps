import 'package:flutter/material.dart';
import '../common/radial_gesture_menu.dart';
import '../../../services/notification/notification_service.dart';

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
            label: '小画笔',
            icon: Icons.brush,
            color: Colors.red.shade300,
            onTap: () => _onItemSelected('小画笔'),
          ),
          RadialMenuItem(
            id: 'brush_medium',
            label: '中画笔',
            icon: Icons.brush,
            color: Colors.red.shade500,
            onTap: () => _onItemSelected('中画笔'),
          ),
          RadialMenuItem(
            id: 'brush_large',
            label: '大画笔',
            icon: Icons.brush,
            color: Colors.red.shade700,
            onTap: () => _onItemSelected('大画笔'),
          ),
          RadialMenuItem(
            id: 'eraser',
            label: '橡皮擦',
            icon: Icons.auto_fix_high,
            color: Colors.grey,
            onTap: () => _onItemSelected('橡皮擦'),
          ),
        ],
        onTap: () => _onItemSelected('画笔'),
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
            label: '新建图层',
            icon: Icons.add,
            color: Colors.blue.shade300,
            onTap: () => _onItemSelected('新建图层'),
          ),
          RadialMenuItem(
            id: 'layer_duplicate',
            label: '复制图层',
            icon: Icons.copy,
            color: Colors.blue.shade500,
            onTap: () => _onItemSelected('复制图层'),
          ),
          RadialMenuItem(
            id: 'layer_delete',
            label: '删除图层',
            icon: Icons.delete,
            color: Colors.blue.shade700,
            onTap: () => _onItemSelected('删除图层'),
          ),
          RadialMenuItem(
            id: 'layer_merge',
            label: '合并图层',
            icon: Icons.merge,
            color: Colors.blue.shade900,
            onTap: () => _onItemSelected('合并图层'),
          ),
        ],
        onTap: () => _onItemSelected('图层'),
      ),

      // 图层组 (右侧)
      RadialMenuItem(
        id: 'layer_group',
        label: '图层组',
        icon: Icons.folder,
        color: Colors.green,
        subItems: [
          RadialMenuItem(
            id: 'group_create',
            label: '创建组',
            icon: Icons.create_new_folder,
            color: Colors.green.shade300,
            onTap: () => _onItemSelected('创建图层组'),
          ),
          RadialMenuItem(
            id: 'group_ungroup',
            label: '取消分组',
            icon: Icons.folder_open,
            color: Colors.green.shade500,
            onTap: () => _onItemSelected('取消分组'),
          ),
          RadialMenuItem(
            id: 'group_rename',
            label: '重命名组',
            icon: Icons.edit,
            color: Colors.green.shade700,
            onTap: () => _onItemSelected('重命名图层组'),
          ),
        ],
        onTap: () => _onItemSelected('图层组'),
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
            label: '文本便签',
            icon: Icons.text_fields,
            color: Colors.orange.shade300,
            onTap: () => _onItemSelected('文本便签'),
          ),
          RadialMenuItem(
            id: 'note_image',
            label: '图片便签',
            icon: Icons.image,
            color: Colors.orange.shade500,
            onTap: () => _onItemSelected('图片便签'),
          ),
          RadialMenuItem(
            id: 'note_voice',
            label: '语音便签',
            icon: Icons.mic,
            color: Colors.orange.shade700,
            onTap: () => _onItemSelected('语音便签'),
          ),
          RadialMenuItem(
            id: 'note_delete',
            label: '删除便签',
            icon: Icons.delete_outline,
            color: Colors.orange.shade900,
            onTap: () => _onItemSelected('删除便签'),
          ),
        ],
        onTap: () => _onItemSelected('便签'),
      ),
    ];
  }

  void _onItemSelected(String action) {
    setState(() {
      _selectedAction = action;
    });

    // 显示选择结果
    context.showInfoSnackBar('选择了: $action');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('轮盘手势菜单示例'),
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
            tooltip: '切换调试模式',
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
          print('菜单选择: ${item.label}');
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
              const Text(
                '使用中键或触摸板双指按下\n来调起轮盘菜单',
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
                    const Text(
                      '当前选择:',
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
                          '使用说明',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. 按住中键或触摸板双指按下调起菜单\n'
                      '2. 拖动到菜单项上会自动进入子菜单\n'
                      '3. 拖回中心区域返回主菜单\n'
                      '4. 松开鼠标/手指执行选择的动作\n'
                      '5. 开启调试模式可以看到连线和角度信息',
                      style: TextStyle(fontSize: 14, height: 1.4),
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
