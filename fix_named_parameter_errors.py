#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复undefined_named_parameter错误
查找并修复本地化方法调用中的命名参数错误
"""

import os
import re
import json
from pathlib import Path

def load_arb_method_signatures(arb_dir):
    """从arb文件中加载方法签名信息"""
    method_signatures = {}
    arb_path = Path(arb_dir)
    
    for arb_file in arb_path.glob('*.arb'):
        try:
            with open(arb_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                
                for key, value in data.items():
                    if not key.startswith('@') and isinstance(value, str):
                        # 分析字符串中的占位符
                        placeholders = re.findall(r'\{(\w+)\}', value)
                        if placeholders:
                            method_signatures[key] = placeholders
                            
        except Exception as e:
            print(f"读取arb文件 {arb_file} 时出错: {e}")
    
    return method_signatures

def find_dart_files_with_localization_calls(root_dir):
    """查找所有调用LocalizationService方法的Dart文件"""
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
                
                # 检查是否使用了LocalizationService方法调用
                if 'LocalizationService.instance.current.' in content:
                    dart_files.append(dart_file)
                    
        except Exception as e:
            print(f"读取文件 {dart_file} 时出错: {e}")
    
    return dart_files

def find_method_calls_in_file(file_path, method_signatures):
    """在文件中查找本地化方法调用"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        found_calls = []
        
        # 查找LocalizationService.instance.current.methodName(...)的调用
        pattern = r'LocalizationService\.instance\.current\.([a-zA-Z_][a-zA-Z0-9_]*(?:_\d+)?)\s*\(([^)]+)\)'
        matches = re.finditer(pattern, content, re.MULTILINE | re.DOTALL)
        
        for match in matches:
            method_name = match.group(1)
            args_str = match.group(2).strip()
            
            if method_name in method_signatures:
                # 分析参数
                args_analysis = analyze_arguments(args_str)
                
                found_calls.append({
                    'method_name': method_name,
                    'args_str': args_str,
                    'args_analysis': args_analysis,
                    'expected_params': method_signatures[method_name],
                    'match_start': match.start(),
                    'match_end': match.end(),
                    'full_match': match.group(0)
                })
        
        return found_calls
        
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return []

def analyze_arguments(args_str):
    """分析参数字符串，区分位置参数和命名参数"""
    if not args_str.strip():
        return {'positional': [], 'named': {}}
    
    # 简单的参数解析（可能需要更复杂的解析器来处理嵌套括号等）
    args = []
    current_arg = ''
    paren_depth = 0
    in_string = False
    string_char = None
    
    for char in args_str:
        if char in ['"', "'"] and not in_string:
            in_string = True
            string_char = char
        elif char == string_char and in_string:
            in_string = False
            string_char = None
        elif not in_string:
            if char in ['(', '[', '{']:
                paren_depth += 1
            elif char in [')', ']', '}']:
                paren_depth -= 1
            elif char == ',' and paren_depth == 0:
                args.append(current_arg.strip())
                current_arg = ''
                continue
        
        current_arg += char
    
    if current_arg.strip():
        args.append(current_arg.strip())
    
    # 区分位置参数和命名参数
    positional = []
    named = {}
    
    for arg in args:
        if ':' in arg and not arg.strip().startswith('('):
            # 可能是命名参数
            parts = arg.split(':', 1)
            if len(parts) == 2:
                param_name = parts[0].strip()
                param_value = parts[1].strip()
                # 检查是否真的是命名参数（不是三元操作符等）
                if re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', param_name):
                    named[param_name] = param_value
                else:
                    positional.append(arg)
            else:
                positional.append(arg)
        else:
            positional.append(arg)
    
    return {'positional': positional, 'named': named}

def fix_method_call(call_info):
    """修复方法调用，将命名参数转换为位置参数"""
    method_name = call_info['method_name']
    expected_params = call_info['expected_params']
    args_analysis = call_info['args_analysis']
    
    # 如果没有命名参数，不需要修复
    if not args_analysis['named']:
        return None
    
    # 构建新的参数列表
    new_args = list(args_analysis['positional'])
    
    # 按照期望的参数顺序添加命名参数
    for param_name in expected_params:
        if param_name in args_analysis['named']:
            new_args.append(args_analysis['named'][param_name])
    
    # 构建新的方法调用
    new_args_str = ', '.join(new_args)
    new_call = f"LocalizationService.instance.current.{method_name}({new_args_str})"
    
    return {
        'old_call': call_info['full_match'],
        'new_call': new_call,
        'match_start': call_info['match_start'],
        'match_end': call_info['match_end']
    }

def fix_named_parameters_in_file(file_path, fixes):
    """修复文件中的命名参数错误"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        changes_made = []
        
        # 按照位置从后往前替换，避免位置偏移
        fixes.sort(key=lambda x: x['match_start'], reverse=True)
        
        for fix in fixes:
            start = fix['match_start']
            end = fix['match_end']
            content = content[:start] + fix['new_call'] + content[end:]
            
            changes_made.append({
                'old': fix['old_call'],
                'new': fix['new_call']
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
    print("开始修复undefined_named_parameter错误...")
    
    # 项目根目录
    project_root = Path(__file__).parent
    lib_dir = project_root / 'lib'
    arb_dir = project_root / 'lib' / 'l10n'
    
    if not arb_dir.exists():
        print(f"错误: 找不到l10n目录 {arb_dir}")
        return
    
    # 加载方法签名
    print("加载方法签名...")
    method_signatures = load_arb_method_signatures(arb_dir)
    print(f"找到 {len(method_signatures)} 个方法签名")
    
    # 查找使用LocalizationService的文件
    print("查找使用LocalizationService的文件...")
    dart_files = find_dart_files_with_localization_calls(lib_dir)
    print(f"找到 {len(dart_files)} 个文件")
    
    # 检查每个文件中的方法调用
    total_fixes = 0
    files_fixed = 0
    
    for dart_file in dart_files:
        calls = find_method_calls_in_file(dart_file, method_signatures)
        
        if not calls:
            continue
        
        fixes = []
        
        for call in calls:
            fix = fix_method_call(call)
            if fix:
                fixes.append(fix)
        
        if fixes:
            changes = fix_named_parameters_in_file(dart_file, fixes)
            if changes:
                print(f"修复文件: {dart_file}")
                for change in changes:
                    print(f"  修复方法调用")
                    print(f"    旧: {change['old']}")
                    print(f"    新: {change['new']}")
                files_fixed += 1
                total_fixes += len(changes)
    
    print(f"\n修复完成!")
    print(f"修复了 {files_fixed} 个文件")
    print(f"总共修复了 {total_fixes} 个方法调用")
    
    if total_fixes > 0:
        print("\n建议运行以下命令验证修复结果:")
        print("flutter analyze --no-fatal-infos")

if __name__ == '__main__':
    main()