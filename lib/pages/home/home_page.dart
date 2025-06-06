import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../components/common/platform_aware_component.dart';
import '../../components/layout/main_layout.dart';
import '../../features/feature_registry.dart';
import '../../features/component-modules/system_info_feature.dart';
import '../../components/vfs/vfs_file_picker_window.dart';

class HomePage extends BasePage {
  const HomePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  @override
  void initState() {
    super.initState();
    _initializeFeatures();
  }

  void _initializeFeatures() {
    final registry = FeatureRegistry();
    registry.register(SystemInfoFeature());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题区域（移除了AppBar）
              Text(
                l10n.home,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.comprehensiveFramework,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24), // Quick actions
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.go('/settings'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.settings, size: 32),
                              SizedBox(height: 8),
                              Text(l10n.settings),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => context.go('/fullscreen-test'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.fullscreen, size: 32),
                              SizedBox(height: 8),
                              Text('全屏测试'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          // 打开VFS文件管理器
                          VfsFileManagerWindow.show(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.folder_special, size: 32),
                              SizedBox(height: 8),
                              Text('文件管理器'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          // Show about dialog
                          showAboutDialog(
                            context: context,
                            applicationName: l10n.appTitle,
                            applicationVersion: '1.0.0',
                            children: [Text(l10n.aboutDialogContent)],
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.info, size: 32),
                              SizedBox(height: 8),
                              Text(l10n.about),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          // Open VFS file manager
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => VfsFileManagerWindow(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.folder_open, size: 32),
                              SizedBox(height: 8),
                              Text('文件管理器'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // Platform component
              Text(
                l10n.platformIntegration,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Expanded(flex: 2, child: PlatformAwareComponent()),

              const SizedBox(height: 16),
              // Features section
              Text(
                l10n.features,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(flex: 1, child: _buildFeaturesSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final l10n = AppLocalizations.of(context)!;
    final registry = FeatureRegistry();
    final enabledFeatures = registry.getEnabledFeatures();

    if (enabledFeatures.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.widgets_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                l10n.noFeaturesEnabled,
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                l10n.enableFeaturesInSettings,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: enabledFeatures.length,
      itemBuilder: (context, index) {
        final feature = enabledFeatures[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: feature.buildWidget(context),
        );
      },
    );
  }
}
