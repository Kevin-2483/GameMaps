#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复ARB文件中的占位符类型不匹配问题
将所有String类型的占位符改为Object类型以保持兼容性
"""

import os
import json
from pathlib import Path

def fix_placeholder_types(file_path):
    """修复ARB文件中的占位符类型"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        fixed_count = 0
        
        for key, value in data.items():
            # 查找描述键（以@开头但不是@@locale）
            if key.startswith('@') and not key.startswith('@@'):
                if isinstance(value, dict) and 'placeholders' in value:
                    placeholders = value['placeholders']
                    
                    for placeholder_name, placeholder_info in placeholders.items():
                        if isinstance(placeholder_info, dict) and 'type' in placeholder_info:
                            if placeholder_info['type'] == 'String':
                                placeholder_info['type'] = 'Object'
                                fixed_count += 1
                                print(f"修复占位符类型: {key}.{placeholder_name} String -> Object")
        
        if fixed_count > 0:
            # 写回文件
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"\n已修复 {fixed_count} 个占位符类型")
        else:
            print("未发现需要修复的占位符类型")
        
        return fixed_count
        
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return 0

def main():
    # 项目根目录
    project_root = Path(__file__).parent.parent.parent
    
    # 修复英文ARB文件的占位符类型
    en_arb_file = project_root / 'lib' / 'l10n' / 'app_en.arb'
    
    print("=== 修复英文ARB文件的占位符类型 ===")
    if en_arb_file.exists():
        fixed_count = fix_placeholder_types(str(en_arb_file))
        print(f"\n英文ARB文件修复完成，共修复 {fixed_count} 个占位符类型")
    else:
        print(f"英文ARB文件不存在: {en_arb_file}")
    
    print("\n=== 修复完成，请重新运行 flutter gen-l10n ===")

if __name__ == '__main__':
    main()