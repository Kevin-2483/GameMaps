# 本地测试 GitHub Pages 部署的 PowerShell 脚本

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

# 分析代码
Write-Host "🔍 分析代码..." -ForegroundColor Blue
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ 代码分析发现问题，但继续构建..." -ForegroundColor Yellow
}

# 运行测试
Write-Host "🧪 运行测试..." -ForegroundColor Blue
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ 测试发现问题，但继续构建..." -ForegroundColor Yellow
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
