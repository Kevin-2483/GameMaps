import 'package:flutter/material.dart';
import '../../components/layout/main_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../components/external_resources/external_resources_export_panel.dart';
import '../../components/external_resources/external_resources_import_panel.dart';
import '../../components/external_resources/external_resources_browse_panel.dart';

/// 外部资源管理页面
class ExternalResourcesPage extends BasePage {
  const ExternalResourcesPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _ExternalResourcesContent();
  }
}

class _ExternalResourcesContent extends StatefulWidget {
  const _ExternalResourcesContent();

  @override
  State<_ExternalResourcesContent> createState() => _ExternalResourcesContentState();
}

class _ExternalResourcesContentState extends State<_ExternalResourcesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resourceManagement),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.file_upload),
              text: l10n.exportDatabase,
            ),
            Tab(
              icon: const Icon(Icons.file_download),
              text: l10n.importDatabase,
            ),
            Tab(
              icon: const Icon(Icons.cloud),
              text: '浏览资源',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExternalResourcesExportPanel(),
          ExternalResourcesImportPanel(),
          ExternalResourcesBrowsePanel(),
        ],
      ),
    );
  }
}
