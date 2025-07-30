#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DeepSeek API与I18n处理器集成测试
验证DeepSeek API在I18n处理器中的实际应用效果
"""

import os
import sys
import tempfile
import shutil
import asyncio
import json
import yaml
from pathlib import Path

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from i18n_processor import I18nProcessor, YamlRecord

class DeepSeekIntegrationTester:
    """DeepSeek API集成测试器"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.deepseek_url = "https://api.deepseek.com/chat/completions"
        self.test_dir = None
        self.yaml_dir = None
        self.dart_dir = None
        
    def setup_test_environment(self):
        """设置测试环境"""
        self.test_dir = tempfile.mkdtemp(prefix='deepseek_i18n_test_')
        print(f"创建测试环境: {self.test_dir}")
        
        # 创建目录结构
        self.yaml_dir = os.path.join(self.test_dir, 'yaml')
        self.dart_dir = os.path.join(self.test_dir, 'lib')
        os.makedirs(self.yaml_dir)
        os.makedirs(self.dart_dir)
        
        # 创建l10n目录
        l10n_dir = os.path.join(self.dart_dir, 'l10n')
        os.makedirs(l10n_dir)
        
        return self.test_dir, self.yaml_dir, self.dart_dir
    
    def cleanup_test_environment(self):
        """清理测试环境"""
        if self.test_dir and os.path.exists(self.test_dir):
            shutil.rmtree(self.test_dir, ignore_errors=True)
    
    def create_test_dart_file(self, filename: str, content: str) -> str:
        """创建测试Dart文件"""
        dart_file = os.path.join(self.dart_dir, filename)
        with open(dart_file, 'w', encoding='utf-8') as f:
            f.write(content)
        return dart_file
    
    def create_test_yaml_file(self, filename: str, dart_path: str, start_line: int, end_line: int, code: str) -> str:
        """创建测试YAML文件"""
        yaml_data = {
            'path': dart_path,
            'start_line': start_line,
            'end_line': end_line,
            'code': code
        }
        
        yaml_file = os.path.join(self.yaml_dir, filename)
        with open(yaml_file, 'w', encoding='utf-8') as f:
            yaml.dump(yaml_data, f, default_flow_style=False, allow_unicode=True)
        
        return yaml_file
    
    async def test_simple_replacement(self) -> bool:
        """测试简单字符串替换"""
        print("\n🧪 测试1: 简单字符串替换")
        
        try:
            # 创建测试文件
            dart_content = "Text('欢迎使用我们的应用');"
            dart_file = self.create_test_dart_file('simple.dart', dart_content)
            
            # 创建YAML记录
            yaml_file = self.create_test_yaml_file(
                'simple.yaml',
                'lib/simple.dart',
                1, 1,
                "Text('欢迎使用我们的应用');"
            )
            
            # 创建处理器
            processor = I18nProcessor(
                yaml_dir=self.yaml_dir,
                api_url=self.deepseek_url,
                api_key=self.api_key,
                max_concurrent=1,
                config_file=os.path.join(os.path.dirname(__file__), 'deepseek_config.json')
            )
            
            # 加载记录
            records = await processor.load_yaml_records()
            if not records:
                print("❌ 未找到YAML记录")
                return False
            
            record = records[0]
            print(f"📝 处理代码: {record.code}")
            
            # 调用AI API
            ai_response = await processor.call_ai_api(record)
            
            if not ai_response.success:
                print(f"❌ AI API调用失败: {ai_response.error_message}")
                return False
            
            print(f"✅ AI响应成功")
            print(f"📄 替换后代码: {ai_response.replaced_code}")
            print(f"🔑 ARB条目: {ai_response.arb_entries}")
            
            # 验证结果
            if 'AppLocalizations.of(context)' not in ai_response.replaced_code and 'l10n.' not in ai_response.replaced_code:
                print("❌ 替换后代码不包含国际化调用")
                return False
            
            if not ai_response.arb_entries:
                print("❌ 未生成ARB条目")
                return False
            
            print("✅ 简单字符串替换测试通过")
            return True
            
        except Exception as e:
            print(f"❌ 简单字符串替换测试失败: {e}")
            return False
    
    async def test_complex_interpolation(self) -> bool:
        """测试复杂字符串插值"""
        print("\n🧪 测试2: 复杂字符串插值")
        
        try:
            # 创建包含插值的复杂代码
            dart_content = """Widget buildUserInfo() {
  return Column(
    children: [
      Text('用户名：\${user.name}'),
      Text('年龄：\${user.age}岁'),
      Text('状态：\${user.isActive ? "在线" : "离线"}'),
    ],
  );
}"""
            
            dart_file = self.create_test_dart_file('complex.dart', dart_content)
            
            # 创建YAML记录
            yaml_file = self.create_test_yaml_file(
                'complex.yaml',
                'lib/complex.dart',
                1, 9,
                dart_content
            )
            
            # 创建处理器
            processor = I18nProcessor(
                yaml_dir=self.yaml_dir,
                api_url=self.deepseek_url,
                api_key=self.api_key,
                max_concurrent=1,
                config_file=os.path.join(os.path.dirname(__file__), 'deepseek_config.json')
            )
            
            # 加载记录
            records = await processor.load_yaml_records()
            record = next((r for r in records if 'complex.yaml' in r.yaml_file), None)
            
            if not record:
                print("❌ 未找到复杂插值记录")
                return False
            
            print(f"📝 处理复杂代码: {record.code[:100]}...")
            
            # 调用AI API
            ai_response = await processor.call_ai_api(record)
            
            if not ai_response.success:
                print(f"❌ AI API调用失败: {ai_response.error_message}")
                return False
            
            print(f"✅ AI响应成功")
            print(f"📄 替换后代码: {ai_response.replaced_code[:200]}...")
            print(f"🔑 ARB条目数量: {len(ai_response.arb_entries)}")
            
            # 验证结果
            l10n_count = ai_response.replaced_code.count('l10n.') + ai_response.replaced_code.count('AppLocalizations.of(context)')
            if l10n_count < 2:
                print(f"❌ 替换后代码国际化调用数量不足: {l10n_count}")
                return False
            
            if len(ai_response.arb_entries) < 2:
                print("❌ ARB条目数量不足")
                return False
            
            # 检查是否正确处理了插值
            has_interpolation = any('{' in value and '}' in value for value in ai_response.arb_entries.values())
            if not has_interpolation:
                print("⚠️  可能未正确处理字符串插值")
            
            print("✅ 复杂字符串插值测试通过")
            return True
            
        except Exception as e:
            print(f"❌ 复杂字符串插值测试失败: {e}")
            return False
    
    async def test_json_format_validation(self) -> bool:
        """测试JSON格式验证"""
        print("\n🧪 测试3: JSON格式验证")
        
        try:
            # 创建测试代码
            dart_content = "ElevatedButton(onPressed: () {}, child: Text('保存设置'));"
            
            dart_file = self.create_test_dart_file('json_test.dart', dart_content)
            
            # 创建YAML记录
            yaml_file = self.create_test_yaml_file(
                'json_test.yaml',
                'lib/json_test.dart',
                1, 1,
                dart_content
            )
            
            # 创建处理器
            processor = I18nProcessor(
                yaml_dir=self.yaml_dir,
                api_url=self.deepseek_url,
                api_key=self.api_key,
                max_concurrent=1,
                config_file=os.path.join(os.path.dirname(__file__), 'deepseek_config.json')
            )
            
            # 加载记录
            records = await processor.load_yaml_records()
            record = next((r for r in records if 'json_test.yaml' in r.yaml_file), None)
            
            if not record:
                print("❌ 未找到JSON测试记录")
                return False
            
            print(f"📝 处理代码: {record.code}")
            
            # 调用AI API
            ai_response = await processor.call_ai_api(record)
            
            if not ai_response.success:
                print(f"❌ AI API调用失败: {ai_response.error_message}")
                return False
            
            print(f"✅ AI响应成功")
            
            # 验证JSON格式
            if not isinstance(ai_response.arb_entries, dict):
                print("❌ ARB条目不是有效的字典格式")
                return False
            
            # 验证键名格式
            for key in ai_response.arb_entries.keys():
                if not key.replace('_', '').isalnum():
                    print(f"⚠️  键名格式可能不规范: {key}")
            
            print("✅ JSON格式验证测试通过")
            return True
            
        except Exception as e:
            print(f"❌ JSON格式验证测试失败: {e}")
            return False
    
    async def test_performance_benchmark(self) -> bool:
        """测试性能基准"""
        print("\n🧪 测试4: 性能基准测试")
        
        try:
            import time
            
            # 创建多个测试文件
            test_cases = [
                ("Text('首页');", "home.yaml"),
                ("Text('设置');", "settings.yaml"),
                ("Text('关于我们');", "about.yaml"),
                ("Text('用户中心');", "user.yaml"),
                ("Text('帮助文档');", "help.yaml")
            ]
            
            for i, (code, yaml_name) in enumerate(test_cases):
                dart_file = self.create_test_dart_file(f'perf_{i}.dart', code)
                yaml_file = self.create_test_yaml_file(
                    yaml_name,
                    f'lib/perf_{i}.dart',
                    1, 1,
                    code
                )
            
            # 创建处理器
            processor = I18nProcessor(
                yaml_dir=self.yaml_dir,
                api_url=self.deepseek_url,
                api_key=self.api_key,
                max_concurrent=2,  # 测试并发
                config_file=os.path.join(os.path.dirname(__file__), 'deepseek_config.json')
            )
            
            # 加载记录
            records = await processor.load_yaml_records()
            print(f"📊 加载了 {len(records)} 个测试记录")
            
            # 性能测试
            start_time = time.time()
            
            successful_calls = 0
            for record in records:
                try:
                    ai_response = await processor.call_ai_api(record)
                    if ai_response.success:
                        successful_calls += 1
                except Exception as e:
                    print(f"⚠️  记录 {record.yaml_file} 处理失败: {e}")
            
            end_time = time.time()
            total_time = end_time - start_time
            
            print(f"📊 性能统计:")
            print(f"  总记录数: {len(records)}")
            print(f"  成功处理: {successful_calls}")
            print(f"  总耗时: {total_time:.2f}秒")
            print(f"  平均耗时: {total_time/len(records):.2f}秒/记录")
            print(f"  成功率: {successful_calls/len(records)*100:.1f}%")
            
            # 性能基准
            if total_time > 10:  # 超过10秒认为性能较差
                print("⚠️  性能可能需要优化")
            
            if successful_calls / len(records) < 0.8:  # 成功率低于80%
                print("❌ 成功率过低")
                return False
            
            print("✅ 性能基准测试通过")
            return True
            
        except Exception as e:
            print(f"❌ 性能基准测试失败: {e}")
            return False
    
    async def run_all_tests(self) -> dict:
        """运行所有集成测试"""
        print("🚀 开始DeepSeek API与I18n处理器集成测试")
        print("=" * 60)
        
        # 设置测试环境
        self.setup_test_environment()
        
        try:
            # 运行所有测试
            tests = [
                ('简单字符串替换', self.test_simple_replacement),
                ('复杂字符串插值', self.test_complex_interpolation),
                ('JSON格式验证', self.test_json_format_validation),
                ('性能基准测试', self.test_performance_benchmark)
            ]
            
            results = []
            successful_tests = 0
            
            for test_name, test_func in tests:
                try:
                    print(f"\n{'='*20} {test_name} {'='*20}")
                    result = await test_func()
                    results.append({
                        'test_name': test_name,
                        'success': result,
                        'error': None
                    })
                    if result:
                        successful_tests += 1
                        print(f"✅ {test_name} 通过")
                    else:
                        print(f"❌ {test_name} 失败")
                except Exception as e:
                    print(f"❌ {test_name} 异常: {e}")
                    results.append({
                        'test_name': test_name,
                        'success': False,
                        'error': str(e)
                    })
            
            # 生成测试报告
            total_tests = len(tests)
            success_rate = successful_tests / total_tests * 100
            
            print("\n" + "=" * 60)
            print("📊 集成测试报告")
            print(f"✅ 成功: {successful_tests}/{total_tests} ({success_rate:.1f}%)")
            
            if successful_tests == total_tests:
                print("🎉 所有集成测试通过！DeepSeek API与I18n处理器兼容性良好。")
            else:
                print("⚠️  部分测试失败，请检查配置和网络连接。")
            
            return {
                'success': successful_tests == total_tests,
                'total_tests': total_tests,
                'successful_tests': successful_tests,
                'success_rate': success_rate,
                'results': results
            }
            
        finally:
            # 清理测试环境
            self.cleanup_test_environment()

async def main():
    """主函数"""
    # DeepSeek API密钥
    api_key = "sk-8e3f9bc188494092ad4768d8f75fb762"
    
    if not api_key:
        print("❌ 请设置DeepSeek API密钥")
        return 1
    
    # 创建集成测试器
    tester = DeepSeekIntegrationTester(api_key)
    
    # 运行所有测试
    results = await tester.run_all_tests()
    
    # 保存测试结果
    with open('deepseek_integration_results.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 集成测试结果已保存到: deepseek_integration_results.json")
    
    return 0 if results['success'] else 1

if __name__ == '__main__':
    asyncio.run(main())