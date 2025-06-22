# Flutter TTS CMakeLists.txt 修复脚本
# 用于修复 flutter_tts 4.2.3 在 Windows 上的 CMake 构建问题

param(
    [switch]$Restore,  # 恢复原始文件
    [switch]$Force     # 强制覆盖
)

$ErrorActionPreference = "Stop"

# 路径配置
$FlutterTtsCMakePath = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\flutter_tts-4.2.3\windows\CMakeLists.txt"
$FixCMakePath = Join-Path $PSScriptRoot "flutter_tts_fix\windows\CMakeLists.txt"
$BackupPath = "$FlutterTtsCMakePath.backup"

function Write-ColoredOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-FlutterTtsInstalled {
    if (-not (Test-Path $FlutterTtsCMakePath)) {
        Write-ColoredOutput "错误: 找不到 flutter_tts CMakeLists.txt 文件" "Red"
        Write-ColoredOutput "路径: $FlutterTtsCMakePath" "Yellow"
        Write-ColoredOutput "请先运行 'flutter pub get' 来安装依赖" "Yellow"
        return $false
    }
    return $true
}

function Test-FixFileExists {
    if (-not (Test-Path $FixCMakePath)) {
        Write-ColoredOutput "错误: 找不到修复文件" "Red"
        Write-ColoredOutput "路径: $FixCMakePath" "Yellow"
        return $false
    }
    return $true
}

function Backup-OriginalFile {
    if (-not (Test-Path $BackupPath) -or $Force) {
        Write-ColoredOutput "正在备份原始文件..." "Yellow"
        Copy-Item $FlutterTtsCMakePath $BackupPath
        Write-ColoredOutput "备份完成: $BackupPath" "Green"
    } else {
        Write-ColoredOutput "备份文件已存在，跳过备份" "Yellow"
    }
}

function Apply-Fix {
    Write-ColoredOutput "正在应用修复..." "Yellow"
    Copy-Item $FixCMakePath $FlutterTtsCMakePath
    Write-ColoredOutput "修复应用成功！" "Green"
}

function Restore-OriginalFile {
    if (Test-Path $BackupPath) {
        Write-ColoredOutput "正在恢复原始文件..." "Yellow"
        Copy-Item $BackupPath $FlutterTtsCMakePath
        Write-ColoredOutput "原始文件恢复成功！" "Green"
    } else {
        Write-ColoredOutput "错误: 找不到备份文件 $BackupPath" "Red"
        exit 1
    }
}

function Show-Status {
    Write-ColoredOutput "`n=== Flutter TTS CMakeLists.txt 状态 ===" "Cyan"
    
    if (Test-Path $FlutterTtsCMakePath) {
        $originalHash = (Get-FileHash $FlutterTtsCMakePath).Hash
        Write-ColoredOutput "原始文件: 存在" "Green"
        
        if (Test-Path $FixCMakePath) {
            $fixHash = (Get-FileHash $FixCMakePath).Hash
            if ($originalHash -eq $fixHash) {
                Write-ColoredOutput "状态: 已修复" "Green"
            } else {
                Write-ColoredOutput "状态: 未修复或版本不匹配" "Yellow"
            }
        }
    } else {
        Write-ColoredOutput "原始文件: 不存在" "Red"
    }
    
    if (Test-Path $BackupPath) {
        Write-ColoredOutput "备份文件: 存在" "Green"
    } else {
        Write-ColoredOutput "备份文件: 不存在" "Yellow"
    }
}

# 主逻辑
try {
    Write-ColoredOutput "Flutter TTS CMakeLists.txt 修复工具" "Cyan"
    Write-ColoredOutput "===============================" "Cyan"
    
    if ($Restore) {
        Write-ColoredOutput "`n正在恢复原始文件..." "Yellow"
        if (-not (Test-FlutterTtsInstalled)) { exit 1 }
        Restore-OriginalFile
    } else {
        Write-ColoredOutput "`n正在应用修复..." "Yellow"
        
        # 检查文件
        if (-not (Test-FlutterTtsInstalled)) { exit 1 }
        if (-not (Test-FixFileExists)) { exit 1 }
        
        # 备份并应用修复
        Backup-OriginalFile
        Apply-Fix
        
        Write-ColoredOutput "`n修复完成！现在可以运行以下命令:" "Green"
        Write-ColoredOutput "  flutter clean" "White"
        Write-ColoredOutput "  flutter pub get" "White"
        Write-ColoredOutput "  flutter run" "White"
    }
    
    Show-Status
    
} catch {
    Write-ColoredOutput "`n错误: $($_.Exception.Message)" "Red"
    exit 1
}

Write-ColoredOutput "`n按任意键继续..." "Gray"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
