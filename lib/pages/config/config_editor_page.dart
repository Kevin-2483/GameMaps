import 'package:flutter/material.dart';
import '../../config/config_manager.dart';
import '../../config/app_config.dart';
import '../../components/common/config_aware_widgets.dart';
import '../../l10n/app_localizations.dart';

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
        _platformFeatureStates[platform]![feature] = platformConfig.hasFeature(
          feature,
        );
      }
    }
  }
  List<String> _getAllPages() {
    return [
      'HomePage',
      'SettingsPage',
      'UserPreferencesPage',
      'MapAtlasPage',
      'LegendManagerPage',
      'ExternalResourcesPage',
      'FullscreenTestPage',
    ];
  }

  List<String> _getAllFeatures() {
    return ['DebugMode', 'ExperimentalFeatures', 'TrayNavigation'];
  }

  void _updateConfig() {
    final newPlatformConfigs = <String, PlatformConfig>{};

    for (final platform in _config.platform.keys) {
      final pages = _platformPageStates[platform]!.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final features = _platformFeatureStates[platform]!.entries
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
      SnackBar(content: Text(AppLocalizations.of(context)!.configUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.configEditor),
        actions: [
          ConfigAwareAppBarAction(
            featureId: 'DebugMode',
            action: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => ConfigUtils.instance.printConfigInfo(),
              tooltip: l10n.printConfigInfo,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateConfig,
            tooltip: l10n.saveConfig,
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
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.pageConfiguration,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._getAllPages().map(
                  (page) => CheckboxListTile(
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
                  l10n.featureConfiguration,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._getAllFeatures().map(
                  (feature) => CheckboxListTile(
                    title: Text(feature),
                    value: _platformFeatureStates[platform]![feature],
                    onChanged: (value) {
                      setState(() {
                        _platformFeatureStates[platform]![feature] =
                            value ?? false;
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
                    l10n.debugInfo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.currentPlatform(
                      ConfigManager.instance.getCurrentPlatform(),
                    ),
                  ),
                  Text(
                    l10n.availablePages(
                      ConfigUtils.instance.availablePages.join(', '),
                    ),
                  ),
                  Text(
                    l10n.availableFeatures(
                      ConfigUtils.instance.availableFeatures.join(', '),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
