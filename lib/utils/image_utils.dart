// This file has been processed by AI for internationalization
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/localization_service.dart';

/// 图片处理工具类
class ImageUtils {
  /// 支持的图片格式
  static const List<String> supportedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'bmp',
    'gif',
  ];

  /// 最大文件大小 (10MB)
  static const int maxFileSize = 10 * 1024 * 1024;

  /// 选择并编码图片文件
  static Future<Uint8List?> pickAndEncodeImage() async {
    try {
      FilePickerResult? result;

      if (kIsWeb) {
        // Web平台使用 FileType.custom 并指定允许的扩展名
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
          allowMultiple: false,
          withData: true, // Web平台需要设置为true才能获取字节数据
        );
      } else {
        // 移动端和桌面端可以直接使用 FileType.image
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // 检查文件大小（限制为10MB）
        if (file.size > 10 * 1024 * 1024) {
          throw Exception(
            LocalizationService.instance.current.imageTooLargeError_4821,
          );
        }

        // 检查文件扩展名
        final extension = file.extension?.toLowerCase();
        final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        if (extension == null || !allowedExtensions.contains(extension)) {
          throw Exception(
            LocalizationService
                .instance
                .current
                .unsupportedImageFormatError_4821,
          );
        }

        // 获取文件字节数据
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception(
            LocalizationService.instance.current.failedToReadImageData_7284,
          );
        }

        return bytes;
      }

      return null; // 用户取消选择
    } catch (e) {
      // 重新抛出异常，让调用方处理
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('选择图片时发生错误: $e');
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
      debugPrint(
        LocalizationService.instance.current.imageDecodeFailed_4821(e),
      );
      return null;
    }
  }

  /// 验证图片数据是否有效
  static bool isValidImageData(Uint8List data) {
    if (data.isEmpty) return false;

    // 检查常见的图片文件头
    // PNG: 89 50 4E 47
    if (data.length >= 4 &&
        data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      return true;
    }

    // JPEG: FF D8
    if (data.length >= 2 && data[0] == 0xFF && data[1] == 0xD8) {
      return true;
    }

    // GIF: 47 49 46 38
    if (data.length >= 4 &&
        data[0] == 0x47 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x38) {
      return true;
    }

    // WebP: 52 49 46 46 (RIFF) 然后在第8-11字节是 57 45 42 50 (WEBP)
    if (data.length >= 12 &&
        data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46 &&
        data[8] == 0x57 &&
        data[9] == 0x45 &&
        data[10] == 0x42 &&
        data[11] == 0x50) {
      return true;
    }

    return false;
  }

  /// 获取图片的MIME类型
  static String? getImageMimeType(Uint8List data) {
    if (!isValidImageData(data)) return null;

    // PNG
    if (data.length >= 4 &&
        data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      return 'image/png';
    }

    // JPEG
    if (data.length >= 2 && data[0] == 0xFF && data[1] == 0xD8) {
      return 'image/jpeg';
    }

    // GIF
    if (data.length >= 4 &&
        data[0] == 0x47 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x38) {
      return 'image/gif';
    }

    // WebP
    if (data.length >= 12 &&
        data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46 &&
        data[8] == 0x57 &&
        data[9] == 0x45 &&
        data[10] == 0x42 &&
        data[11] == 0x50) {
      return 'image/webp';
    }

    return null;
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
        border: Border.all(color: borderColor.withAlpha((0.3 * 255).toInt())),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              LocalizationService.instance.current.transparentLayer_7285,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 从图片数据创建图片Widget
  static Widget buildImageFromBytes(
    Uint8List? imageBytes, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    double opacity = 1.0,
  }) {
    if (imageBytes == null || imageBytes.isEmpty) {
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

  /// 从Base64数据创建图片Widget (保留向后兼容)
  static Widget buildImageFromBase64(
    String base64Data, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    double opacity = 1.0,
  }) {
    final imageBytes = decodeBase64Image(base64Data);
    return buildImageFromBytes(
      imageBytes,
      width: width,
      height: height,
      fit: fit,
      opacity: opacity,
    );
  }

  /// 获取图片的尺寸信息
  static Future<Size?> getImageSize(Uint8List? imageBytes) async {
    if (imageBytes == null || imageBytes.isEmpty) return null;

    try {
      final image = await decodeImageFromList(imageBytes);
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      debugPrint(LocalizationService.instance.current.failedToGetImageSize(e));
      return null;
    }
  }

  /// 获取图片的尺寸信息 (Base64版本，保留向后兼容)
  static Future<Size?> getImageSizeFromBase64(String base64Data) async {
    final imageBytes = decodeBase64Image(base64Data);
    return getImageSize(imageBytes);
  }
}
