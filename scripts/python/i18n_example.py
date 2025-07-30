#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
国际化处理工具使用示例

此脚本展示如何使用 I18nProcessor 来处理Flutter项目的国际化。
包含进度跟踪、文件标记、ARB文件组织等新功能。
"""

import os
import asyncio
from pathlib import Path
from i18n_processor import I18nProcessor

def check_dependencies():
    """检查必要的依赖包"""
    required_packages = ['aiohttp', 'aiofiles', 'PyYAML']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print("缺少以下依赖包:")
        for package in missing_packages:
            print(f"  - {package}")
        print("\n请运行以下命令安装:")
        print(f"pip install {' '.join(missing_packages)}")
        return False
    
    return True

async def example_basic_usage():
    """基本使用示例"""
    print("=== 基本使用示例 ===")
    
    # 配置参数
    yaml_dir = "e:/code/r6box/r6box/yaml"  # YAML文件目录
    api_url = "https://api.openai.com/v1/chat/completions"  # API地址
    api_key = os.getenv('OPENAI_API_KEY')  # 从环境变量获取API密钥
    max_concurrent = 3  # 最大并发数
    
    if not api_key:
        print("错误: 请设置环境变量 OPENAI_API_KEY")
        return
    
    # 创建处理器
    processor = I18nProcessor(
        yaml_dir=yaml_dir,
        api_url=api_url,
        api_key=api_key,
        max_concurrent=max_concurrent
    )
    
    print(f"开始处理YAML文件: {yaml_dir}")
    print(f"最大并发数: {max_concurrent}")
    print("-" * 50)
    
    # 运行处理
    await processor.run()
    
    print("-" * 50)
    print("处理完成!")

async def example_with_config():
    """使用配置文件的示例"""
    print("\n=== 使用配置文件示例 ===")
    
    yaml_dir = "e:/code/r6box/r6box/yaml"
    api_key = os.getenv('OPENAI_API_KEY')
    config_file = "e:/code/r6box/r6box/scripts/python/i18n_config.json"
    
    if not api_key:
        print("错误: 请设置环境变量 OPENAI_API_KEY")
        return
    
    # 使用配置文件创建处理器
    processor = I18nProcessor(
        yaml_dir=yaml_dir,
        api_url="https://api.openai.com/v1/chat/completions",
        api_key=api_key,
        max_concurrent=5,
        config_file=config_file
    )
    
    # 自定义ARB输出路径
    processor.config['output_settings']['arb_base_path'] = "lib/l10n/generated"
    
    print(f"使用配置文件: {config_file}")
    print(f"ARB输出路径: {processor.config['output_settings']['arb_base_path']}")
    print("-" * 50)
    
    await processor.run()
    
    print("-" * 50)
    print("配置文件处理完成!")

async def example_progress_management():
    """进度管理示例"""
    print("\n=== 进度管理示例 ===")
    
    yaml_dir = "e:/code/r6box/r6box/yaml"
    api_key = os.getenv('OPENAI_API_KEY')
    
    if not api_key:
        print("错误: 请设置环境变量 OPENAI_API_KEY")
        return
    
    processor = I18nProcessor(
        yaml_dir=yaml_dir,
        api_url="https://api.openai.com/v1/chat/completions",
        api_key=api_key,
        max_concurrent=3
    )
    
    # 检查进度文件
    progress_file = processor.progress_file
    if progress_file.exists():
        print(f"发现进度文件: {progress_file}")
        print(f"已处理文件数: {len(processor.processed_files)}")
        
        # 可以选择重置进度
        reset = input("是否重置进度并重新处理所有文件? (y/N): ")
        if reset.lower() == 'y':
            progress_file.unlink()
            processor.processed_files = {}
            print("已重置进度")
    else:
        print("未发现进度文件，将处理所有文件")
    
    print("-" * 50)
    await processor.run()
    print("-" * 50)
    print("进度管理示例完成!")

async def main():
    """主函数"""
    # 检查依赖
    if not check_dependencies():
        return
    
    print("国际化处理工具示例")
    print("=" * 60)
    
    # 运行不同的示例
    try:
        # 基本使用
        await example_basic_usage()
        
        # 使用配置文件
        # await example_with_config()
        
        # 进度管理
        # await example_progress_management()
        
    except KeyboardInterrupt:
        print("\n用户中断处理")
    except Exception as e:
        print(f"\n处理过程中发生错误: {e}")

if __name__ == '__main__':
    asyncio.run(main())