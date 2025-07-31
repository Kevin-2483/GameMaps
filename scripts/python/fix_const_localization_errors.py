#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复const widget中使用LocalizationService的错误
移除const关键字或重新组织const的使用
"""

import os
import re
from pathlib import Path

def fix_const_localization_in_file(file_path):
    """修复单个文件中const widget使用LocalizationService的问题"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        lines = content.split('\n')
        modified_lines = []
        i = 0
        changes_made = False
        
        while i < len(lines):
            line = lines[i]
            
            # 检查是否是const widget开头的行
            const_widget_match = re.match(r'^(\s*)const\s+(\w+)\s*\(', line)
            if const_widget_match:
                indent = const_widget_match.group(1)
                widget_name = const_widget_match.group(2)
                
                # 收集完整的widget构造
                widget_lines = [line]
                j = i + 1
                paren_count = line.count('(') - line.count(')')
                
                while j < len(lines) and paren_count > 0:
                    widget_lines.append(lines[j])
                    paren_count += lines[j].count('(') - lines[j].count(')')
                    j += 1
                
                # 检查是否包含LocalizationService
                full_widget = '\n'.join(widget_lines)
                if 'LocalizationService.instance.current' in full_widget:
                    # 移除最外层的const，但保留内部可以const的部分
                    first_line = widget_lines[0]
                    first_line = re.sub(r'^(\s*)const\s+', r'\1', first_line)
                    widget_lines[0] = first_line
                    
                    # 尝试在内部添加const到不包含LocalizationService的部分
                    for k in range(len(widget_lines)):
                        widget_line = widget_lines[k]
                        # 查找可以添加const的地方（如TextStyle, BoxDecoration等）
                        if ('TextStyle(' in widget_line or 'BoxDecoration(' in widget_line or 
                            'EdgeInsets.' in widget_line or 'BorderRadius.' in widget_line or
                            'Color(' in widget_line) and 'LocalizationService' not in widget_line:
                            # 如果这行不是已经有const的
                            if not re.search(r'\bconst\s+', widget_line):
                                # 在适当位置添加const
                                widget_line = re.sub(r'(\s+)(TextStyle|BoxDecoration|EdgeInsets|BorderRadius|Color)\(', 
                                                    r'\1const \2(', widget_line)
                                widget_lines[k] = widget_line
                    
                    print(f"修复const widget: {file_path}")
                    print(f"  行 {i+1}: 移除 {widget_name} 的const关键字")
                    changes_made = True
                
                modified_lines.extend(widget_lines)
                i = j
            else:
                modified_lines.append(line)
                i += 1
        
        if changes_made:
            new_content = '\n'.join(modified_lines)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            return True
        else:
            return False
            
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return False

def find_dart_files_with_const_localization(root_dir):
    """查找所有在const widget中使用LocalizationService的Dart文件"""
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
                
                # 检查是否在const widget中使用了LocalizationService
                has_const_localization = (
                    'const ' in content and 
                    'LocalizationService.instance.current' in content
                )
                
                if has_const_localization:
                    # 更精确的检查 - 查找const widget
                    lines = content.split('\n')
                    for i, line in enumerate(lines):
                        const_widget_match = re.match(r'^\s*const\s+\w+\s*\(', line)
                        if const_widget_match:
                            # 查找这个widget是否在后续行中使用了LocalizationService
                            j = i
                            paren_count = line.count('(') - line.count(')')
                            while j < len(lines) - 1 and paren_count > 0:
                                j += 1
                                if 'LocalizationService.instance.current' in lines[j]:
                                    dart_files.append(dart_file)
                                    break
                                paren_count += lines[j].count('(') - lines[j].count(')')
                            if dart_file in dart_files:
                                break
                    
        except Exception as e:
            print(f"读取文件 {dart_file} 时出错: {e}")
    
    return dart_files

def main():
    """主函数"""
    print("开始修复const widget中使用LocalizationService的错误...")
    
    # 项目根目录
    project_root = Path(__file__).parent / 'lib'
    
    if not project_root.exists():
        print(f"错误: 找不到lib目录 {project_root}")
        return
    
    # 查找需要修复的文件
    files_to_check = find_dart_files_with_const_localization(project_root)
    
    if not files_to_check:
        print("没有找到在const widget中使用LocalizationService的文件。")
        return
    
    print(f"找到 {len(files_to_check)} 个需要修复的文件")
    
    # 修复文件
    fixed_count = 0
    for file_path in files_to_check:
        if fix_const_localization_in_file(file_path):
            fixed_count += 1
    
    print(f"\n修复完成! 共修复了 {fixed_count} 个文件的const widget问题。")
    
    if fixed_count > 0:
        print("\n建议运行以下命令验证修复结果:")
        print("flutter analyze --no-fatal-infos")

if __name__ == '__main__':
    main()