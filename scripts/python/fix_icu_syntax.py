#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复ARB文件中的ICU语法错误
将数字占位符 {0}, {1}, {2} 等转换为命名占位符
"""

import os
import json
import re
from pathlib import Path

def fix_icu_syntax_in_arb(file_path):
    """修复ARB文件中的ICU语法错误"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        fixed_count = 0
        
        for key, value in data.items():
            if isinstance(value, str) and not key.startswith('@'):
                # 查找数字占位符模式 {0}, {1}, {2} 等
                if re.search(r'\{\d+\}', value):
                    original_value = value
                    
                    # 替换数字占位符为命名占位符
                    # {0} -> {arg0}, {1} -> {arg1}, 等等
                    def replace_placeholder(match):
                        num = match.group(1)
                        return f'{{arg{num}}}'
                    
                    new_value = re.sub(r'\{(\d+)\}', replace_placeholder, value)
                    
                    if new_value != original_value:
                        data[key] = new_value
                        fixed_count += 1
                        print(f"修复: {key}")
                        print(f"  原文: {original_value}")
                        print(f"  修复: {new_value}")
                        print()
        
        if fixed_count > 0:
            # 写回文件
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"已修复 {fixed_count} 个ICU语法错误")
        else:
            print("未发现需要修复的ICU语法错误")
        
        return fixed_count
        
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return 0

def fix_pagenotfound_type(file_path):
    """修复pageNotFound的类型不匹配问题"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 检查是否有pageNotFound的描述
        if '@pageNotFound' in data:
            desc = data['@pageNotFound']
            if isinstance(desc, dict) and 'placeholders' in desc:
                placeholders = desc['placeholders']
                if 'uri' in placeholders and 'type' in placeholders['uri']:
                    if placeholders['uri']['type'] == 'String':
                        placeholders['uri']['type'] = 'Object'
                        print("修复了pageNotFound的uri占位符类型: String -> Object")
                        
                        with open(file_path, 'w', encoding='utf-8') as f:
                            json.dump(data, f, ensure_ascii=False, indent=2)
                        return True
        
        return False
        
    except Exception as e:
        print(f"修复pageNotFound类型时出错: {e}")
        return False

def main():
    # 项目根目录
    project_root = Path(__file__).parent.parent.parent
    
    # 修复主要的中文ARB文件
    zh_arb_file = project_root / 'lib' / 'l10n' / 'app_zh.arb'
    en_arb_file = project_root / 'lib' / 'l10n' / 'app_en.arb'
    
    print("=== 修复中文ARB文件的ICU语法错误 ===")
    if zh_arb_file.exists():
        fixed_zh = fix_icu_syntax_in_arb(str(zh_arb_file))
        print(f"中文ARB文件修复完成，共修复 {fixed_zh} 个错误\n")
    else:
        print(f"中文ARB文件不存在: {zh_arb_file}\n")
    
    print("=== 修复英文ARB文件的pageNotFound类型问题 ===")
    if en_arb_file.exists():
        fixed_en = fix_pagenotfound_type(str(en_arb_file))
        if fixed_en:
            print("英文ARB文件修复完成\n")
        else:
            print("英文ARB文件无需修复\n")
    else:
        print(f"英文ARB文件不存在: {en_arb_file}\n")
    
    print("=== 修复完成，请重新运行 flutter gen-l10n ===")

if __name__ == '__main__':
    main()