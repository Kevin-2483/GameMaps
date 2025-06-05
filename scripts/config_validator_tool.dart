import 'dart:io';
import 'config_validator.dart';

/// 配置验证工具的命令行入口
void main(List<String> args) async {
  if (args.isEmpty) {
    print('用法: dart config_validator_tool.dart <config_file_path>');
    print('示例: dart config_validator_tool.dart assets/config/app_config.json');
    exit(1);
  }

  final configPath = args[0];
  print('验证配置文件: $configPath');
  print('${'=' * 50}');

  final result = await ConfigValidator.validateConfigFile(configPath);
  result.printResults();

  print('=' * 50);

  if (result.isValid) {
    if (result.hasWarnings) {
      print('✅ 配置文件有效，但有警告');
      exit(1); // 有警告时返回非零退出码
    } else {
      print('✅ 配置文件完全有效');
      exit(0);
    }
  } else {
    print('❌ 配置文件无效');
    exit(2); // 有错误时返回错误退出码
  }
}
