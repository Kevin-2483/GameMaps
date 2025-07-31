#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复在替换过程中丢失后缀的本地化键
搜索arb文件中的每个键在项目中的使用，通过搜索去除后缀的名字，如果不一样，则修复
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

def load_arb_keys(arb_dir):
    """加载所有arb文件中的键"""
    arb_keys = set()
    arb_path = Path(arb_dir)
    
    for arb_file in arb_path.glob('*.arb'):
        try:
            with open(arb_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                for key in data.keys():
                    if not key.startswith('@'):  # 跳过元数据键
                        arb_keys.add(key)
        except Exception as e:
            print(f"读取arb文件 {arb_file} 时出错: {e}")
    
    return arb_keys

def extract_base_name_and_suffix(key):
    """从键中提取基础名称和后缀"""
    # 匹配模式：baseName_数字
    match = re.match(r'^(.+)_(\d+)$', key)
    if match:
        return match.group(1), match.group(2)
    else:
        return key, None

def find_dart_files_using_localization(root_dir):
    """查找所有使用LocalizationService的Dart文件"""
    dart_files = []
    root_path = Path(root_dir)
    
    for dart_file in root_path.rglob('*.dart'):
        # 跳过生成的文件和测试文件
        if (
            'app_localizations' in dart_file.name or 
            '.g.dart' in dart_file.name or
            'test/' in str(dart_file) or
            'localization_service.dart' in dart_file.name or
            '.freezed.dart' in dart_file.name or
            '.mocks.dart' in dart_file.name
        ):
            continue
            
        try:
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
                
                # 检查是否使用了LocalizationService
                if 'LocalizationService.instance.current' in content:
                    dart_files.append(dart_file)
                    
        except Exception as e:
            print(f"读取文件 {dart_file} 时出错: {e}")
    
    return dart_files

def find_localization_usage_in_file(file_path, base_names):
    """在文件中查找本地化键的使用情况"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        found_usages = []
        
        # 查找LocalizationService.instance.current.xxx的使用
        pattern = r'LocalizationService\.instance\.current\.([a-zA-Z_][a-zA-Z0-9_]*(?:_\d+)?)'  
        matches = re.finditer(pattern, content)
        
        for match in matches:
            used_key = match.group(1)
            base_name, suffix = extract_base_name_and_suffix(used_key)
            
            # 检查是否是我们关心的基础名称
            if base_name in base_names:
                found_usages.append({
                    'used_key': used_key,
                    'base_name': base_name,
                    'suffix': suffix,
                    'match_start': match.start(),
                    'match_end': match.end(),
                    'full_match': match.group(0)
                })
        
        return found_usages
        
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return []

def fix_missing_suffixes_in_file(file_path, corrections):
    """修复文件中缺失后缀的本地化键"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        changes_made = []
        
        # 按照位置从后往前替换，避免位置偏移
        corrections.sort(key=lambda x: x['match_start'], reverse=True)
        
        for correction in corrections:
            old_match = correction['full_match']
            new_key = f"LocalizationService.instance.current.{correction['correct_key']}"
            
            # 替换
            start = correction['match_start']
            end = correction['match_end']
            content = content[:start] + new_key + content[end:]
            
            changes_made.append({
                'old': correction['used_key'],
                'new': correction['correct_key']
            })
        
        if changes_made:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return changes_made
        else:
            return []
            
    except Exception as e:
        print(f"修复文件 {file_path} 时出错: {e}")
        return []

def main():
    """主函数"""
    print("开始检查和修复丢失后缀的本地化键...")
    
    # 项目根目录
    project_root = Path(__file__).parent
    lib_dir = project_root / 'lib'
    arb_dir = project_root / 'lib' / 'l10n'
    
    if not arb_dir.exists():
        print(f"错误: 找不到l10n目录 {arb_dir}")
        return
    
    # 加载arb文件中的所有键
    print("加载arb文件中的键...")
    arb_keys = load_arb_keys(arb_dir)
    print(f"找到 {len(arb_keys)} 个本地化键")
    
    # 按基础名称分组
    base_name_to_keys = defaultdict(list)
    for key in arb_keys:
        base_name, suffix = extract_base_name_and_suffix(key)
        base_name_to_keys[base_name].append(key)
    
    # 查找使用LocalizationService的文件
    print("查找使用LocalizationService的文件...")
    dart_files = find_dart_files_using_localization(lib_dir)
    print(f"找到 {len(dart_files)} 个文件")
    
    # 检查每个文件中的使用情况
    total_corrections = 0
    files_fixed = 0
    
    for dart_file in dart_files:
        usages = find_localization_usage_in_file(dart_file, base_name_to_keys.keys())
        
        if not usages:
            continue
        
        corrections = []
        
        for usage in usages:
            used_key = usage['used_key']
            base_name = usage['base_name']
            
            # 检查使用的键是否在arb文件中存在
            if used_key not in arb_keys:
                # 查找正确的键（有后缀的版本）
                possible_keys = base_name_to_keys[base_name]
                if len(possible_keys) == 1:
                    correct_key = possible_keys[0]
                    if correct_key != used_key:
                        corrections.append({
                            'used_key': used_key,
                            'correct_key': correct_key,
                            'match_start': usage['match_start'],
                            'match_end': usage['match_end'],
                            'full_match': usage['full_match']
                        })
                elif len(possible_keys) > 1:
                    # 如果有多个可能的键，选择最常见的或者提示用户
                    print(f"警告: {dart_file} 中的 {used_key} 有多个可能的正确键: {possible_keys}")
                    # 暂时选择第一个
                    correct_key = possible_keys[0]
                    if correct_key != used_key:
                        corrections.append({
                            'used_key': used_key,
                            'correct_key': correct_key,
                            'match_start': usage['match_start'],
                            'match_end': usage['match_end'],
                            'full_match': usage['full_match']
                        })
        
        if corrections:
            changes = fix_missing_suffixes_in_file(dart_file, corrections)
            if changes:
                print(f"修复文件: {dart_file}")
                for change in changes:
                    print(f"  {change['old']} → {change['new']}")
                files_fixed += 1
                total_corrections += len(changes)
    
    print(f"\n修复完成!")
    print(f"修复了 {files_fixed} 个文件")
    print(f"总共修复了 {total_corrections} 个本地化键")
    
    if total_corrections > 0:
        print("\n建议运行以下命令验证修复结果:")
        print("flutter analyze --no-fatal-infos")

if __name__ == '__main__':
    main()