#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ARB 文件合并工具
支持指定目录和输出文件、报告合并状态、手动处理冲突键、向已有内容的 ARB 文件合并
"""

import os
import json
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from datetime import datetime

class ARBMerger:
    def __init__(self):
        self.conflicts = {}
        self.file_sources = {}
        self.stats = {
            'total_files': 0,
            'total_keys': 0,
            'conflicts': 0,
            'new_keys': 0,
            'updated_keys': 0,
            'skipped_keys': 0
        }
        self.interactive_mode = False
        self.conflict_resolution = 'last'  # 'last', 'first', 'interactive', 'skip'
    
    def load_arb_file(self, file_path: str) -> Dict:
        """加载 ARB 文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ 无法加载文件 {file_path}: {e}")
            return {}
    
    def save_arb_file(self, file_path: str, data: Dict) -> bool:
        """保存 ARB 文件"""
        try:
            # 确保目录存在
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            # 确保 @@locale 在最前面
            if '@@locale' in data:
                locale_value = data.pop('@@locale')
                ordered_data = {'@@locale': locale_value, **data}
            else:
                ordered_data = data
            
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(ordered_data, f, ensure_ascii=False, indent=2)
            return True
        except Exception as e:
            print(f"❌ 无法保存文件 {file_path}: {e}")
            return False
    
    def resolve_conflict(self, key: str, old_value: str, new_value: str, old_source: str, new_source: str) -> Optional[str]:
        """解决冲突键"""
        if self.conflict_resolution == 'first':
            return old_value
        elif self.conflict_resolution == 'last':
            return new_value
        elif self.conflict_resolution == 'skip':
            self.stats['skipped_keys'] += 1
            return old_value
        elif self.conflict_resolution == 'interactive':
            print(f"\n🔑 冲突键: '{key}'")
            print(f"1. 保留原值: '{old_value}' (来自: {old_source})")
            print(f"2. 使用新值: '{new_value}' (来自: {new_source})")
            print("3. 跳过此键")
            
            while True:
                choice = input("请选择 (1/2/3): ").strip()
                if choice == '1':
                    return old_value
                elif choice == '2':
                    return new_value
                elif choice == '3':
                    self.stats['skipped_keys'] += 1
                    return old_value
                else:
                    print("无效选择，请输入 1、2 或 3")
        
        return new_value  # 默认使用新值
    
    def merge_single_file(self, source_file: str, target_data: Dict, target_source: str = "目标文件") -> Dict:
        """合并单个 ARB 文件到目标数据"""
        source_data = self.load_arb_file(source_file)
        if not source_data:
            return target_data
        
        self.stats['total_files'] += 1
        file_new_keys = 0
        file_updated_keys = 0
        file_conflicts = 0
        
        print(f"\n📄 处理文件: {source_file}")
        
        for key, value in source_data.items():
            # 跳过元数据键
            if key.startswith('@@'):
                continue
            
            # 处理描述键
            if key.startswith('@'):
                if key in target_data and target_data[key] != value:
                    print(f"  ℹ️  描述键冲突 '{key}': 保持原值")
                else:
                    target_data[key] = value
                continue
            
            # 处理普通键
            if key in target_data:
                if target_data[key] != value:
                    # 记录冲突
                    if key not in self.conflicts:
                        self.conflicts[key] = []
                    
                    conflict_info = {
                        'file': source_file,
                        'old_value': target_data[key],
                        'new_value': value,
                        'old_source': self.file_sources.get(key, target_source)
                    }
                    self.conflicts[key].append(conflict_info)
                    
                    # 解决冲突
                    resolved_value = self.resolve_conflict(
                        key, target_data[key], value,
                        self.file_sources.get(key, target_source), source_file
                    )
                    
                    if resolved_value != target_data[key]:
                        target_data[key] = resolved_value
                        self.file_sources[key] = source_file
                        print(f"  🔄 更新键 '{key}': 使用新值")
                    else:
                        print(f"  ⚠️  冲突键 '{key}': 保持原值")
                    
                    file_conflicts += 1
                    self.stats['conflicts'] += 1
                else:
                    print(f"  ✓ 键 '{key}': 值相同，无需更新")
                
                file_updated_keys += 1
                self.stats['updated_keys'] += 1
            else:
                # 新键
                target_data[key] = value
                self.file_sources[key] = source_file
                file_new_keys += 1
                self.stats['new_keys'] += 1
                print(f"  ➕ 新增键 '{key}'")
        
        non_meta_keys = len([k for k in source_data.keys() if not k.startswith('@')])
        self.stats['total_keys'] += non_meta_keys
        
        print(f"  📊 统计: 新增 {file_new_keys}, 更新 {file_updated_keys}, 冲突 {file_conflicts}")
        
        return target_data
    
    def find_arb_files(self, directory: str, exclude_files: List[str] = None) -> List[str]:
        """递归查找目录中的所有 ARB 文件"""
        if exclude_files is None:
            exclude_files = []
        
        arb_files = []
        
        for root, dirs, files in os.walk(directory):
            for file in sorted(files):  # 排序确保处理顺序一致
                if file.endswith('.arb') and file not in exclude_files:
                    arb_files.append(os.path.join(root, file))
        
        return arb_files
    
    def merge_directory(self, source_dir: str, output_file: str, base_file: str = None) -> bool:
        """合并目录中的所有 ARB 文件"""
        print(f"🔍 扫描目录: {source_dir}")
        print("=" * 60)
        
        # 初始化目标数据
        target_data = {}
        target_source = "新文件"
        
        # 如果指定了基础文件，先加载它
        if base_file and os.path.exists(base_file):
            target_data = self.load_arb_file(base_file)
            target_source = base_file
            # 记录基础文件中的键来源
            for key in target_data.keys():
                if not key.startswith('@'):
                    self.file_sources[key] = f'{base_file} (基础文件)'
            print(f"📁 已加载基础文件: {base_file} ({len([k for k in target_data.keys() if not k.startswith('@')])} 个键)")
        
        # 如果输出文件已存在且不是基础文件，加载它
        elif os.path.exists(output_file):
            target_data = self.load_arb_file(output_file)
            target_source = output_file
            # 记录输出文件中的键来源
            for key in target_data.keys():
                if not key.startswith('@'):
                    self.file_sources[key] = f'{output_file} (已存在)'
            print(f"📁 已加载现有输出文件: {output_file} ({len([k for k in target_data.keys() if not k.startswith('@')])} 个键)")
        
        # 查找所有 ARB 文件
        exclude_files = []
        if base_file:
            exclude_files.append(os.path.basename(base_file))
        if output_file != base_file:
            exclude_files.append(os.path.basename(output_file))
        
        arb_files = self.find_arb_files(source_dir, exclude_files)
        
        if not arb_files:
            print("⚠️  未找到需要合并的 ARB 文件")
            return False
        
        print(f"📋 找到 {len(arb_files)} 个 ARB 文件待合并")
        
        # 逐个合并文件
        for arb_file in arb_files:
            target_data = self.merge_single_file(arb_file, target_data, target_source)
        
        # 保存结果
        if self.save_arb_file(output_file, target_data):
            self.print_summary(output_file)
            return True
        else:
            return False
    
    def merge_files(self, source_files: List[str], output_file: str, base_file: str = None) -> bool:
        """合并指定的 ARB 文件列表"""
        print(f"📋 合并 {len(source_files)} 个指定文件")
        print("=" * 60)
        
        # 初始化目标数据
        target_data = {}
        target_source = "新文件"
        
        # 如果指定了基础文件，先加载它
        if base_file and os.path.exists(base_file):
            target_data = self.load_arb_file(base_file)
            target_source = base_file
            # 记录基础文件中的键来源
            for key in target_data.keys():
                if not key.startswith('@'):
                    self.file_sources[key] = f'{base_file} (基础文件)'
            print(f"📁 已加载基础文件: {base_file} ({len([k for k in target_data.keys() if not k.startswith('@')])} 个键)")
        
        # 如果输出文件已存在且不是基础文件，加载它
        elif os.path.exists(output_file):
            target_data = self.load_arb_file(output_file)
            target_source = output_file
            # 记录输出文件中的键来源
            for key in target_data.keys():
                if not key.startswith('@'):
                    self.file_sources[key] = f'{output_file} (已存在)'
            print(f"📁 已加载现有输出文件: {output_file} ({len([k for k in target_data.keys() if not k.startswith('@')])} 个键)")
        
        # 逐个合并文件
        for source_file in source_files:
            if os.path.exists(source_file):
                target_data = self.merge_single_file(source_file, target_data, target_source)
            else:
                print(f"⚠️  文件不存在: {source_file}")
        
        # 保存结果
        if self.save_arb_file(output_file, target_data):
            self.print_summary(output_file)
            return True
        else:
            return False
    
    def print_summary(self, output_file: str):
        """打印合并总结"""
        print("\n" + "=" * 60)
        print("📊 合并统计报告")
        print("=" * 60)
        print(f"✅ 合并完成！输出文件: {output_file}")
        print(f"📁 处理文件数: {self.stats['total_files']}")
        print(f"🔑 总键数: {self.stats['total_keys']}")
        print(f"🆕 新增键: {self.stats['new_keys']}")
        print(f"🔄 更新键: {self.stats['updated_keys']}")
        print(f"⚠️  冲突键: {self.stats['conflicts']}")
        print(f"⏭️  跳过键: {self.stats['skipped_keys']}")
        
        # 输出冲突详情
        if self.conflicts:
            print("\n" + "=" * 60)
            print("⚠️  冲突详情报告")
            print("=" * 60)
            for key, conflict_list in list(self.conflicts.items())[:10]:  # 只显示前10个
                print(f"\n🔑 键: '{key}'")
                for i, conflict in enumerate(conflict_list):
                    print(f"  {i+1}. 来源: {conflict['old_source']}")
                    print(f"     原值: '{conflict['old_value']}'")
                    print(f"     新值: '{conflict['new_value']}' (来自: {conflict['file']})")
            
            if len(self.conflicts) > 10:
                print(f"\n... 还有 {len(self.conflicts) - 10} 个冲突键")
            
            print(f"\n💡 冲突解决策略: {self.conflict_resolution}")
        
        # 生成冲突报告文件
        if self.conflicts:
            conflict_report_file = output_file.replace('.arb', '_conflicts.json')
            conflict_report = {
                'timestamp': datetime.now().isoformat(),
                'summary': self.stats,
                'conflicts': self.conflicts,
                'file_sources': self.file_sources,
                'conflict_resolution': self.conflict_resolution
            }
            
            try:
                with open(conflict_report_file, 'w', encoding='utf-8') as f:
                    json.dump(conflict_report, f, ensure_ascii=False, indent=2)
                print(f"\n📄 冲突报告已保存: {conflict_report_file}")
            except Exception as e:
                print(f"\n❌ 无法保存冲突报告: {e}")
        
        print("\n" + "=" * 60)

def main():
    parser = argparse.ArgumentParser(
        description='ARB 文件合并工具',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:
  # 合并目录中的所有 ARB 文件
  python merge_arb_files.py --dir lib/l10n/zh --output lib/l10n/app_zh.arb
  
  # 合并指定文件
  python merge_arb_files.py --files file1.arb file2.arb --output merged.arb
  
  # 向现有文件合并，交互式处理冲突
  python merge_arb_files.py --dir lib/l10n/zh --output lib/l10n/app_zh.arb --conflict interactive
  
  # 使用基础文件作为起点
  python merge_arb_files.py --dir lib/l10n/zh --output merged.arb --base app_zh.arb
        """
    )
    
    # 输入选项
    input_group = parser.add_mutually_exclusive_group(required=True)
    input_group.add_argument('--dir', '-d', help='要合并的 ARB 文件目录')
    input_group.add_argument('--files', '-f', nargs='+', help='要合并的 ARB 文件列表')
    
    # 输出选项
    parser.add_argument('--output', '-o', required=True, help='输出 ARB 文件路径')
    parser.add_argument('--base', '-b', help='基础 ARB 文件（作为合并起点）')
    
    # 冲突处理选项
    parser.add_argument('--conflict', '-c', 
                       choices=['last', 'first', 'interactive', 'skip'],
                       default='last',
                       help='冲突解决策略 (默认: last)')
    
    # 其他选项
    parser.add_argument('--verbose', '-v', action='store_true', help='详细输出')
    
    args = parser.parse_args()
    
    # 创建合并器
    merger = ARBMerger()
    merger.conflict_resolution = args.conflict
    
    print("🛠️  ARB 文件合并工具")
    print("=" * 60)
    print(f"冲突解决策略: {args.conflict}")
    
    # 执行合并
    success = False
    if args.dir:
        success = merger.merge_directory(args.dir, args.output, args.base)
    elif args.files:
        success = merger.merge_files(args.files, args.output, args.base)
    
    if success:
        print("\n🎉 合并操作成功完成！")
        return 0
    else:
        print("\n❌ 合并操作失败！")
        return 1

if __name__ == '__main__':
    exit(main())