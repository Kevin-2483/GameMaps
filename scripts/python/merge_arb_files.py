#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
合并分层的ARB文件到主ARB文件中
"""

import os
import json
from pathlib import Path

def merge_arb_files(zh_dir, output_file):
    """合并所有ARB文件到一个主文件中"""
    merged_data = {}
    
    # 首先读取主app_zh.arb文件
    main_arb_path = os.path.join(zh_dir, 'app_zh.arb')
    if os.path.exists(main_arb_path):
        with open(main_arb_path, 'r', encoding='utf-8') as f:
            merged_data = json.load(f)
        print(f"已加载主文件: {main_arb_path}")
    
    # 递归遍历所有子目录和文件
    def process_directory(dir_path, prefix=""):
        for item in os.listdir(dir_path):
            item_path = os.path.join(dir_path, item)
            
            if os.path.isfile(item_path) and item.endswith('.arb') and item != 'app_zh.arb':
                # 处理ARB文件
                try:
                    with open(item_path, 'r', encoding='utf-8') as f:
                        arb_data = json.load(f)
                    
                    # 合并数据，跳过@@locale等元数据
                    for key, value in arb_data.items():
                        if not key.startswith('@@') and not key.startswith('@'):
                            merged_data[key] = value
                        elif key.startswith('@') and not key.startswith('@@'):
                            # 保留描述信息
                            merged_data[key] = value
                    
                    print(f"已合并: {item_path} ({len(arb_data)} 项)")
                    
                except Exception as e:
                    print(f"错误：无法处理文件 {item_path}: {e}")
            
            elif os.path.isdir(item_path):
                # 递归处理子目录
                process_directory(item_path, prefix + item + "_")
    
    # 处理zh目录下的所有文件和子目录
    process_directory(zh_dir)
    
    # 确保@@locale在最前面
    if '@@locale' not in merged_data:
        merged_data['@@locale'] = 'zh'
    
    # 重新排序，确保@@locale在最前面
    ordered_data = {'@@locale': merged_data['@@locale']}
    for key, value in merged_data.items():
        if key != '@@locale':
            ordered_data[key] = value
    
    # 写入输出文件
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(ordered_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n合并完成！")
    print(f"输出文件: {output_file}")
    print(f"总计条目: {len([k for k in ordered_data.keys() if not k.startswith('@')])}") 
    
    return len(ordered_data)

def main():
    # 项目根目录
    project_root = Path(__file__).parent.parent.parent
    zh_dir = project_root / 'lib' / 'l10n' / 'zh'
    output_file = project_root / 'lib' / 'l10n' / 'app_zh.arb'
    
    print(f"源目录: {zh_dir}")
    print(f"输出文件: {output_file}")
    
    if not zh_dir.exists():
        print(f"错误：源目录不存在: {zh_dir}")
        return
    
    # 合并ARB文件
    total_entries = merge_arb_files(str(zh_dir), str(output_file))
    
    print(f"\n成功合并 {total_entries} 个条目到 {output_file}")

if __name__ == '__main__':
    main()