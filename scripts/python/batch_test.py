#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量测试脚本
使用现有的YAML文件进行真实场景的稳定性测试
"""

import os
import sys
import asyncio
import shutil
import tempfile
import yaml
import json
from pathlib import Path
from typing import List, Dict, Tuple
import time
import random

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from i18n_processor import I18nProcessor, YamlRecord, AIResponse

class BatchTester:
    """批量测试器"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.yaml_dir = self.project_root / 'yaml'
        self.test_results = []
        
    def load_existing_yaml_files(self) -> List[Path]:
        """加载现有的YAML文件"""
        yaml_files = []
        if self.yaml_dir.exists():
            for file in self.yaml_dir.glob('*.yaml'):
                yaml_files.append(file)
        return yaml_files
    
    def parse_yaml_file(self, yaml_file: Path) -> YamlRecord:
        """解析YAML文件"""
        try:
            with open(yaml_file, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            return YamlRecord(
                path=data['path'],
                start_line=data['start_line'],
                end_line=data['end_line'],
                code=data['code'],
                yaml_file=yaml_file.name
            )
        except Exception as e:
            print(f"❌ 解析YAML文件失败 {yaml_file}: {e}")
            return None
    
    def create_mock_ai_response(self, record: YamlRecord) -> AIResponse:
        """创建模拟的AI响应"""
        # 简单的模拟：将中文替换为l10n调用
        import re
        
        # 查找中文字符串
        chinese_pattern = r"[\u4e00-\u9fff]+"
        chinese_matches = re.findall(chinese_pattern, record.code)
        
        if not chinese_matches:
            # 如果没有中文，返回原代码
            return AIResponse(
                replaced_code=record.code,
                arb_entries={},
                success=True
            )
        
        # 生成替换代码和ARB条目
        replaced_code = record.code
        arb_entries = {}
        
        for i, chinese_text in enumerate(chinese_matches):
            # 生成键名
            key_name = f"testKey{i + 1}"
            
            # 替换代码中的中文
            replaced_code = replaced_code.replace(
                f"'{chinese_text}'", 
                f"AppLocalizations.of(context).{key_name}"
            ).replace(
                f'"{chinese_text}"', 
                f"AppLocalizations.of(context).{key_name}"
            )
            
            arb_entries[key_name] = chinese_text
        
        return AIResponse(
            replaced_code=replaced_code,
            arb_entries=arb_entries,
            success=True
        )
    
    def create_test_environment(self) -> Tuple[str, I18nProcessor]:
        """创建测试环境"""
        test_dir = tempfile.mkdtemp(prefix='batch_test_')
        
        # 复制项目结构
        lib_dir = os.path.join(test_dir, 'lib')
        os.makedirs(lib_dir, exist_ok=True)
        
        # 复制相关的Dart文件
        project_lib = self.project_root / 'lib'
        if project_lib.exists():
            shutil.copytree(project_lib, lib_dir, dirs_exist_ok=True)
        
        # 创建处理器
        processor = I18nProcessor(
            yaml_dir=str(self.yaml_dir),
            api_url="http://test.api",
            api_key="test_key"
        )
        
        return test_dir, processor
    
    async def test_single_record(self, record: YamlRecord, processor: I18nProcessor, test_dir: str) -> Dict:
        """测试单个记录"""
        test_result = {
            'yaml_file': record.yaml_file,
            'path': record.path,
            'start_line': record.start_line,
            'end_line': record.end_line,
            'success': False,
            'error': None,
            'processing_time': 0
        }
        
        try:
            start_time = time.time()
            
            # 检查Dart文件是否存在
            dart_file_path = Path(test_dir) / record.path
            if not dart_file_path.exists():
                test_result['error'] = f"Dart文件不存在: {dart_file_path}"
                return test_result
            
            # 创建模拟AI响应
            ai_response = self.create_mock_ai_response(record)
            
            # 执行替换
            success = await processor.replace_dart_code(record, ai_response)
            
            end_time = time.time()
            test_result['processing_time'] = end_time - start_time
            test_result['success'] = success
            
            if not success:
                test_result['error'] = "替换操作失败"
            
        except Exception as e:
            test_result['error'] = str(e)
        
        return test_result
    
    async def run_batch_test(self, max_files: int = 10) -> Dict:
        """运行批量测试"""
        print(f"🚀 开始批量测试，最多测试 {max_files} 个文件")
        print("=" * 60)
        
        # 加载YAML文件
        yaml_files = self.load_existing_yaml_files()
        if not yaml_files:
            print("❌ 没有找到YAML文件")
            return {'success': False, 'error': '没有找到YAML文件'}
        
        print(f"📁 找到 {len(yaml_files)} 个YAML文件")
        
        # 随机选择文件进行测试
        test_files = random.sample(yaml_files, min(max_files, len(yaml_files)))
        
        # 创建测试环境
        test_dir, processor = self.create_test_environment()
        
        try:
            results = []
            successful_tests = 0
            
            for i, yaml_file in enumerate(test_files, 1):
                print(f"\n🧪 测试 {i}/{len(test_files)}: {yaml_file.name}")
                
                # 解析YAML文件
                record = self.parse_yaml_file(yaml_file)
                if record is None:
                    continue
                
                # 执行测试
                result = await self.test_single_record(record, processor, test_dir)
                results.append(result)
                
                if result['success']:
                    print(f"✅ 成功 - 耗时: {result['processing_time']:.3f}s")
                    successful_tests += 1
                else:
                    print(f"❌ 失败 - {result['error']}")
            
            # 统计结果
            total_tests = len(results)
            success_rate = (successful_tests / total_tests * 100) if total_tests > 0 else 0
            
            print("\n" + "=" * 60)
            print(f"📊 批量测试结果:")
            print(f"   总测试数: {total_tests}")
            print(f"   成功数: {successful_tests}")
            print(f"   失败数: {total_tests - successful_tests}")
            print(f"   成功率: {success_rate:.1f}%")
            
            if success_rate >= 80:
                print("🎉 批量测试通过！系统稳定性良好。")
            elif success_rate >= 60:
                print("⚠️  批量测试部分通过，建议检查失败的用例。")
            else:
                print("❌ 批量测试失败率较高，需要检查系统稳定性。")
            
            # 显示失败的测试详情
            failed_tests = [r for r in results if not r['success']]
            if failed_tests:
                print("\n❌ 失败的测试详情:")
                for test in failed_tests[:5]:  # 只显示前5个
                    print(f"   - {test['yaml_file']}: {test['error']}")
                if len(failed_tests) > 5:
                    print(f"   ... 还有 {len(failed_tests) - 5} 个失败测试")
            
            return {
                'success': success_rate >= 80,
                'total_tests': total_tests,
                'successful_tests': successful_tests,
                'success_rate': success_rate,
                'results': results
            }
        
        finally:
            # 清理测试环境
            shutil.rmtree(test_dir)
    
    async def run_stress_test(self, iterations: int = 5) -> Dict:
        """运行压力测试"""
        print(f"🔥 开始压力测试，运行 {iterations} 轮")
        print("=" * 60)
        
        all_results = []
        
        for i in range(iterations):
            print(f"\n🔄 第 {i + 1}/{iterations} 轮测试")
            result = await self.run_batch_test(max_files=5)
            all_results.append(result)
            
            if not result['success']:
                print(f"⚠️  第 {i + 1} 轮测试失败")
        
        # 统计压力测试结果
        successful_rounds = sum(1 for r in all_results if r['success'])
        total_rounds = len(all_results)
        
        print("\n" + "=" * 60)
        print(f"🔥 压力测试结果:")
        print(f"   总轮数: {total_rounds}")
        print(f"   成功轮数: {successful_rounds}")
        print(f"   成功率: {successful_rounds / total_rounds * 100:.1f}%")
        
        if successful_rounds == total_rounds:
            print("🎉 压力测试完全通过！系统非常稳定。")
        elif successful_rounds >= total_rounds * 0.8:
            print("✅ 压力测试基本通过，系统稳定性良好。")
        else:
            print("❌ 压力测试失败，系统稳定性需要改进。")
        
        return {
            'success': successful_rounds >= total_rounds * 0.8,
            'total_rounds': total_rounds,
            'successful_rounds': successful_rounds,
            'all_results': all_results
        }

async def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description='I18n处理器批量测试')
    parser.add_argument('--project-root', default='.', help='项目根目录')
    parser.add_argument('--max-files', type=int, default=10, help='最大测试文件数')
    parser.add_argument('--stress-test', action='store_true', help='运行压力测试')
    parser.add_argument('--iterations', type=int, default=5, help='压力测试轮数')
    
    args = parser.parse_args()
    
    # 获取项目根目录
    if args.project_root == '.':
        # 如果是当前目录，尝试找到项目根目录
        current_dir = Path(__file__).parent
        project_root = current_dir.parent.parent  # 回到项目根目录
    else:
        project_root = Path(args.project_root)
    
    print(f"📁 项目根目录: {project_root}")
    
    # 创建测试器
    tester = BatchTester(str(project_root))
    
    if args.stress_test:
        # 运行压力测试
        result = await tester.run_stress_test(args.iterations)
    else:
        # 运行批量测试
        result = await tester.run_batch_test(args.max_files)
    
    # 返回退出码
    sys.exit(0 if result['success'] else 1)

if __name__ == '__main__':
    asyncio.run(main())