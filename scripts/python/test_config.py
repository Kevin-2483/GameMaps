#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
配置测试脚本
用于验证i18n_processor配置是否正确加载
"""

import sys
import os
from pathlib import Path

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from i18n_processor import I18nProcessor

def test_config_loading():
    """测试配置加载"""
    print("=== 配置加载测试 ===")
    
    # 创建处理器实例
    processor = I18nProcessor(
        yaml_dir="yaml",
        api_url="https://api.openai.com/v1/chat/completions",
        api_key="test-key",
        config_file="i18n_config_production.json"
    )
    
    print("\n配置内容:")
    print(f"API URL: {processor.api_url}")
    print(f"API 模型: {processor.config['api_settings']['model']}")
    print(f"温度: {processor.config['api_settings']['temperature']}")
    print(f"最大令牌: {processor.config['api_settings']['max_tokens']}")
    print(f"Top-P: {processor.config['api_settings'].get('top_p', '未设置')}")
    print(f"频率惩罚: {processor.config['api_settings'].get('frequency_penalty', '未设置')}")
    print(f"存在惩罚: {processor.config['api_settings'].get('presence_penalty', '未设置')}")
    
    print("\n处理设置:")
    print(f"最大并发: {processor.config['processing_settings']['max_concurrent']}")
    print(f"重试次数: {processor.config['processing_settings']['retry_attempts']}")
    print(f"重试延迟: {processor.config['processing_settings']['retry_delay']}")
    print(f"超时时间: {processor.config['processing_settings'].get('timeout', '未设置')}")
    
    print("\n输出设置:")
    print(f"ARB基础路径: {processor.config['output_settings']['arb_base_path']}")
    print(f"备份原文件: {processor.config['output_settings']['backup_original']}")
    print(f"验证行数: {processor.config['output_settings']['validate_line_count']}")
    
    # 测试备份功能
    print("\n=== 备份功能测试 ===")
    test_file = Path("test_backup.txt")
    test_file.write_text("测试内容", encoding='utf-8')
    
    backup_result = processor.backup_file(test_file)
    if backup_result:
        print(f"备份已创建: {backup_result}")
        backup_result.unlink()  # 删除备份文件
    else:
        print("备份已禁用 - 配置生效！")
    
    test_file.unlink()  # 删除测试文件
    
    print("\n=== 测试完成 ===")

if __name__ == '__main__':
    test_config_loading()