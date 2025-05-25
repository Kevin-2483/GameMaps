import 'package:flutter/material.dart';
import '../../config/config_manager.dart';
import '../../config/app_config.dart';
import '../../components/common/config_aware_widgets.dart';

/// 配置编辑器页面
class ConfigEditorPage extends StatefulWidget {
  const ConfigEditorPage({super.key});

  @override
  State<ConfigEditorPage> createState() => _ConfigEditorPageState();
}

class _ConfigEditorPageState extends State<ConfigEditorPage> {
  late AppConfig _config;
  final Map<String, Map<String, bool>> _platformPageStates = {};
  final Map<String, Map<String, bool>> _platformFeatureStates = {};

  @override
  void initState() {
    super.initState();
    _config = ConfigManager.instance.config;
    _initializeStates();
  }

  void _initializeStates() {
    for (final entry in _config.platform.entries) {
      final platform = entry.key;
      final platformConfig = entry.value;
      
      _platformPageStates[platform] = {};
      _platformFeatureStates[platform] = {};
      
      // 初始化页面状态
      for (final page in _getAllPages()) {
        _platformPageStates[platform]![page] = platformConfig.hasPage(page);
      }
      
      // 初始化功能状态
      for (final feature in _getAllFeatures()) {
        _platformFeatureStates[platform]![feature] = platformConfig.hasFeature(feature);
      }
    }
  }

  List<String> _getAllPages() {
    return ['HomePage', 'SettingsPage', 'TrayNavigation'];
  }

  List<String> _getAllFeatures() {
    return ['DebugMode', 'ExperimentalFeatures'];
  }

  void _updateConfig() {
    final newPlatformConfigs = <String, PlatformConfig>{};
    
    for (final platform in _config.platform.keys) {
      final pages = _platformPageStates[platform]!
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
          
      final features = _platformFeatureStates[platform]!
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
          
      newPlatformConfigs[platform] = PlatformConfig(
        pages: pages,
        features: features,
      );
    }
    
    final newConfig = AppConfig(
      platform: newPlatformConfigs,
      build: _config.build,
    );
    
    ConfigManager.instance.updateConfig(newConfig);
    setState(() {
      _config = newConfig;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配置已更新')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置编辑器'),
        actions: [
          ConfigAwareAppBarAction(
            featureId: 'DebugMode',
            action: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => ConfigUtils.instance.printConfigInfo(),
              tooltip: '打印配置信息',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateConfig,
            tooltip: '保存配置',
          ),
        ],
      ),
      body: DefaultTabController(
        length: _config.platform.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: _config.platform.keys
                  .map((platform) => Tab(text: platform))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                children: _config.platform.keys
                    .map((platform) => _buildPlatformTab(platform))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformTab(String platform) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '页面配置',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._getAllPages().map((page) => 
                  CheckboxListTile(
                    title: Text(page),
                    value: _platformPageStates[platform]![page],
                    onChanged: (value) {
                      setState(() {
                        _platformPageStates[platform]![page] = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '功能配置',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._getAllFeatures().map((feature) => 
                  CheckboxListTile(
                    title: Text(feature),
                    value: _platformFeatureStates[platform]![feature],
                    onChanged: (value) {
                      setState(() {
                        _platformFeatureStates[platform]![feature] = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        ConfigAwareWidget(
          featureId: 'DebugMode',
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '调试信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('当前平台: ${ConfigManager.instance.getCurrentPlatform()}'),
                  Text('可用页面: ${ConfigUtils.instance.availablePages.join(', ')}'),
                  Text('可用功能: ${ConfigUtils.instance.availableFeatures.join(', ')}'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
