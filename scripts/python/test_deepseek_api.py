#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DeepSeek API配置和测试脚本
用于验证DeepSeek API的配置和功能
"""

import json
import asyncio
import aiohttp
from typing import Dict, List
import time

class DeepSeekAPITester:
    """DeepSeek API测试器"""
    
    def __init__(self, api_key: str, base_url: str = "https://api.deepseek.com"):
        self.api_key = api_key
        self.base_url = base_url
        self.chat_url = f"{base_url}/chat/completions"
        
    async def test_api_connection(self) -> bool:
        """测试API连接"""
        print("🔗 测试API连接...")
        
        try:
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'model': 'deepseek-chat',
                'messages': [
                    {'role': 'system', 'content': 'You are a helpful assistant'},
                    {'role': 'user', 'content': 'Hello, please respond with "Connection successful"'}
                ],
                'max_tokens': 50,
                'temperature': 0.1
            }
            
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=30)) as session:
                async with session.post(self.chat_url, headers=headers, json=payload) as response:
                    if response.status == 200:
                        result = await response.json()
                        content = result['choices'][0]['message']['content']
                        print(f"✅ API连接成功: {content}")
                        return True
                    else:
                        error_text = await response.text()
                        print(f"❌ API连接失败 (状态码: {response.status}): {error_text}")
                        return False
                        
        except Exception as e:
            print(f"❌ API连接异常: {e}")
            return False
    
    async def test_simple_question(self) -> Dict:
        """测试简单问题 - 难度1"""
        print("\n📝 测试1: 简单问题")
        
        question = "什么是人工智能？请用一句话回答。"
        print(f"问题: {question}")
        
        return await self._send_request(question, max_tokens=100)
    
    async def test_code_generation(self) -> Dict:
        """测试代码生成 - 难度2"""
        print("\n💻 测试2: 代码生成")
        
        question = "请用Python写一个函数，计算斐波那契数列的第n项，要求使用递归方法。"
        print(f"问题: {question}")
        
        return await self._send_request(question, max_tokens=300)
    
    async def test_complex_reasoning(self) -> Dict:
        """测试复杂推理 - 难度3"""
        print("\n🧠 测试3: 复杂推理")
        
        question = """有一个经典的逻辑问题：
        三个人A、B、C，其中一个总是说真话，一个总是说假话，一个有时说真话有时说假话。
        现在他们分别说：
        A说："B是说假话的人"
        B说："C不是说真话的人"
        C说："A和B中有一个是说真话的人"
        请分析谁是说真话的人，谁是说假话的人，谁是有时说真话有时说假话的人？"""
        
        print(f"问题: {question[:100]}...")
        
        return await self._send_request(question, max_tokens=500)
    
    async def test_i18n_specific_task(self) -> Dict:
        """测试国际化相关任务 - 难度4"""
        print("\n🌐 测试4: 国际化任务")
        
        question = """请将以下Dart代码中的中文字符串替换为Flutter l10n调用，并生成对应的ARB键值对：
        
        ```dart
        Widget buildUserProfile() {
          return Column(
            children: [
              Text('用户信息'),
              Text('姓名：${user.name}'),
              Text('年龄：${user.age}岁'),
              ElevatedButton(
                onPressed: () => logout(),
                child: Text('退出登录'),
              ),
            ],
          );
        }
        ```
        
        要求：
        1. 保持代码结构不变
        2. 将中文字符串替换为l10n.keyName格式
        3. 生成合理的ARB键名
        4. 返回JSON格式，包含replaced_code和arb_entries"""
        
        print(f"问题: 国际化代码转换任务")
        
        return await self._send_request(question, max_tokens=800)
    
    async def test_json_parsing_task(self) -> Dict:
        """测试JSON解析任务 - 难度5"""
        print("\n📊 测试5: JSON格式化任务")
        
        question = """请分析以下配置文件，并生成一个优化的版本：
        
        {
          "api_settings": {
            "url": "https://api.openai.com/v1/chat/completions",
            "model": "gpt-3.5-turbo",
            "temperature": 0.1
          },
          "processing": {
            "concurrent": 5,
            "retry": 3
          }
        }
        
        要求：
        1. 添加缺失的重要配置项
        2. 优化配置结构
        3. 添加注释说明
        4. 确保JSON格式正确
        5. 返回完整的优化后的JSON配置"""
        
        print(f"问题: JSON配置优化任务")
        
        return await self._send_request(question, max_tokens=600)
    
    async def _send_request(self, question: str, max_tokens: int = 300) -> Dict:
        """发送API请求"""
        start_time = time.time()
        
        try:
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'model': 'deepseek-chat',
                'messages': [
                    {'role': 'system', 'content': 'You are a helpful assistant. Please provide accurate and detailed responses.'},
                    {'role': 'user', 'content': question}
                ],
                'max_tokens': max_tokens,
                'temperature': 0.1
            }
            
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=60)) as session:
                async with session.post(self.chat_url, headers=headers, json=payload) as response:
                    end_time = time.time()
                    response_time = end_time - start_time
                    
                    if response.status == 200:
                        result = await response.json()
                        content = result['choices'][0]['message']['content']
                        
                        # 分析响应质量
                        analysis = self._analyze_response(question, content)
                        
                        print(f"✅ 响应成功 (耗时: {response_time:.2f}秒)")
                        print(f"📝 回答: {content[:200]}{'...' if len(content) > 200 else ''}")
                        print(f"📊 质量分析: {analysis}")
                        
                        return {
                            'success': True,
                            'content': content,
                            'response_time': response_time,
                            'analysis': analysis,
                            'token_usage': result.get('usage', {})
                        }
                    else:
                        error_text = await response.text()
                        print(f"❌ 请求失败 (状态码: {response.status}): {error_text}")
                        return {
                            'success': False,
                            'error': f"HTTP {response.status}: {error_text}",
                            'response_time': response_time
                        }
                        
        except Exception as e:
            end_time = time.time()
            response_time = end_time - start_time
            print(f"❌ 请求异常: {e}")
            return {
                'success': False,
                'error': str(e),
                'response_time': response_time
            }
    
    def _analyze_response(self, question: str, response: str) -> Dict:
        """分析响应质量"""
        analysis = {
            'length': len(response),
            'has_code': '```' in response or 'def ' in response or 'function' in response,
            'has_json': '{' in response and '}' in response,
            'is_structured': '\n' in response and ('1.' in response or '-' in response),
            'completeness': 'complete' if len(response) > 50 else 'incomplete'
        }
        
        # 特定任务的质量检查
        if 'Dart' in question or 'Flutter' in question:
            analysis['dart_specific'] = 'l10n' in response and 'Text(' in response
        
        if 'JSON' in question:
            analysis['json_valid'] = self._is_valid_json_in_response(response)
        
        return analysis
    
    def _is_valid_json_in_response(self, response: str) -> bool:
        """检查响应中是否包含有效的JSON"""
        try:
            # 尝试提取JSON部分
            start = response.find('{')
            end = response.rfind('}') + 1
            if start != -1 and end > start:
                json_part = response[start:end]
                json.loads(json_part)
                return True
        except:
            pass
        return False
    
    async def run_all_tests(self) -> Dict:
        """运行所有测试"""
        print("🚀 开始DeepSeek API全面测试")
        print("=" * 50)
        
        # 首先测试连接
        if not await self.test_api_connection():
            return {'success': False, 'error': 'API连接失败'}
        
        # 运行所有测试
        tests = [
            ('简单问题', self.test_simple_question),
            ('代码生成', self.test_code_generation),
            ('复杂推理', self.test_complex_reasoning),
            ('国际化任务', self.test_i18n_specific_task),
            ('JSON任务', self.test_json_parsing_task)
        ]
        
        results = []
        total_time = 0
        
        for test_name, test_func in tests:
            try:
                result = await test_func()
                results.append({
                    'test_name': test_name,
                    'result': result
                })
                if result.get('success'):
                    total_time += result.get('response_time', 0)
            except Exception as e:
                print(f"❌ 测试 {test_name} 异常: {e}")
                results.append({
                    'test_name': test_name,
                    'result': {'success': False, 'error': str(e)}
                })
        
        # 生成测试报告
        successful_tests = sum(1 for r in results if r['result'].get('success'))
        total_tests = len(results)
        
        print("\n" + "=" * 50)
        print("📊 测试报告")
        print(f"✅ 成功: {successful_tests}/{total_tests}")
        print(f"⏱️  总耗时: {total_time:.2f}秒")
        print(f"📈 平均响应时间: {total_time/successful_tests if successful_tests > 0 else 0:.2f}秒")
        
        return {
            'success': successful_tests == total_tests,
            'results': results,
            'summary': {
                'total_tests': total_tests,
                'successful_tests': successful_tests,
                'total_time': total_time,
                'average_response_time': total_time/successful_tests if successful_tests > 0 else 0
            }
        }

async def main():
    """主函数"""
    # DeepSeek API配置
    api_key = "sk-8e3f9bc188494092ad4768d8f75fb762"
    base_url = "https://api.deepseek.com"
    
    # 创建测试器
    tester = DeepSeekAPITester(api_key, base_url)
    
    # 运行所有测试
    results = await tester.run_all_tests()
    
    # 保存测试结果
    with open('deepseek_test_results.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 测试结果已保存到: deepseek_test_results.json")
    
    return 0 if results['success'] else 1

if __name__ == '__main__':
    asyncio.run(main())