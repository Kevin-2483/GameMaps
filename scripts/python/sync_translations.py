#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
同步中文翻译到英文ARB文件
确保英文文件包含所有中文文件中的翻译键，避免空值访问问题
"""

import json
import re
from pathlib import Path

def load_arb_file(file_path):
    """加载ARB文件并返回JSON对象"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ 加载文件失败 {file_path}: {e}")
        return None

def save_arb_file(file_path, data):
    """保存ARB文件"""
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"❌ 保存文件失败 {file_path}: {e}")
        return False

def extract_translation_keys(arb_data):
    """提取翻译键（排除元数据键）"""
    translation_keys = set()
    for key in arb_data.keys():
        if not key.startswith('@') and key != '@@locale':
            translation_keys.add(key)
    return translation_keys

def sync_translations(zh_file, en_file):
    """同步中文翻译到英文文件"""
    print(f"🔄 开始同步翻译...")
    print(f"📖 中文文件: {zh_file}")
    print(f"📝 英文文件: {en_file}")
    
    # 加载文件
    zh_data = load_arb_file(zh_file)
    en_data = load_arb_file(en_file)
    
    if not zh_data or not en_data:
        return False
    
    # 提取翻译键
    zh_keys = extract_translation_keys(zh_data)
    en_keys = extract_translation_keys(en_data)
    
    print(f"📊 中文翻译条目: {len(zh_keys)}")
    print(f"📊 英文翻译条目: {len(en_keys)}")
    
    # 找出缺失的键
    missing_keys = zh_keys - en_keys
    print(f"🔍 缺失的英文翻译: {len(missing_keys)}")
    
    if not missing_keys:
        print("✅ 英文文件已包含所有翻译键")
        return True
    
    # 添加缺失的翻译
    added_count = 0
    for key in missing_keys:
        if key in zh_data:
            # 使用中文翻译作为英文翻译的占位符
            zh_value = zh_data[key]
            # 为英文添加标记，表明这是从中文复制的
            en_data[key] = f"[ZH] {zh_value}"
            added_count += 1
            
            # 如果中文有对应的元数据，也复制过来
            zh_meta_key = f"@{key}"
            if zh_meta_key in zh_data:
                en_data[zh_meta_key] = zh_data[zh_meta_key]
    
    print(f"➕ 添加了 {added_count} 个翻译条目")
    
    # 保存更新后的英文文件
    if save_arb_file(en_file, en_data):
        print(f"✅ 英文文件更新成功")
        return True
    else:
        return False

def main():
    # 文件路径
    project_root = Path("e:/code/r6box/r6box")
    zh_file = project_root / "lib" / "l10n" / "app_zh.arb"
    en_file = project_root / "lib" / "l10n" / "app_en.arb"
    
    # 检查文件是否存在
    if not zh_file.exists():
        print(f"❌ 中文文件不存在: {zh_file}")
        return
    
    if not en_file.exists():
        print(f"❌ 英文文件不存在: {en_file}")
        return
    
    # 备份英文文件
    backup_file = en_file.with_suffix('.arb.backup')
    try:
        import shutil
        shutil.copy2(en_file, backup_file)
        print(f"💾 已创建备份: {backup_file}")
    except Exception as e:
        print(f"⚠️ 创建备份失败: {e}")
    
    # 执行同步
    if sync_translations(zh_file, en_file):
        print(f"\n🎉 翻译同步完成！")
        print(f"💡 建议执行以下命令重新生成本地化文件:")
        print(f"   flutter gen-l10n")
        print(f"   flutter analyze")
    else:
        print(f"\n❌ 翻译同步失败")
        # 如果失败，尝试恢复备份
        if backup_file.exists():
            try:
                import shutil
                shutil.copy2(backup_file, en_file)
                print(f"🔄 已恢复备份文件")
            except Exception as e:
                print(f"❌ 恢复备份失败: {e}")

if __name__ == "__main__":
    main()