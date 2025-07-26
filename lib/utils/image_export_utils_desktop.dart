import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

/// 桌面平台的图片导出实现

/// 导出多张图片
Future<bool> exportImagesImpl(
  List<Uint8List> imageBytes, {
  String baseName = 'export',
  String format = 'png',
}) async {
  try {
    // 让用户选择保存目录
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择导出目录',
    );
    
    if (selectedDirectory == null) {
      return false; // 用户取消了选择
    }
    
    // 保存每张图片
    for (int i = 0; i < imageBytes.length; i++) {
      final fileName = imageBytes.length == 1 
          ? '$baseName.$format'
          : '${baseName}_${i + 1}.$format';
      final filePath = path.join(selectedDirectory, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(imageBytes[i]);
    }
    
    return true;
  } catch (e) {
    print('桌面平台导出图片失败: $e');
    return false;
  }
}

/// 导出单张图片
Future<bool> exportSingleImageImpl(
  Uint8List imageBytes, {
  String fileName = 'export.png',
}) async {
  try {
    // 让用户选择保存位置
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: '保存图片',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );
    
    if (outputFile == null) {
      return false; // 用户取消了保存
    }
    
    final file = File(outputFile);
    await file.writeAsBytes(imageBytes);
    
    return true;
  } catch (e) {
    print('桌面平台导出单张图片失败: $e');
    return false;
  }
}