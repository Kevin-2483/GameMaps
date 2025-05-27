import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// 图片处理工具类
class ImageUtils {
  /// 支持的图片格式
  static const List<String> supportedExtensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
  
  /// 最大文件大小 (10MB)
  static const int maxFileSize = 10 * 1024 * 1024;
  /// 选择并上传图片文件
  static Future<String?> pickAndEncodeImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowedExtensions: supportedExtensions,
        allowMultiple: false,
        withData: true, // 确保获取文件数据
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // 优先使用bytes，如果没有则尝试读取路径
        Uint8List? fileBytes;
        if (file.bytes != null) {
          fileBytes = file.bytes!;
        } else if (file.path != null) {
          // 在某些平台上可能需要从路径读取
          try {
            final fileObject = File(file.path!);
            fileBytes = await fileObject.readAsBytes();
          } catch (e) {
            throw Exception('无法读取文件: ${e.toString()}');
          }
        } else {
          throw Exception('无法获取文件数据');
        }
        
        final fileName = file.name;
        
        // 检查文件大小
        if (fileBytes.length > maxFileSize) {
          throw Exception('文件大小超过限制 (最大10MB)');
        }
        
        // 检查文件格式
        final extension = fileName.split('.').last.toLowerCase();
        if (!supportedExtensions.contains(extension)) {
          throw Exception('不支持的文件格式，支持: ${supportedExtensions.join(', ')}');
        }
        
        // 转换为Base64
        return base64Encode(fileBytes);
      }
      
      // 用户取消选择，返回null而不是抛出异常
      return null;
    } catch (e) {
      // 重新抛出异常，保持原有的错误信息
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('选择图片失败: ${e.toString()}');
      }
    }
  }

  /// 将Base64字符串解码为图片数据
  static Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('解码图片失败: $e');
      return null;
    }
  }

  /// 创建透明图片的占位符
  static Widget buildTransparentPlaceholder({
    double? width,
    double? height,
    Color borderColor = Colors.grey,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              '透明图层',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 从Base64数据创建图片Widget
  static Widget buildImageFromBase64(
    String base64Data, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    double opacity = 1.0,
  }) {
    final imageBytes = decodeBase64Image(base64Data);
    if (imageBytes == null) {
      return buildTransparentPlaceholder(width: width, height: height);
    }

    return Opacity(
      opacity: opacity,
      child: Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return buildTransparentPlaceholder(width: width, height: height);
        },
      ),
    );
  }

  /// 获取图片的尺寸信息
  static Future<Size?> getImageSize(String base64Data) async {
    final imageBytes = decodeBase64Image(base64Data);
    if (imageBytes == null) return null;

    try {
      final image = await decodeImageFromList(imageBytes);
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      debugPrint('获取图片尺寸失败: $e');
      return null;
    }
  }
}
