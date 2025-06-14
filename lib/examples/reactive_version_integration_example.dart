import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/reactive_version_manager.dart';
import '../services/reactive_version_adapter.dart';
import '../data/map_data_bloc.dart';
import '../data/map_data_state.dart';
import '../models/map_item.dart';

/// 响应式版本管理集成示例
/// 展示如何在地图编辑器中使用新的版本管理系统
class ReactiveVersionIntegrationExample extends StatefulWidget {
  const ReactiveVersionIntegrationExample({super.key});

  @override
  State<ReactiveVersionIntegrationExample> createState() =>
      _ReactiveVersionIntegrationExampleState();
}

class _ReactiveVersionIntegrationExampleState
    extends State<ReactiveVersionIntegrationExample>
    with ReactiveVersionMixin {
  late MapDataBloc _mapDataBloc;
  String _statusMessage = '未初始化';

  @override
  void initState() {
    super.initState();
    _initializeExample();
  }

  void _initializeExample() async {
    try {
      // 1. 创建地图数据BLoC（实际使用中从外部传入）
      // _mapDataBloc = MapDataBloc(mapService: yourMapService);

      // 2. 初始化版本管理（与现有地图编辑器集成）
      initializeVersionManagement(
        mapTitle: 'Test Map',
        mapDataBloc: _mapDataBloc,
      );

      // 3. 初始化默认版本
      await createVersion(
        'default',
        versionName: '默认版本',
      );

      setState(() {
        _statusMessage = '版本管理系统初始化完成';
      });

      debugPrint('响应式版本管理系统初始化完成');
    } catch (e) {
      setState(() {
        _statusMessage = '初始化失败: $e';
      });
      debugPrint('初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('响应式版本管理示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: hasUnsavedChanges ? _saveCurrentVersion : null,
            tooltip: '保存当前版本',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showDebugInfo,
            tooltip: '调试信息',
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('状态: $_statusMessage'),
                if (currentVersionId != null) 
                  Text('当前版本: $currentVersionId'),
                Text('未保存更改: ${hasUnsavedChanges ? '是' : '否'}'),
              ],
            ),
          ),

          // 版本列表
          Expanded(
            child: ListView.builder(
              itemCount: allVersionStates.length,
              itemBuilder: (context, index) {
                final versionState = allVersionStates[index];
                final isCurrentVersion = versionState.versionId == currentVersionId;
                
                return ListTile(
                  leading: Icon(
                    isCurrentVersion ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isCurrentVersion ? Colors.blue : Colors.grey,
                  ),
                  title: Text(versionState.versionName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${versionState.versionId}'),
                      Text('最后修改: ${versionState.lastModified.toString().substring(0, 19)}'),
                      if (versionState.hasUnsavedChanges)
                        const Text(
                          '有未保存的更改',
                          style: TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCurrentVersion)
                        IconButton(
                          icon: const Icon(Icons.switch_account),
                          onPressed: () => _switchToVersion(versionState.versionId),
                          tooltip: '切换到此版本',
                        ),
                      if (versionState.versionId != 'default')
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteVersion(versionState.versionId),
                          tooltip: '删除版本',
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewVersion,
        tooltip: '创建新版本',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 切换到指定版本
  void _switchToVersion(String versionId) async {
    try {
      setState(() {
        _statusMessage = '正在切换版本...';
      });

      await switchVersion(versionId);

      setState(() {
        _statusMessage = '已切换到版本: $versionId';
      });

      debugPrint('切换到版本: $versionId');
    } catch (e) {
      setState(() {
        _statusMessage = '切换版本失败: $e';
      });
      debugPrint('切换版本失败: $e');
    }
  }

  /// 创建新版本
  void _createNewVersion() async {
    final TextEditingController controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新版本'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '版本名称',
            hintText: '输入版本名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('创建'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final versionId = 'version_${DateTime.now().millisecondsSinceEpoch}';
        
        setState(() {
          _statusMessage = '正在创建版本...';
        });

        final newVersionState = await createVersion(
          versionId,
          versionName: result,
          sourceVersionId: currentVersionId, // 从当前版本复制
        );

        setState(() {
          _statusMessage = '创建版本成功: ${newVersionState?.versionName}';
        });

        debugPrint('创建版本成功: $versionId');
      } catch (e) {
        setState(() {
          _statusMessage = '创建版本失败: $e';
        });
        debugPrint('创建版本失败: $e');
      }
    }
  }

  /// 删除版本
  void _deleteVersion(String versionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除版本 "$versionId" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() {
          _statusMessage = '正在删除版本...';
        });

        await deleteVersion(versionId);

        setState(() {
          _statusMessage = '删除版本成功: $versionId';
        });

        debugPrint('删除版本成功: $versionId');
      } catch (e) {
        setState(() {
          _statusMessage = '删除版本失败: $e';
        });
        debugPrint('删除版本失败: $e');
      }
    }
  }

  /// 保存当前版本
  void _saveCurrentVersion() async {
    try {
      setState(() {
        _statusMessage = '正在保存...';
      });

      await saveCurrentVersion();

      setState(() {
        _statusMessage = '保存成功';
      });

      debugPrint('保存当前版本成功');
    } catch (e) {
      setState(() {
        _statusMessage = '保存失败: $e';
      });
      debugPrint('保存失败: $e');
    }
  }

  /// 显示调试信息
  void _showDebugInfo() {
    final debugInfo = versionAdapter?.getAdapterStatus();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('调试信息'),
        content: SingleChildScrollView(
          child: Text(
            debugInfo.toString(),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    disposeVersionManagement();
    _mapDataBloc.close();
    super.dispose();
  }
}

/// 在现有地图编辑器中集成的示例代码
/// 
/// 使用方法：
/// 
/// 1. 在地图编辑器页面中添加 ReactiveVersionMixin
/// ```dart
/// class _MapEditorPageState extends State<MapEditorPage> 
///     with MapEditorReactiveMixin, ReactiveVersionMixin {
/// ```
/// 
/// 2. 在初始化时设置版本管理
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   initializeVersionManagement(
///     mapTitle: widget.mapTitle ?? _currentMap?.title ?? 'Unknown',
///     mapDataBloc: reactiveIntegration.mapDataBloc,
///   );
/// }
/// ```
/// 
/// 3. 在需要的地方调用版本管理方法
/// ```dart
/// // 切换版本
/// await switchVersion('version_id');
/// 
/// // 创建版本
/// await createVersion('new_version_id', versionName: '新版本');
/// 
/// // 保存当前版本
/// await saveCurrentVersion();
/// 
/// // 检查未保存更改
/// if (hasUnsavedChanges) {
///   // 提示用户有未保存的更改
/// }
/// ```
/// 
/// 4. 在dispose时清理资源
/// ```dart
/// @override
/// void dispose() {
///   disposeVersionManagement();
///   super.dispose();
/// }
/// ```
