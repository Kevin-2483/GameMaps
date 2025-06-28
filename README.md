# GameMaps 構建指南

本專案支援 macOS 及 Android 平台構建，請依照下列步驟進行。

---

## macOS 構建說明

### 1. 依賴安裝

- 需安裝 Flutter SDK，建議使用本專案上層目錄的 `../flutter_macos_arm64_3.32.5-stable`
- 安裝 CocoaPods：

  ```sh
  sudo gem install cocoapods
  ```

- 安裝 Xcode 並確保已安裝 Command Line Tools

### 2. 構建步驟

- 進入專案目錄：

  ```sh
  cd /Users/kevin/Documents/code/flutter/GameMaps
  ```

- 使用 macOS 構建腳本：

  ```sh
  ./macos_build.sh
  ```

- 或使用 Xcode 開啟 `macos/Runner.xcworkspace`，選擇目標並點擊 Build 執行

---

## Android 構建說明

### 1. 推薦使用 Nix 配置環境

- 若已安裝 [devenv](https://devenv.sh/)，可直接使用 `devenv.nix`：

  ```sh
  devenv shell
  ```

- 若無 devenv，請使用 `.devenv.flake.nix` 產生 shell：

  ```sh
  nix develop
  ```

### 2. 構建步驟

- 進入專案目錄：

  ```sh
  cd /Users/kevin/Documents/code/flutter/GameMaps
  ```

- 使用 Flutter 命令構建 APK：

  ```sh
  flutter build apk
  ```

---

## 其他

- 詳細 Flutter 安裝與設定請參考官方文檔：<https://docs.flutter.dev/get-started/install>
- 若遇到依賴問題，請先執行 `flutter pub get`。
