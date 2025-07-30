#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复所有使用AppLocalizations.of(context)的文件
将其替换为LocalizationService.instance.current
"""

import os
import re
from pathlib import Path

def fix_localization_in_file(file_path):
    """修复单个文件中的本地化问题"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 检查是否需要添加import
        needs_import = 'AppLocalizations.of(context)' in content
        has_localization_service_import = 'import' in content and 'services/localization_service.dart' in content
        
        if needs_import and not has_localization_service_import:
            # 查找现有的import语句
            import_pattern = r"(import\s+['\"][^'\"]*l10n/app_localizations\.dart['\"];)"
            import_match = re.search(import_pattern, content)
            
            if import_match:
                # 在app_localizations.dart import后添加localization_service import
                new_import = import_match.group(1) + "\nimport '../services/localization_service.dart';"
                if 'lib/services/' in str(file_path):
                    new_import = import_match.group(1) + "\nimport 'localization_service.dart';"
                elif 'lib/collaboration/' in str(file_path):
                    new_import = import_match.group(1) + "\nimport '../services/localization_service.dart';"
                elif 'lib/providers/' in str(file_path):
                    new_import = import_match.group(1) + "\nimport '../services/localization_service.dart';"
                elif 'lib/components/' in str(file_path):
                    new_import = import_match.group(1) + "\nimport '../../services/localization_service.dart';"
                elif 'lib/pages/' in str(file_path):
                    new_import = import_match.group(1) + "\nimport '../../services/localization_service.dart';"
                else:
                    # 默认路径
                    new_import = import_match.group(1) + "\nimport '../services/localization_service.dart';"
                
                content = content.replace(import_match.group(1), new_import)
        
        # 替换所有AppLocalizations.of(context)为LocalizationService.instance.current
        content = re.sub(
            r'AppLocalizations\.of\(context\)',
            'LocalizationService.instance.current',
            content
        )
        
        # 如果内容有变化，写回文件
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"已修复: {file_path}")
            return True
        else:
            return False
            
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return False

def find_dart_files_with_localization_issues(root_dir):
    """查找所有包含AppLocalizations.of(context)的Dart文件"""
    dart_files = []
    root_path = Path(root_dir)
    
    for dart_file in root_path.rglob('*.dart'):
        # 跳过生成的文件
        if 'app_localizations' in dart_file.name or '.g.dart' in dart_file.name:
            continue
            
        try:
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
                if 'AppLocalizations.of(context)' in content:
                    dart_files.append(dart_file)
        except Exception as e:
            print(f"读取文件 {dart_file} 时出错: {e}")
    
    return dart_files

def main():
    """主函数"""
    print("开始修复本地化上下文问题...")
    
    # 项目根目录
    project_root = Path(__file__).parent / 'lib'
    
    if not project_root.exists():
        print(f"错误: 找不到lib目录 {project_root}")
        return
    
    # 查找需要修复的文件
    files_to_fix = find_dart_files_with_localization_issues(project_root)
    
    if not files_to_fix:
        print("没有找到需要修复的文件。")
        return
    
    print(f"找到 {len(files_to_fix)} 个需要修复的文件:")
    for file_path in files_to_fix:
        print(f"  - {file_path}")
    
    # 修复文件
    fixed_count = 0
    for file_path in files_to_fix:
        if fix_localization_in_file(file_path):
            fixed_count += 1
    
    print(f"\n修复完成! 共修复了 {fixed_count} 个文件。")
    
    if fixed_count > 0:
        print("\n建议运行以下命令验证修复结果:")
        print("flutter analyze --no-fatal-infos")

if __name__ == '__main__':
    main()