import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../components/layout/main_layout.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../../services/notification/notification_service.dart';

class AboutPage extends BasePage {
  const AboutPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _AboutPageContent();
  }
}

class _AboutPageContent extends StatefulWidget {
  const _AboutPageContent();

  @override
  State<_AboutPageContent> createState() => _AboutPageContentState();
}

class _AboutPageContentState extends State<_AboutPageContent> {
  PackageInfo? _packageInfo;
  String? _licenseText;

  // 自定义致谢项目列表 - 您可以在这里添加更多项目
  static const List<Map<String, String>> _customAcknowledgments = [
    {
      'name': 'R6 Operators Assets',
      'description': '彩虹六号干员头像和图标资源',
      'subtitle': 'marcopixel/r6operators 仓库提供的干员素材',
      'url': 'https://github.com/marcopixel/r6operators',
      'icon': 'image',
    },

    // 示例：您可以取消注释并修改以下项目
    // {
    //   'name': 'Ubisoft 官方资源',
    //   'description': '游戏内素材和图标',
    //   'subtitle': '来自《彩虹六号：围攻》官方资源',
    //   'icon': 'palette',
    // },
    // {
    //   'name': 'Community Maps Data',
    //   'description': '社区贡献的地图数据',
    //   'subtitle': '来自 R6 社区的地图标注和战术点位',
    //   'url': 'https://github.com/your-repo/r6-maps-data',
    //   'icon': 'library_books',
    // },

    // 添加更多项目的格式：
    // {
    //   'name': '项目名称',                    // 必需：项目名称
    //   'description': '项目描述',             // 必需：简短描述
    //   'subtitle': '详细信息或来源',           // 必需：详细信息
    //   'url': 'https://github.com/...',     // 可选：项目链接
    //   'icon': 'code',                     // 可选：图标名称
    // },

    // 支持的图标名称：
    // 'folder_special' - 文件夹图标（默认）
    // 'code' - 代码图标
    // 'image' - 图片图标
    // 'palette' - 调色板图标
    // 'library_books' - 书籍图标
  ];

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    _loadLicenseText();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = packageInfo;
      });
    }
  }

  Future<void> _loadLicenseText() async {
    try {
      final licenseText = await rootBundle.loadString('LICENSE');
      if (mounted) {
        setState(() {
          _licenseText = licenseText;
        });
      }
    } catch (e) {
      // LICENSE 文件不存在或无法读取
      debugPrint('无法加载 LICENSE 文件: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(title: '关于', icon: Icons.info_outline),
          Expanded(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAppInfoSection(context),
                  const SizedBox(height: 16),
                  _buildLicenseSection(context),
                  const SizedBox(height: 16),
                  _buildProjectLinksSection(context),
                  const SizedBox(height: 16),
                  _buildOpenSourceSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.videogame_asset,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _packageInfo?.appName ?? 'R6BOX',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '版本 ${_packageInfo?.version ?? '1.2.0'} (${_packageInfo?.buildNumber ?? '1'})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('应用描述', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'R6BOX 是一款专为《彩虹六号：围攻》玩家设计的综合工具箱应用。提供地图编辑器、战术分析、数据统计等功能，帮助玩家提升游戏体验和竞技水平。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('许可证', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('GPL v3 License'),
              subtitle: const Text('开源许可证，保证软件自由'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLicenseDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectLinksSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('项目地址', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('GitHub 仓库'),
              subtitle: const Text('查看源代码、报告问题和贡献代码'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl('https://github.com/Kevin-2483/GameMaps'),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('问题反馈'),
              subtitle: const Text('报告 Bug 或提出功能建议'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () =>
                  _launchUrl('https://github.com/Kevin-2483/GameMaps/issues'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('项目文档'),
              subtitle: const Text('查看详细的使用说明和开发文档'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () =>
                  _launchUrl('https://github.com/Kevin-2483/GameMaps/wiki'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenSourceSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('开源项目致谢', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '本项目使用了以下优秀的开源项目和资源：',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // 动态生成自定义致谢项目
            ..._customAcknowledgments.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildCustomAcknowledgment(
                  context,
                  item['name']!,
                  item['description']!,
                  item['subtitle']!,
                  item['url'],
                  item['icon'],
                ),
              ),
            ),

            const Divider(height: 24),

            Text(
              '此外，本项目还依赖众多 Flutter 生态系统中的优秀开源包，点击下方按钮查看完整的依赖项列表和许可证信息。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showFullLicensePage(context),
                icon: const Icon(Icons.list),
                label: const Text('查看完整许可证列表'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAcknowledgment(
    BuildContext context,
    String name,
    String description,
    String subtitle,
    String? url,
    String? iconName,
  ) {
    // 根据图标名称选择合适的图标
    IconData getIcon(String? iconName) {
      switch (iconName) {
        case 'folder_special':
          return Icons.folder_special;
        case 'code':
          return Icons.code;
        case 'image':
          return Icons.image;
        case 'palette':
          return Icons.palette;
        case 'library_books':
          return Icons.library_books;
        default:
          return Icons.folder_special;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: url != null ? () => _launchUrl(url) : null,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              getIcon(iconName),
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (url != null)
              Icon(
                Icons.open_in_new,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // 如果无法启动 URL，复制到剪贴板
      Clipboard.setData(ClipboardData(text: url));
    }
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GPL v3 License'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _licenseText != null
              ? SingleChildScrollView(
                  child: Text(
                    _licenseText!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (_licenseText != null)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _licenseText!));
                Navigator.of(context).pop();
                context.showSuccessSnackBar('许可证文本已复制到剪贴板');
              },
              child: const Text('复制'),
            ),
        ],
      ),
    );
  }

  void _showFullLicensePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: _packageInfo?.appName ?? 'R6BOX',
      applicationVersion: _packageInfo?.version ?? '1.2.0',
      applicationIcon: Icon(
        Icons.videogame_asset,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
      ),
      applicationLegalese: '© 2024 R6BOX Team\n使用 GPL v3 许可证发布',
    );
  }
}
