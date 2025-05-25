# R6Box PowerShell 构建脚本
# 用法: .\build.ps1 <platform> [build_mode]
# 平台: Windows, MacOS, Linux, Android, iOS, Web
# 构建模式: debug, profile, release (默认: release)

param(
    [Parameter(Mandatory=$true)]
    [string]$Platform,
    
    [Parameter(Mandatory=$false)]
    [string]$BuildMode = "release"
)

$ErrorActionPreference = "Stop"

# 验证平台参数
$validPlatforms = @("Windows", "MacOS", "Linux", "Android", "iOS", "Web")
if ($Platform -notin $validPlatforms) {
    Write-Host "Error: Invalid platform '$Platform'" -ForegroundColor Red
    Write-Host "Available platforms: $($validPlatforms -join ', ')" -ForegroundColor Yellow
    exit 1
}

# 验证构建模式
$validModes = @("debug", "profile", "release")
if ($BuildMode -notin $validModes) {
    Write-Host "Error: Invalid build mode '$BuildMode'" -ForegroundColor Red
    Write-Host "Available modes: $($validModes -join ', ')" -ForegroundColor Yellow
    exit 1
}

Write-Host "Building R6Box for $Platform in $BuildMode mode..." -ForegroundColor Green

try {
    # 步骤 1: 生成构建配置
    Write-Host "Step 1: Generating build configuration for $Platform..." -ForegroundColor Cyan
    & dart scripts\build_config_generator.dart $Platform
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to generate build configuration"
    }
    
    # 步骤 2: 读取构建参数
    $paramFile = "scripts\build_params_$Platform.txt"
    if (!(Test-Path $paramFile)) {
        throw "Build parameters file not found: $paramFile"
    }
    
    Write-Host "Step 2: Reading build parameters..." -ForegroundColor Cyan
    $buildParams = Get-Content $paramFile
    Write-Host "Parameters: $($buildParams -join ' ')" -ForegroundColor Gray
    
    # 步骤 3: 执行 Flutter 构建
    Write-Host "Step 3: Starting Flutter build..." -ForegroundColor Cyan
    
    $flutterCmd = @("flutter", "build")
    
    switch ($Platform.ToLower()) {
        "windows" { $flutterCmd += "windows" }
        "macos"   { $flutterCmd += "macos" }
        "linux"   { $flutterCmd += "linux" }
        "android" { $flutterCmd += "apk" }
        "ios"     { $flutterCmd += "ios" }
        "web"     { $flutterCmd += "web" }
    }
    
    $flutterCmd += "--$BuildMode"
    $flutterCmd += $buildParams
    
    Write-Host "Executing: $($flutterCmd -join ' ')" -ForegroundColor Gray
    & $flutterCmd[0] $flutterCmd[1..($flutterCmd.Length-1)]
    
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter build failed"
    }
    
    Write-Host "Build completed successfully for $Platform!" -ForegroundColor Green
    Write-Host "Build output can be found in the build\ directory" -ForegroundColor Yellow
    
} catch {
    Write-Host "Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # 清理临时文件
    if (Test-Path $paramFile) {
        Remove-Item $paramFile -ErrorAction SilentlyContinue
    }
}
