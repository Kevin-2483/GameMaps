// This file has been processed by AI for internationalization
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:path/path.dart' as path;
import 'package:super_clipboard/super_clipboard.dart';

import 'virtual_file_system/vfs_platform_io.dart';
import 'localization_service.dart';

/// 剪贴板服务类，负责处理图像复制到系统剪贴板
class ClipboardService {
  /// 将MapCanvas捕获的选中区域复制到剪贴板
  ///
  /// [rgbaData] - RGBA格式的图像数据 (来自captureCanvasAreaToRgbaUint8List)
  /// [width] - 图像宽度
  /// [height] - 图像高度
  static Future<bool> copyCanvasSelectionToClipboard({
    required Uint8List rgbaData,
    required int width,
    required int height,
  }) async {
    try {
      if (rgbaData.isEmpty || width <= 0 || height <= 0) {
        debugPrint(LocalizationService.instance.current.invalidImageData_7281);
        return false;
      }

      // 将RGBA数据转换为img.Image
      // 注意：captureCanvasAreaToRgbaUint8List()现在直接返回RGBA格式的数据
      // 所以这里使用RGBA顺序
      final image = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: rgbaData.buffer,
        format: img.Format.uint8,
        numChannels: 4,
        order: img.ChannelOrder.rgba, // 直接使用RGBA顺序
      );

      // 编码为PNG格式
      final pngBytes = img.encodePng(image);

      // Web 平台特殊处理
      if (kIsWeb) {
        return await _copyImageOnWeb(pngBytes, width, height);
      }

      // 其他平台处理（需要文件系统支持）
      return await _copyImageOnNativePlatforms(pngBytes, width, height);
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.copyMapSelectionFailed_4829(e),
      );
      return false;
    }
  }

  /// Web 平台的图像复制实现
  static Future<bool> _copyImageOnWeb(
    Uint8List pngBytes,
    int width,
    int height,
  ) async {
    try {
      // 尝试使用 super_clipboard
      final clipboard = SystemClipboard.instance;
      if (clipboard != null) {
        final item = DataWriterItem();
        item.add(Formats.png(pngBytes));

        await clipboard.write([item]);

        debugPrint(
          LocalizationService.instance.current.mapAreaCopiedToClipboard(
            width,
            height,
          ),
        );
        return true;
      } else {
        debugPrint(
          LocalizationService.instance.current.clipboardUnavailableWeb_9274,
        );

        // 在 Web 平台上，如果 SystemClipboard.instance 为空，
        // 我们需要设置剪贴板事件监听器来处理复制操作
        // 这里先回退到文本模式，提示用户使用 Ctrl+C
        return await _copyToClipboardFallback(width, height, isWeb: true);
      }
    } catch (e) {
      debugPrint(LocalizationService.instance.current.webImageCopyFailed(e));
      return await _copyToClipboardFallback(width, height, isWeb: true);
    }
  }

  /// 原生平台的图像复制实现
  static Future<bool> _copyImageOnNativePlatforms(
    Uint8List pngBytes,
    int width,
    int height,
  ) async {
    try {
      // 保存临时文件到剪贴板专用子目录
      final tempDir = await VfsPlatformIO.getTempDirectory();
      final clipboardDir = Directory(
        path.join(tempDir.path, 'clipboard_files'),
      );

      // 确保剪贴板目录存在
      if (!await clipboardDir.exists()) {
        await clipboardDir.create(recursive: true);
      }

      final tempFile = File(
        path.join(
          clipboardDir.path,
          'canvas_selection_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      );
      await tempFile.writeAsBytes(pngBytes);

      // 尝试使用 super_clipboard 复制图像
      try {
        final clipboard = SystemClipboard.instance;
        if (clipboard != null) {
          final item = DataWriterItem();
          item.add(Formats.png(pngBytes));

          await clipboard.write([item]);

          debugPrint(
            LocalizationService.instance.current.mapAreaCopiedToClipboard(
              width,
              height,
            ),
          );

          // 清理临时文件
          try {
            await tempFile.delete();
          } catch (e) {
            debugPrint(
              LocalizationService.instance.current.tempFileDeletionWarning(e),
            );
          }

          return true;
        } else {
          debugPrint(
            LocalizationService.instance.current.clipboardUnavailable_7281,
          );
          return await _copyImageWithPlatformChannels(tempFile, width, height);
        }
      } catch (e) {
        debugPrint(
          LocalizationService.instance.current.clipboardCopyImageFailed(e),
        );

        // 回退到平台特定的实现
        return await _copyImageWithPlatformChannels(tempFile, width, height);
      }
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.nativeImageCopyFailed_4821(e),
      );
      return false;
    }
  }

  /// 平台特定的图像剪贴板实现（备用方案）
  static Future<bool> _copyImageWithPlatformChannels(
    File imageFile,
    int width,
    int height,
  ) async {
    try {
      if (Platform.isWindows) {
        // Windows 平台：尝试使用 PowerShell 复制图像
        final result = await Process.run('powershell', [
          '-Command',
          'Add-Type -AssemblyName System.Windows.Forms; '
              'Add-Type -AssemblyName System.Drawing; '
              '\$image = [System.Drawing.Image]::FromFile("${imageFile.path}"); '
              '[System.Windows.Forms.Clipboard]::SetImage(\$image); '
              '\$image.Dispose()',
        ]);

        if (result.exitCode == 0) {
          debugPrint(
            LocalizationService.instance.current.imageCopiedToClipboard_4821,
          );
          // 清理临时文件
          try {
            await imageFile.delete();
          } catch (e) {
            debugPrint(
              LocalizationService.instance.current.tempFileDeletionWarning(e),
            );
          }
          return true;
        } else {
          debugPrint(
            LocalizationService.instance.current.windowsPowerShellCopyFailed(
              result.stderr,
            ),
          );
        }
      } else if (Platform.isMacOS) {
        // macOS 平台：使用 osascript
        final result = await Process.run('osascript', [
          '-e',
          'set the clipboard to (read (POSIX file "${imageFile.path}") as JPEG picture)',
        ]);

        if (result.exitCode == 0) {
          debugPrint(
            LocalizationService.instance.current.imageCopiedToClipboard_4821,
          );
          // 清理临时文件
          try {
            await imageFile.delete();
          } catch (e) {
            debugPrint(
              LocalizationService.instance.current.tempFileDeletionWarning_4821(
                e,
              ),
            );
          }
          return true;
        } else {
          debugPrint(
            LocalizationService.instance.current.macOsCopyFailed_7421(
              result.stderr,
            ),
          );
        }
      } else if (Platform.isLinux) {
        // Linux 平台：尝试使用 xclip
        final result = await Process.run('xclip', [
          '-selection',
          'clipboard',
          '-t',
          'image/png',
          '-i',
          imageFile.path,
        ]);

        if (result.exitCode == 0) {
          debugPrint(
            LocalizationService
                .instance
                .current
                .imageCopiedToClipboardLinux_4821,
          );
          // 清理临时文件
          try {
            await imageFile.delete();
          } catch (e) {
            debugPrint(
              LocalizationService.instance.current.tempFileDeletionWarning(e),
            );
          }
          return true;
        } else {
          debugPrint(
            LocalizationService.instance.current.linuxXclipCopyFailed(
              result.stderr,
            ),
          );
        }
      }

      // 如果平台特定实现失败，回退到文本模式
      return await _copyToClipboardFallback(width, height);
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.platformCopyFailed_7285(e),
      );
      return await _copyToClipboardFallback(width, height);
    }
  }

  /// 回退方案：复制文本提示到剪贴板
  static Future<bool> _copyToClipboardFallback(
    int width,
    int height, {
    bool isWeb = false,
  }) async {
    try {
      final platformHint = isWeb ? 'Web平台' : '此平台';
      await Clipboard.setData(
        ClipboardData(
          text: LocalizationService.instance.current.mapSelectionSavedWithSize(
            width,
            height,
            platformHint,
          ),
        ),
      );

      debugPrint(
        LocalizationService.instance.current.fallbackToTextModeCopy(
          width,
          height,
          isWeb
              ? LocalizationService.instance.current.web_1234
              : LocalizationService.instance.current.native_5678,
        ),
      );
      return true;
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.textModeCopyFailed_4821(e),
      );
      return false;
    }
  }

  /// 从剪贴板读取图片数据
  ///
  /// 返回 [Uint8List?] - 成功时返回图片的字节数据（PNG格式），失败时返回null
  static Future<Uint8List?> readImageFromClipboard() async {
    try {
      // 优先使用 super_clipboard
      final clipboard = SystemClipboard.instance;
      if (clipboard != null) {
        try {
          final reader = await clipboard.read();

          // 尝试读取PNG格式（二进制格式需要使用 getFile）
          if (reader.canProvide(Formats.png)) {
            Uint8List? pngData;
            await reader.getFile(Formats.png, (file) async {
              final stream = file.getStream();
              final chunks = <int>[];
              await for (final chunk in stream) {
                chunks.addAll(chunk);
              }
              pngData = Uint8List.fromList(chunks);
            });

            if (pngData != null) {
              final isSynthesized = reader.isSynthesized(Formats.png);
              debugPrint(
                LocalizationService.instance.current.clipboardPngReadSuccess(
                  pngData!.length.toString(),
                  isSynthesized,
                ),
              );
              return pngData;
            }
          }

          // 尝试读取JPEG格式
          if (reader.canProvide(Formats.jpeg)) {
            Uint8List? jpegData;
            await reader.getFile(Formats.jpeg, (file) async {
              final stream = file.getStream();
              final chunks = <int>[];
              await for (final chunk in stream) {
                chunks.addAll(chunk);
              }
              jpegData = Uint8List.fromList(chunks);
            });

            if (jpegData != null) {
              debugPrint(
                LocalizationService.instance.current.jpegImageReadSuccess(
                  jpegData!.length,
                ),
              );
              return jpegData;
            }
          }

          // 尝试读取GIF格式
          if (reader.canProvide(Formats.gif)) {
            Uint8List? gifData;
            await reader.getFile(Formats.gif, (file) async {
              final stream = file.getStream();
              final chunks = <int>[];
              await for (final chunk in stream) {
                chunks.addAll(chunk);
              }
              gifData = Uint8List.fromList(chunks);
            });

            if (gifData != null) {
              debugPrint(
                LocalizationService.instance.current.clipboardGifReadSuccess(
                  gifData!.length,
                ),
              );
              return gifData;
            }
          }

          debugPrint(
            LocalizationService
                .instance
                .current
                .clipboardNoSupportedImageFormat_4821,
          );
        } catch (e) {
          debugPrint(
            LocalizationService.instance.current.superClipboardReadError_7425(
              e,
            ),
          );
        }
      } else {
        debugPrint(
          LocalizationService.instance.current.clipboardUnavailable_7421,
        );
      }
      // 回退到平台特定的实现
      if (kIsWeb) {
        debugPrint(
          LocalizationService.instance.current.webClipboardNotSupported_7281,
        );
        return null;
      }
      return await _readImageWithPlatformChannels();
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.clipboardImageReadFailed(e),
      );
      return null;
    }
  }

  /// 平台特定的剪贴板图片读取实现（备用方案）
  static Future<Uint8List?> _readImageWithPlatformChannels() async {
    try {
      // Web 平台不支持文件系统操作
      if (kIsWeb) {
        debugPrint(
          LocalizationService.instance.current.webClipboardNotSupported_7281,
        );
        return null;
      }

      final tempDir = await VfsPlatformIO.getTempDirectory();
      final clipboardDir = Directory(
        path.join(tempDir.path, 'clipboard_files'),
      );

      // 确保剪贴板目录存在
      if (!await clipboardDir.exists()) {
        await clipboardDir.create(recursive: true);
      }

      final tempFilePath = path.join(
        clipboardDir.path,
        'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (Platform.isWindows) {
        // Windows 平台：使用 PowerShell 读取剪贴板图片
        final result = await Process.run('powershell', [
          '-Command',
          'Add-Type -AssemblyName System.Windows.Forms; '
              'Add-Type -AssemblyName System.Drawing; '
              '\$clip = [System.Windows.Forms.Clipboard]::GetImage(); '
              'if (\$clip -ne \$null) { '
              '\$clip.Save("$tempFilePath", [System.Drawing.Imaging.ImageFormat]::Png); '
              '\$clip.Dispose(); '
              'Write-Output "success" '
              '} else { '
              'Write-Output "no_image" '
              '}',
        ]);

        if (result.exitCode == 0 &&
            result.stdout.toString().trim() == 'success') {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            final bytes = await tempFile.readAsBytes();
            // 清理临时文件
            try {
              await tempFile.delete();
            } catch (e) {
              debugPrint(
                LocalizationService.instance.current.tempFileDeletionWarning(e),
              );
            }
            debugPrint(
              LocalizationService.instance.current
                  .windowsClipboardImageReadSuccess(bytes.length),
            );
            return bytes;
          }
        } else {
          debugPrint(
            LocalizationService.instance.current.powershellReadError_4821,
          );
        }
      } else if (Platform.isMacOS) {
        // macOS 平台：使用 osascript
        final result = await Process.run('osascript', [
          '-e',
          'try\n'
              'set theClipboard to the clipboard as «class PNGf»\n'
              'set theFile to open for access POSIX file "$tempFilePath" with write permission\n'
              'write theClipboard to theFile\n'
              'close access theFile\n'
              'return "success"\n'
              'on error\n'
              'return "no_image"\n'
              'end try',
        ]);

        if (result.exitCode == 0 &&
            result.stdout.toString().trim() == 'success') {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            final bytes = await tempFile.readAsBytes();
            // 清理临时文件
            try {
              await tempFile.delete();
            } catch (e) {
              debugPrint(
                LocalizationService.instance.current
                    .tempFileDeletionWarning_7284(e),
              );
            }
            debugPrint(
              'macOS: ${LocalizationService.instance.current.clipboardImageReadSuccess_7285}, ${LocalizationService.instance.current.sizeInBytes_7285(bytes.length)}',
            );
            return bytes;
          }
        } else {
          debugPrint(
            LocalizationService.instance.current.macOsScriptReadFailed_7281,
          );
        }
      } else if (Platform.isLinux) {
        // Linux 平台：尝试使用 xclip
        final result = await Process.run('xclip', [
          '-selection',
          'clipboard',
          '-t',
          'image/png',
          '-o',
        ]);

        if (result.exitCode == 0 && result.stdout.isNotEmpty) {
          final bytes = result.stdout as Uint8List;
          debugPrint(
            'Linux: ${LocalizationService.instance.current.clipboardImageReadSuccess_7425(bytes.length)}',
          );
          return bytes;
        } else {
          debugPrint(
            LocalizationService.instance.current.linuxXclipReadFailed_7281,
          );
        }
      }

      debugPrint(LocalizationService.instance.current.clipboardReadError_4821);
      return null;
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.clipboardReadFailed_7285(e),
      );
      return null;
    }
  }
}
