#!/bin/zsh
# macos_build.sh
# 設定 Flutter bin 路徑為上一層 flutter 目錄
export PATH=$PATH:../flutter_macos_arm64_3.32.5-stable/flutter/bin

# 生成構建配置與.env
flutter pub get
dart scripts/build_config_generator.dart MacOS

# 載入.env到環境變數（如果存在）
if [ -f build/.env ]; then
  export $(grep -v '^#' build/.env | xargs)
fi

cp pubspec.macos.yaml pubspec.yaml
flutter pub get

open macos/Runner.xcworkspace