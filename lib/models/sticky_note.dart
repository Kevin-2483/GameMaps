import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';
import 'map_layer.dart'; // 导入MapDrawingElement和转换器
import 'map_item.dart'; // 导入Uint8ListConverter

part 'sticky_note.g.dart';

/// 便签数据模型
/// 支持在便签上放置绘画元素，类似图层系统
@JsonSerializable()
class StickyNote {
  final String id;
  final String title; // 便签标题
  final String content; // 便签文本内容（可选）
  @OffsetConverter()
  final Offset position; // 便签在画布上的位置 (相对坐标 0.0-1.0)
  @SizeConverter()
  final Size size; // 便签大小 (相对坐标)
  final double opacity; // 透明度 0.0-1.0
  final bool isVisible; // 是否可见
  final bool isCollapsed; // 是否折叠（只显示标题栏）
  final bool isSelected; // 是否选中
  final int zIndex; // Z层级，数值越大越在上层
  @ColorConverter()
  final Color backgroundColor; // 背景颜色
  @ColorConverter()
  final Color titleBarColor; // 标题栏颜色
  @ColorConverter()
  final Color textColor; // 文字颜色
  @Uint8ListConverter()
  final Uint8List? backgroundImageData; // 背景图片数据
  final String? backgroundImageHash; // VFS资产系统中的背景图像哈希引用
  @BoxFitConverter()
  final BoxFit backgroundImageFit; // 背景图片适应方式
  final double backgroundImageOpacity; // 背景图片透明度
  final List<MapDrawingElement> elements; // 便签上的绘画元素列表
  final List<String>? tags; // 标签列表，用于分类和筛选
  final DateTime createdAt;
  final DateTime updatedAt;
  const StickyNote({
    required this.id,
    required this.title,
    this.content = '',
    required this.position,
    this.size = const Size(0.2, 0.15), // 默认尺寸
    this.opacity = 1.0,
    this.isVisible = true,
    this.isCollapsed = false,
    this.isSelected = false,
    this.zIndex = 0,
    this.backgroundColor = const Color(0xFFFFF9C4), // 默认黄色便签
    this.titleBarColor = const Color(0xFFF9A825), // 标题栏颜色
    this.textColor = const Color(0xFF424242), // 文字颜色
    this.backgroundImageData,
    this.backgroundImageHash,
    this.backgroundImageFit = BoxFit.cover,
    this.backgroundImageOpacity = 0.3,
    this.elements = const [], // 默认无绘画元素
    this.tags, // 标签列表，默认为null
    required this.createdAt,
    required this.updatedAt,
  });

  factory StickyNote.fromJson(Map<String, dynamic> json) =>
      _$StickyNoteFromJson(json);
  Map<String, dynamic> toJson() => _$StickyNoteToJson(this);
  StickyNote copyWith({
    String? id,
    String? title,
    String? content,
    Offset? position,
    Size? size,
    double? opacity,
    bool? isVisible,
    bool? isCollapsed,
    bool? isSelected,
    int? zIndex,
    Color? backgroundColor,
    Color? titleBarColor,
    Color? textColor,
    Uint8List? backgroundImageData,
    String? backgroundImageHash,
    BoxFit? backgroundImageFit,
    double? backgroundImageOpacity,
    List<MapDrawingElement>? elements,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearBackgroundImageData = false, // 用于明确清除背景图片数据
    bool clearBackgroundImageHash = false, // 用于明确清除背景图像哈希
    bool clearTags = false, // 用于明确清除tags
  }) {
    return StickyNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      position: position ?? this.position,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isSelected: isSelected ?? this.isSelected,
      zIndex: zIndex ?? this.zIndex,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleBarColor: titleBarColor ?? this.titleBarColor,
      textColor: textColor ?? this.textColor,
      backgroundImageData: clearBackgroundImageData
          ? null
          : (backgroundImageData ?? this.backgroundImageData),
      backgroundImageHash: clearBackgroundImageHash
          ? null
          : (backgroundImageHash ?? this.backgroundImageHash),
      backgroundImageFit: backgroundImageFit ?? this.backgroundImageFit,
      backgroundImageOpacity:
          backgroundImageOpacity ?? this.backgroundImageOpacity,
      elements: elements ?? this.elements,
      tags: clearTags ? null : (tags ?? this.tags),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 添加绘画元素
  StickyNote addElement(MapDrawingElement element) {
    final newElements = List<MapDrawingElement>.from(elements);
    newElements.add(element);
    return copyWith(elements: newElements, updatedAt: DateTime.now());
  }

  /// 移除绘画元素
  StickyNote removeElement(String elementId) {
    final newElements = elements.where((e) => e.id != elementId).toList();
    return copyWith(elements: newElements, updatedAt: DateTime.now());
  }

  /// 更新绘画元素
  StickyNote updateElement(String elementId, MapDrawingElement newElement) {
    final newElements = elements
        .map((e) => e.id == elementId ? newElement : e)
        .toList();
    return copyWith(elements: newElements, updatedAt: DateTime.now());
  }

  /// 清空所有绘画元素
  StickyNote clearElements() {
    return copyWith(elements: [], updatedAt: DateTime.now());
  }

  /// 获取指定类型的绘画元素
  List<MapDrawingElement> getElementsByType(DrawingElementType type) {
    return elements.where((e) => e.type == type).toList();
  }

  /// 检查是否有绘画元素
  bool get hasElements => elements.isNotEmpty;

  /// 检查是否有背景图片
  bool get hasBackgroundImage =>
      (backgroundImageData != null && backgroundImageData!.isNotEmpty) ||
      (backgroundImageHash != null && backgroundImageHash!.isNotEmpty);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StickyNote) return false;

    return id == other.id &&
        title == other.title &&
        content == other.content &&
        position == other.position &&
        size == other.size &&
        opacity == other.opacity &&
        isVisible == other.isVisible &&
        isCollapsed == other.isCollapsed &&
        isSelected == other.isSelected &&
        zIndex == other.zIndex &&
        backgroundColor == other.backgroundColor &&
        titleBarColor == other.titleBarColor &&
        textColor == other.textColor &&
        backgroundImageFit == other.backgroundImageFit &&
        backgroundImageOpacity == other.backgroundImageOpacity &&
        elements.length == other.elements.length &&
        _listsEqual(elements, other.elements) &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      position,
      size,
      opacity,
      isVisible,
      isCollapsed,
      isSelected,
      zIndex,
      backgroundColor,
      titleBarColor,
      textColor,
      backgroundImageFit,
      backgroundImageOpacity,
      elements.length,
      createdAt,
      updatedAt,
    );
  }

  /// 辅助方法：比较两个绘画元素列表是否相等
  bool _listsEqual(
    List<MapDrawingElement> list1,
    List<MapDrawingElement> list2,
  ) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

/// Size 转换器，用于 JSON 序列化
class SizeConverter implements JsonConverter<Size, Map<String, dynamic>> {
  const SizeConverter();

  @override
  Size fromJson(Map<String, dynamic> json) {
    return Size(
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Size object) {
    return {'width': object.width, 'height': object.height};
  }
}
