# 测试资源包说明文档

## 概述
这是一个用于测试外部资源上传功能的示例资源包。

## 包含文件
- images/logo.png - 应用程序Logo
- images/background.jpg - 主背景图片
- configs/settings.json - 应用配置文件
- data/operators.json - 彩虹六号干员数据
- sounds/notification.mp3 - 通知音效
- docs/readme.txt - 本说明文档

## 安装说明
1. 将此资源包压缩为ZIP文件
2. 在R6Box应用中选择"外部资源管理"
3. 上传ZIP文件
4. 预览文件映射并根据需要调整目标路径
5. 确认安装

## 文件映射
根据metadata.json中的配置，文件将被复制到以下位置：
- Logo图片 -> fs/assets/images/logo.png
- 背景图片 -> fs/assets/images/backgrounds/main_bg.jpg
- 应用配置 -> fs/configs/app_settings.json
- 干员数据 -> fs/data/r6_operators.json
- 通知音效 -> fs/assets/sounds/notification.mp3
- 说明文档 -> fs/docs/readme.txt

## 注意事项
- 确保目标路径符合应用的安全要求
- 安装前会检查文件冲突
- 可以在预览界面手动调整目标路径

## 版本信息
- 版本: 1.0.0
- 创建日期: 2024-01-15
- 作者: 测试用户

---
此文档由R6Box外部资源测试包生成