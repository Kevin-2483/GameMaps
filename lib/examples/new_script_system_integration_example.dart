import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/new_reactive_script_manager.dart';
import '../data/map_data_bloc.dart';
import '../models/script_data.dart';
import '../pages/map_editor/widgets/reactive_script_panel.dart';
import '../pages/map_editor/widgets/script_status_monitor.dart';
import '../pages/map_editor/widgets/script_editor_window_reactive.dart';

/// 新脚本系统集成示例
/// 展示如何在地图编辑器中使用新的异步脚本管理器
class NewScriptSystemIntegrationExample extends StatefulWidget {
  final MapDataBloc mapDataBloc;

  const NewScriptSystemIntegrationExample({
    super.key,
    required this.mapDataBloc,
  });

  @override
  State<NewScriptSystemIntegrationExample> createState() => 
      _NewScriptSystemIntegrationExampleState();
}

class _NewScriptSystemIntegrationExampleState 
    extends State<NewScriptSystemIntegrationExample> {
  late NewReactiveScriptManager _scriptManager;
  bool _showStatusMonitor = false;
  String? _editingScriptId;

  @override
  void initState() {
    super.initState();
    _initializeScriptManager();
  }

  /// 初始化脚本管理器
  Future<void> _initializeScriptManager() async {
    _scriptManager = NewReactiveScriptManager(mapDataBloc: widget.mapDataBloc);
    await _scriptManager.initialize();
    
    // 监听脚本状态变化
    _scriptManager.addListener(_onScriptManagerChanged);
    
    setState(() {
      // 触发UI更新
    });
  }

  /// 脚本管理器状态变化回调
  void _onScriptManagerChanged() {
    if (mounted) {
      setState(() {
        // 更新UI以反映脚本状态变化
      });
    }
  }

  @override
  void dispose() {
    _scriptManager.removeListener(_onScriptManagerChanged);
    _scriptManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新脚本系统演示'),
        actions: [
          // 状态监控器切换按钮
          IconButton(
            onPressed: () {
              setState(() {
                _showStatusMonitor = !_showStatusMonitor;
              });
            },
            icon: Icon(_showStatusMonitor ? Icons.visibility_off : Icons.monitor),
            tooltip: _showStatusMonitor ? '隐藏状态监控' : '显示状态监控',
          ),
          // 系统信息按钮
          IconButton(
            onPressed: _showSystemInfo,
            icon: const Icon(Icons.info),
            tooltip: '系统信息',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    return Column(
      children: [
        // 状态监控器（可折叠）
        if (_showStatusMonitor) ...[
          Container(
            padding: const EdgeInsets.all(16),
            child: ScriptStatusMonitor(
              scriptManager: _scriptManager,
              showDetailed: true,
            ),
          ),
          const Divider(height: 1),
        ],
        
        // 主要内容区域
        Expanded(
          child: Row(
            children: [
              // 左侧：脚本面板
              SizedBox(
                width: 320,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: ReactiveScriptPanel(
                    scriptManager: _scriptManager,
                    onNewScript: _createNewScript,
                  ),
                ),
              ),
              
              const VerticalDivider(width: 1),
              
              // 右侧：脚本编辑器或占位符
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
        
        // 底部状态栏
        _buildStatusBar(),
      ],
    );
  }

  /// 构建主要内容区域
  Widget _buildMainContent() {
    if (_editingScriptId != null) {
      final script = _scriptManager.scripts
          .firstWhere((s) => s.id == _editingScriptId);
      
      return ReactiveScriptEditorWindow(
        script: script,
        scriptManager: _scriptManager,
        onClose: () {
          setState(() {
            _editingScriptId = null;
          });
        },
      );
    }

    // 占位符内容
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '新异步脚本执行引擎',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '选择左侧脚本进行编辑，或创建新脚本开始使用',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          
          // 功能特性卡片
          _buildFeatureCards(),
          
          const SizedBox(height: 24),
          
          // 快速开始按钮
          Wrap(
            spacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _createNewScript,
                icon: const Icon(Icons.add),
                label: const Text('创建脚本'),
              ),
              OutlinedButton.icon(
                onPressed: _showSystemInfo,
                icon: const Icon(Icons.info),
                label: const Text('系统信息'),
              ),
              OutlinedButton.icon(
                onPressed: _runSystemTest,
                icon: const Icon(Icons.play_arrow),
                label: const Text('系统测试'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建功能特性卡片
  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.flash_on,
        'title': '异步执行',
        'description': '脚本在隔离环境运行，不阻塞UI',
      },
      {
        'icon': Icons.security,
        'title': '安全沙盒',
        'description': '脚本错误不会影响主程序',
      },
      {
        'icon': Icons.devices,
        'title': '跨平台',
        'description': 'Web Worker + Isolate 双引擎',
      },
      {
        'icon': Icons.speed,
        'title': '高性能',
        'description': '消息传递机制，响应迅速',
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // 紧凑状态监控器
          ScriptStatusMonitor(
            scriptManager: _scriptManager,
            showDetailed: false,
          ),
          
          const Spacer(),
          
          // 系统信息
          Text(
            '新异步脚本引擎 | 消息传递机制',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 创建新脚本
  void _createNewScript() {
    // 这里可以打开新脚本创建对话框
    // 或者直接创建一个示例脚本
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建新脚本功能待实现')),
    );
  }

  /// 显示系统信息
  void _showSystemInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新脚本系统信息'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('执行引擎', 
                kIsWeb ? 'Web Worker (浏览器)' : 'Dart Isolate (桌面)'),
              _buildInfoRow('脚本数量', '${_scriptManager.scripts.length}'),
              _buildInfoRow('启用脚本', 
                '${_scriptManager.scripts.where((s) => s.isEnabled).length}'),
              _buildInfoRow('运行中脚本', 
                '${_scriptManager.scriptStatuses.values.where((s) => s == ScriptStatus.running).length}'),
              _buildInfoRow('地图数据', 
                _scriptManager.hasMapData ? '已连接' : '未连接'),
              _buildInfoRow('架构特性', '异步隔离执行 + 消息传递'),
              _buildInfoRow('安全性', '沙盒环境 + 受控API'),
              const SizedBox(height: 16),
              Text(
                '新的脚本管理器采用现代化的异步架构，确保脚本执行不会阻塞用户界面，同时提供更好的安全性和性能。',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 运行系统测试
  void _runSystemTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('系统测试功能待实现')),
    );
  }
}
