@echo off
echo 正在修复 flutter_tts Windows CMakeLists.txt...

set "FLUTTER_TTS_CMAKE_PATH=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\flutter_tts-4.2.3\windows\CMakeLists.txt"
set "FIX_CMAKE_PATH=%~dp0flutter_tts_fix\windows\CMakeLists.txt"

if exist "%FLUTTER_TTS_CMAKE_PATH%" (
    echo 找到原始 CMakeLists.txt: %FLUTTER_TTS_CMAKE_PATH%
    
    if exist "%FIX_CMAKE_PATH%" (
        echo 正在备份原始文件...
        copy "%FLUTTER_TTS_CMAKE_PATH%" "%FLUTTER_TTS_CMAKE_PATH%.backup" >nul
        
        echo 正在应用修复...
        copy "%FIX_CMAKE_PATH%" "%FLUTTER_TTS_CMAKE_PATH%" >nul
        
        echo 修复完成！
        echo 原始文件已备份为: %FLUTTER_TTS_CMAKE_PATH%.backup
    ) else (
        echo 错误: 找不到修复文件 %FIX_CMAKE_PATH%
        exit /b 1
    )
) else (
    echo 错误: 找不到 flutter_tts CMakeLists.txt 文件
    echo 请先运行 flutter pub get
    exit /b 1
)

echo.
echo 现在可以运行 flutter run 来启动应用了
pause
