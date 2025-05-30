import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../components/web/web_context_menu_handler.dart';
import '../../components/layout/main_layout.dart';
import '../../components/layout/page_configuration.dart';

/// Web右键菜单测试页面
class WebContextMenuDemoPage extends BasePage {
  const WebContextMenuDemoPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _WebContextMenuDemoContent();
  }
}

class _WebContextMenuDemoContent extends StatefulWidget {
  const _WebContextMenuDemoContent();

  @override
  State<_WebContextMenuDemoContent> createState() => _WebContextMenuDemoContentState();
}

class _WebContextMenuDemoContentState extends State<_WebContextMenuDemoContent> {
  int _selectedItemIndex = -1;
  final List<String> _items = List.generate(10, (index) => '项目 ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return WebContextMenuHandler(
      preventWebContextMenu: kIsWeb,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Web右键菜单演示'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文字
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Web平台右键菜单说明',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '当前平台: ${kIsWeb ? 'Web浏览器' : '桌面/移动设备'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kIsWeb ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '在Web平台上：\n'
                        '• 浏览器默认的右键菜单已被禁用\n'
                        '• 使用Flutter自定义的右键菜单\n'
                        '• 与桌面平台保持一致的交互体验\n\n'
                        '在桌面/移动平台上：\n'
                        '• 使用系统原生的右键菜单样式\n'
                        '• 保持平台原生的交互体验',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 演示区域
              Expanded(
                child: Row(
                  children: [
                    // 左侧：简单右键菜单演示
                    Expanded(
                      child: _buildSimpleDemo(),
                    ),
                    const SizedBox(width: 16),
                    
                    // 右侧：列表右键菜单演示
                    Expanded(
                      child: _buildListDemo(),
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

  Widget _buildSimpleDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '简单右键菜单',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // 可右键的区域
            Expanded(
              child: ContextMenuWrapper(
                menuBuilder: (context) => [
                  ContextMenuItem(
                    label: '新建',
                    icon: Icons.add,
                    onTap: () => _showMessage('新建项目'),
                  ),
                  ContextMenuItem(
                    label: '打开',
                    icon: Icons.folder_open,
                    onTap: () => _showMessage('打开文件'),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: '复制',
                    icon: Icons.copy,
                    onTap: () => _showMessage('已复制'),
                  ),
                  ContextMenuItem(
                    label: '粘贴',
                    icon: Icons.paste,
                    onTap: () => _showMessage('已粘贴'),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: '属性',
                    icon: Icons.settings,
                    onTap: () => _showMessage('显示属性'),
                  ),
                ],
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mouse, size: 48),
                        SizedBox(height: 8),
                        Text(
                          '右键点击这里',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '试试看右键菜单功能',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '列表项右键菜单',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // 列表
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isSelected = _selectedItemIndex == index;
                  
                  return ContextMenuWrapper(
                    menuBuilder: (context) => [
                      ContextMenuItem(
                        label: '查看详情',
                        icon: Icons.visibility,
                        onTap: () => _showMessage('查看 $item 详情'),
                      ),
                      ContextMenuItem(
                        label: '编辑',
                        icon: Icons.edit,
                        onTap: () => _showMessage('编辑 $item'),
                      ),
                      ContextMenuItem(
                        label: '重命名',
                        icon: Icons.edit,
                        onTap: () => _showRenameDialog(index),
                      ),
                      const ContextMenuItem.divider(),
                      ContextMenuItem(
                        label: '复制',
                        icon: Icons.copy,
                        onTap: () => _copyItem(index),
                      ),
                      ContextMenuItem(
                        label: '移动',
                        icon: Icons.move_up,
                        onTap: () => _showMessage('移动 $item'),
                      ),
                      const ContextMenuItem.divider(),
                      ContextMenuItem(
                        label: '删除',
                        icon: Icons.delete,
                        onTap: () => _deleteItem(index),
                      ),
                    ],
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        selected: isSelected,
                        selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        leading: CircleAvatar(
                          backgroundColor: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        title: Text(item),
                        subtitle: Text('右键查看选项 - ${kIsWeb ? 'Web模式' : '桌面模式'}'),
                        trailing: const Icon(Icons.more_vert),
                        onTap: () {
                          setState(() {
                            _selectedItemIndex = index;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyItem(int index) {
    setState(() {
      _items.insert(index + 1, '${_items[index]} (副本)');
    });
    _showMessage('已复制项目');
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${_items[index]}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _items.removeAt(index);
                if (_selectedItemIndex == index) {
                  _selectedItemIndex = -1;
                } else if (_selectedItemIndex > index) {
                  _selectedItemIndex--;
                }
              });
              _showMessage('已删除项目');
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(int index) {
    final TextEditingController controller = TextEditingController(
      text: _items[index],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '新名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _items[index] = controller.text.trim();
                });
                _showMessage('已重命名');
              }
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
