#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ARB Sync - ARB文件键同步工具

功能：
1. 搜索目录中的所有ARB文件
2. 对比各文件缺失的键
3. 自动互相补充缺失的键（使用原始键名作为值）
4. 按字母顺序排序所有键
5. 保持元数据键的位置
"""

import json
import argparse
from pathlib import Path
from typing import Dict, List, Set, Any
import logging
from collections import OrderedDict

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ARBSyncTool:
    """ARB文件同步工具"""
    
    def __init__(self, directory: str, backup: bool = True):
        self.directory = Path(directory)
        self.backup = backup
        self.arb_files = []
        self.arb_data = {}
        
    def find_arb_files(self) -> List[Path]:
        """查找目录中的所有ARB文件"""
        arb_files = list(self.directory.glob('*.arb'))
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
    
    def save_arb_file(self, file_path: Path, data: Dict[str, Any]):
        """保存ARB文件"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            logger.info(f"保存ARB文件: {file_path.name}")
        except Exception as e:
            logger.error(f"保存ARB文件失败 {file_path}: {e}")
    
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
    
    def separate_keys(self, data: Dict[str, Any]) -> tuple[Dict[str, Any], Dict[str, Any]]:
        """分离元数据键和普通键"""
        metadata = {}
        content = {}
        
        for key, value in data.items():
            if key.startswith('@@') or key.startswith('@'):
                metadata[key] = value
            else:
                content[key] = value
        
        return metadata, content
    
    def get_all_content_keys(self) -> Set[str]:
        """获取所有ARB文件中的内容键（排除元数据键）"""
        all_keys = set()
        
        for file_path, data in self.arb_data.items():
            metadata, content = self.separate_keys(data)
            all_keys.update(content.keys())
        
        logger.info(f"总共找到 {len(all_keys)} 个唯一的内容键")
        return all_keys
    
    def find_missing_keys(self) -> Dict[str, Set[str]]:
        """查找每个文件缺失的键"""
        all_keys = self.get_all_content_keys()
        missing_keys = {}
        
        for file_path, data in self.arb_data.items():
            metadata, content = self.separate_keys(data)
            current_keys = set(content.keys())
            missing = all_keys - current_keys
            missing_keys[str(file_path)] = missing
            
            if missing:
                logger.info(f"{file_path.name} 缺失 {len(missing)} 个键: {sorted(missing)}")
            else:
                logger.info(f"{file_path.name} 没有缺失的键")
        
        return missing_keys
    
    def add_missing_keys(self, missing_keys: Dict[str, Set[str]]):
        """为每个文件添加缺失的键"""
        for file_path_str, missing in missing_keys.items():
            if not missing:
                continue
                
            file_path = Path(file_path_str)
            data = self.arb_data[file_path]
            metadata, content = self.separate_keys(data)
            
            # 添加缺失的键，使用键名作为默认值
            for key in missing:
                content[key] = key
                logger.debug(f"为 {file_path.name} 添加键: {key}")
            
            # 更新数据
            self.arb_data[file_path] = {**metadata, **content}
            
            logger.info(f"为 {file_path.name} 添加了 {len(missing)} 个缺失的键")
    
    def sort_keys(self):
        """对所有ARB文件的键进行排序"""
        for file_path, data in self.arb_data.items():
            metadata, content = self.separate_keys(data)
            
            # 对内容键进行字母排序
            sorted_content = OrderedDict(sorted(content.items()))
            
            # 重新组合：元数据在前，排序后的内容在后
            sorted_data = OrderedDict()
            sorted_data.update(metadata)
            sorted_data.update(sorted_content)
            
            self.arb_data[file_path] = sorted_data
            logger.info(f"对 {file_path.name} 的键进行了排序")
    
    def print_statistics(self):
        """打印统计信息"""
        print("\n" + "="*50)
        print("ARB文件同步统计")
        print("="*50)
        
        all_keys = self.get_all_content_keys()
        print(f"总共处理的ARB文件数: {len(self.arb_files)}")
        print(f"总共的唯一键数: {len(all_keys)}")
        
        for file_path in self.arb_files:
            data = self.arb_data[file_path]
            metadata, content = self.separate_keys(data)
            print(f"{file_path.name}: {len(content)} 个内容键, {len(metadata)} 个元数据键")
        
        print("="*50)
    
    def sync_arb_files(self):
        """同步ARB文件的主函数"""
        logger.info(f"开始同步ARB文件，目录: {self.directory}")
        
        # 查找ARB文件
        self.arb_files = self.find_arb_files()
        if not self.arb_files:
            logger.warning("未找到任何ARB文件")
            return
        
        # 加载所有ARB文件
        for file_path in self.arb_files:
            self.arb_data[file_path] = self.load_arb_file(file_path)
        
        # 查找缺失的键
        missing_keys = self.find_missing_keys()
        
        # 为每个文件创建备份
        if self.backup:
            for file_path in self.arb_files:
                self.create_backup(file_path)
        
        # 添加缺失的键
        self.add_missing_keys(missing_keys)
        
        # 对键进行排序
        self.sort_keys()
        
        # 保存所有文件
        for file_path in self.arb_files:
            self.save_arb_file(file_path, self.arb_data[file_path])
        
        # 打印统计信息
        self.print_statistics()
        
        logger.info("ARB文件同步完成！")

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='ARB文件键同步工具')
    parser.add_argument('directory', help='包含ARB文件的目录路径')
    parser.add_argument('--no-backup', action='store_true', help='不创建备份文件')
    parser.add_argument('--verbose', '-v', action='store_true', help='显示详细日志')
    
    args = parser.parse_args()
    
    # 设置日志级别
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # 检查目录是否存在
    directory = Path(args.directory)
    if not directory.exists():
        logger.error(f"目录不存在: {args.directory}")
        return 1
    
    if not directory.is_dir():
        logger.error(f"路径不是目录: {args.directory}")
        return 1
    
    # 创建同步工具并执行
    try:
        sync_tool = ARBSyncTool(directory=args.directory, backup=not args.no_backup)
        sync_tool.sync_arb_files()
        return 0
    except Exception as e:
        logger.error(f"同步失败: {e}")
        return 1

if __name__ == '__main__':
    import sys
    sys.exit(main())