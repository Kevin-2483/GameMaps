#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# python scripts/python/arb_unused_keys.py . --delete --max-workers 24 --no-backup --force --output unused_keys_report.md    
"""
ARB Unused Keys Finder - ARB文件未使用键查找工具

功能：
1. 扫描项目中的所有代码文件
2. 查找ARB文件中定义的键
3. 检查哪些键在代码中未被使用
4. 生成未使用键的报告
5. 支持多种文件类型的扫描
"""

import json
import re
import argparse
import os
from pathlib import Path
from typing import Dict, List, Set, Any, Tuple
import logging
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ARBUnusedKeysFinder:
    """ARB文件未使用键查找工具"""
    
    def __init__(self, project_dir: str, arb_dir: str = None, exclude_dirs: List[str] = None, backup: bool = True, max_workers: int = None):
        self.project_dir = Path(project_dir)
        self.arb_dir = Path(arb_dir) if arb_dir else self.project_dir / 'lib' / 'l10n'
        # 自动添加l10n目录到排除列表，避免扫描ARB文件作为代码文件
        default_excludes = ['build', '.git', '.dart_tool', 'node_modules', '.vscode', 'l10n']
        self.exclude_dirs = set(exclude_dirs or default_excludes)
        # 确保l10n目录总是被排除
        self.exclude_dirs.add('l10n')
        self.backup = backup
        
        # 多线程配置
        self.max_workers = max_workers or min(32, (os.cpu_count() or 1) + 4)
        self.lock = threading.Lock()
        
        # 支持的代码文件扩展名
        self.code_extensions = {'.dart'}
        
        # ARB数据
        self.arb_files = {}
        self.all_keys = set()
        
        # 使用情况
        self.key_usage = defaultdict(list)  # key -> [file_paths]
        self.unused_keys = set()
        
    def find_arb_files(self) -> List[Path]:
        """查找ARB文件"""
        if not self.arb_dir.exists():
            logger.error(f"ARB目录不存在: {self.arb_dir}")
            return []
        
        arb_files = list(self.arb_dir.glob('*.arb'))
        logger.info(f"找到 {len(arb_files)} 个ARB文件: {[f.name for f in arb_files]}")
        return arb_files
    
    def load_arb_file(self, file_path: Path) -> Dict[str, Any]:
        """加载ARB文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                logger.info(f"加载ARB文件: {file_path.name}，包含 {len(data)} 个键")
                return data
        except Exception as e:
            logger.error(f"加载ARB文件失败 {file_path}: {e}")
            return {}
    
    def extract_content_keys(self, arb_data: Dict[str, Any]) -> Set[str]:
        """提取ARB文件中的内容键（排除元数据键）"""
        content_keys = set()
        for key in arb_data.keys():
            if not (key.startswith('@@') or key.startswith('@')):
                content_keys.add(key)
        return content_keys
    
    def create_backup(self, file_path: Path):
        """创建备份文件"""
        if not self.backup:
            return
        
        backup_path = file_path.with_suffix('.arb.backup')
        try:
            backup_path.write_text(file_path.read_text(encoding='utf-8'), encoding='utf-8')
            logger.info(f"创建备份文件: {backup_path.name}")
        except Exception as e:
            logger.error(f"创建备份失败 {file_path}: {e}")
    
    def save_arb_file(self, file_path: Path, data: Dict[str, Any]):
        """保存ARB文件"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            logger.info(f"保存ARB文件: {file_path.name}")
        except Exception as e:
            logger.error(f"保存ARB文件失败 {file_path}: {e}")
    
    def find_code_files(self) -> List[Path]:
        """查找项目中的代码文件"""
        code_files = []
        
        def should_exclude_dir(dir_path: Path) -> bool:
            """检查是否应该排除目录"""
            return any(excluded in dir_path.parts for excluded in self.exclude_dirs)
        
        for file_path in self.project_dir.rglob('*'):
            if file_path.is_file() and file_path.suffix in self.code_extensions:
                if not should_exclude_dir(file_path):
                    code_files.append(file_path)
        
        logger.info(f"找到 {len(code_files)} 个代码文件")
        return code_files
    
    def search_key_in_file(self, file_path: Path, keys: Set[str]) -> Set[str]:
        """在文件中搜索键的使用"""
        found_keys = set()
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
                # 为每个键创建多种可能的搜索模式
                for key in keys:
                    patterns = [
                        # Dart/Flutter常见模式
                        rf"\b{re.escape(key)}\b",  # 直接键名
                        rf"['\"]({re.escape(key)})['\"]"  # 字符串中的键名
                    ]
                    
                    for pattern in patterns:
                        if re.search(pattern, content, re.IGNORECASE):
                            found_keys.add(key)
                            break
                            
        except Exception as e:
            logger.debug(f"读取文件失败 {file_path}: {e}")
        
        return found_keys

    def process_file_batch(self, file_paths: List[Path]) -> Dict[str, List[str]]:
        """处理一批文件，返回键使用情况"""
        local_usage = defaultdict(list)
        
        for file_path in file_paths:
            try:
                found_keys = self.search_key_in_file(file_path, self.all_keys)
                relative_path = str(file_path.relative_to(self.project_dir))
                
                for key in found_keys:
                    local_usage[key].append(relative_path)
                    
            except Exception as e:
                logger.debug(f"处理文件失败 {file_path}: {e}")
                
        return local_usage

    def scan_key_usage(self):
        """扫描键的使用情况（多线程版本）"""
        logger.info(f"开始扫描键的使用情况...（使用 {self.max_workers} 个线程）")
        
        code_files = self.find_code_files()
        total_files = len(code_files)
        
        if total_files == 0:
            logger.warning("没有找到代码文件")
            return
        
        # 将文件分批处理
        batch_size = max(1, total_files // (self.max_workers * 4))  # 每个线程处理多个批次
        file_batches = [code_files[i:i + batch_size] for i in range(0, total_files, batch_size)]
        
        logger.info(f"将 {total_files} 个文件分为 {len(file_batches)} 个批次处理")
        
        processed_files = 0
        
        # 使用线程池处理文件批次
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # 提交所有批次任务
            future_to_batch = {executor.submit(self.process_file_batch, batch): batch for batch in file_batches}
            
            # 收集结果
            for future in as_completed(future_to_batch):
                batch = future_to_batch[future]
                processed_files += len(batch)
                
                try:
                    batch_usage = future.result()
                    
                    # 线程安全地合并结果
                    with self.lock:
                        for key, file_paths in batch_usage.items():
                            self.key_usage[key].extend(file_paths)
                    
                    # 显示进度
                    progress = processed_files / total_files * 100
                    logger.info(f"扫描进度: {processed_files}/{total_files} ({progress:.1f}%)")
                    
                except Exception as e:
                    logger.error(f"处理批次失败: {e}")
        
        # 找出未使用的键
        self.unused_keys = self.all_keys - set(self.key_usage.keys())
        
        logger.info(f"扫描完成。找到 {len(self.key_usage)} 个被使用的键，{len(self.unused_keys)} 个未使用的键")
    
    def generate_report(self, output_file: str = None) -> str:
        """生成报告"""
        report_lines = []
        report_lines.append("# ARB文件未使用键报告")
        report_lines.append("")
        report_lines.append(f"扫描项目: {self.project_dir}")
        report_lines.append(f"ARB目录: {self.arb_dir}")
        report_lines.append("")
        
        # 统计信息
        report_lines.append("## 统计信息")
        report_lines.append(f"- 总键数: {len(self.all_keys)}")
        report_lines.append(f"- 已使用键数: {len(self.key_usage)}")
        report_lines.append(f"- 未使用键数: {len(self.unused_keys)}")
        report_lines.append(f"- 使用率: {len(self.key_usage)/len(self.all_keys)*100:.1f}%" if self.all_keys else "- 使用率: 0%")
        report_lines.append("")
        
        # 按ARB文件分组显示未使用的键
        report_lines.append("## 未使用的键（按文件分组）")
        for arb_file, arb_data in self.arb_files.items():
            file_keys = self.extract_content_keys(arb_data)
            file_unused_keys = file_keys & self.unused_keys
            
            if file_unused_keys:
                report_lines.append(f"### {arb_file.name}")
                report_lines.append(f"未使用键数: {len(file_unused_keys)}/{len(file_keys)}")
                report_lines.append("")
                
                for key in sorted(file_unused_keys):
                    value = arb_data.get(key, "")
                    # 截断过长的值
                    if len(str(value)) > 100:
                        value = str(value)[:97] + "..."
                    report_lines.append(f"- `{key}`: {value}")
                report_lines.append("")
        
        # 显示使用频率最低的键
        if self.key_usage:
            report_lines.append("## 使用频率最低的键（前20个）")
            usage_counts = [(key, len(files)) for key, files in self.key_usage.items()]
            usage_counts.sort(key=lambda x: x[1])
            
            for key, count in usage_counts[:20]:
                report_lines.append(f"- `{key}`: 使用 {count} 次")
            report_lines.append("")
        
        # 完整的未使用键列表
        if self.unused_keys:
            report_lines.append("## 完整未使用键列表")
            for key in sorted(self.unused_keys):
                report_lines.append(f"- {key}")
        
        report_content = "\n".join(report_lines)
        
        # 保存到文件
        if output_file:
            output_path = Path(output_file)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(report_content)
            logger.info(f"报告已保存到: {output_path}")
        
        return report_content
    
    def print_summary(self):
        """打印摘要信息"""
        print("\n" + "="*60)
        print("ARB未使用键查找结果")
        print("="*60)
        print(f"项目目录: {self.project_dir}")
        print(f"ARB目录: {self.arb_dir}")
        print(f"总键数: {len(self.all_keys)}")
        print(f"已使用键数: {len(self.key_usage)}")
        print(f"未使用键数: {len(self.unused_keys)}")
        if self.all_keys:
            print(f"使用率: {len(self.key_usage)/len(self.all_keys)*100:.1f}%")
        
        if self.unused_keys:
            print(f"\n未使用的键（前10个）:")
            for key in sorted(list(self.unused_keys)[:10]):
                print(f"  - {key}")
            if len(self.unused_keys) > 10:
                print(f"  ... 还有 {len(self.unused_keys) - 10} 个")
        
        print("="*60)
    
    def find_unused_keys(self):
        """查找未使用键的主函数"""
        logger.info(f"开始查找未使用的ARB键，项目目录: {self.project_dir}")
        
        # 查找并加载ARB文件
        arb_files = self.find_arb_files()
        if not arb_files:
            logger.warning("未找到任何ARB文件")
            return
        
        for arb_file in arb_files:
            arb_data = self.load_arb_file(arb_file)
            if arb_data:
                self.arb_files[arb_file] = arb_data
                content_keys = self.extract_content_keys(arb_data)
                self.all_keys.update(content_keys)
        
        if not self.all_keys:
            logger.warning("未找到任何内容键")
            return
        
        logger.info(f"总共找到 {len(self.all_keys)} 个唯一的内容键")
        
        # 扫描键的使用情况
        self.scan_key_usage()
        
        # 打印摘要
        self.print_summary()
    
    def confirm_deletion(self) -> bool:
        """确认是否删除未使用的键"""
        if not self.unused_keys:
            logger.info("没有找到未使用的键，无需删除")
            return False
        
        print(f"\n找到 {len(self.unused_keys)} 个未使用的键:")
        for i, key in enumerate(sorted(list(self.unused_keys)[:10]), 1):
            print(f"  {i}. {key}")
        
        if len(self.unused_keys) > 10:
            print(f"  ... 还有 {len(self.unused_keys) - 10} 个")
        
        print("\n这些键将从所有ARB文件中删除。")
        if self.backup:
            print("原文件将备份为 .arb.backup")
        
        while True:
            response = input("\n确认删除这些未使用的键吗？ (y/N): ").strip().lower()
            if response in ['y', 'yes']:
                return True
            elif response in ['n', 'no', '']:
                return False
            else:
                print("请输入 'y' 或 'n'")
    
    def delete_unused_keys(self, force: bool = False) -> bool:
        """删除未使用的键"""
        if not self.unused_keys:
            logger.info("没有找到未使用的键，无需删除")
            return False
        
        if not force and not self.confirm_deletion():
            logger.info("用户取消删除操作")
            return False
        
        logger.info(f"开始删除 {len(self.unused_keys)} 个未使用的键...")
        
        deleted_count = 0
        for arb_file_path, arb_data in self.arb_files.items():
            # 创建备份
            self.create_backup(arb_file_path)
            
            # 删除未使用的键
            original_count = len(arb_data)
            keys_to_delete = []
            
            for key in arb_data.keys():
                if key in self.unused_keys:
                    keys_to_delete.append(key)
            
            for key in keys_to_delete:
                del arb_data[key]
                deleted_count += 1
            
            # 保存修改后的文件
            if keys_to_delete:
                self.save_arb_file(arb_file_path, arb_data)
                logger.info(f"{arb_file_path.name}: 删除了 {len(keys_to_delete)} 个键")
        
        logger.info(f"删除完成！总共删除了 {deleted_count} 个键")
        return True

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='ARB文件未使用键查找工具')
    parser.add_argument('project_dir', help='项目根目录路径')
    parser.add_argument('--arb-dir', help='ARB文件目录路径（默认: project_dir/lib/l10n）')
    parser.add_argument('--exclude', nargs='*', default=['build', '.git', '.dart_tool', 'node_modules', '.vscode'],
                       help='要排除的目录名称')
    parser.add_argument('--output', '-o', help='输出报告文件路径')
    parser.add_argument('--delete', action='store_true', help='自动删除未使用的键')
    parser.add_argument('--force', action='store_true', help='强制删除，不询问确认（需要与--delete一起使用）')
    parser.add_argument('--no-backup', action='store_true', help='删除时不创建备份文件')
    parser.add_argument('--max-workers', type=int, help='最大线程数（默认: CPU核心数+4，最大32）')
    parser.add_argument('--verbose', '-v', action='store_true', help='显示详细日志')
    
    args = parser.parse_args()
    
    # 设置日志级别
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # 检查参数组合
    if args.force and not args.delete:
        logger.error("--force 参数只能与 --delete 一起使用")
        return 1
    
    # 检查项目目录是否存在
    project_dir = Path(args.project_dir)
    if not project_dir.exists():
        logger.error(f"项目目录不存在: {args.project_dir}")
        return 1
    
    if not project_dir.is_dir():
        logger.error(f"路径不是目录: {args.project_dir}")
        return 1
    
    # 创建查找工具并执行
    try:
        finder = ARBUnusedKeysFinder(
            project_dir=args.project_dir,
            arb_dir=args.arb_dir,
            exclude_dirs=args.exclude,
            backup=not args.no_backup,
            max_workers=args.max_workers
        )
        
        finder.find_unused_keys()
        
        # 生成报告
        if args.output:
            finder.generate_report(args.output)
        
        # 删除未使用的键
        if args.delete:
            success = finder.delete_unused_keys(force=args.force)
            if success:
                logger.info("删除操作完成")
            else:
                logger.info("删除操作被取消或无需删除")
        
        return 0
    except Exception as e:
        logger.error(f"操作失败: {e}")
        return 1

if __name__ == '__main__':
    import sys
    sys.exit(main())