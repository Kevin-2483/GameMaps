#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ARB Translator - ARB文件自动翻译工具

功能：
1. 加载英文ARB文件中的中文内容
2. 并发调用AI API进行中文到英文的翻译
3. 生成新的英文ARB文件
4. 复用i18n_config.json配置
"""

import asyncio
import aiohttp
import aiofiles
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
import argparse
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor
import logging
from collections import defaultdict
import time
from datetime import datetime
import re
import hashlib

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class TranslationTask:
    """翻译任务数据结构"""
    key: str
    chinese_text: str
    context: Optional[str] = None

@dataclass
class TranslationResult:
    """翻译结果数据结构"""
    key: str
    english_text: str
    success: bool
    error_message: Optional[str] = None
    processed_by_ai: bool = True

@dataclass
class ProgressEntry:
    """进度条目数据结构"""
    key: str
    original_text: str
    translated_text: str
    processed_by_ai: bool
    timestamp: str
    success: bool
    error_message: Optional[str] = None

class ARBTranslator:
    """ARB文件翻译器"""
    
    def __init__(self, config_file: str = "scripts/python/i18n_config.json", max_concurrent: int = None, api_key: str = None, target_language: str = "英文"):
        self.config = self.load_config(config_file)
        self.api_url = self.config['api_settings']['url']
        self.api_key = api_key or self.get_api_key()
        self.max_concurrent = max_concurrent or self.config['processing_settings']['max_concurrent']
        self.target_language = target_language
        self.session = None
        self.semaphore = asyncio.Semaphore(self.max_concurrent)
        
        # 进度文件相关
        self.progress_file_path = None
        self.progress_data = {}
        
        # 统计信息
        self.stats = {
            'total_tasks': 0,
            'successful_translations': 0,
            'failed_translations': 0,
            'skipped_translations': 0,
            'start_time': None,
            'end_time': None
        }
    
    def load_config(self, config_file: str) -> Dict:
        """加载配置文件"""
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"加载配置文件失败: {e}")
            # 返回默认配置
            return {
                'api_settings': {
                    'url': 'https://api.deepseek.com/chat/completions',
                    'model': 'deepseek-chat',
                    'temperature': 0.1,
                    'max_tokens': 4000,
                    'top_p': 0.95,
                    'frequency_penalty': 0.0,
                    'presence_penalty': 0.0
                },
                'processing_settings': {
                    'max_concurrent': 3,
                    'retry_attempts': 3,
                    'retry_delay': 2.0,
                    'timeout': 120
                }
            }
    
    def get_api_key(self) -> str:
        """获取API密钥"""
        import os
        api_key = os.getenv('DEEPSEEK_API_KEY')
        if not api_key:
            logger.warning("未找到DEEPSEEK_API_KEY环境变量，请确保已设置")
            return ""
        return api_key
    
    def is_chinese_text(self, text: str) -> bool:
        """检查文本是否包含中文字符"""
        chinese_pattern = re.compile(r'[\u4e00-\u9fff]+')
        return bool(chinese_pattern.search(text))
    
    def get_progress_file_path(self, arb_file_path: str) -> str:
        """获取进度文件路径"""
        arb_path = Path(arb_file_path)
        progress_file_name = f".{arb_path.stem}.json"
        return str(arb_path.parent / progress_file_name)
    
    async def load_progress_file(self, progress_file_path: str) -> Dict[str, ProgressEntry]:
        """加载进度文件"""
        try:
            if Path(progress_file_path).exists():
                async with aiofiles.open(progress_file_path, 'r', encoding='utf-8') as f:
                    content = await f.read()
                    data = json.loads(content)
                    
                    # 转换为ProgressEntry对象
                    progress_entries = {}
                    for key, entry_data in data.items():
                        progress_entries[key] = ProgressEntry(
                            key=entry_data['key'],
                            original_text=entry_data['original_text'],
                            translated_text=entry_data['translated_text'],
                            processed_by_ai=entry_data.get('processed_by_ai', True),
                            timestamp=entry_data['timestamp'],
                            success=entry_data['success'],
                            error_message=entry_data.get('error_message')
                        )
                    return progress_entries
        except Exception as e:
            logger.warning(f"加载进度文件失败 {progress_file_path}: {e}")
        
        return {}
    
    async def save_progress_entry(self, entry: ProgressEntry):
        """保存单个进度条目到文件"""
        if not self.progress_file_path:
            return
        
        try:
            # 更新内存中的进度数据
            self.progress_data[entry.key] = entry
            
            # 转换为可序列化的字典
            serializable_data = {}
            for key, progress_entry in self.progress_data.items():
                serializable_data[key] = {
                    'key': progress_entry.key,
                    'original_text': progress_entry.original_text,
                    'translated_text': progress_entry.translated_text,
                    'processed_by_ai': progress_entry.processed_by_ai,
                    'timestamp': progress_entry.timestamp,
                    'success': progress_entry.success,
                    'error_message': progress_entry.error_message
                }
            
            # 确保目录存在
            Path(self.progress_file_path).parent.mkdir(parents=True, exist_ok=True)
            
            # 写入文件
            async with aiofiles.open(self.progress_file_path, 'w', encoding='utf-8') as f:
                await f.write(json.dumps(serializable_data, ensure_ascii=False, indent=2))
                
        except Exception as e:
            logger.error(f"保存进度条目失败: {e}")
    
    async def save_translation_result_immediately(self, arb_file_path: str, result: TranslationResult):
        """立即保存翻译结果到ARB文件"""
        try:
            # 读取当前ARB文件
            current_arb = await self.load_arb_file(arb_file_path)
            
            # 更新翻译结果
            current_arb[result.key] = result.english_text
            
            # 写回文件
            async with aiofiles.open(arb_file_path, 'w', encoding='utf-8') as f:
                await f.write(json.dumps(current_arb, ensure_ascii=False, indent=2))
            
            logger.info(f"已保存翻译结果到ARB文件: {result.key} -> {result.english_text}")
            
        except Exception as e:
            logger.error(f"保存翻译结果到ARB文件失败: {e}")
    
    def is_key_already_processed(self, key: str) -> bool:
        """检查键是否已经处理过"""
        return key in self.progress_data and self.progress_data[key].success
    
    async def load_arb_file(self, arb_file_path: str) -> Dict[str, str]:
        """加载ARB文件"""
        try:
            async with aiofiles.open(arb_file_path, 'r', encoding='utf-8') as f:
                content = await f.read()
                return json.loads(content)
        except Exception as e:
            logger.error(f"加载ARB文件失败 {arb_file_path}: {e}")
            return {}
    
    def extract_translation_tasks(self, arb_data: Dict[str, str]) -> List[TranslationTask]:
        """提取需要翻译的任务"""
        tasks = []
        for key, value in arb_data.items():
            # 跳过元数据键
            if key.startswith('@@') or key.startswith('@'):
                continue
            
            # 跳过已经处理过的键
            if self.is_key_already_processed(key):
                logger.info(f"跳过已处理的键: {key}")
                self.stats['skipped_translations'] += 1
                continue
            
            # 只处理包含中文的值
            if isinstance(value, str) and self.is_chinese_text(value):
                tasks.append(TranslationTask(
                    key=key,
                    chinese_text=value,
                    context=f"ARB localization key: {key}"
                ))
        
        return tasks
    
    def create_translation_prompt(self, task: TranslationTask) -> str:
        """创建翻译提示词"""
        # 根据目标语言动态生成提示词
        language_prompts = {
            "英文": {
                "instruction": "请将以下中文文本翻译成英文",
                "result_label": "英文翻译："
            },
            "日文": {
                "instruction": "请将以下中文文本翻译成日文",
                "result_label": "日文翻译："
            },
            "韩文": {
                "instruction": "请将以下中文文本翻译成韩文",
                "result_label": "韩文翻译："
            },
            "法文": {
                "instruction": "请将以下中文文本翻译成法文",
                "result_label": "法文翻译："
            },
            "德文": {
                "instruction": "请将以下中文文本翻译成德文",
                "result_label": "德文翻译："
            },
            "西班牙文": {
                "instruction": "请将以下中文文本翻译成西班牙文",
                "result_label": "西班牙文翻译："
            },
            "俄文": {
                "instruction": "请将以下中文文本翻译成俄文",
                "result_label": "俄文翻译："
            },
            "阿拉伯文": {
                "instruction": "请将以下中文文本翻译成阿拉伯文",
                "result_label": "阿拉伯文翻译："
            },
            "中文": {
                "instruction": "请将以下文本翻译成中文",
                "result_label": "中文翻译："
            }
        }
        
        # 获取对应语言的提示词配置，如果不存在则使用英文作为默认
        lang_config = language_prompts.get(self.target_language, language_prompts["英文"])
        
        prompt = f"""{lang_config["instruction"]}。这是一个Flutter应用的本地化字符串。

要求：
1. 保持原文的语义和语调
2. 适合用户界面显示
3. 简洁明了
4. 如果包含占位符（如{{variable}}），请保持不变
5. 只返回翻译结果，不要包含其他内容

上下文：{task.context}
中文原文：{task.chinese_text}

{lang_config["result_label"]}"""
        return prompt
    
    async def translate_text(self, task: TranslationTask) -> TranslationResult:
        """调用AI API翻译文本"""
        async with self.semaphore:
            try:
                prompt = self.create_translation_prompt(task)
                
                payload = {
                    "model": self.config['api_settings']['model'],
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": self.config['api_settings']['temperature'],
                    "max_tokens": self.config['api_settings']['max_tokens'],
                    "top_p": self.config['api_settings']['top_p'],
                    "frequency_penalty": self.config['api_settings']['frequency_penalty'],
                    "presence_penalty": self.config['api_settings']['presence_penalty']
                }
                
                headers = {
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json"
                }
                
                timeout = aiohttp.ClientTimeout(total=self.config['processing_settings']['timeout'])
                
                async with self.session.post(
                    self.api_url,
                    json=payload,
                    headers=headers,
                    timeout=timeout
                ) as response:
                    if response.status == 200:
                        result = await response.json()
                        english_text = result['choices'][0]['message']['content'].strip()
                        
                        # 清理翻译结果
                        english_text = self.clean_translation_result(english_text)
                        
                        logger.info(f"翻译成功: {task.key} -> {english_text}")
                        return TranslationResult(
                            key=task.key,
                            english_text=english_text,
                            success=True,
                            processed_by_ai=True
                        )
                    else:
                        error_msg = f"API请求失败，状态码: {response.status}"
                        logger.error(f"翻译失败 {task.key}: {error_msg}")
                        return TranslationResult(
                            key=task.key,
                            english_text=task.chinese_text,  # 保持原文
                            success=False,
                            error_message=error_msg,
                            processed_by_ai=False
                        )
                        
            except Exception as e:
                error_msg = f"翻译异常: {str(e)}"
                logger.error(f"翻译失败 {task.key}: {error_msg}")
                return TranslationResult(
                    key=task.key,
                    english_text=task.chinese_text,  # 保持原文
                    success=False,
                    error_message=error_msg,
                    processed_by_ai=False
                )
    
    def clean_translation_result(self, text: str) -> str:
        """清理翻译结果"""
        # 移除可能的引号
        text = text.strip('"\'')
        
        # 移除前后空白
        text = text.strip()
        
        # 根据目标语言定义可能的前缀
        language_prefixes = {
            "英文": ["英文翻译：", "English translation:", "Translation:", "英文：", "English:"],
            "日文": ["日文翻译：", "Japanese translation:", "日文：", "Japanese:"],
            "韩文": ["韩文翻译：", "Korean translation:", "韩文：", "Korean:"],
            "法文": ["法文翻译：", "French translation:", "法文：", "French:"],
            "德文": ["德文翻译：", "German translation:", "德文：", "German:"],
            "西班牙文": ["西班牙文翻译：", "Spanish translation:", "西班牙文：", "Spanish:"],
            "俄文": ["俄文翻译：", "Russian translation:", "俄文：", "Russian:"],
            "阿拉伯文": ["阿拉伯文翻译：", "Arabic translation:", "阿拉伯文：", "Arabic:"],
            "中文": ["中文翻译：", "Chinese translation:", "中文：", "Chinese:"]
        }
        
        # 获取当前目标语言的前缀列表，如果不存在则使用英文的前缀
        prefixes = language_prefixes.get(self.target_language, language_prefixes["英文"])
        
        # 移除前缀
        for prefix in prefixes:
            if text.startswith(prefix):
                text = text[len(prefix):].strip()
                break
        
        return text
    
    async def translate_batch(self, tasks: List[TranslationTask]) -> List[TranslationResult]:
        """批量翻译"""
        logger.info(f"开始批量翻译，共 {len(tasks)} 个任务")
        
        # 创建HTTP会话
        connector = aiohttp.TCPConnector(limit=self.max_concurrent)
        self.session = aiohttp.ClientSession(connector=connector)
        
        try:
            # 并发执行翻译任务
            translation_tasks = [self.translate_text(task) for task in tasks]
            results = await asyncio.gather(*translation_tasks, return_exceptions=True)
            
            # 处理异常结果
            processed_results = []
            for i, result in enumerate(results):
                if isinstance(result, Exception):
                    logger.error(f"任务 {tasks[i].key} 执行异常: {result}")
                    processed_results.append(TranslationResult(
                        key=tasks[i].key,
                        english_text=tasks[i].chinese_text,
                        success=False,
                        error_message=str(result),
                        processed_by_ai=False
                    ))
                else:
                    processed_results.append(result)
            
            return processed_results
            
        finally:
            await self.session.close()
    
    async def process_translation_result(self, result: TranslationResult, output_path: str):
        """处理单个翻译结果"""
        # 创建进度条目
        progress_entry = ProgressEntry(
            key=result.key,
            original_text=result.english_text if not result.success else "",  # 如果翻译失败，记录原文
            translated_text=result.english_text,
            processed_by_ai=result.processed_by_ai,
            timestamp=datetime.now().isoformat(),
            success=result.success,
            error_message=result.error_message
        )
        
        # 保存进度条目
        await self.save_progress_entry(progress_entry)
        
        # 立即保存翻译结果到ARB文件
        await self.save_translation_result_immediately(output_path, result)
        
        # 更新统计
        if result.success:
            self.stats['successful_translations'] += 1
        else:
            self.stats['failed_translations'] += 1
            logger.warning(f"翻译失败，保持原文 {result.key}: {result.error_message}")
    
    async def migrate_existing_translations(self, arb_file_path: str):
        """迁移现有翻译，标记为已处理"""
        logger.info("开始迁移现有翻译...")
        
        # 加载ARB文件
        arb_data = await self.load_arb_file(arb_file_path)
        
        migrated_count = 0
        for key, value in arb_data.items():
            # 跳过元数据键
            if key.startswith('@@') or key.startswith('@'):
                continue
            
            # 跳过已经处理过的键
            if self.is_key_already_processed(key):
                continue
            
            # 创建进度条目（标记为非AI处理）
            progress_entry = ProgressEntry(
                key=key,
                original_text="",  # 迁移的条目没有原文记录
                translated_text=value,
                processed_by_ai=False,  # 标记为非AI处理
                timestamp=datetime.now().isoformat(),
                success=True,
                error_message=None
            )
            
            # 保存进度条目
            await self.save_progress_entry(progress_entry)
            migrated_count += 1
        
        logger.info(f"迁移完成，共标记 {migrated_count} 个条目为已处理")
        return migrated_count
    
    def print_statistics(self):
        """打印统计信息"""
        duration = (self.stats['end_time'] - self.stats['start_time']).total_seconds()
        
        print("\n" + "="*50)
        print("翻译统计信息")
        print("="*50)
        print(f"总任务数: {self.stats['total_tasks']}")
        print(f"成功翻译: {self.stats['successful_translations']}")
        print(f"翻译失败: {self.stats['failed_translations']}")
        print(f"跳过已处理: {self.stats['skipped_translations']}")
        if self.stats['total_tasks'] > 0:
            print(f"成功率: {(self.stats['successful_translations']/self.stats['total_tasks']*100):.1f}%")
        print(f"总耗时: {duration:.2f} 秒")
        if duration > 0:
            print(f"平均速度: {(self.stats['total_tasks']/duration):.2f} 任务/秒")
        print("="*50)
    
    async def translate_arb_file(self, input_arb_path: str, output_arb_path: str, migrate_existing: bool = False):
        """翻译ARB文件的主函数"""
        self.stats['start_time'] = datetime.now()
        
        try:
            # 设置进度文件路径
            self.progress_file_path = self.get_progress_file_path(output_arb_path)
            
            # 加载进度文件
            self.progress_data = await self.load_progress_file(self.progress_file_path)
            logger.info(f"加载进度文件: {self.progress_file_path}，已有 {len(self.progress_data)} 个条目")
            
            # 如果需要迁移现有翻译
            if migrate_existing:
                await self.migrate_existing_translations(input_arb_path)
                return
            
            # 加载ARB文件
            logger.info(f"加载ARB文件: {input_arb_path}")
            arb_data = await self.load_arb_file(input_arb_path)
            
            if not arb_data:
                logger.error("ARB文件为空或加载失败")
                return
            
            # 如果输出文件不存在，复制输入文件作为基础
            if not Path(output_arb_path).exists():
                logger.info(f"输出文件不存在，复制输入文件作为基础: {output_arb_path}")
                Path(output_arb_path).parent.mkdir(parents=True, exist_ok=True)
                async with aiofiles.open(output_arb_path, 'w', encoding='utf-8') as f:
                    await f.write(json.dumps(arb_data, ensure_ascii=False, indent=2))
            
            # 提取翻译任务
            tasks = self.extract_translation_tasks(arb_data)
            self.stats['total_tasks'] = len(tasks)
            
            if not tasks:
                logger.info("没有找到需要翻译的中文内容")
                return
            
            logger.info(f"找到 {len(tasks)} 个需要翻译的条目，目标语言：{self.target_language}")
            
            # 创建HTTP会话
            connector = aiohttp.TCPConnector(limit=self.max_concurrent)
            self.session = aiohttp.ClientSession(connector=connector)
            
            try:
                # 逐个处理翻译任务（实时保存）
                for i, task in enumerate(tasks, 1):
                    logger.info(f"处理任务 {i}/{len(tasks)}: {task.key}")
                    
                    # 翻译单个任务
                    result = await self.translate_text(task)
                    
                    # 立即处理翻译结果
                    await self.process_translation_result(result, output_arb_path)
                    
                    # 可选：添加小延迟避免API限流
                    if i < len(tasks):
                        await asyncio.sleep(0.1)
                        
            finally:
                await self.session.close()
            
        except Exception as e:
            logger.error(f"翻译过程中发生错误: {e}")
            raise
        finally:
            self.stats['end_time'] = datetime.now()
            self.print_statistics()

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='ARB文件自动翻译工具')
    parser.add_argument('input_arb', help='输入的ARB文件路径')
    parser.add_argument('output_arb', help='输出的ARB文件路径')
    parser.add_argument('--config', default='scripts/python/i18n_config.json', 
                       help='配置文件路径 (默认: scripts/python/i18n_config.json)')
    parser.add_argument('--concurrent', type=int, help='并发数量 (覆盖配置文件设置)')
    parser.add_argument('--api-key', help='API密钥 (覆盖环境变量DEEPSEEK_API_KEY)')
    parser.add_argument('--target-language', default='英文', 
                       choices=['英文', '日文', '韩文', '法文', '德文', '西班牙文', '俄文', '阿拉伯文', '中文'],
                       help='目标翻译语言 (默认: 英文)')
    parser.add_argument('--migrate', action='store_true', help='迁移现有翻译，标记为已处理（不执行新翻译）')
    
    args = parser.parse_args()
    
    # 检查输入文件是否存在
    if not Path(args.input_arb).exists():
        logger.error(f"输入文件不存在: {args.input_arb}")
        return 1
    
    # 创建翻译器
    translator = ARBTranslator(
        config_file=args.config, 
        max_concurrent=args.concurrent,
        target_language=args.target_language
    )
    
    # 如果提供了API密钥参数，覆盖默认设置
    if args.api_key:
        translator.api_key = args.api_key
    
    # 执行翻译或迁移
    try:
        if args.migrate:
            logger.info("执行迁移模式...")
            asyncio.run(translator.translate_arb_file(args.input_arb, args.output_arb, migrate_existing=True))
            logger.info("迁移完成！")
        else:
            logger.info("执行翻译模式...")
            asyncio.run(translator.translate_arb_file(args.input_arb, args.output_arb, migrate_existing=False))
            logger.info("翻译完成！")
        return 0
    except Exception as e:
        logger.error(f"操作失败: {e}")
        return 1

if __name__ == '__main__':
    import sys
    sys.exit(main())