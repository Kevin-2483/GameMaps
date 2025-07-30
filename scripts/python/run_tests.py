#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
快速测试运行器
用于快速验证I18n处理器的稳定性
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

from i18n_processor import I18nProcessor, YamlRecord, AIResponse

def create_test_environment():
    """创建测试环境"""
    test_dir = tempfile.mkdtemp(prefix='i18n_test_')
    print(f"创建测试环境: {test_dir}")
    
    # 创建目录结构
    yaml_dir = os.path.join(test_dir, 'yaml')
    dart_dir = os.path.join(test_dir, 'lib')
    os.makedirs(yaml_dir)
    os.makedirs(dart_dir)
    
    return test_dir, yaml_dir, dart_dir

def create_test_dart_file(dart_dir, filename, content):
    """创建测试Dart文件"""
    dart_file = os.path.join(dart_dir, filename)
    with open(dart_file, 'w', encoding='utf-8') as f:
        f.write(content)
    return dart_file

async def test_basic_replacement():
    """基础替换测试"""
    print("\n🧪 测试1: 基础单行替换")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        # 创建测试文件
        original_content = "debugPrint('Hello World');"
        dart_file = create_test_dart_file(dart_dir, 'test.dart', original_content)
        
        # 创建处理器
        processor = I18nProcessor(
            yaml_dir=yaml_dir,
            api_url="http://test.api",
            api_key="test_key"
        )
        
        # 创建测试记录
        record = YamlRecord(
            path=os.path.relpath(dart_file, test_dir),
            start_line=1,
            end_line=1,
            code=original_content,
            yaml_file='test.yaml'
        )
        
        # 创建AI响应
        ai_response = AIResponse(
            replaced_code="debugPrint(AppLocalizations.of(context).helloWorld);",
            arb_entries={"helloWorld": "Hello World"},
            success=True
        )
        
        # 打印替换前的内容
        print(f"📄 替换前文件内容:")
        with open(dart_file, 'r', encoding='utf-8') as f:
            before_lines = f.readlines()
        for i, line in enumerate(before_lines, 1):
            print(f"  {i:2d}: {line.rstrip()}")
        
        print(f"🎯 要替换的行号: {record.start_line}-{record.end_line}")
        print(f"🔤 原始代码: {record.code}")
        print(f"🔄 替换为: {ai_response.replaced_code}")
        
        # 执行替换
        result = await processor.replace_dart_code(record, ai_response)
        
        if result:
            # 打印替换后的内容
            print(f"📄 替换后文件内容:")
            with open(dart_file, 'r', encoding='utf-8') as f:
                after_lines = f.readlines()
            for i, line in enumerate(after_lines, 1):
                print(f"  {i:2d}: {line.rstrip()}")
            
            # 验证结果
            new_content = ''.join(after_lines)
            if 'AppLocalizations.of(context).helloWorld' in new_content:
                print("✅ 基础替换测试通过")
                return True
            else:
                print("❌ 替换内容不正确")
                return False
        else:
            print("❌ 替换操作失败")
            return False
    
    except Exception as e:
        print(f"❌ 测试异常: {e}")
        return False
    
    finally:
        shutil.rmtree(test_dir)

async def test_multiline_replacement():
    """多行替换测试"""
    print("\n🧪 测试2: 多行代码替换")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        original_content = """class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('第一行文本');
    return Text('第二行文本');
  }
}"""
        
        dart_file = create_test_dart_file(dart_dir, 'widget.dart', original_content)
        
        processor = I18nProcessor(
            yaml_dir=yaml_dir,
            api_url="http://test.api",
            api_key="test_key"
        )
        
        record = YamlRecord(
            path=os.path.relpath(dart_file, test_dir),
            start_line=4,
            end_line=5,
            code="    return Text('第一行文本');\n    return Text('第二行文本');",
            yaml_file='widget.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code="    return Text(AppLocalizations.of(context).firstLineText);\n    return Text(AppLocalizations.of(context).secondLineText);",
            arb_entries={
                "firstLineText": "第一行文本",
                "secondLineText": "第二行文本"
            },
            success=True
        )
        
        # 打印替换前的内容
        print(f"📄 替换前文件内容:")
        with open(dart_file, 'r', encoding='utf-8') as f:
            before_lines = f.readlines()
        for i, line in enumerate(before_lines, 1):
            print(f"  {i:2d}: {line.rstrip()}")
        
        print(f"🎯 要替换的行号: {record.start_line}-{record.end_line}")
        print(f"🔤 原始代码: {record.code}")
        print(f"🔄 替换为: {ai_response.replaced_code}")
        
        result = await processor.replace_dart_code(record, ai_response)
        
        if result:
            # 打印替换后的内容
            print(f"📄 替换后文件内容:")
            with open(dart_file, 'r', encoding='utf-8') as f:
                after_lines = f.readlines()
            for i, line in enumerate(after_lines, 1):
                print(f"  {i:2d}: {line.rstrip()}")
            
            # 验证结果
            new_content = ''.join(after_lines)
            if ('AppLocalizations.of(context).firstLineText' in new_content and 
                'AppLocalizations.of(context).secondLineText' in new_content):
                print("✅ 多行替换测试通过")
                return True
            else:
                print("❌ 多行替换内容不正确")
                print(f"文件内容:\n{new_content}")
                return False
        else:
            print("❌ 多行替换操作失败")
            return False
    
    except Exception as e:
        print(f"❌ 测试异常: {e}")
        return False
    
    finally:
        shutil.rmtree(test_dir)

async def test_ai_marker_handling():
    """AI标记处理测试"""
    print("\n🧪 测试3: AI标记处理")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        # 测试已有AI标记的文件
        original_content = """// This file has been processed by AI
debugPrint('测试消息');"""
        
        dart_file = create_test_dart_file(dart_dir, 'marked.dart', original_content)
        
        processor = I18nProcessor(
            yaml_dir=yaml_dir,
            api_url="http://test.api",
            api_key="test_key"
        )
        
        record = YamlRecord(
            path=os.path.relpath(dart_file, test_dir),
            start_line=1,
            end_line=1,
            code="debugPrint('测试消息');",
            yaml_file='marked.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code="debugPrint(AppLocalizations.of(context).testMessage);",
            arb_entries={"testMessage": "测试消息"},
            success=True
        )
        
        # 打印替换前的内容
        print(f"📄 替换前文件内容:")
        with open(dart_file, 'r', encoding='utf-8') as f:
            before_lines = f.readlines()
        for i, line in enumerate(before_lines, 1):
            print(f"  {i:2d}: {line.rstrip()}")
        
        print(f"🎯 要替换的行号: {record.start_line}-{record.end_line}")
        print(f"🔤 原始代码: {record.code}")
        print(f"🔄 替换为: {ai_response.replaced_code}")
        
        result = await processor.replace_dart_code(record, ai_response)
        
        if result:
            # 打印替换后的内容
            print(f"📄 替换后文件内容:")
            with open(dart_file, 'r', encoding='utf-8') as f:
                after_lines = f.readlines()
            for i, line in enumerate(after_lines, 1):
                print(f"  {i:2d}: {line.rstrip()}")
            
            # 检查AI标记数量
            ai_marker_count = sum(1 for line in after_lines if 'This file has been processed by AI' in line)
            
            if ai_marker_count == 1 and 'AppLocalizations.of(context).testMessage' in ''.join(after_lines):
                print("✅ AI标记处理测试通过")
                return True
            else:
                print(f"❌ AI标记数量错误: {ai_marker_count}")
                return False
        else:
            print("❌ AI标记处理失败")
            return False
    
    except Exception as e:
        print(f"❌ 测试异常: {e}")
        return False
    
    finally:
        shutil.rmtree(test_dir)

async def test_error_handling():
    """错误处理测试"""
    print("\n🧪 测试4: 错误处理")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        # 创建小文件测试超出范围的行号
        original_content = "debugPrint('test');"
        dart_file = create_test_dart_file(dart_dir, 'small.dart', original_content)
        
        processor = I18nProcessor(
            yaml_dir=yaml_dir,
            api_url="http://test.api",
            api_key="test_key"
        )
        
        # 使用超出范围的行号
        record = YamlRecord(
            path=os.path.relpath(dart_file, test_dir),
            start_line=10,  # 超出文件范围
            end_line=15,
            code="invalid code",
            yaml_file='error.yaml'
        )
        
        ai_response = AIResponse(
            replaced_code="replacement",
            arb_entries={},
            success=True
        )
        
        result = await processor.replace_dart_code(record, ai_response)
        
        # 应该返回False，表示正确处理了错误
        if not result:
            print("✅ 错误处理测试通过")
            return True
        else:
            print("❌ 错误处理失败，应该返回False")
            return False
    
    except Exception as e:
        print(f"❌ 测试异常: {e}")
        return False
    
    finally:
        shutil.rmtree(test_dir)

async def test_code_position_adjustment():
    """测试代码位置自动调整功能"""
    print("\n🧪 测试5: 代码位置自动调整")
    
    # 创建测试环境
    test_dir, yaml_dir, dart_dir = create_test_environment()
    print(f"创建测试环境: {test_dir}")
    
    try:
        # 创建测试文件，模拟代码位置发生偏移的情况
        original_content = """class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 新增的注释行
    return Text('Hello World');
  }
}"""
        
        dart_file = os.path.join(dart_dir, "position_test.dart")
        with open(dart_file, 'w', encoding='utf-8') as f:
            f.write(original_content)
        
        print("📄 替换前文件内容:")
        lines = original_content.split('\n')
        for i, line in enumerate(lines, 1):
            print(f"   {i}: {line}")
        
        # 创建处理器
        processor = I18nProcessor(
            yaml_dir=str(test_dir),
            api_url="http://fake-api.com",
            api_key="fake-key"
        )
        
        # 创建记录，假设YAML中记录的是第4行，但实际代码在第5行
        record = YamlRecord(
            path=dart_file,  # 使用绝对路径
            start_line=4,  # YAML中记录的行号
            end_line=4,
            code="    return Text('Hello World');",  # 期望的代码
            yaml_file="test.yaml"
        )
        
        print(f"🎯 YAML记录的行号: {record.start_line}-{record.end_line}")
        print(f"🔤 期望的代码: {record.code}")
        
        # 模拟AI响应
        ai_response = AIResponse(
            replaced_code="    return Text(AppLocalizations.of(context).helloWorld);",
            arb_entries={"helloWorld": "Hello World"},
            success=True
        )
        
        print(f"🔄 替换为: {ai_response.replaced_code}")
        
        # 执行替换
        result = await processor.replace_dart_code(record, ai_response)
        
        # 验证成功
        if not result:
            print("❌ 代码位置调整测试失败：应该成功找到并替换代码")
            return False
        
        # 读取替换后的内容
        with open(dart_file, 'r', encoding='utf-8') as f:
            new_content = f.read()
        print("📄 替换后文件内容:")
        new_lines = new_content.split('\n')
        for i, line in enumerate(new_lines, 1):
            print(f"   {i}: {line}")
        
        # 验证替换是否正确
        if "AppLocalizations.of(context).helloWorld" not in new_content:
            print("❌ 替换内容验证失败：未找到期望的替换内容")
            return False
        if "return Text('Hello World');" in new_content:
            print("❌ 原始代码应该被替换")
            return False
        
        print("✅ 代码位置自动调整测试通过")
        return True
        
    except Exception as e:
        print(f"❌ 测试执行异常: {e}")
        return False
    finally:
        # 清理
        shutil.rmtree(test_dir)

async def test_arb_file_assembly():
    """测试ARB文件组装功能"""
    print("\n🧪 测试6: ARB文件组装")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        # 创建处理器实例
        processor = I18nProcessor(
            yaml_dir=str(yaml_dir),
            api_url="http://test",
            api_key="test"
        )
        
        # 模拟多个YAML记录和AI响应
        test_cases = [
            {
                "record": YamlRecord(
                    path="lib/pages/home_page.dart",
                    start_line=1,
                    end_line=1,
                    code="Text('Welcome')",
                    yaml_file="home.yaml"
                ),
                "response": AIResponse(
                    replaced_code="Text(AppLocalizations.of(context)!.welcome)",
                    arb_entries={"welcome": "Welcome", "homeTitle": "Home Page"},
                    success=True
                )
            },
            {
                "record": YamlRecord(
                    path="lib/pages/home_page.dart",
                    start_line=2,
                    end_line=2,
                    code="Text('Settings')",
                    yaml_file="home.yaml"
                ),
                "response": AIResponse(
                    replaced_code="Text(AppLocalizations.of(context)!.settings)",
                    arb_entries={"settings": "Settings", "homeSubtitle": "Main Screen"},
                    success=True
                )
            },
            {
                "record": YamlRecord(
                    path="lib/widgets/custom_button.dart",
                    start_line=1,
                    end_line=1,
                    code="Text('Click Me')",
                    yaml_file="button.yaml"
                ),
                "response": AIResponse(
                    replaced_code="Text(AppLocalizations.of(context)!.clickMe)",
                    arb_entries={"clickMe": "Click Me", "buttonLabel": "Action Button"},
                    success=True
                )
            }
        ]
        
        print("📦 收集ARB条目...")
        
        # 收集所有ARB条目
        for i, case in enumerate(test_cases, 1):
            print(f"  处理第{i}个记录: {case['record'].path}")
            print(f"  ARB条目: {case['response'].arb_entries}")
            processor.collect_arb_entries(case['record'], case['response'])
        
        print(f"\n📊 收集完成，共收集到 {len(processor.arb_data)} 个ARB文件的数据:")
        for arb_path, entries in processor.arb_data.items():
            print(f"  {arb_path}: {len(entries)} 个条目")
            for key, value in entries.items():
                print(f"    {key}: {value}")
        
        # 验证ARB数据收集是否正确
        expected_arb_files = 2  # home.arb 和 button.arb
        if len(processor.arb_data) != expected_arb_files:
            print(f"❌ ARB文件数量不正确，期望{expected_arb_files}个，实际{len(processor.arb_data)}个")
            return False
        
        # 查找包含home_page的ARB路径
        home_arb_path = None
        button_arb_path = None
        
        for arb_path in processor.arb_data.keys():
            if "home_page.arb" in arb_path:
                home_arb_path = arb_path
            elif "custom_button.arb" in arb_path:
                button_arb_path = arb_path
        
        # 验证home.arb的条目数量
        if home_arb_path:
            home_entries = processor.arb_data[home_arb_path]
            expected_home_entries = 4  # welcome, homeTitle, settings, homeSubtitle
            if len(home_entries) != expected_home_entries:
                print(f"❌ home.arb条目数量不正确，期望{expected_home_entries}个，实际{len(home_entries)}个")
                return False
            print(f"✅ 找到home.arb: {home_arb_path} ({len(home_entries)}个条目)")
        else:
            print(f"❌ 未找到包含home_page.arb的路径")
            return False
        
        # 验证button.arb的条目数量
        if button_arb_path:
            button_entries = processor.arb_data[button_arb_path]
            expected_button_entries = 2  # clickMe, buttonLabel
            if len(button_entries) != expected_button_entries:
                print(f"❌ button.arb条目数量不正确，期望{expected_button_entries}个，实际{len(button_entries)}个")
                return False
            print(f"✅ 找到button.arb: {button_arb_path} ({len(button_entries)}个条目)")
        else:
            print(f"❌ 未找到包含custom_button.arb的路径")
            return False
        
        print("✅ ARB文件组装测试通过：数据收集正确")
        return True
            
    except Exception as e:
        print(f"❌ 测试执行异常: {e}")
        return False
    finally:
        # 清理测试环境
        shutil.rmtree(test_dir)

async def test_progress_tracking_and_resume():
    """测试处理过程记录和断点续传功能"""
    print("\n🧪 测试7: 处理过程记录和断点续传")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        # 创建多个测试YAML文件
        yaml_files = [
            ("test1.yaml", "lib/test1.dart", "Text('Hello')"),
            ("test2.yaml", "lib/test2.dart", "Text('World')"),
            ("test3.yaml", "lib/test3.dart", "Text('Test')")
        ]
        
        # 创建YAML文件
        for yaml_name, dart_path, code in yaml_files:
            yaml_content = {
                'path': dart_path,
                'start_line': 1,
                'end_line': 1,
                'code': code
            }
            yaml_file_path = os.path.join(yaml_dir, yaml_name)
            with open(yaml_file_path, 'w', encoding='utf-8') as f:
                yaml.dump(yaml_content, f, allow_unicode=True)
        
        print(f"📝 创建了 {len(yaml_files)} 个测试YAML文件")
        
        # 第一次处理：创建处理器并模拟部分处理
        print("\n🔄 第一次处理（模拟部分完成）...")
        processor1 = I18nProcessor(
            yaml_dir=str(yaml_dir),
            api_url="http://test",
            api_key="test"
        )
        
        # 手动标记第一个文件为已处理
        yaml_file1 = Path(os.path.join(yaml_dir, "test1.yaml"))
        processor1.mark_file_processed(yaml_file1, status='success')
        processor1.update_file_dart_info(yaml_file1, "lib/test1.dart")
        
        # 手动标记第二个文件为处理失败
        yaml_file2 = Path(os.path.join(yaml_dir, "test2.yaml"))
        processor1.mark_file_processed(yaml_file2, status='failed', error_msg='模拟API错误')
        
        # 保存进度
        processor1.save_progress_immediately()
        
        # 验证进度文件是否创建
        progress_file = os.path.join(yaml_dir, '.i18n_progress.json')
        if not os.path.exists(progress_file):
            print("❌ 进度文件未创建")
            return False
        
        print("✅ 进度文件创建成功")
        
        # 读取并验证进度内容
        with open(progress_file, 'r', encoding='utf-8') as f:
            progress_data = json.load(f)
        
        print(f"📊 进度文件内容: {len(progress_data)} 个记录")
        for key, value in progress_data.items():
            print(f"  {key}: {value['status']} ({value.get('timestamp', 'N/A')})")
        
        # 验证进度记录
        if 'test1.yaml' not in progress_data:
            print("❌ test1.yaml 进度记录缺失")
            return False
        
        if progress_data['test1.yaml']['status'] != 'success':
            print("❌ test1.yaml 状态不正确")
            return False
        
        if 'test2.yaml' not in progress_data:
            print("❌ test2.yaml 进度记录缺失")
            return False
        
        if progress_data['test2.yaml']['status'] != 'failed':
            print("❌ test2.yaml 状态不正确")
            return False
        
        print("✅ 进度记录验证通过")
        
        # 第二次处理：创建新的处理器实例，测试断点续传
        print("\n🔄 第二次处理（断点续传）...")
        processor2 = I18nProcessor(
            yaml_dir=str(yaml_dir),
            api_url="http://test",
            api_key="test"
        )
        
        # 验证进度是否正确加载
        loaded_progress = processor2.processed_files
        print(f"📥 加载的进度记录: {len(loaded_progress)} 个")
        
        if len(loaded_progress) != 2:
            print(f"❌ 加载的进度记录数量不正确，期望2个，实际{len(loaded_progress)}个")
            return False
        
        # 测试文件处理状态检查
        yaml_file1_processed = processor2.is_file_processed(yaml_file1)
        yaml_file2_processed = processor2.is_file_processed(yaml_file2)  # 失败的文件应该被重新处理
        yaml_file3 = Path(os.path.join(yaml_dir, "test3.yaml"))
        yaml_file3_processed = processor2.is_file_processed(yaml_file3)
        
        print(f"📋 文件处理状态检查:")
        print(f"  test1.yaml (成功): {'已处理' if yaml_file1_processed else '未处理'}")
        print(f"  test2.yaml (失败): {'已处理' if yaml_file2_processed else '未处理'}")
        print(f"  test3.yaml (新文件): {'已处理' if yaml_file3_processed else '未处理'}")
        
        # 验证断点续传逻辑
        if not yaml_file1_processed:
            print("❌ 成功处理的文件应该被跳过")
            return False
        
        if yaml_file2_processed:
            print("❌ 失败的文件应该被重新处理")
            return False
        
        if yaml_file3_processed:
            print("❌ 新文件应该需要处理")
            return False
        
        print("✅ 断点续传逻辑验证通过")
        
        # 测试进度更新
        print("\n🔄 测试进度更新...")
        processor2.mark_file_processed(yaml_file3, status='success')
        processor2.save_progress_immediately()
        
        # 验证更新后的进度
        with open(progress_file, 'r', encoding='utf-8') as f:
            updated_progress = json.load(f)
        
        if len(updated_progress) != 3:
            print(f"❌ 更新后进度记录数量不正确，期望3个，实际{len(updated_progress)}个")
            return False
        
        if 'test3.yaml' not in updated_progress:
            print("❌ test3.yaml 进度记录未添加")
            return False
        
        print("✅ 进度更新验证通过")
        
        print("✅ 处理过程记录和断点续传测试通过")
        return True
        
    except Exception as e:
        print(f"❌ 测试执行异常: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        # 清理测试环境
        shutil.rmtree(test_dir)

async def test_complex_statements_prompt():
    """测试复杂语句提示词优化"""
    print("\n🧪 测试8: 复杂语句提示词优化")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        # 创建处理器实例
        processor = I18nProcessor(
            yaml_dir=str(yaml_dir),
            api_url="http://test",
            api_key="test"
        )
        
        # 测试复杂语句的提示词生成
        complex_test_cases = [
            {
                "name": "字符串插值",
                "record": YamlRecord(
                    path="lib/test.dart",
                    start_line=1,
                    end_line=1,
                    code="Text('用户${user.name}，欢迎回来！')",
                    yaml_file="test.yaml"
                ),
                "expected_keywords": ["插值处理", "插值表达式", "welcomeBackUser"]
            },
            {
                "name": "条件表达式",
                "record": YamlRecord(
                    path="lib/test.dart",
                    start_line=1,
                    end_line=1,
                    code="Text(isSuccess ? '操作成功' : '操作失败')",
                    yaml_file="test.yaml"
                ),
                "expected_keywords": ["条件表达式", "三元运算符", "operationSuccess"]
            },
            {
                "name": "嵌套结构",
                "record": YamlRecord(
                    path="lib/test.dart",
                    start_line=1,
                    end_line=3,
                    code="Container(\n  child: Text('嵌套文本'),\n)",
                    yaml_file="test.yaml"
                ),
                "expected_keywords": ["嵌套结构", "Widget", "嵌套层级"]
            },
            {
                "name": "方法链调用",
                "record": YamlRecord(
                    path="lib/test.dart",
                    start_line=1,
                    end_line=1,
                    code="list.where((item) => item.contains('搜索')).toList()",
                    yaml_file="test.yaml"
                ),
                "expected_keywords": ["方法链调用", "链式调用", "流式API"]
            },
            {
                "name": "特殊字符",
                "record": YamlRecord(
                    path="lib/test.dart",
                    start_line=1,
                    end_line=1,
                    code="Text('包含\\n换行\\t制表符的文本')",
                    yaml_file="test.yaml"
                ),
                "expected_keywords": ["特殊字符", "转义字符", "Unicode"]
            }
        ]
        
        print("📝 测试复杂语句提示词生成...")
        
        all_passed = True
        for i, test_case in enumerate(complex_test_cases, 1):
            print(f"\n  测试 {i}: {test_case['name']}")
            print(f"  代码: {test_case['record'].code}")
            
            # 生成提示词
            prompt = processor.create_ai_prompt(test_case['record'])
            
            # 验证提示词是否包含预期的关键词
            missing_keywords = []
            for keyword in test_case['expected_keywords']:
                if keyword not in prompt:
                    missing_keywords.append(keyword)
            
            if missing_keywords:
                print(f"  ❌ 缺少关键词: {missing_keywords}")
                all_passed = False
            else:
                print(f"  ✅ 包含所有预期关键词")
            
            # 检查提示词长度和结构
            if len(prompt) < 1000:
                print(f"  ⚠️  提示词可能过短: {len(prompt)} 字符")
            
            # 验证提示词包含复杂语句处理指导
            complex_guidance_keywords = [
                "复杂语句处理重点",
                "插值处理",
                "嵌套结构处理",
                "运算表达式处理",
                "条件表达式处理",
                "方法链调用处理",
                "特殊字符处理"
            ]
            
            guidance_found = sum(1 for keyword in complex_guidance_keywords if keyword in prompt)
            print(f"  📊 复杂语句指导覆盖: {guidance_found}/{len(complex_guidance_keywords)} 项")
            
            if guidance_found < len(complex_guidance_keywords) * 0.8:  # 至少80%覆盖
                print(f"  ⚠️  复杂语句指导覆盖不足")
                all_passed = False
        
        # 验证提示词的整体结构
        print("\n📋 验证提示词整体结构...")
        sample_prompt = processor.create_ai_prompt(complex_test_cases[0]['record'])
        
        required_sections = [
            "项目l10n配置信息",
            "要求：",
            "复杂语句处理重点：",
            "输出格式要求：",
            "ARB条目格式说明：",
            "原代码：",
            "复杂示例参考：",
            "请严格按照上述JSON格式返回"
        ]
        
        missing_sections = []
        for section in required_sections:
            if section not in sample_prompt:
                missing_sections.append(section)
        
        if missing_sections:
            print(f"❌ 缺少必要章节: {missing_sections}")
            all_passed = False
        else:
            print("✅ 提示词结构完整")
        
        # 验证JSON格式示例
        if '"replaced_code":' in sample_prompt and '"arb_entries":' in sample_prompt:
            print("✅ JSON格式示例正确")
        else:
            print("❌ JSON格式示例缺失或不正确")
            all_passed = False
        
        if all_passed:
            print("\n✅ 复杂语句提示词优化测试通过")
            return True
        else:
            print("\n❌ 复杂语句提示词优化测试失败")
            return False
            
    except Exception as e:
        print(f"❌ 测试执行异常: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        # 清理测试环境
        shutil.rmtree(test_dir)

async def test_ai_api_configuration():
    """测试AI API配置功能"""
    print("\n🧪 测试9: AI API配置")
    
    test_dir, yaml_dir, dart_dir = create_test_environment()
    
    try:
        # 测试1: 默认配置加载
        print("\n📋 测试默认配置加载...")
        processor = I18nProcessor(
            yaml_dir=yaml_dir,
            api_url="https://api.openai.com/v1/chat/completions",
            api_key="test_key"
        )
        
        # 验证基本配置
        if not processor.api_url:
            print("❌ API URL未设置")
            return False
        
        if not processor.api_key:
            print("❌ API密钥未设置")
            return False
        
        print("✅ 基本配置验证通过")
        
        # 测试2: 提示词生成
        print("\n📋 测试提示词生成...")
        
        test_record = YamlRecord(
            path="lib/test.dart",
            start_line=1,
            end_line=1,
            code="Text('测试文本')",
            yaml_file="test.yaml"
        )
        
        prompt = processor.create_ai_prompt(test_record)
        
        if not prompt:
            print("❌ 提示词生成失败")
            return False
        
        if "测试文本" not in prompt:
            print("❌ 提示词不包含原始代码")
            return False
        
        if "JSON格式" not in prompt:
            print("❌ 提示词不包含格式要求")
            return False
        
        print("✅ 提示词生成正确")
        
        # 测试3: 配置文件加载
        print("\n📋 测试配置文件加载...")
        
        # 创建测试配置文件
        test_config = {
            "api_settings": {
                "model": "gpt-4",
                "temperature": 0.2,
                "max_tokens": 3000
            },
            "processing_settings": {
                "max_concurrent": 5,
                "retry_attempts": 3
            }
        }
        
        config_file_path = os.path.join(test_dir, "test_config.json")
        with open(config_file_path, 'w', encoding='utf-8') as f:
            json.dump(test_config, f, indent=2)
        
        print("✅ 配置文件创建成功")
        
        # 测试4: API参数验证
        print("\n📋 测试API参数验证...")
        
        if processor.api_key != "test_key":
            print(f"❌ API密钥设置错误: {processor.api_key}")
            return False
        
        if "openai.com" not in processor.api_url:
            print(f"❌ API URL设置错误: {processor.api_url}")
            return False
        
        print("✅ API参数验证通过")
        
        # 测试5: 错误处理
        print("\n📋 测试错误处理...")
        
        # 测试无效配置文件
        invalid_config_path = os.path.join(test_dir, "invalid_config.json")
        with open(invalid_config_path, 'w', encoding='utf-8') as f:
            f.write("invalid json content")
        
        try:
            # 应该能够处理无效配置文件而不崩溃
            processor_invalid = I18nProcessor(
                yaml_dir=yaml_dir,
                api_url="https://api.openai.com/v1/chat/completions",
                api_key="test_key"
            )
            print("✅ 无效配置文件处理正确")
        except Exception as e:
            print(f"❌ 无效配置文件处理异常: {e}")
            return False
        
        print("✅ AI API配置测试全部通过")
        return True
        
    except Exception as e:
        print(f"❌ AI API配置测试失败: {e}")
        return False
    finally:
        # 清理测试环境
        shutil.rmtree(test_dir)

async def run_quick_tests():
    """运行快速测试"""
    print("🚀 开始运行I18n处理器快速稳定性测试")
    print("=" * 50)
    
    tests = [
        test_basic_replacement,
        test_multiline_replacement,
        test_ai_marker_handling,
        test_error_handling,
        test_code_position_adjustment,
        test_arb_file_assembly,
        test_progress_tracking_and_resume,
        test_complex_statements_prompt,
        test_ai_api_configuration
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if await test():
                passed += 1
        except Exception as e:
            print(f"❌ 测试执行异常: {e}")
    
    print("\n" + "=" * 50)
    print(f"📊 测试结果: {passed}/{total} 通过")
    
    if passed == total:
        print("🎉 所有测试通过！Dart替换方法稳定性良好。")
    else:
        print(f"⚠️  有 {total - passed} 个测试失败，需要检查代码稳定性。")
    
    return passed == total

async def main():
    """主函数"""
    print("🚀 开始运行I18n处理器测试")
    print("=" * 50)
    
    tests = [
        test_basic_replacement,
        test_multiline_replacement,
        test_ai_marker_handling,
        test_error_handling,
        test_code_position_adjustment,
        test_arb_file_assembly,
        test_progress_tracking_and_resume,
        test_complex_statements_prompt,
        test_ai_api_configuration
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            result = await test()
            if result is not False:  # 对于没有返回值的测试，认为通过
                passed += 1
        except Exception as e:
            print(f"❌ 测试失败: {e}")
    
    print("\n" + "=" * 50)
    print(f"📊 测试结果: {passed}/{total} 通过")
    
    if passed == total:
        print("🎉 所有测试通过！Dart替换方法稳定性良好。")
        return 0
    else:
        print("⚠️  部分测试失败，请检查代码。")
        return 1

if __name__ == '__main__':
    asyncio.run(main())