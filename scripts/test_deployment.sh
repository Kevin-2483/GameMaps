#!/bin/bash

# 本地测试 GitHub Pages 部署的脚本

echo "🚀 开始构建 Flutter Web 应用..."

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: Flutter 未安装或不在 PATH 中"
    exit 1
fi

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 分析代码
echo "🔍 分析代码..."
flutter analyze --no-fatal-infos
if [ $? -ne 0 ]; then
    echo "⚠️ 代码分析发现问题，但继续构建..."
fi

# 运行测试
echo "🧪 运行测试..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ 测试失败"
    exit 1
fi

# 构建 Web 应用
echo "🏗️ 构建 Web 应用..."
flutter build web --release --base-href="/r6box/"

# 添加 .nojekyll 文件
touch build/web/.nojekyll

echo "✅ 构建完成！"
echo "📂 构建文件位于: build/web"
echo ""
echo "🌐 要在本地测试，请运行:"
echo "   cd build/web"
echo "   python -m http.server 8000"
echo "   然后访问: http://localhost:8000"
echo ""
echo "📋 部署到 GitHub Pages 时，应用将可通过以下地址访问:"
echo "   https://[你的用户名].github.io/r6box/"
