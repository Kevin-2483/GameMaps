import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:super_clipboard/super_clipboard.dart';

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
    required int height,  }) async {
    try {
      if (rgbaData.isEmpty || width <= 0 || height <= 0) {
        print('无效的图像数据');
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
      
      // 保存临时文件
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, 'canvas_selection_${DateTime.now().millisecondsSinceEpoch}.png'));
      await tempFile.writeAsBytes(pngBytes);
      
      // 尝试使用 super_clipboard 复制图像
      try {
        final clipboard = SystemClipboard.instance;
        if (clipboard != null) {
          final item = DataWriterItem();
          item.add(Formats.png(pngBytes));
          
          await clipboard.write([item]);
          
          print('地图选中区域已成功复制到剪贴板: ${width}x$height');
          
          // 清理临时文件
          try {
            await tempFile.delete();
          } catch (e) {
            print('警告：无法删除临时文件: $e');
          }
          
          return true;
        } else {
          print('系统剪贴板不可用，尝试平台特定实现');
          return await _copyImageWithPlatformChannels(tempFile, width, height);
        }
      } catch (e) {
        print('使用 super_clipboard 复制图像失败: $e');
        
        // 回退到平台特定的实现
        return await _copyImageWithPlatformChannels(tempFile, width, height);
      }
    } catch (e) {
      print('复制地图选中区域失败: $e');
      return false;
    }
  }
  
  /// 平台特定的图像剪贴板实现（备用方案）
  static Future<bool> _copyImageWithPlatformChannels(File imageFile, int width, int height) async {
    try {
      if (Platform.isWindows) {
        // Windows 平台：尝试使用 PowerShell 复制图像
        final result = await Process.run(
          'powershell',
          [
            '-Command',
            'Add-Type -AssemblyName System.Windows.Forms; '
            'Add-Type -AssemblyName System.Drawing; '
            '\$image = [System.Drawing.Image]::FromFile("${imageFile.path}"); '
            '[System.Windows.Forms.Clipboard]::SetImage(\$image); '
            '\$image.Dispose()'
          ],
        );
        
        if (result.exitCode == 0) {
          print('Windows: 图像已成功复制到剪贴板');
          // 清理临时文件
          try {
            await imageFile.delete();
          } catch (e) {
            print('警告：无法删除临时文件: $e');
          }
          return true;
        } else {
          print('Windows PowerShell 复制失败: ${result.stderr}');
        }
      } else if (Platform.isMacOS) {
        // macOS 平台：使用 osascript
        final result = await Process.run(
          'osascript',
          [
            '-e',
            'set the clipboard to (read (POSIX file "${imageFile.path}") as JPEG picture)'
          ],
        );
        
        if (result.exitCode == 0) {
          print('macOS: 图像已成功复制到剪贴板');
          // 清理临时文件
          try {
            await imageFile.delete();
          } catch (e) {
            print('警告：无法删除临时文件: $e');
          }
          return true;
        } else {
          print('macOS osascript 复制失败: ${result.stderr}');
        }
      } else if (Platform.isLinux) {
        // Linux 平台：尝试使用 xclip
        final result = await Process.run(
          'xclip',
          ['-selection', 'clipboard', '-t', 'image/png', '-i', imageFile.path],
        );
        
        if (result.exitCode == 0) {
          print('Linux: 图像已成功复制到剪贴板');
          // 清理临时文件
          try {
            await imageFile.delete();
          } catch (e) {
            print('警告：无法删除临时文件: $e');
          }
          return true;
        } else {
          print('Linux xclip 复制失败: ${result.stderr}');
        }
      }
      
      // 如果平台特定实现失败，回退到文本模式
      return await _copyToClipboardFallback(width, height);
    } catch (e) {
      print('平台特定复制实现失败: $e');
      return await _copyToClipboardFallback(width, height);
    }
  }
  
  /// 回退方案：复制文本提示到剪贴板
  static Future<bool> _copyToClipboardFallback(int width, int height) async {
    try {
      await Clipboard.setData(ClipboardData(
        text: '地图选中区域已保存 (${width}x$height) - 图像剪贴板功能在此平台不可用',
      ));
      
      print('已回退到文本模式复制: ${width}x$height');
      return true;
    } catch (e) {
      print('文本模式复制也失败了: $e');
      return false;
    }
  }  /// 从剪贴板读取图片数据
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
              print('super_clipboard: 从剪贴板成功读取PNG图片，大小: ${pngData!.length} 字节${isSynthesized ? ' (合成)' : ''}');
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
              print('super_clipboard: 从剪贴板成功读取JPEG图片，大小: ${jpegData!.length} 字节');
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
              print('super_clipboard: 从剪贴板成功读取GIF图片，大小: ${gifData!.length} 字节');
              return gifData;
            }
          }
          
          print('super_clipboard: 剪贴板中没有支持的图片格式');
        } catch (e) {
          print('super_clipboard 读取失败: $e，回退到平台特定实现');
        }
      } else {
        print('系统剪贴板不可用，使用平台特定实现');
      }
      
      // 回退到平台特定的实现
      return await _readImageWithPlatformChannels();
    } catch (e) {
      print('从剪贴板读取图片失败: $e');
      return null;
    }
  }
  
  /// 平台特定的剪贴板图片读取实现（备用方案）
  static Future<Uint8List?> _readImageWithPlatformChannels() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = path.join(tempDir.path, 'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.png');
      
      if (Platform.isWindows) {
        // Windows 平台：使用 PowerShell 读取剪贴板图片
        final result = await Process.run(
          'powershell',
          [
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
            '}'
          ],
        );
        
        if (result.exitCode == 0 && result.stdout.toString().trim() == 'success') {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            final bytes = await tempFile.readAsBytes();
            // 清理临时文件
            try {
              await tempFile.delete();
            } catch (e) {
              print('警告：无法删除临时文件: $e');
            }
            print('Windows: 从剪贴板成功读取图片，大小: ${bytes.length} 字节');
            return bytes;
          }
        } else {
          print('Windows PowerShell 读取失败或剪贴板中没有图片');
        }
      } else if (Platform.isMacOS) {
        // macOS 平台：使用 osascript
        final result = await Process.run(
          'osascript',
          [
            '-e',
            'try\n'
            'set theClipboard to the clipboard as «class PNGf»\n'
            'set theFile to open for access POSIX file "$tempFilePath" with write permission\n'
            'write theClipboard to theFile\n'
            'close access theFile\n'
            'return "success"\n'
            'on error\n'
            'return "no_image"\n'
            'end try'
          ],
        );
        
        if (result.exitCode == 0 && result.stdout.toString().trim() == 'success') {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            final bytes = await tempFile.readAsBytes();
            // 清理临时文件
            try {
              await tempFile.delete();
            } catch (e) {
              print('警告：无法删除临时文件: $e');
            }
            print('macOS: 从剪贴板成功读取图片，大小: ${bytes.length} 字节');
            return bytes;
          }
        } else {
          print('macOS osascript 读取失败或剪贴板中没有图片');
        }
      } else if (Platform.isLinux) {
        // Linux 平台：尝试使用 xclip
        final result = await Process.run(
          'xclip',
          ['-selection', 'clipboard', '-t', 'image/png', '-o'],
        );
        
        if (result.exitCode == 0 && result.stdout.isNotEmpty) {
          final bytes = result.stdout as Uint8List;
          print('Linux: 从剪贴板成功读取图片，大小: ${bytes.length} 字节');
          return bytes;
        } else {
          print('Linux xclip 读取失败或剪贴板中没有图片');
        }
      }
      
      print('平台特定的剪贴板读取不支持或失败');
      return null;
    } catch (e) {
      print('平台特定剪贴板读取实现失败: $e');
      return null;
    }
  }
}
