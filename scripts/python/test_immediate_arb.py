#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试即时ARB文件生成功能
"""

import sys
import os
import asyncio
import json
import yaml
from pathlib import Path
import tempfile
import shutil

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from i18n_processor import I18nProcessor, YamlRecord, AIResponse

async def test_immediate_arb_generation():
    """测试即时ARB文件生成"""
    print("=== 即时ARB文件生成测试 ===")
    
    # 创建临时目录
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        yaml_dir = temp_path / "yaml"
        yaml_dir.mkdir()
        
        # 创建测试YAML文件
        test_yaml = yaml_dir / "test_page.yaml"
        yaml_content = {
            'path': 'pages/test/test_page.dart',
            'start_line': 10,
            'end_line': 12,
            'code': 'title: const Text("测试页面")'
        }
        
        with open(test_yaml, 'w', encoding='utf-8') as f:
            yaml.dump(yaml_content, f, allow_unicode=True)
        
        print(f"创建测试YAML文件: {test_yaml}")
        
        # 创建处理器实例
        processor = I18nProcessor(
            yaml_dir=str(yaml_dir),
            api_url="https://api.deepseek.com/chat/completions",
            api_key="test-key",
            config_file="i18n_config_production.json"
        )
        
        # 创建测试记录
        record = YamlRecord(
            path="pages/test/test_page.dart",
            start_line=10,
            end_line=12,
            code='title: const Text("测试页面")',
            yaml_file=str(test_yaml)
        )
        
        # 模拟AI响应
        ai_response = AIResponse(
            replaced_code='title: Text(S.of(context).testPageTitle)',
            arb_entries={
                'testPageTitle': '测试页面',
                'testPageSubtitle': '这是一个测试页面'
            },
            success=True
        )
        
        print("\n开始测试即时ARB文件生成...")
        
        # 测试即时生成
        await processor.collect_arb_entries(record, ai_response)
        
        # 检查ARB文件是否立即生成
        expected_arb_path = temp_path / "lib" / "l10n" / "pages" / "test" / "test_page.arb"
        
        if expected_arb_path.exists():
            print(f"✅ ARB文件已立即生成: {expected_arb_path}")
            
            # 读取并验证内容
            with open(expected_arb_path, 'r', encoding='utf-8') as f:
                arb_content = json.load(f)
            
            print(f"ARB文件内容: {json.dumps(arb_content, ensure_ascii=False, indent=2)}")
            
            # 验证条目
            expected_keys = ['testPageTitle', 'testPageSubtitle']
            for key in expected_keys:
                if key in arb_content:
                    print(f"✅ 找到预期键: {key} = {arb_content[key]}")
                else:
                    print(f"❌ 缺少预期键: {key}")
        else:
            print(f"❌ ARB文件未生成: {expected_arb_path}")
        
        # 测试第二次添加（模拟续传场景）
        print("\n测试第二次添加条目（模拟续传）...")
        
        ai_response2 = AIResponse(
            replaced_code='subtitle: Text(S.of(context).testPageDescription)',
            arb_entries={
                'testPageDescription': '页面描述',
                'testPageButton': '点击按钮'
            },
            success=True
        )
        
        await processor.collect_arb_entries(record, ai_response2)
        
        # 验证合并结果
        if expected_arb_path.exists():
            with open(expected_arb_path, 'r', encoding='utf-8') as f:
                merged_content = json.load(f)
            
            print(f"合并后ARB文件内容: {json.dumps(merged_content, ensure_ascii=False, indent=2)}")
            
            # 验证所有条目都存在
            all_expected_keys = ['testPageTitle', 'testPageSubtitle', 'testPageDescription', 'testPageButton']
            for key in all_expected_keys:
                if key in merged_content:
                    print(f"✅ 合并后找到键: {key} = {merged_content[key]}")
                else:
                    print(f"❌ 合并后缺少键: {key}")
        
        print("\n=== 测试完成 ===")

if __name__ == '__main__':
    asyncio.run(test_immediate_arb_generation())