#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复缺少AppLocalizations导入的文件
"""

import os
import re
from pathlib import Path

def find_files_with_ai_comment(root_dir):
    """查找包含AI处理注释的文件"""
    ai_files = []
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        first_line = f.readline().strip()
                        if first_line == '// This file has been processed by AI for internationalization':
                            ai_files.append(file_path)
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    return ai_files

def check_and_fix_imports(file_path):
    """检查并修复文件的导入"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 检查是否使用了AppLocalizations
        if 'AppLocalizations.of(context)' not in content:
            return False, "No AppLocalizations usage found"
        
        # 检查是否已经有导入
        if "import 'package:flutter_gen/gen_l10n/app_localizations.dart';" in content:
            return False, "Import already exists"
        
        # 查找导入部分的结束位置
        lines = content.split('\n')
        import_end_index = -1
        
        for i, line in enumerate(lines):
            if line.strip().startswith('import '):
                import_end_index = i
            elif line.strip() and not line.strip().startswith('//') and not line.strip().startswith('import '):
                break
        
        if import_end_index == -1:
            # 如果没有找到导入，在第一行注释后添加
            for i, line in enumerate(lines):
                if not line.strip().startswith('//'):
                    import_end_index = i - 1
                    break
        
        # 插入导入语句
        import_line = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';"
        lines.insert(import_end_index + 1, import_line)
        
        # 写回文件
        new_content = '\n'.join(lines)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        return True, "Import added successfully"
        
    except Exception as e:
        return False, f"Error processing file: {e}"

def main():
    # 项目根目录
    root_dir = Path(__file__).parent.parent.parent / 'lib'
    
    print(f"Scanning directory: {root_dir}")
    
    # 查找所有AI处理过的文件
    ai_files = find_files_with_ai_comment(str(root_dir))
    print(f"Found {len(ai_files)} files with AI processing comment")
    
    fixed_count = 0
    skipped_count = 0
    error_count = 0
    
    for file_path in ai_files:
        relative_path = os.path.relpath(file_path, root_dir)
        success, message = check_and_fix_imports(file_path)
        
        if success:
            print(f"✓ Fixed: {relative_path}")
            fixed_count += 1
        elif "No AppLocalizations usage found" in message:
            skipped_count += 1
        elif "Import already exists" in message:
            skipped_count += 1
        else:
            print(f"✗ Error: {relative_path} - {message}")
            error_count += 1
    
    print(f"\nSummary:")
    print(f"Fixed: {fixed_count}")
    print(f"Skipped: {skipped_count}")
    print(f"Errors: {error_count}")
    print(f"Total: {len(ai_files)}")

if __name__ == '__main__':
    main()