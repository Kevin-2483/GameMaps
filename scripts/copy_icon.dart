import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> arguments) async {
  if (arguments.length < 2) {
    print('用法: dart copy_svg.dart <源目录> <目标目录>');
    exit(1);
  }

  final sourceDir = Directory(arguments[0]);
  final targetDir = Directory(arguments[1]);

  if (!sourceDir.existsSync()) {
    print('源目录不存在喵: ${sourceDir.path}');
    exit(1);
  }

  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  final svgFiles = <File>[];

  // 递归收集所有 .svg 文件
  await for (final entity in sourceDir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.toLowerCase().endsWith('.svg')) {
      svgFiles.add(entity);
    }
  }

  print('发现 ${svgFiles.length} 个 SVG 文件喵~');

  for (final file in svgFiles) {
    final originalName = p.basename(file.path);
    String targetPath = p.join(targetDir.path, originalName);

    // 避免覆盖已有文件，自动加后缀
    int i = 1;
    while (File(targetPath).existsSync()) {
      final nameWithoutExt = p.basenameWithoutExtension(originalName);
      final ext = p.extension(originalName);
      targetPath = p.join(targetDir.path, '${nameWithoutExt}_copy$i$ext');
      i++;
    }

    await file.copy(targetPath);
    print('复制: ${file.path} -> $targetPath');
  }

  print('🎉 全部 SVG 已复制完毕喵~【蹭蹭】');
}
