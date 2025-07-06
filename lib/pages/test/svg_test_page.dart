import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';

class SvgTestPage extends StatefulWidget {
  const SvgTestPage({super.key});

  @override
  State<SvgTestPage> createState() => _SvgTestPageState();
}

class _SvgTestPageState extends State<SvgTestPage> {
  List<String> svgFiles = [];
  bool isLoading = true;
  String? errorMessage;

  // R6 干员 SVG 文件列表
  final List<String> operatorFiles = [
    'ace.svg',
    'alibi.svg',
    'amaru.svg',
    'aruni.svg',
    'ash.svg',
    'azami.svg',
    'bandit.svg',
    'blackbeard.svg',
    'blitz.svg',
    'brava.svg',
    'buck.svg',
    'capitao.svg',
    'castle.svg',
    'caveira.svg',
    'clash.svg',
    'deimos.svg',
    'doc.svg',
    'dokkaebi.svg',
    'echo.svg',
    'ela.svg',
    'fenrir.svg',
    'finka.svg',
    'flores.svg',
    'frost.svg',
    'fuze.svg',
    'glaz.svg',
    'goyo.svg',
    'gridlock.svg',
    'grim.svg',
    'hibana.svg',
    'iana.svg',
    'iq.svg',
    'jackal.svg',
    'jager.svg',
    'kaid.svg',
    'kali.svg',
    'kapkan.svg',
    'lesion.svg',
    'lion.svg',
    'maestro.svg',
    'maverick.svg',
    'melusi.svg',
    'mira.svg',
    'montagne.svg',
    'mozzie.svg',
    'mute.svg',
    'nokk.svg',
    'nomad.svg',
    'oryx.svg',
    'osa.svg',
    'pulse.svg',
    'ram.svg',
    'rauora.svg',
    'recruit_blue.svg',
    'recruit_green.svg',
    'recruit_orange.svg',
    'recruit_red.svg',
    'recruit_yellow.svg',
    'rook.svg',
    'sens.svg',
    'sentry.svg',
    'skopos.svg',
    'sledge.svg',
    'smoke.svg',
    'solis.svg',
    'striker.svg',
    'tachanka.svg',
    'thatcher.svg',
    'thermite.svg',
    'thorn.svg',
    'thunderbird.svg',
    'tubarao.svg',
    'twitch.svg',
    'valkyrie.svg',
    'vigil.svg',
    'wamai.svg',
    'warden.svg',
    'ying.svg',
    'zero.svg',
    'zofia.svg',
  ];

  @override
  void initState() {
    super.initState();
    _loadSvgFiles();
  }

  Future<void> _loadSvgFiles() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // 验证 SVG 文件是否存在
      List<String> validFiles = [];
      for (String fileName in operatorFiles) {
        try {
          await rootBundle.load('assets/images/r6operators_flat/$fileName');
          validFiles.add(fileName);
        } catch (e) {
          debugPrint('文件不存在: $fileName');
        }
      }

      setState(() {
        svgFiles = validFiles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '加载 SVG 文件时出错: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('R6 干员 SVG 测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadSvgFiles,
            icon: const Icon(Icons.refresh),
            tooltip: '重新加载',
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Text(
              isLoading ? '正在加载 SVG 文件...' : '找到 ${svgFiles.length} 个 SVG 文件',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // 内容区域
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadSvgFiles, child: const Text('重试')),
          ],
        ),
      );
    }

    if (svgFiles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '未找到 SVG 文件',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 每行显示4个
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: svgFiles.length,
      itemBuilder: (context, index) {
        final fileName = svgFiles[index];
        final operatorName = fileName
            .replaceAll('.svg', '')
            .replaceAll('_', ' ');

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () => _showSvgDialog(fileName, operatorName),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SVG 图片
                  Expanded(
                    child: FutureBuilder<ScalableImage>(
                      future: ScalableImage.fromSvgAsset(
                        rootBundle,
                        'assets/images/r6operators_flat/$fileName',
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ScalableImageWidget(si: snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 32,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '加载失败',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 干员名称
                  Text(
                    operatorName.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSvgDialog(String fileName, String operatorName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Text(
                operatorName.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 大尺寸 SVG
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<ScalableImage>(
                    future: ScalableImage.fromSvgAsset(
                      rootBundle,
                      'assets/images/r6operators_flat/$fileName',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ScalableImageWidget(si: snapshot.data!);
                      } else if (snapshot.hasError) {
                        return Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '无法加载 SVG 文件',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 文件信息
              Text(
                '文件: $fileName',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),

              const SizedBox(height: 16),

              // 关闭按钮
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
