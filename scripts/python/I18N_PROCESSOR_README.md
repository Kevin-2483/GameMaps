# I18n Processor - Flutter 国际化处理工具

这是一个用于自动化处理 Flutter 项目中文字符串国际化的工具集。它可以将 Dart 代码中的中文字符串自动替换为 l10n 调用，并生成对应的 ARB 文件。

## 工具组成

1. **extract_all_strings.py** - 中文字符串提取工具
2. **i18n_processor.py** - 国际化处理核心工具
3. **i18n_example.py** - 使用示例
4. **i18n_config.json** - 配置文件模板
5. **requirements_i18n.txt** - 依赖包列表

## 工作流程

```
1. 提取中文字符串 → 2. AI处理转换 → 3. 替换代码 → 4. 生成ARB文件
   extract_all_strings.py    i18n_processor.py
```

## 安装依赖

```bash
pip install -r requirements_i18n.txt
```

## 使用步骤

### 步骤 1: 提取中文字符串

首先使用 `extract_all_strings.py` 扫描项目并提取包含中文的代码段：

```bash
# 扫描 lib 目录，排除 lib/l10n，输出到 yaml 目录
python extract_all_strings.py lib -e lib/l10n -d yaml
```

这会在 `yaml` 目录下生成大量 YAML 文件，每个文件包含一个代码段的信息：

```yaml
path: pages/home/home_page.dart
start_line: 589
end_line: 591
code: "debugPrint('缓冲计算公式: ${_baseBufferMultiplier}');"
```

### 步骤 2: 配置 API 密钥

设置环境变量或直接在命令行中提供 API 密钥：

```bash
# 方法1: 设置环境变量
export OPENAI_API_KEY="your-api-key-here"

# 方法2: 在命令行中直接提供
# 见下面的使用命令
```

### 步骤 3: 运行国际化处理

```bash
# 基本用法
python i18n_processor.py yaml --api-key your-api-key-here

# 自定义并发数和API地址
python i18n_processor.py yaml \
  --api-key your-api-key-here \
  --api-url https://api.openai.com/v1/chat/completions \
  --max-concurrent 3
```

### 步骤 4: 验证结果

处理完成后，检查：

1. **Dart 文件**: 中文字符串应该被替换为 `l10n.keyName` 格式
2. **ARB 文件**: 在 `lib/l10n/` 目录下生成对应的 `.arb` 文件

## 示例使用

运行示例脚本：

```bash
python i18n_example.py
```

## 配置选项

### 命令行参数

- `yaml_dir`: YAML 文件目录路径（必需）
- `--api-key`: AI API 密钥（必需）
- `--api-url`: API 地址（默认: OpenAI API）
- `--max-concurrent`: 最大并发数（默认: 5）

### 配置文件

可以修改 `i18n_config.json` 来自定义更多设置：

```json
{
  "api_settings": {
    "model": "gpt-3.5-turbo",
    "temperature": 0.1
  },
  "processing_settings": {
    "max_concurrent": 5
  }
}
```

## 处理示例

### 输入（原始 Dart 代码）
```dart
debugPrint('VFS系统初始化成功');
```

### 输出（处理后的代码）
```dart
debugPrint(l10n.vfsInitSuccess);
```

### 生成的 ARB 条目
```json
{
  "vfsInitSuccess": "VFS系统初始化成功"
}
```

## 文件结构

处理后的项目结构：

```
project/
├── lib/
│   ├── l10n/
│   │   ├── pages/
│   │   │   ├── home/
│   │   │   │   └── home_page.arb
│   │   │   └── about/
│   │   │       └── about_page.arb
│   │   └── main.arb
│   ├── pages/
│   │   ├── home/
│   │   │   └── home_page.dart  # 已更新
│   │   └── about/
│   │       └── about_page.dart  # 已更新
│   └── main.dart  # 已更新
└── yaml/  # 临时文件，处理完可删除
    ├── home_page_589_591.yaml
    └── ...
```

## 注意事项

1. **备份代码**: 处理前请备份您的代码，虽然工具会验证行数，但建议谨慎操作

2. **API 限制**: 注意 API 调用频率限制，建议设置合理的并发数（3-5）

3. **代码审查**: 处理完成后请仔细审查生成的代码，确保替换正确

4. **ARB 文件**: 生成的 ARB 文件需要添加到 Flutter 的国际化配置中

5. **依赖导入**: 确保 Dart 文件中已导入 l10n 相关依赖：
   ```dart
   import 'package:flutter_gen/gen_l10n/app_localizations.dart';
   ```

## 故障排除

### 常见问题

1. **API 调用失败**
   - 检查 API 密钥是否正确
   - 检查网络连接
   - 检查 API 配额

2. **行数不匹配**
   - AI 可能改变了代码结构
   - 检查日志中的警告信息
   - 手动调整有问题的代码段

3. **文件路径错误**
   - 确保 YAML 文件中的路径相对于项目根目录正确
   - 检查文件是否存在

### 日志信息

工具会输出详细的日志信息，包括：
- 处理进度
- 成功/失败统计
- 错误详情
- 生成的文件信息

## 扩展功能

可以根据需要扩展工具功能：

1. **支持其他 AI API**: 修改 API 调用逻辑
2. **自定义提示词**: 修改 AI 提示模板
3. **批量处理优化**: 添加更多并发控制
4. **结果验证**: 添加更多验证逻辑

## 许可证

本工具遵循项目的许可证协议。