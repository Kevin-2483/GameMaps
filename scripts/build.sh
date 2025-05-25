#!/bin/bash
# R6Box 构建脚本 (Linux/macOS)
# 用法: ./build.sh <platform> [build_mode]
# 平台: Windows, MacOS, Linux, Android, iOS, Web
# 构建模式: debug, profile, release (默认: release)

set -e

if [ -z "$1" ]; then
    echo "Usage: ./build.sh <platform> [build_mode]"
    echo "Available platforms: Windows, MacOS, Linux, Android, iOS, Web"
    echo "Build modes: debug, profile, release (default: release)"
    exit 1
fi

TARGET_PLATFORM="$1"
BUILD_MODE="${2:-release}"

echo "Building R6Box for $TARGET_PLATFORM in $BUILD_MODE mode..."

# 生成构建配置
echo "Generating build configuration for $TARGET_PLATFORM..."
dart scripts/build_config_generator.dart "$TARGET_PLATFORM"

# 读取构建参数
BUILD_PARAMS_FILE="scripts/build_params_$TARGET_PLATFORM.txt"
if [ ! -f "$BUILD_PARAMS_FILE" ]; then
    echo "Build parameters file not found: $BUILD_PARAMS_FILE"
    exit 1
fi

# 读取构建参数
BUILD_PARAMS=$(cat "$BUILD_PARAMS_FILE" | tr '\n' ' ')

# 根据平台执行构建
echo "Building with parameters: $BUILD_PARAMS"

case "$TARGET_PLATFORM" in
    "Windows")
        flutter build windows --verbose $BUILD_PARAMS --build-name="$BUILD_MODE"
        ;;
    "MacOS")
        flutter build macos --verbose $BUILD_PARAMS --build-name="$BUILD_MODE"
        ;;
    "Linux")
        flutter build linux --verbose $BUILD_PARAMS --build-name="$BUILD_MODE"
        ;;
    "Android")
        flutter build apk --verbose $BUILD_PARAMS --build-name="$BUILD_MODE"
        ;;
    "iOS")
        flutter build ios --verbose $BUILD_PARAMS --build-name="$BUILD_MODE"
        ;;
    "Web")
        flutter build web --verbose $BUILD_PARAMS --build-name="$BUILD_MODE"
        ;;
    *)
        echo "Unsupported platform: $TARGET_PLATFORM"
        exit 1
        ;;
esac

echo "Build completed successfully for $TARGET_PLATFORM!"

# 清理临时文件
rm -f "$BUILD_PARAMS_FILE"

echo "Build output can be found in the build/ directory"