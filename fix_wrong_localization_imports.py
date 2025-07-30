#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复错误的LocalizationService导入路径
将错误的导入路径修复为正确的路径
"""

import os
import re
from pathlib import Path

def fix_wrong_import_in_file(file_path):
    """修复单个文件中错误的LocalizationService导入路径"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 查找并修复错误的导入路径
        wrong_patterns = [
            "import '../services/localization_service.dart';",
            "import '../../services/localization_service.dart';",
            "import '../../../services/localization_service.dart';",
            "import '../../../../services/localization_service.dart';",
            "import 'services/localization_service.dart';"
        ]
        
        # 确定正确的导入路径
        correct_import = get_correct_import_path(file_path)
        
        # 替换错误的导入
        for wrong_pattern in wrong_patterns:
            if wrong_pattern in content:
                content = content.replace(wrong_pattern, f"import '{correct_import}';")
                print(f"修复导入路径: {file_path}")
                print(f"  从: {wrong_pattern}")
                print(f"  到: import '{correct_import}';")
        
        # 如果使用了LocalizationService但没有任何导入，添加导入
        uses_localization_service = 'LocalizationService.instance.current' in content
        has_any_localization_import = 'localization_service.dart' in content
        
        if uses_localization_service and not has_any_localization_import:
            # 查找插入import的位置
            import_insertion_point = find_import_insertion_point(content)
            
            if import_insertion_point is not None:
                # 在指定位置插入import
                lines = content.split('\n')
                lines.insert(import_insertion_point, f"import '{correct_import}';")
                content = '\n'.join(lines)
                print(f"添加缺失的导入: {file_path}")
            else:
                # 如果找不到合适的位置，在文件开头添加
                content = f"import '{correct_import}';\n{content}"
                print(f"在文件开头添加导入: {file_path}")
        
        # 如果内容有变化，写回文件
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        else:
            return False
            
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return False

def get_correct_import_path(file_path):
    """根据文件路径确定LocalizationService的正确导入路径"""
    file_path_str = str(file_path).replace('\\', '/')
    
    # 计算相对于lib/services/localization_service.dart的路径
    if 'lib/services/' in file_path_str:
        if 'lib/services/webdav/' in file_path_str:
            return '../localization_service.dart'
        elif 'lib/services/vfs/' in file_path_str:
            return '../localization_service.dart'
        elif 'lib/services/audio/' in file_path_str:
            return '../localization_service.dart'
        elif 'lib/services/scripting/' in file_path_str:
            return '../localization_service.dart'
        elif 'lib/services/legend_vfs/' in file_path_str:
            return '../localization_service.dart'
        elif 'lib/services/virtual_file_system/' in file_path_str:
            return '../localization_service.dart'
        elif 'lib/services/vfs_map_storage/' in file_path_str:
            return '../localization_service.dart'
        else:
            return 'localization_service.dart'
    elif 'lib/collaboration/' in file_path_str:
        # 计算从collaboration目录到services的路径
        collaboration_part = file_path_str[file_path_str.find('lib/collaboration/') + len('lib/collaboration/'):]
        depth = collaboration_part.count('/')
        return '../' * (depth + 1) + 'services/localization_service.dart'
    elif 'lib/providers/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/utils/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/widgets/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/components/' in file_path_str:
        # 计算从components目录到services的路径
        components_part = file_path_str[file_path_str.find('lib/components/') + len('lib/components/'):]
        depth = components_part.count('/')
        return '../' * (depth + 1) + 'services/localization_service.dart'
    elif 'lib/pages/' in file_path_str:
        # 计算从pages目录到services的路径
        pages_part = file_path_str[file_path_str.find('lib/pages/') + len('lib/pages/'):]
        depth = pages_part.count('/')
        return '../' * (depth + 1) + 'services/localization_service.dart'
    elif 'lib/features/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/mixins/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/models/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/router/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/config/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/data/' in file_path_str:
        return '../services/localization_service.dart'
    elif 'lib/examples/' in file_path_str:
        return '../services/localization_service.dart'
    else:
        # 默认路径，从lib根目录
        return 'services/localization_service.dart'

def find_import_insertion_point(content):
    """找到插入import语句的合适位置"""
    lines = content.split('\n')
    
    # 查找最后一个import语句的位置
    last_import_line = -1
    for i, line in enumerate(lines):
        stripped_line = line.strip()
        if stripped_line.startswith('import ') and stripped_line.endswith(';'):
            last_import_line = i
    
    if last_import_line >= 0:
        # 在最后一个import语句后插入
        return last_import_line + 1
    
    # 如果没有找到import语句，查找第一个非注释、非空行
    for i, line in enumerate(lines):
        stripped_line = line.strip()
        if stripped_line and not stripped_line.startswith('//') and not stripped_line.startswith('/*'):
            return i
    
    return None

def find_dart_files_with_localization_service(root_dir):
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
                uses_localization_service = 'LocalizationService.instance.current' in content
                
                if uses_localization_service:
                    dart_files.append(dart_file)
                    
        except Exception as e:
            print(f"读取文件 {dart_file} 时出错: {e}")
    
    return dart_files

def main():
    """主函数"""
    print("开始修复错误的LocalizationService导入路径...")
    
    # 项目根目录
    project_root = Path(__file__).parent / 'lib'
    
    if not project_root.exists():
        print(f"错误: 找不到lib目录 {project_root}")
        return
    
    # 查找需要修复的文件
    files_to_check = find_dart_files_with_localization_service(project_root)
    
    if not files_to_check:
        print("没有找到使用LocalizationService的文件。")
        return
    
    print(f"找到 {len(files_to_check)} 个使用LocalizationService的文件")
    
    # 修复文件
    fixed_count = 0
    for file_path in files_to_check:
        if fix_wrong_import_in_file(file_path):
            fixed_count += 1
    
    print(f"\n修复完成! 共修复了 {fixed_count} 个文件的导入问题。")
    
    if fixed_count > 0:
        print("\n建议运行以下命令验证修复结果:")
        print("flutter analyze --no-fatal-infos")

if __name__ == '__main__':
    main()