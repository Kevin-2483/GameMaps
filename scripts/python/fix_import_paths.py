#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复Flutter项目中的本地化文件导入路径
将 package:flutter_gen/gen_l10n/app_localizations.dart 替换为正确的相对路径
"""

import os
import re
from pathlib import Path

def calculate_relative_path(file_path, target_path):
    """计算从file_path到target_path的相对路径"""
    file_dir = Path(file_path).parent
    target = Path(target_path)
    
    try:
        relative = os.path.relpath(target, file_dir)
        # 将Windows路径分隔符转换为Unix风格
        relative = relative.replace('\\', '/')
        return relative
    except ValueError:
        # 如果无法计算相对路径，返回绝对路径
        return str(target).replace('\\', '/')

def fix_import_in_file(file_path, target_localization_file):
    """修复单个文件中的导入路径"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 检查是否包含需要修复的导入
        old_import = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';"
        if old_import not in content:
            return False
        
        # 计算相对路径
        relative_path = calculate_relative_path(file_path, target_localization_file)
        new_import = f"import '{relative_path}';"
        
        # 替换导入语句
        new_content = content.replace(old_import, new_import)
        
        # 写回文件
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✅ 已修复: {file_path}")
        print(f"   {old_import}")
        print(f"   -> {new_import}")
        return True
        
    except Exception as e:
        print(f"❌ 修复失败 {file_path}: {e}")
        return False

def main():
    # 项目根目录
    project_root = Path("e:/code/r6box/r6box")
    
    # 目标本地化文件路径
    target_localization_file = project_root / "lib" / "l10n" / "app_localizations.dart"
    
    if not target_localization_file.exists():
        print(f"❌ 目标文件不存在: {target_localization_file}")
        return
    
    print(f"🎯 目标本地化文件: {target_localization_file}")
    print(f"🔍 搜索需要修复的文件...")
    
    # 搜索所有需要修复的Dart文件
    dart_files = []
    for dart_file in project_root.rglob("*.dart"):
        try:
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
                if "import 'package:flutter_gen/gen_l10n/app_localizations.dart';" in content:
                    dart_files.append(dart_file)
        except Exception as e:
            print(f"⚠️ 读取文件失败 {dart_file}: {e}")
    
    print(f"📋 找到 {len(dart_files)} 个需要修复的文件")
    
    if not dart_files:
        print("✅ 没有需要修复的文件")
        return
    
    # 修复所有文件
    fixed_count = 0
    for dart_file in dart_files:
        if fix_import_in_file(dart_file, target_localization_file):
            fixed_count += 1
    
    print(f"\n🎉 修复完成！")
    print(f"📊 总计修复: {fixed_count}/{len(dart_files)} 个文件")
    
    if fixed_count > 0:
        print("\n💡 建议执行以下命令验证修复结果:")
        print("   flutter analyze")
        print("   flutter build")

if __name__ == "__main__":
    main()