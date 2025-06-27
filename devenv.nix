{ pkgs, lib, ... }:
{
  dotenv.enable = true;
  languages.java.enable = true;
  languages.python.enable = true;
  languages.python.venv.enable = true;
  languages.dart.enable = true;
  languages.java.jdk.package = lib.mkDefault pkgs.jdk17;
  env.PUB_HOSTED_URL = "https://pub.dev";
  env.FLUTTER_STORAGE_BASE_URL = "https://storage.googleapis.com";
  env.FLUTTER_GIT_URL = "https://github.com/flutter/flutter.git";
  env.DEVELOPER_DIR = "/Applications/Xcode.app/Contents/Developer";
  android = {
    enable = true;
    reactNative.enable = false;
    flutter.enable = true;
    platforms.version = [ "34" "33" "35" "31" ];
    systemImageTypes = [ "google_apis_playstore" ];
    abis = [ "arm64-v8a" "x86_64" ];
    cmake.version = [ "3.22.1" ];
    cmdLineTools.version = "11.0";
    tools.version = "26.1.1";
    platformTools.version = "36.0.0";
    buildTools.version = [ "34.0.0" "30.0.3" ];
    emulator = {
      enable = false;
    };
    sources.enable = true;
    systemImages.enable = false;
    ndk.enable = true;
    ndk.version = [ "27.0.12077973" ];
    googleAPIs.enable = true;
    googleTVAddOns.enable = true;
    extras = [ "extras;google;gcm" ];
    extraLicenses = [
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
    android-studio = {
      enable = false;
    };
  };
  packages = with pkgs; [
    cocoapods
  ];
  enterShell = ''
  # export PATH=$PATH:/Users/kevin/Documents/code/flutter/flutter_macos_arm64_3.32.5-stable/flutter/bin
  echo "🚀 development environment build completed!"
  flutter doctor -v
'';
}
