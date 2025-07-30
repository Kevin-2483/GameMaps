#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
I18n处理器测试套件
用于测试Dart代码替换方法的稳定性和正确性
"""

import os
import sys
import tempfile
import shutil
import json
import yaml
from pathlib import Path
from typing import Dict, List, Tuple
import unittest
from unittest.mock import patch, MagicMock

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from i18n_processor import I18nProcessor, YamlRecord, AIResponse

class TestI18nProcessor(unittest.TestCase):
    """I18n处理器测试类"""
    
    def setUp(self):
        """测试前准备"""
        self.test_dir = tempfile.mkdtemp()
        self.yaml_dir = os.path.join(self.test_dir, 'yaml')
        self.dart_dir = os.path.join(self.test_dir, 'lib')
        os.makedirs(self.yaml_dir)
        os.makedirs(self.dart_dir)
        
        # 创建测试用的I18n处理器
        self.processor = I18nProcessor(
            yaml_dir=self.yaml_dir,
            api_url="http://test.api",
            api_key="test_key"
        )
        
        # 创建测试用的l10n.yaml
        l10n_config = {
            'arb-dir': 'lib/l10n',
            'template-arb-file': 'app_en.arb',
            'output-localization-file': 'app_localizations.dart',
            'output-class': 'AppLocalizations'
        }
        with open(os.path.join(self.test_dir, 'l10n.yaml'), 'w', encoding='utf-8') as f:
            yaml.dump(l10n_config, f)
    
    def tearDown(self):
        """测试后清理"""
        shutil.rmtree(self.test_dir)
    
    def create_test_dart_file(self, content: str, filename: str = 'test.dart') -> str:
        """创建测试用的Dart文件"""
        dart_file = os.path.join(self.dart_dir, filename)
        with open(dart_file, 'w', encoding='utf-8') as f:
            f.write(content)
        return dart_file
    
    def test_single_line_replacement(self):
        """测试单行代码替换"""
        # 创建测试文件
        original_content = "debugPrint('测试消息');"
        dart_file = self.create_test_dart_file(original_content)
        
        # 创建测试记录
        record = YamlRecord(
            path=os.path.relpath(dart_file, self.test_dir),
            start_line=1,
            end_line=1,
            code=original_content,
            yaml_file='test.yaml'
        )
        
        # 创建AI响应
        ai_response = AIResponse(
            replaced_code="debugPrint(AppLocalizations.of(context).testMessage);",
            arb_entries={"testMessage": "测试消息"},
            success=True
        )
        
        # 执行替换
        import asyncio
        result = asyncio.run(self.processor.replace_dart_code(record, ai_response))
        
        # 验证结果
        self.assertTrue(result)
        
        # 检查文件内容
        with open(dart_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        self.assertIn('// This file has been processed by AI', content)
        self.assertIn('AppLocalizations.of(context).testMessage', content)
    
    def test_multi_line_replacement(self):
        """测试多行代码替换"""
        original_content = """void showMessage() {
  print('第一行消息');
  print('第二行消息');
}"""
        dart_file = self.create_test_dart_file(original_content)
        
        record = YamlRecord(
            path=os.path.relpath(dart_file, self.test_dir),
            start_line=2,
            end_line=3,
            code="  print('第一行消息');\n  print('第二行消息');",
            yaml_file='test.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code="  print(AppLocalizations.of(context).firstMessage);\n  print(AppLocalizations.of(context).secondMessage);",
            arb_entries={
                "firstMessage": "第一行消息",
                "secondMessage": "第二行消息"
            },
            success=True
        )
        
        import asyncio
        result = asyncio.run(self.processor.replace_dart_code(record, ai_response))
        
        self.assertTrue(result)
        
        with open(dart_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        self.assertIn('AppLocalizations.of(context).firstMessage', content)
        self.assertIn('AppLocalizations.of(context).secondMessage', content)
    
    def test_file_with_existing_ai_marker(self):
        """测试已有AI标记的文件"""
        original_content = """// This file has been processed by AI
debugPrint('测试消息');"""
        dart_file = self.create_test_dart_file(original_content)
        
        record = YamlRecord(
            path=os.path.relpath(dart_file, self.test_dir),
            start_line=2,
            end_line=2,
            code="debugPrint('测试消息');",
            yaml_file='test.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code="debugPrint(AppLocalizations.of(context).testMessage);",
            arb_entries={"testMessage": "测试消息"},
            success=True
        )
        
        import asyncio
        result = asyncio.run(self.processor.replace_dart_code(record, ai_response))
        
        self.assertTrue(result)
        
        with open(dart_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # 确保只有一个AI标记
        ai_marker_count = sum(1 for line in lines if 'This file has been processed by AI' in line)
        self.assertEqual(ai_marker_count, 1)
    
    def test_invalid_line_numbers(self):
        """测试无效的行号"""
        original_content = "debugPrint('测试消息');"
        dart_file = self.create_test_dart_file(original_content)
        
        # 测试超出范围的行号
        record = YamlRecord(
            path=os.path.relpath(dart_file, self.test_dir),
            start_line=5,  # 超出文件范围
            end_line=10,
            code="invalid code",
            yaml_file='test.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code="replacement",
            arb_entries={},
            success=True
        )
        
        import asyncio
        result = asyncio.run(self.processor.replace_dart_code(record, ai_response))
        
        # 应该返回False，表示替换失败
        self.assertFalse(result)
    
    def test_backup_creation(self):
        """测试备份文件创建"""
        original_content = "debugPrint('测试消息');"
        dart_file = self.create_test_dart_file(original_content)
        
        # 执行备份
        backup_path = self.processor.backup_file(Path(dart_file))
        
        # 验证备份文件存在
        self.assertIsNotNone(backup_path)
        self.assertTrue(backup_path.exists())
        
        # 验证备份内容
        with open(backup_path, 'r', encoding='utf-8') as f:
            backup_content = f.read()
        
        self.assertEqual(backup_content, original_content)
    
    def test_empty_file(self):
        """测试空文件处理"""
        dart_file = self.create_test_dart_file('')
        
        record = YamlRecord(
            path=os.path.relpath(dart_file, self.test_dir),
            start_line=1,
            end_line=1,
            code='',
            yaml_file='test.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code='// Empty file',
            arb_entries={},
            success=True
        )
        
        import asyncio
        result = asyncio.run(self.processor.replace_dart_code(record, ai_response))
        
        # 空文件处理应该失败或特殊处理
        self.assertFalse(result)
    
    def test_large_file_performance(self):
        """测试大文件性能"""
        # 创建一个较大的文件（1000行）
        large_content = '\n'.join([f"// Line {i}" for i in range(1000)])
        dart_file = self.create_test_dart_file(large_content)
        
        record = YamlRecord(
            path=os.path.relpath(dart_file, self.test_dir),
            start_line=500,
            end_line=500,
            code="// Line 499",  # 注意：文件行号从1开始，数组索引从0开始
            yaml_file='test.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code="// Replaced line 500",
            arb_entries={},
            success=True
        )
        
        import time
        import asyncio
        
        start_time = time.time()
        result = asyncio.run(self.processor.replace_dart_code(record, ai_response))
        end_time = time.time()
        
        # 验证处理时间合理（应该在1秒内完成）
        self.assertTrue(result)
        self.assertLess(end_time - start_time, 1.0)

class TestBatchProcessing(unittest.TestCase):
    """批量处理测试"""
    
    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.yaml_dir = os.path.join(self.test_dir, 'yaml')
        os.makedirs(self.yaml_dir)
    
    def tearDown(self):
        shutil.rmtree(self.test_dir)
    
    def test_yaml_record_loading(self):
        """测试YAML记录加载"""
        # 创建测试YAML文件
        yaml_content = {
            'path': 'test.dart',
            'start_line': 1,
            'end_line': 1,
            'code': "print('test');"
        }
        
        yaml_file = os.path.join(self.yaml_dir, 'test.yaml')
        with open(yaml_file, 'w', encoding='utf-8') as f:
            yaml.dump(yaml_content, f)
        
        processor = I18nProcessor(
            yaml_dir=self.yaml_dir,
            api_url="http://test.api",
            api_key="test_key"
        )
        
        import asyncio
        records = asyncio.run(processor.load_yaml_records())
        
        self.assertEqual(len(records), 1)
        self.assertEqual(records[0].path, 'test.dart')
        self.assertEqual(records[0].start_line, 1)
        self.assertEqual(records[0].end_line, 1)

def run_stability_test():
    """运行稳定性测试"""
    print("开始运行I18n处理器稳定性测试...")
    
    # 创建测试套件
    test_suite = unittest.TestSuite()
    
    # 添加测试用例
    test_suite.addTest(unittest.makeSuite(TestI18nProcessor))
    test_suite.addTest(unittest.makeSuite(TestBatchProcessing))
    
    # 运行测试
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # 输出结果
    if result.wasSuccessful():
        print("\n✅ 所有测试通过！Dart替换方法稳定性良好。")
    else:
        print(f"\n❌ 测试失败：{len(result.failures)} 个失败，{len(result.errors)} 个错误")
        for test, traceback in result.failures + result.errors:
            print(f"失败测试: {test}")
            print(f"错误信息: {traceback}")
    
    return result.wasSuccessful()

if __name__ == '__main__':
    run_stability_test()