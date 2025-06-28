# Windows 專用構建腳本，使用 pubspec.back.yaml
# 用法：在 PowerShell 執行本腳本

Write-Host "🚀 開始 Windows 構建..." -ForegroundColor Green

# 檢查 Flutter 是否安裝
try {
    $flutterVersion = flutter --version 2>$null
    if (-not $flutterVersion) {
        throw "Flutter not found"
    }
}
catch {
    Write-Host "❌ 錯誤: Flutter 未安裝或不在 PATH 中" -ForegroundColor Red
    exit 1
}

# 準備 pubspec.yaml
Write-Host "📄 準備 pubspec.yaml..." -ForegroundColor Blue
Copy-Item -Path "pubspec.back.yaml" -Destination "pubspec.yaml" -Force

# 取得依賴
Write-Host "📦 取得依賴..." -ForegroundColor Blue
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 依賴獲取失敗" -ForegroundColor Red
    exit 1
}

# 構建 Windows
Write-Host "🏗️ 開始構建 Windows..." -ForegroundColor Blue
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 構建失敗" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Windows 構建完成！" -ForegroundColor Green
Write-Host "📂 輸出目錄: build/windows/runner/Release" -ForegroundColor Yellow
