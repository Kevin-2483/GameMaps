# 简化的本地构建脚本 - 只构建，不测试

Write-Host "🚀 开始构建 Flutter Web 应用..." -ForegroundColor Green

# 检查 Flutter 是否安装
try {
    $flutterVersion = flutter --version 2>$null
    if (-not $flutterVersion) {
        throw "Flutter not found"
    }
}
catch {
    Write-Host "❌ 错误: Flutter 未安装或不在 PATH 中" -ForegroundColor Red
    exit 1
}

# 获取依赖
Write-Host "📦 获取依赖..." -ForegroundColor Blue
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 获取依赖失败" -ForegroundColor Red
    exit 1
}

# 构建 Web 应用
Write-Host "🏗️ 构建 Web 应用..." -ForegroundColor Blue
flutter build web --release --base-href="/r6box/"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 构建失败" -ForegroundColor Red
    exit 1
}

# 添加 .nojekyll 文件
New-Item -Path "build/web/.nojekyll" -ItemType File -Force | Out-Null

Write-Host "✅ 构建完成！" -ForegroundColor Green
Write-Host "📂 构建文件位于: build/web" -ForegroundColor Yellow
Write-Host ""
Write-Host "🌐 要在本地测试，请运行:" -ForegroundColor Cyan
Write-Host "   cd build/web" -ForegroundColor White
Write-Host "   python -m http.server 8000" -ForegroundColor White
Write-Host "   然后访问: http://localhost:8000" -ForegroundColor White
Write-Host ""
Write-Host "📋 部署到 GitHub Pages 时，应用将可通过以下地址访问:" -ForegroundColor Cyan
Write-Host "   https://[你的用户名].github.io/r6box/" -ForegroundColor White
Write-Host ""
Write-Host "💡 提示: 代码分析和测试请在本地运行:" -ForegroundColor Yellow
Write-Host "   flutter analyze" -ForegroundColor White
Write-Host "   flutter test" -ForegroundColor White
