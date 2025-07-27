import 'dart:ui' as ui;

/// PDF图片信息模型
class PdfImageInfo {
  final ui.Image image;
  String title;
  String content;

  PdfImageInfo({required this.image, this.title = '', this.content = ''});

  /// 复制并修改
  PdfImageInfo copyWith({ui.Image? image, String? title, String? content}) {
    return PdfImageInfo(
      image: image ?? this.image,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  /// 是否有文本内容
  bool get hasText => title.isNotEmpty || content.isNotEmpty;
}
