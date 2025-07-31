# ARB翻译工具使用说明

这个工具可以自动将ARB文件中的中文内容翻译成英文，支持并发处理，复用现有的i18n_config.json配置。

## 文件说明

- `arb_translator.py` - 主要的翻译工具
- `translate_arb_example.py` - 使用示例脚本
- `i18n_config.json` - 配置文件（复用现有配置）

## 环境准备

### 1. 安装依赖

```bash
pip install aiohttp aiofiles
```

### 2. 设置API密钥

有两种方式设置API密钥：

**方式1: 环境变量（推荐）**
```bash
# Windows
set DEEPSEEK_API_KEY=your_api_key_here

# Linux/macOS
export DEEPSEEK_API_KEY=your_api_key_here
```

**方式2: 命令行参数**
```bash
# 直接在命令行中指定API密钥
python scripts/python/arb_translator.py input.arb output.arb --api-key sk-your-api-key-here
```

## 使用方法

### 方法1: 命令行直接使用

```bash
# 基本用法
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb

# 指定配置文件
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --config scripts/python/i18n_config.json

# 指定并发数量
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --concurrent 5

# 通过命令行参数指定API密钥（无需设置环境变量）
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --api-key sk-your-api-key-here

# 迁移现有翻译（标记为已处理，不执行新翻译）
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --migrate

# 组合使用多个参数
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --api-key sk-your-api-key-here --concurrent 3 --config scripts/python/i18n_config.json

python scripts/python/arb_translator.py input.arb output.arb --target-language 日文
```

### 方法2: 使用示例脚本

```bash
python scripts/python/translate_arb_example.py
```

然后按照提示选择操作：
1. 增量翻译单个ARB文件（只翻译未处理的条目）
2. 迁移现有翻译（标记为已处理）
3. 批量翻译ARB文件
4. 退出

### 方法3: 在代码中使用

```python
import asyncio
from arb_translator import ARBTranslator

# 增量翻译示例
async def translate_my_arb():
    translator = ARBTranslator(
        config_file="scripts/python/i18n_config.json",
        max_concurrent=3
    )
    
    # 增量翻译（只处理未翻译的条目）
    await translator.translate_arb_file(
        "lib/l10n/app_en.arb",
        "lib/l10n/app_en_translated.arb",
        migrate_existing=False
    )

# 迁移现有翻译示例
async def migrate_existing():
    translator = ARBTranslator(
        config_file="scripts/python/i18n_config.json"
    )
    
    # 迁移现有翻译（标记为已处理）
    await translator.translate_arb_file(
        "lib/l10n/app_en.arb",
        "lib/l10n/app_en_translated.arb",
        migrate_existing=True
    )

# 运行
asyncio.run(translate_my_arb())
# 或
asyncio.run(migrate_existing())
```

## 配置说明

工具复用现有的`i18n_config.json`配置文件，主要配置项：

```json
{
  "api_settings": {
    "url": "https://api.deepseek.com/chat/completions",
    "model": "deepseek-chat",
    "temperature": 0.1,
    "max_tokens": 4000
  },
  "processing_settings": {
    "max_concurrent": 3,
    "retry_attempts": 3,
    "retry_delay": 2.0,
    "timeout": 120
  }
}
```

## 核心功能

### 1. 增量翻译
- 自动跳过已翻译的条目
- 实时保存翻译结果
- 支持断点续传
- 进度文件跟踪（`.app_en.json`）

### 2. 迁移功能
- 标记现有翻译为已处理
- 区分AI翻译和人工翻译
- 批量迁移现有条目

### 3. 进度跟踪
- 每个ARB文件对应一个进度文件
- 记录翻译状态、时间戳、错误信息
- 支持AI处理标记

## 工作原理

1. **加载ARB文件**: 读取输入的ARB文件内容
2. **加载进度文件**: 检查已处理的条目（`.{filename}.json`）
3. **识别中文内容**: 自动识别包含中文字符且未处理的键值对
4. **逐个翻译**: 依次处理翻译任务（非并发，避免API限流）
5. **实时保存**: 每完成一个翻译立即保存到ARB文件和进度文件
6. **AI翻译**: 调用DeepSeek API进行中文到英文的翻译
7. **状态跟踪**: 记录每个条目的处理状态和来源

## 翻译质量保证

- **上下文感知**: 为每个翻译任务提供ARB键名作为上下文
- **占位符保护**: 自动保护Flutter占位符（如`{variable}`）
- **结果清理**: 自动清理AI返回的多余内容
- **错误处理**: 翻译失败时保持原文不变

## 输出示例

### 增量翻译模式
```
2024-01-20 10:30:15 - INFO - 加载进度文件: lib/l10n/.app_en_translated.json，已有 120 个条目
2024-01-20 10:30:15 - INFO - 加载ARB文件: lib/l10n/app_en.arb
2024-01-20 10:30:15 - INFO - 跳过已处理的键: home
2024-01-20 10:30:15 - INFO - 跳过已处理的键: settings
2024-01-20 10:30:15 - INFO - 找到 36 个需要翻译的条目
2024-01-20 10:30:16 - INFO - 处理任务 1/36: newFeature
2024-01-20 10:30:17 - INFO - 翻译成功: newFeature -> New Feature
2024-01-20 10:30:17 - INFO - 已保存翻译结果到ARB文件: newFeature -> New Feature
...

==================================================
翻译统计信息
==================================================
总任务数: 36
成功翻译: 35
翻译失败: 1
跳过已处理: 120
成功率: 97.2%
总耗时: 45.32 秒
平均速度: 0.79 任务/秒
==================================================
```

### 迁移模式
```
2024-01-20 10:25:10 - INFO - 执行迁移模式...
2024-01-20 10:25:10 - INFO - 加载进度文件: lib/l10n/.app_en_translated.json，已有 0 个条目
2024-01-20 10:25:10 - INFO - 开始迁移现有翻译...
2024-01-20 10:25:11 - INFO - 迁移完成，共标记 156 个条目为已处理
2024-01-20 10:25:11 - INFO - 迁移完成！
```

### 进度文件示例（`.app_en_translated.json`）
```json
{
  "home": {
    "key": "home",
    "original_text": "",
    "translated_text": "Home",
    "processed_by_ai": false,
    "timestamp": "2024-01-20T10:25:11.123456",
    "success": true,
    "error_message": null
  },
  "newFeature": {
    "key": "newFeature",
    "original_text": "新功能",
    "translated_text": "New Feature",
    "processed_by_ai": true,
    "timestamp": "2024-01-20T10:30:17.654321",
    "success": true,
    "error_message": null
  }
}
```

## 注意事项

1. **API密钥**: 确保设置了正确的DEEPSEEK_API_KEY环境变量或使用--api-key参数
2. **网络连接**: 需要稳定的网络连接访问DeepSeek API
3. **进度文件**: 进度文件（`.{filename}.json`）记录翻译状态，请勿手动删除
4. **迁移操作**: 首次使用建议先执行--migrate标记现有翻译
5. **增量翻译**: 支持断点续传，可随时中断和恢复翻译
6. **实时保存**: 每个翻译结果立即保存，避免数据丢失
7. **检查结果**: 翻译完成后建议人工检查重要的翻译结果

## 故障排除

### 常见问题

1. **API密钥错误**
   ```
   错误: 未找到DEEPSEEK_API_KEY环境变量
   解决: 设置正确的API密钥环境变量
   ```

2. **网络超时**
   ```
   错误: 翻译异常: timeout
   解决: 检查网络连接，或增加timeout配置
   ```

3. **并发过高**
   ```
   错误: API请求失败，状态码: 429
   解决: 降低max_concurrent配置值
   ```

4. **文件权限**
   ```
   错误: 保存ARB文件失败: Permission denied
   解决: 检查输出目录的写入权限
   ```

### 调试模式

如需更详细的日志信息，可以修改日志级别：

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 使用场景

### 1. 首次翻译
```bash
# 1. 先迁移现有翻译
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --migrate

# 2. 然后翻译新增内容
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --api-key your-key
```

### 2. 日常维护
```bash
# 只翻译新增的中文条目
python scripts/python/arb_translator.py lib/l10n/app_en.arb lib/l10n/app_en_translated.arb --api-key your-key
```

### 3. 断点续传
如果翻译过程中断，直接重新运行相同命令即可从中断处继续。

## 扩展功能

可以根据需要扩展以下功能：

1. **支持其他翻译API**: 修改`translate_text`方法
2. **批量处理目录**: 扫描目录下所有ARB文件
3. **翻译缓存**: 避免重复翻译相同内容
4. **质量评估**: 添加翻译质量评分机制
5. **多语言支持**: 扩展到其他语言对的翻译