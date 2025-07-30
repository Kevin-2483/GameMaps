#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
I18n Processor - 国际化处理工具

功能：
1. 并发读取YAML文件记录
2. 调用AI API进行中文字符串国际化处理
3. 替换Dart代码中的中文字符串为l10n调用
4. 生成对应的ARB文件
"""

import asyncio
import aiohttp
import aiofiles
import json
import yaml
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
import argparse
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor
import logging
from collections import defaultdict
import shutil
import time
from datetime import datetime
import hashlib
import os

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class YamlRecord:
    """YAML记录数据结构"""
    path: str
    start_line: int
    end_line: int
    code: str
    yaml_file: str

@dataclass
class AIResponse:
    """AI响应数据结构"""
    replaced_code: str
    arb_entries: Dict[str, str]
    success: bool
    error_message: Optional[str] = None

class I18nProcessor:
    """国际化处理器"""
    
    def __init__(self, yaml_dir: str, api_url: str, api_key: str, max_concurrent: int = 5, config_file: Optional[str] = None):
        self.yaml_dir = Path(yaml_dir)
        
        # 加载配置文件
        self.config = self.load_config(config_file)
        
        # 应用配置文件中的API设置，如果存在的话
        if 'api_settings' in self.config and 'url' in self.config['api_settings']:
            self.api_url = self.config['api_settings']['url']
        else:
            self.api_url = api_url
            
        self.api_key = api_key
        
        # 应用配置文件中的并发数设置，如果存在的话
        if 'processing_settings' in self.config and 'max_concurrent' in self.config['processing_settings']:
            self.max_concurrent = self.config['processing_settings']['max_concurrent']
        else:
            self.max_concurrent = max_concurrent
            
        self.semaphore = asyncio.Semaphore(self.max_concurrent)
        self.arb_data = defaultdict(dict)  # 按文件路径分组的ARB数据
        
        # 进度跟踪文件
        self.progress_file = self.yaml_dir / '.i18n_progress.json'
        self.processed_files = self.load_progress()
        
        # 已处理的Dart文件集合（用于添加AI处理标记）
        self.processed_dart_files = set()
        
        # 统计信息
        self.stats = {
            'total_records': 0,
            'processed_successfully': 0,
            'failed_records': 0,
            'skipped_records': 0,
            'api_calls': 0,
            'start_time': None,
            'end_time': None
        }
        
    def load_config(self, config_file: Optional[str]) -> Dict:
        """加载配置文件"""
        default_config = {
            'api_settings': {
                'model': 'gpt-3.5-turbo',
                'temperature': 0.1,
                'max_tokens': 2000
            },
            'processing_settings': {
                'retry_attempts': 3,
                'retry_delay': 1.0,
                'backup_original': True,
                'validate_line_count': True
            },
            'output_settings': {
                'arb_base_path': 'lib/l10n'
            }
        }
        
        if config_file and Path(config_file).exists():
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                    # 合并配置
                    for key, value in user_config.items():
                        if key in default_config and isinstance(value, dict):
                            default_config[key].update(value)
                        else:
                            default_config[key] = value
                logger.info(f"已加载配置文件: {config_file}")
            except Exception as e:
                logger.warning(f"加载配置文件失败，使用默认配置: {e}")
        
        return default_config
    
    def load_progress(self) -> Dict[str, Dict[str, Any]]:
        """加载处理进度"""
        if self.progress_file.exists():
            try:
                with open(self.progress_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                logger.warning(f"无法加载进度文件: {e}")
        return {}
    
    def save_progress(self):
        """保存处理进度"""
        try:
            with open(self.progress_file, 'w', encoding='utf-8') as f:
                json.dump(self.processed_files, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.error(f"无法保存进度文件: {e}")
    
    def save_progress_immediately(self):
        """立即保存进度（用于每个文件处理后）"""
        self.save_progress()
    
    def get_file_hash(self, file_path: Path) -> str:
        """获取文件内容的哈希值"""
        try:
            with open(file_path, 'rb') as f:
                return hashlib.md5(f.read()).hexdigest()
        except Exception:
            return ""
    
    def is_file_processed(self, yaml_file: Path) -> bool:
        """检查YAML文件是否已被处理"""
        file_key = str(yaml_file.relative_to(self.yaml_dir))
        current_hash = self.get_file_hash(yaml_file)
        
        if file_key in self.processed_files:
            file_info = self.processed_files[file_key]
            if isinstance(file_info, dict):
                stored_hash = file_info.get('hash', '')
                status = file_info.get('status', 'unknown')
                return stored_hash == current_hash and status == 'success'
            else:
                # 兼容旧格式
                return file_info == current_hash
        return False
    
    def mark_file_processed(self, yaml_file: Path, status: str = 'success', error_msg: str = None):
        """标记YAML文件处理状态"""
        file_key = str(yaml_file.relative_to(self.yaml_dir))
        file_hash = self.get_file_hash(yaml_file)
        
        file_info = {
            'hash': file_hash,
            'status': status,  # 'success', 'failed', 'processing'
            'timestamp': datetime.now().isoformat(),
            'dart_file': None,  # 将在处理时设置
            'error': error_msg
        }
        
        self.processed_files[file_key] = file_info
        logger.debug(f"标记文件状态: {file_key} -> {status}")
    
    def update_file_dart_info(self, yaml_file: Path, dart_file: str):
        """更新文件的Dart文件信息"""
        file_key = str(yaml_file.relative_to(self.yaml_dir))
        if file_key in self.processed_files:
            self.processed_files[file_key]['dart_file'] = dart_file
    
    def backup_file(self, file_path: Path) -> Optional[Path]:
        """备份文件"""
        # 检查output_settings中的backup_original设置，如果不存在则检查processing_settings
        backup_enabled = self.config.get('output_settings', {}).get('backup_original', 
                                                                 self.config.get('processing_settings', {}).get('backup_original', True))
        if not backup_enabled:
            return None
            
        try:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            backup_path = file_path.with_suffix(f'.backup_{timestamp}{file_path.suffix}')
            shutil.copy2(file_path, backup_path)
            logger.debug(f"已备份文件: {backup_path}")
            return backup_path
        except Exception as e:
            logger.error(f"备份文件失败 {file_path}: {e}")
            return None
        
    async def load_yaml_records(self) -> List[YamlRecord]:
        """加载所有YAML记录"""
        records = []
        yaml_files = list(self.yaml_dir.glob('*.yaml')) + list(self.yaml_dir.glob('*.yml'))
        logger.info(f"找到 {len(yaml_files)} 个YAML文件")
        
        skipped_count = 0
        for yaml_file in yaml_files:
            # 检查文件是否已处理
            if self.is_file_processed(yaml_file):
                logger.debug(f"跳过已处理的文件: {yaml_file.name}")
                skipped_count += 1
                continue
                
            try:
                async with aiofiles.open(yaml_file, 'r', encoding='utf-8') as f:
                    content = await f.read()
                    data = yaml.safe_load(content)
                    
                record = YamlRecord(
                    path=data['path'],
                    start_line=data['start_line'],
                    end_line=data['end_line'],
                    code=data['code'],
                    yaml_file=str(yaml_file)
                )
                records.append(record)
            except Exception as e:
                logger.error(f"加载YAML文件失败 {yaml_file}: {e}")
        
        if skipped_count > 0:
            logger.info(f"跳过 {skipped_count} 个已处理的文件")
        logger.info(f"成功加载 {len(records)} 个待处理记录")
        return records
    
    def create_ai_prompt(self, record: YamlRecord) -> str:
        """创建AI提示词"""
        # 读取l10n配置信息
        l10n_config_path = Path(self.yaml_dir).parent / "l10n.yaml"
        l10n_class = "AppLocalizations"  # 默认值
        template_arb = "app_en.arb"  # 默认值
        
        if l10n_config_path.exists():
            try:
                with open(l10n_config_path, 'r', encoding='utf-8') as f:
                    l10n_config = yaml.safe_load(f)
                    l10n_class = l10n_config.get('output-class', 'AppLocalizations')
                    template_arb = l10n_config.get('template-arb-file', 'app_en.arb')
            except Exception as e:
                logger.warning(f"读取l10n.yaml失败，使用默认配置: {e}")
        
        prompt = f"""
请将以下Dart代码段中的中文字符串替换为Flutter l10n调用。

项目l10n配置信息：
- 本地化类名: {l10n_class}
- 模板ARB文件: {template_arb}
- 调用格式: {l10n_class}.of(context).keyName

要求：
1. 保持代码行数完全相等（{record.end_line - record.start_line + 1}行）
2. 将中文字符串替换为 {l10n_class}.of(context).keyName 格式
3. 生成合理的键名（使用英文，简洁明了，驼峰命名）
4. 键名应该语义化，能够反映字符串的用途和上下文,添加随机数字后缀避免重复

⚠️ 复杂语句处理重点：
5. **字符串插值处理**：对于包含 ${{}} 或 $ 插值的字符串，需要特别注意：
   - 保持插值表达式的完整性和正确性
   - 确保插值变量在替换后仍能正确访问
   - 示例：'用户${{name}}，欢迎回来！' → {l10n_class}.of(context).welcomeBackUser(name)

6. **嵌套结构处理**：对于嵌套的Widget或方法调用：
   - 保持原有的嵌套层级和结构
   - 确保括号、逗号等语法元素正确匹配
   - 不要破坏原有的代码逻辑和层次

7. **运算表达式处理**：对于包含运算的复杂表达式：
   - 保持运算符的优先级和结合性
   - 确保变量引用和方法调用的正确性
   - 不要改变原有的计算逻辑

8. **条件表达式处理**：对于三元运算符或条件表达式：
   - 保持条件判断的完整性
   - 确保各分支的返回类型一致
   - 示例：condition ? '成功' : '失败' → condition ? {l10n_class}.of(context).success : {l10n_class}.of(context).failure

9. **方法链调用处理**：对于链式调用的代码：
   - 保持方法链的完整性和顺序
   - 确保每个方法调用的参数正确
   - 不要破坏流式API的使用模式

10. **特殊字符处理**：注意处理包含特殊字符的字符串：
    - 转义字符（\n, \t, \', \"等）
    - Unicode字符和表情符号
    - 正则表达式模式字符串

输出格式要求：
必须返回严格的JSON格式，包含以下两个字段：
- "replaced_code": 字符串类型，包含替换后的完整Dart代码
- "arb_entries": 对象类型，键为l10n键名（字符串和生成的键完全相同,包括随机后缀），值为原中文内容（字符串）

ARB条目格式说明：
- 键名必须是有效的Dart标识符（字母开头，只包含字母、数字、下划线）
- 值为原始的中文字符串内容（保持原有的插值占位符格式）
- 对于插值字符串，使用ARB的占位符语法：{{"userWelcome_3632": "用户{{name}}，欢迎回来！"}}

原代码：
```dart
{record.code}
```

复杂示例参考：
{{
  "replaced_code": "Text(isSuccess ? {l10n_class}.of(context).operationSuccess : {l10n_class}.of(context).operationFailed)",
  "arb_entries": {{
    "operationSuccess": "操作成功",
    "operationFailed": "操作失败"
  }}
}}

请严格按照上述JSON格式返回，不要包含任何其他文本、注释或代码块标记。
特别注意：确保替换后的代码在语法和逻辑上完全正确，能够直接编译运行。
"""
        return prompt
    
    async def call_ai_api(self, record: YamlRecord) -> AIResponse:
        """调用AI API（带重试机制）"""
        async with self.semaphore:
            retry_attempts = self.config['processing_settings']['retry_attempts']
            retry_delay = self.config['processing_settings']['retry_delay']
            
            for attempt in range(retry_attempts):
                try:
                    self.stats['api_calls'] += 1
                    prompt = self.create_ai_prompt(record)
                    
                    # 获取超时设置
                    timeout = self.config['processing_settings'].get('timeout', 60)
                    
                    async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=timeout)) as session:
                        headers = {
                            'Authorization': f'Bearer {self.api_key}',
                            'Content-Type': 'application/json'
                        }
                        
                        # 构建基础payload
                        system_message = "你是一个专业的Flutter国际化助手。你的任务是将Dart代码中的中文字符串替换为Flutter国际化调用，并生成对应的ARB键值对。\n\n核心要求：\n1. 精确保持代码行数不变\n2. 使用AppLocalizations.of(context).keyName格式进行替换\n3. 生成语义化的英文键名\n4. 正确处理字符串插值和复杂表达式\n5. 返回标准JSON格式"
                        
                        payload = {
                            'model': self.config['api_settings']['model'],
                            'messages': [
                                {'role': 'system', 'content': system_message},
                                {'role': 'user', 'content': prompt}
                            ],
                            'temperature': self.config['api_settings']['temperature'],
                            'max_tokens': self.config['api_settings']['max_tokens']
                        }
                        
                        # 添加可选参数
                        optional_params = ['top_p', 'frequency_penalty', 'presence_penalty']
                        for param in optional_params:
                            if param in self.config['api_settings']:
                                payload[param] = self.config['api_settings'][param]
                        
                        async with session.post(self.api_url, headers=headers, json=payload) as response:
                            if response.status == 200:
                                result = await response.json()
                                ai_content = result['choices'][0]['message']['content']
                                
                                # 清理AI返回的内容（移除可能的markdown标记）
                                ai_content = ai_content.strip()
                                if ai_content.startswith('```json'):
                                    ai_content = ai_content[7:]
                                if ai_content.endswith('```'):
                                    ai_content = ai_content[:-3]
                                ai_content = ai_content.strip()
                                
                                # 解析AI返回的JSON
                                try:
                                    ai_data = json.loads(ai_content)
                                    
                                    # 验证必需字段
                                    if 'replaced_code' not in ai_data or 'arb_entries' not in ai_data:
                                        raise ValueError("AI返回的JSON缺少必需字段")
                                    
                                    # 验证行数是否相等
                                    if self.config['processing_settings']['validate_line_count']:
                                        original_lines = record.code.count('\n') + 1
                                        replaced_lines = ai_data['replaced_code'].count('\n') + 1
                                        
                                        if original_lines != replaced_lines:
                                            logger.warning(f"行数不匹配 {record.yaml_file}: 原始{original_lines}行 vs 替换{replaced_lines}行")
                                            if abs(original_lines - replaced_lines) > 2:  # 允许小幅差异
                                                raise ValueError(f"行数差异过大: {original_lines} vs {replaced_lines}")
                                    
                                    return AIResponse(
                                        replaced_code=ai_data['replaced_code'],
                                        arb_entries=ai_data['arb_entries'],
                                        success=True
                                    )
                                except (json.JSONDecodeError, ValueError) as e:
                                    if attempt < retry_attempts - 1:
                                        logger.warning(f"AI返回解析失败 {record.yaml_file} (尝试 {attempt + 1}/{retry_attempts}): {e}")
                                        await asyncio.sleep(retry_delay)
                                        continue
                                    else:
                                        logger.error(f"AI返回解析失败 {record.yaml_file}: {e}")
                                        logger.debug(f"AI原始返回: {ai_content}")
                                        return AIResponse(
                                            replaced_code="",
                                            arb_entries={},
                                            success=False,
                                            error_message=f"JSON解析失败: {e}"
                                        )
                            else:
                                error_text = await response.text()
                                if attempt < retry_attempts - 1:
                                    logger.warning(f"API调用失败 {record.yaml_file} (尝试 {attempt + 1}/{retry_attempts}): {response.status}")
                                    await asyncio.sleep(retry_delay)
                                    continue
                                else:
                                    error_msg = f"API调用失败: {response.status} - {error_text}"
                                    logger.error(f"{error_msg} - {record.yaml_file}")
                                    return AIResponse(
                                        replaced_code="",
                                        arb_entries={},
                                        success=False,
                                        error_message=error_msg
                                    )
                                
                except asyncio.TimeoutError:
                    if attempt < retry_attempts - 1:
                        logger.warning(f"API调用超时 {record.yaml_file} (尝试 {attempt + 1}/{retry_attempts})")
                        await asyncio.sleep(retry_delay)
                        continue
                    else:
                        logger.error(f"API调用超时 {record.yaml_file}")
                        return AIResponse(
                            replaced_code="",
                            arb_entries={},
                            success=False,
                            error_message="API调用超时"
                        )
                except Exception as e:
                    if attempt < retry_attempts - 1:
                        logger.warning(f"AI API调用异常 {record.yaml_file} (尝试 {attempt + 1}/{retry_attempts}): {e}")
                        await asyncio.sleep(retry_delay)
                        continue
                    else:
                        logger.error(f"AI API调用异常 {record.yaml_file}: {e}")
                        return AIResponse(
                            replaced_code="",
                            arb_entries={},
                            success=False,
                            error_message=str(e)
                        )
            
            # 如果所有重试都失败了
            return AIResponse(
                replaced_code="",
                arb_entries={},
                success=False,
                error_message="所有重试尝试都失败了"
            )
    
    def verify_and_adjust_line_numbers(self, lines: List[str], start_idx: int, end_idx: int, 
                                       expected_code: str, file_path: str) -> Tuple[Optional[int], Optional[int]]:
        """验证并调整行号，确保目标位置的代码与期望代码一致"""
        def normalize_code(code: str) -> str:
            """标准化代码，去除多余空白和换行符"""
            return ''.join(code.split())
        
        def extract_code_from_lines(lines: List[str], start: int, end: int) -> str:
            """从文件行中提取代码段"""
            if start < 0 or end >= len(lines) or start > end:
                return ""
            code_lines = []
            for i in range(start, end + 1):
                line = lines[i].rstrip('\n')
                code_lines.append(line)
            return '\n'.join(code_lines)
        
        # 标准化期望的代码
        expected_normalized = normalize_code(expected_code)
        
        # 首先检查原始位置
        current_code = extract_code_from_lines(lines, start_idx, end_idx)
        current_normalized = normalize_code(current_code)
        
        if current_normalized == expected_normalized:
            logger.debug(f"代码匹配成功 {file_path}: 行{start_idx+1}-{end_idx+1}")
            return start_idx, end_idx
        
        # 如果不匹配，尝试在附近范围内查找
        search_range = 3  # 前后搜索3行
        code_length = end_idx - start_idx + 1
        
        logger.warning(f"原始位置代码不匹配 {file_path}: 行{start_idx+1}-{end_idx+1}，尝试搜索附近位置")
        logger.debug(f"期望代码: {repr(expected_code)}")
        logger.debug(f"实际代码: {repr(current_code)}")
        
        # 在搜索范围内尝试不同的起始位置
        for offset in range(-search_range, search_range + 1):
            if offset == 0:  # 已经检查过原始位置
                continue
                
            new_start = start_idx + offset
            new_end = new_start + code_length - 1
            
            if new_start < 0 or new_end >= len(lines):
                continue
                
            test_code = extract_code_from_lines(lines, new_start, new_end)
            test_normalized = normalize_code(test_code)
            
            if test_normalized == expected_normalized:
                logger.info(f"找到匹配代码 {file_path}: 调整行号从{start_idx+1}-{end_idx+1}到{new_start+1}-{new_end+1}")
                return new_start, new_end
        
        # 如果仍然找不到，尝试不同长度的代码段
        for length_offset in [-1, 1, -2, 2]:
            new_length = code_length + length_offset
            if new_length <= 0:
                continue
                
            for offset in range(-search_range, search_range + 1):
                new_start = start_idx + offset
                new_end = new_start + new_length - 1
                
                if new_start < 0 or new_end >= len(lines):
                    continue
                    
                test_code = extract_code_from_lines(lines, new_start, new_end)
                test_normalized = normalize_code(test_code)
                
                if test_normalized == expected_normalized:
                    logger.info(f"找到匹配代码 {file_path}: 调整行号从{start_idx+1}-{end_idx+1}到{new_start+1}-{new_end+1}")
                    return new_start, new_end
        
        return None, None
    
    async def replace_dart_code(self, record: YamlRecord, ai_response: AIResponse) -> bool:
        """替换Dart文件中的代码段"""
        try:
            dart_file = Path(record.path)
            if not dart_file.is_absolute():
                # 假设相对于项目根目录的lib目录
                project_root = self.yaml_dir.parent.parent  # scripts/python -> scripts -> project_root
                dart_file = project_root / 'lib' / record.path
            
            if not dart_file.exists():
                logger.error(f"Dart文件不存在: {dart_file}")
                return False
            
            # 备份原文件
            backup_path = self.backup_file(dart_file)
            
            # 读取原文件
            async with aiofiles.open(dart_file, 'r', encoding='utf-8') as f:
                lines = await f.readlines()
            
            # 检查第一行是否为AI处理标记
            dart_file_str = str(dart_file)
            ai_comment = "// This file has been processed by AI for internationalization\n"
            has_ai_marker = False
            
            if lines:
                first_line = lines[0].strip()
                if first_line.startswith("// This file has been processed by AI"):
                    has_ai_marker = True
            
            # 如果没有AI标记，添加到第一行（但不影响行号计算）
            if not has_ai_marker and dart_file_str not in self.processed_dart_files:
                lines.insert(0, ai_comment)
                self.processed_dart_files.add(dart_file_str)
                logger.debug(f"已为文件添加AI处理标记: {dart_file}")
            elif has_ai_marker:
                # 文件已有标记，记录到已处理集合
                self.processed_dart_files.add(dart_file_str)
            
            # 重要：行号计算必须基于原始文件结构，AI标记不影响行号
            # 如果文件现在有AI标记（无论是原有的还是刚添加的），
            # 原始的第1行现在在数组索引1的位置，第2行在索引2，以此类推
            
            # 检查当前文件是否有AI标记（包括刚添加的）
            current_has_marker = len(lines) > 0 and lines[0].strip().startswith("// This file has been processed by AI")
            
            if current_has_marker:
                # 有AI标记：原始第N行现在在数组索引N的位置（因为AI标记占了索引0）
                start_idx = record.start_line
                end_idx = record.end_line
            else:
                # 没有AI标记：原始第N行在数组索引N-1的位置
                start_idx = record.start_line - 1
                end_idx = record.end_line - 1
            
            # 验证行号范围
            if start_idx < 0 or end_idx >= len(lines) or start_idx > end_idx:
                marker_info = "有AI标记" if current_has_marker else "无AI标记"
                logger.error(f"无效的行号范围 {record.path}: 原始行{record.start_line}-{record.end_line}, 数组索引{start_idx}-{end_idx} (文件共{len(lines)}行，{marker_info})")
                return False
            
            # 代码一致性检查和行号微调
            adjusted_start, adjusted_end = self.verify_and_adjust_line_numbers(
                lines, start_idx, end_idx, record.code, record.path
            )
            if adjusted_start is None or adjusted_end is None:
                logger.error(f"无法找到匹配的代码段 {record.path}: 期望代码与实际文件内容不匹配")
                return False
            
            start_idx, end_idx = adjusted_start, adjusted_end
            
            # 将替换的代码按行分割
            replacement_lines = ai_response.replaced_code.split('\n')
            
            # 确保每行都以换行符结尾（除了最后一行）
            for i in range(len(replacement_lines) - 1):
                if not replacement_lines[i].endswith('\n'):
                    replacement_lines[i] += '\n'
            
            # 如果最后一行不是空的且原来的最后一行有换行符，则添加换行符
            if replacement_lines and end_idx < len(lines) - 1 and lines[end_idx].endswith('\n'):
                if not replacement_lines[-1].endswith('\n'):
                    replacement_lines[-1] += '\n'
            
            # 执行替换
            new_lines = lines[:start_idx] + replacement_lines + lines[end_idx + 1:]
            
            # 写回文件
            async with aiofiles.open(dart_file, 'w', encoding='utf-8') as f:
                await f.writelines(new_lines)
            
            logger.info(f"成功替换代码: {dart_file} (原始行 {record.start_line}-{record.end_line})")
            if backup_path:
                logger.debug(f"原文件已备份至: {backup_path}")
            return True
            
        except Exception as e:
            logger.error(f"替换Dart代码失败 {record.path}: {e}")
            return False
    
    async def collect_arb_entries(self, record: YamlRecord, ai_response: AIResponse):
        """收集ARB条目并立即生成文件"""
        # 根据原始Dart文件路径生成ARB文件路径
        dart_path = Path(record.path)
        
        # 获取相对于项目根目录的路径
        try:
            # 假设Dart文件在lib目录下
            if 'lib' in dart_path.parts:
                lib_index = dart_path.parts.index('lib')
                relative_parts = dart_path.parts[lib_index + 1:]  # 跳过'lib'
                relative_path = Path(*relative_parts).with_suffix('')
            else:
                # 如果不在lib目录下，保持完整的相对路径结构
                relative_path = dart_path.with_suffix('')
        except Exception:
            relative_path = dart_path.stem
        
        # 构建ARB文件路径，保持目录结构
        arb_base_path = self.config['output_settings']['arb_base_path']
        arb_file_path = Path(arb_base_path) / f"{relative_path}.arb"
        
        arb_key = str(arb_file_path)
        
        # 检查键冲突
        if arb_key in self.arb_data:
            for key, value in ai_response.arb_entries.items():
                if key in self.arb_data[arb_key] and self.arb_data[arb_key][key] != value:
                    logger.warning(f"ARB键冲突: {key} 在 {arb_file_path}")
                    logger.warning(f"  现有值: {self.arb_data[arb_key][key]}")
                    logger.warning(f"  新值: {value}")
        
        # 立即生成ARB文件
        await self.generate_single_arb_file(arb_key, ai_response.arb_entries)
        
        # 同时保存到内存中（用于统计和兼容性）
        if arb_key not in self.arb_data:
            self.arb_data[arb_key] = {}
        self.arb_data[arb_key].update(ai_response.arb_entries)
        
        logger.debug(f"立即生成ARB条目: {len(ai_response.arb_entries)} 个条目 -> {arb_file_path}")
        
    async def generate_single_arb_file(self, arb_path: str, new_entries: Dict[str, str]):
        """立即生成单个ARB文件"""
        try:
            arb_file = self.yaml_dir.parent / arb_path
            arb_file.parent.mkdir(parents=True, exist_ok=True)
            
            # 如果文件已存在，合并内容
            existing_entries = {}
            if arb_file.exists():
                async with aiofiles.open(arb_file, 'r', encoding='utf-8') as f:
                    content = await f.read()
                    try:
                        existing_entries = json.loads(content)
                    except json.JSONDecodeError:
                        logger.warning(f"现有ARB文件格式错误，将覆盖: {arb_file}")
            
            # 合并条目
            existing_entries.update(new_entries)
            
            # 写入ARB文件
            async with aiofiles.open(arb_file, 'w', encoding='utf-8') as f:
                await f.write(json.dumps(existing_entries, ensure_ascii=False, indent=2))
            
            logger.info(f"立即生成ARB文件: {arb_file} ({len(new_entries)} 个新条目)")
            
        except Exception as e:
            logger.error(f"生成ARB文件失败 {arb_path}: {e}")
    
    async def generate_arb_files(self):
        """生成ARB文件（批量模式，用于兼容）"""
        for arb_path, entries in self.arb_data.items():
            await self.generate_single_arb_file(arb_path, entries)
    
    async def process_record(self, record: YamlRecord) -> bool:
        """处理单个记录"""
        logger.info(f"处理记录: {record.yaml_file}")
        
        try:
            # 标记为处理中
            self.mark_file_processed(Path(record.yaml_file), 'processing')
            self.save_progress_immediately()
            
            # 调用AI API
            ai_response = await self.call_ai_api(record)
            
            if not ai_response.success:
                error_msg = f"AI处理失败: {ai_response.error_message}"
                self.mark_file_processed(Path(record.yaml_file), 'failed', error_msg)
                self.save_progress_immediately()
                logger.error(f"AI处理失败: {record.yaml_file} - {ai_response.error_message}")
                return False
            
            # 替换Dart代码
            if await self.replace_dart_code(record, ai_response):
                # 收集ARB条目并立即生成文件
                await self.collect_arb_entries(record, ai_response)
                
                # 更新Dart文件信息
                self.update_file_dart_info(Path(record.yaml_file), record.path)
                
                # 标记文件为成功处理
                self.mark_file_processed(Path(record.yaml_file), 'success')
                self.save_progress_immediately()
                
                logger.info(f"✓ 成功处理: {record.yaml_file}")
                return True
            else:
                error_msg = "Dart代码替换失败"
                self.mark_file_processed(Path(record.yaml_file), 'failed', error_msg)
                self.save_progress_immediately()
                logger.error(f"✗ 代码替换失败: {record.yaml_file}")
                return False
                
        except Exception as e:
            error_msg = f"处理异常: {str(e)}"
            self.mark_file_processed(Path(record.yaml_file), 'failed', error_msg)
            self.save_progress_immediately()
            logger.error(f"✗ 处理记录失败 {record.yaml_file}: {e}")
            return False
    
    async def run(self):
        """运行主处理流程"""
        self.stats['start_time'] = datetime.now()
        logger.info("开始国际化处理...")
        logger.info(f"配置信息: 模型={self.config['api_settings']['model']}, 并发数={self.max_concurrent}, 重试次数={self.config['processing_settings']['retry_attempts']}")
        
        # 加载YAML记录
        records = await self.load_yaml_records()
        if not records:
            logger.warning("没有找到有效的YAML记录")
            return
        
        self.stats['total_records'] = len(records)
        logger.info(f"开始处理 {len(records)} 个记录，最大并发数: {self.max_concurrent}")
        
        # 并发处理记录
        tasks = [self.process_record(record) for record in records]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # 统计结果
        success_count = sum(1 for result in results if result is True)
        exception_count = sum(1 for result in results if isinstance(result, Exception))
        
        self.stats['processed_successfully'] = success_count
        self.stats['failed_records'] = len(records) - success_count
        
        # 保存进度
        self.save_progress()
        logger.info("已保存处理进度")
        
        self.stats['end_time'] = datetime.now()
        
        # 计算处理时间
        processing_time = self.stats['end_time'] - self.stats['start_time']
        
        logger.info(f"处理完成: {success_count}/{len(records)} 成功, {exception_count} 异常")
        logger.info(f"总耗时: {processing_time.total_seconds():.2f}秒, API调用次数: {self.stats['api_calls']}")
        
        # 生成ARB文件
        if self.arb_data:
            logger.info("生成ARB文件...")
            await self.generate_arb_files()
            total_entries = sum(len(entries) for entries in self.arb_data.values())
            logger.info(f"生成了 {len(self.arb_data)} 个ARB文件，共 {total_entries} 个条目")
        else:
            logger.warning("没有ARB数据需要生成")
        
        # 输出最终统计
        self.print_final_stats()
    
    def print_final_stats(self):
        """输出最终统计信息"""
        print("\n" + "=" * 60)
        print("处理统计报告")
        print("=" * 60)
        print(f"总记录数: {self.stats['total_records']}")
        print(f"成功处理: {self.stats['processed_successfully']}")
        print(f"处理失败: {self.stats['failed_records']}")
        if self.stats['skipped_records'] > 0:
            print(f"跳过文件: {self.stats['skipped_records']}")
        
        if self.stats['total_records'] > 0:
            success_rate = (self.stats['processed_successfully'] / self.stats['total_records'] * 100)
            print(f"成功率: {success_rate:.1f}%")
        
        print(f"API调用次数: {self.stats['api_calls']}")
        
        if self.stats['start_time'] and self.stats['end_time']:
            processing_time = self.stats['end_time'] - self.stats['start_time']
            print(f"总耗时: {processing_time.total_seconds():.2f}秒")
            if self.stats['api_calls'] > 0:
                avg_time = processing_time.total_seconds() / self.stats['api_calls']
                print(f"平均每次API调用: {avg_time:.2f}秒")
        
        # 详细进度统计
        if self.processed_files:
            status_counts = {'success': 0, 'failed': 0, 'processing': 0}
            failed_files = []
            
            for file_key, file_info in self.processed_files.items():
                if isinstance(file_info, dict):
                    status = file_info.get('status', 'unknown')
                    status_counts[status] = status_counts.get(status, 0) + 1
                    
                    if status == 'failed':
                        error_msg = file_info.get('error', '未知错误')
                        failed_files.append(f"  {file_key}: {error_msg}")
            
            print("\n进度详情:")
            print(f"  成功: {status_counts.get('success', 0)}")
            print(f"  失败: {status_counts.get('failed', 0)}")
            if status_counts.get('processing', 0) > 0:
                print(f"  处理中: {status_counts.get('processing', 0)}")
            
            if failed_files:
                print("\n失败文件详情:")
                for failed_file in failed_files[:10]:  # 最多显示10个
                    print(failed_file)
                if len(failed_files) > 10:
                    print(f"  ... 还有 {len(failed_files) - 10} 个失败文件")
        
        if self.arb_data:
            total_entries = sum(len(entries) for entries in self.arb_data.values())
            print(f"\n生成ARB文件: {len(self.arb_data)}个")
            print(f"总ARB条目: {total_entries}个")
            
            # 显示ARB文件列表
            print("\nARB文件列表:")
            for arb_file, entries in self.arb_data.items():
                print(f"  {arb_file} ({len(entries)} 个条目)")
        
        if len(self.processed_dart_files) > 0:
            print(f"\n已标记AI处理的Dart文件: {len(self.processed_dart_files)}个")
        
        print(f"\n进度文件: {self.progress_file}")
        print("=" * 60)

def main():
    parser = argparse.ArgumentParser(
        description='国际化处理工具 - 将Dart代码中的中文字符串替换为l10n调用',
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument(
        'yaml_dir',
        help='包含YAML记录文件的目录路径'
    )
    
    parser.add_argument(
        '--api-url',
        default='https://api.openai.com/v1/chat/completions',
        help='AI API的URL地址\n(默认: OpenAI API)'
    )
    
    parser.add_argument(
        '--api-key',
        help='AI API的密钥\n(也可通过环境变量 OPENAI_API_KEY 设置)'
    )
    
    parser.add_argument(
        '--max-concurrent',
        type=int,
        default=5,
        help='最大并发请求数\n(默认: 5)'
    )
    
    parser.add_argument(
        '--config',
        help='配置文件路径\n(JSON格式，可覆盖默认设置)'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='试运行模式，不实际修改文件'
    )
    
    parser.add_argument(
        '--log-level',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
        default='INFO',
        help='日志级别\n(默认: INFO)'
    )
    
    parser.add_argument(
        '--reset-progress',
        action='store_true',
        help='重置处理进度，重新处理所有文件'
    )
    
    parser.add_argument(
        '--arb-output',
        help='ARB文件输出目录\n(覆盖配置文件中的设置)'
    )
    
    args = parser.parse_args()
    
    # 设置日志级别
    logging.getLogger().setLevel(getattr(logging, args.log_level))
    
    # 获取API密钥
    api_key = args.api_key or os.getenv('OPENAI_API_KEY')
    if not api_key:
        logger.error("错误: 请提供API密钥")
        logger.error("方法1: 使用 --api-key 参数")
        logger.error("方法2: 设置环境变量 OPENAI_API_KEY")
        return 1
    
    if args.dry_run:
        logger.info("*** 试运行模式 - 不会实际修改文件 ***")
    
    try:
        # 创建处理器并运行
        processor = I18nProcessor(
            yaml_dir=args.yaml_dir,
            api_url=args.api_url,
            api_key=api_key,
            max_concurrent=args.max_concurrent,
            config_file=args.config
        )
        
        # 重置进度
        if args.reset_progress:
            if processor.progress_file.exists():
                processor.progress_file.unlink()
                logger.info("已重置处理进度")
            processor.processed_files = {}
        
        # 覆盖ARB输出目录
        if args.arb_output:
            processor.config['output_settings']['arb_base_path'] = args.arb_output
            logger.info(f"ARB输出目录设置为: {args.arb_output}")
        
        # 如果是试运行模式，修改配置
        if args.dry_run:
            processor.config['output_settings']['backup_original'] = False
            logger.info("试运行模式：已禁用文件备份和修改")
        
        # 运行异步处理
        asyncio.run(processor.run())
        return 0
        
    except KeyboardInterrupt:
        logger.info("\n用户中断处理")
        return 1
    except Exception as e:
        logger.error(f"处理过程中发生错误: {e}")
        logger.debug("详细错误信息:", exc_info=True)
        return 1

if __name__ == '__main__':
    import sys
    sys.exit(main())