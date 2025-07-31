#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ARB翻译工具使用示例

这个脚本演示如何使用arb_translator.py来翻译ARB文件
"""

import asyncio
import sys
from pathlib import Path
from arb_translator import ARBTranslator
import logging

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async def translate_app_en_arb():
    """翻译app_en.arb文件的示例"""
    
    # 文件路径
    input_file = "lib/l10n/app_en.arb"
    output_file = "lib/l10n/app_en_translated.arb"
    config_file = "scripts/python/i18n_config.json"
    
    # 检查文件是否存在
    if not Path(input_file).exists():
        logger.error(f"输入文件不存在: {input_file}")
        return False
    
    try:
        # 创建翻译器实例
        translator = ARBTranslator(config_file=config_file, max_concurrent=3)
        
        # 执行增量翻译（只翻译未处理的条目）
        logger.info(f"开始增量翻译 {input_file} -> {output_file}")
        await translator.translate_arb_file(input_file, output_file, migrate_existing=False)
        
        logger.info("翻译完成！")
        return True
        
    except Exception as e:
        logger.error(f"翻译失败: {e}")
        return False

async def migrate_existing_translations():
    """迁移现有翻译的示例"""
    
    # 文件路径
    input_file = "lib/l10n/app_en.arb"
    output_file = "lib/l10n/app_en_translated.arb"
    config_file = "scripts/python/i18n_config.json"
    
    # 检查文件是否存在
    if not Path(input_file).exists():
        logger.error(f"输入文件不存在: {input_file}")
        return False
    
    try:
        # 创建翻译器实例
        translator = ARBTranslator(config_file=config_file, max_concurrent=3)
        
        # 执行迁移（标记现有翻译为已处理）
        logger.info(f"开始迁移现有翻译 {input_file}")
        await translator.translate_arb_file(input_file, output_file, migrate_existing=True)
        
        logger.info("迁移完成！")
        return True
        
    except Exception as e:
        logger.error(f"迁移失败: {e}")
        return False

async def batch_translate_arb_files():
    """批量翻译多个ARB文件的示例"""
    
    # 定义要翻译的文件列表
    files_to_translate = [
        ("lib/l10n/app_en.arb", "lib/l10n/app_en_translated.arb"),
        # 可以添加更多文件
        # ("lib/l10n/other_en.arb", "lib/l10n/other_en_translated.arb"),
    ]
    
    config_file = "scripts/python/i18n_config.json"
    
    # 创建翻译器实例
    translator = ARBTranslator(config_file=config_file, max_concurrent=2)
    
    success_count = 0
    total_count = len(files_to_translate)
    
    for input_file, output_file in files_to_translate:
        if not Path(input_file).exists():
            logger.warning(f"跳过不存在的文件: {input_file}")
            continue
            
        try:
            logger.info(f"翻译文件 {input_file} -> {output_file}")
            await translator.translate_arb_file(input_file, output_file)
            success_count += 1
            logger.info(f"文件翻译完成: {output_file}")
            
        except Exception as e:
            logger.error(f"翻译文件失败 {input_file}: {e}")
    
    logger.info(f"批量翻译完成: {success_count}/{total_count} 个文件成功")
    return success_count == total_count

def main():
    """主函数"""
    print("ARB翻译工具使用示例")
    print("=" * 50)
    
    # 检查环境变量
    import os
    if not os.getenv('DEEPSEEK_API_KEY'):
        print("警告: 未设置DEEPSEEK_API_KEY环境变量")
        print("请先设置API密钥: set DEEPSEEK_API_KEY=your_api_key")
        return 1
    
    print("选择操作:")
    print("1. 增量翻译单个ARB文件 (app_en.arb)")
    print("2. 迁移现有翻译（标记为已处理）")
    print("3. 批量翻译ARB文件")
    print("4. 退出")
    
    choice = input("请输入选择 (1-4): ").strip()
    
    if choice == '1':
        print("\n开始增量翻译单个文件...")
        success = asyncio.run(translate_app_en_arb())
        return 0 if success else 1
        
    elif choice == '2':
        print("\n开始迁移现有翻译...")
        success = asyncio.run(migrate_existing_translations())
        return 0 if success else 1
        
    elif choice == '3':
        print("\n开始批量翻译...")
        success = asyncio.run(batch_translate_arb_files())
        return 0 if success else 1
        
    elif choice == '4':
        print("退出")
        return 0
        
    else:
        print("无效选择")
        return 1

if __name__ == '__main__':
    sys.exit(main())