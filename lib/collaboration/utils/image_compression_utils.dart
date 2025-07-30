// This file has been processed by AI for internationalization
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// 图片压缩工具类
/// 用于压缩地图封面图片以便在协作中同步
class ImageCompressionUtils {
  /// 压缩图片并转换为base64字符串
  ///
  /// [imageData] 原始图片数据
  /// [quality] 压缩质量 (1-100)
  /// [maxWidth] 最大宽度，默认300
  /// [maxHeight] 最大高度，默认300
  static Future<String?> compressImageToBase64(
    Uint8List imageData, {
    int quality = 70,
    int maxWidth = 300,
    int maxHeight = 300,
  }) async {
    try {
      // 解码图片
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );

      final frame = await codec.getNextFrame();
      final image = frame.image;

      // 转换为字节数据
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      final compressedBytes = byteData.buffer.asUint8List();

      // 转换为base64
      return base64Encode(compressedBytes);
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.imageCompressionFailed_7284(e),
      );
      return null;
    }
  }

  /// 从base64字符串解码图片数据
  static Uint8List? decodeBase64ToImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint(LocalizationService.instance.current.base64DecodeFailed(e));
      return null;
    }
  }

  /// 检查压缩后的图片大小是否合适（用于网络传输）
  /// 返回true表示大小合适，false表示需要进一步压缩
  static bool isCompressedSizeAcceptable(
    String base64String, {
    int maxSizeKB = 50, // 默认最大50KB
  }) {
    final sizeInBytes = base64String.length * 0.75; // base64编码大约增加33%
    final sizeInKB = sizeInBytes / 1024;
    return sizeInKB <= maxSizeKB;
  }

  /// 自适应压缩，确保图片大小适合网络传输
  static Future<String?> adaptiveCompress(
    Uint8List imageData, {
    int maxSizeKB = 50,
    int initialQuality = 70,
    int maxWidth = 300,
    int maxHeight = 300,
  }) async {
    int quality = initialQuality;
    String? compressedBase64;

    // 尝试不同的压缩质量直到满足大小要求
    while (quality >= 10) {
      compressedBase64 = await compressImageToBase64(
        imageData,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (compressedBase64 != null &&
          isCompressedSizeAcceptable(compressedBase64, maxSizeKB: maxSizeKB)) {
        break;
      }

      quality -= 10; // 降低质量重试
    }

    return compressedBase64;
  }
}
