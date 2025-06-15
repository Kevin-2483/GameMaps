# 便签背景图片资产存储时机修复

## 问题描述

上传时储存资产的方式并不可靠，因为资产文件夹在地图保存时会清理，所以保存资产的步骤通常放到和便签保存一样的位置。

## 问题分析

之前的实现在便签图片上传时立即调用 `saveAsset()` 保存到资产系统，但这存在以下问题：

1. **时机不当**: 资产保存时机太早，可能在地图保存前被清理
2. **不一致性**: 与图层背景的保存方式不一致
3. **可靠性问题**: 资产文件夹可能在地图保存时清理，导致资产丢失

## 解决方案

参考图层背景的保存方式，将便签背景图片的资产保存移到便签数据保存时进行。

### 1. 图片上传阶段 - 只保存直接数据

**文件**: `lib/pages/map_editor/widgets/sticky_note_panel.dart`

```dart
/// 处理图片上传
Future<void> _handleImageUpload(StickyNote note) async {
  final Uint8List? imageData = await ImageUtils.pickAndEncodeImage();
  if (imageData != null) {
    // 直接保存图像数据到便签，不立即保存到资产系统
    // 资产保存将在地图保存时由VFS服务处理
    final updatedNote = note.copyWith(
      backgroundImageData: imageData,
      clearBackgroundImageHash: true, // 清除旧的哈希引用
      updatedAt: DateTime.now(),
    );
    
    widget.onStickyNoteUpdated(updatedNote);
    debugPrint('便签背景图片已上传，将在地图保存时存储到资产系统');
  }
}
```

**关键变化**:
- 移除了VFS服务依赖
- 上传时只保存 `backgroundImageData`，清除 `backgroundImageHash`
- 资产保存延迟到地图保存时进行

### 2. 便签保存阶段 - 转换为资产存储

**文件**: `lib/services/vfs_map_storage/vfs_map_service_impl.dart`

```dart
/// 保存便签数据
Future<void> saveStickyNote(String mapTitle, StickyNote stickyNote, [String version = 'default']) async {
  StickyNote stickyNoteToSave = stickyNote;
  
  // 1. 处理便签背景图片 - 参考图层背景的保存方式
  if (stickyNote.backgroundImageData != null && stickyNote.backgroundImageData!.isNotEmpty) {
    // 保存背景图片到资产系统并获取哈希（与图层背景保存方式一致）
    final hash = await saveAsset(mapTitle, stickyNote.backgroundImageData!, 'image/png');
    
    // 创建用于磁盘存储的便签副本（使用哈希引用，清除直接数据以节省空间）
    stickyNoteToSave = stickyNote.copyWith(
      backgroundImageHash: hash,
      clearBackgroundImageData: true, // 磁盘存储时清除直接图像数据
    );
  }
  
  // 保存便签JSON数据
  final stickyNoteJson = jsonEncode(stickyNoteToSave.toJson());
  await _storageService.writeFile(stickyNotePath, utf8.encode(stickyNoteJson));
}
```

**关键变化**:
- 保存时才调用 `saveAsset()` 存储图片到资产系统
- 磁盘存储的便签只包含哈希引用，不包含直接图像数据
- 与图层背景的保存方式完全一致

### 3. 便签加载阶段 - 恢复直接数据

加载便签时，VFS服务会自动将哈希引用恢复为直接数据：

```dart
// 1. 处理便签背景图片的图片资产恢复
if (stickyNote.backgroundImageHash != null && stickyNote.backgroundImageHash!.isNotEmpty) {
  final imageData = await getAsset(mapTitle, stickyNote.backgroundImageHash!);
  if (imageData != null) {
    // 将资产数据恢复到便签的backgroundImageData字段
    stickyNote = stickyNote.copyWith(backgroundImageData: imageData);
  }
}
```

### 4. 简化组件依赖

**移除的依赖**:
- StickyNotePanel 不再需要 VfsMapService 依赖
- StickyNotePanel 不再需要 mapTitle 参数
- map_editor_page.dart 不再传递VFS服务给便签面板

## 与图层背景对比

| 功能阶段 | 图层背景 | 便签背景 (修复后) |
|---------|---------|----------------|
| **上传时** | 保存到 `layer.imageData` | 保存到 `note.backgroundImageData` |
| **地图保存时** | `saveLayer()` → `saveAsset()` | `saveStickyNote()` → `saveAsset()` |
| **磁盘存储** | 只保存哈希引用 | 只保存哈希引用 |
| **加载时** | 恢复为 `imageData` | 恢复为 `backgroundImageData` |
| **显示时** | 使用直接数据 | 使用直接数据 |

## 优势

### 1. **时机正确性**
- 资产保存与地图保存同步进行
- 避免资产过早保存被清理的问题

### 2. **一致性**
- 与图层背景的处理方式完全一致
- 遵循相同的资产管理模式

### 3. **可靠性**
- 资产保存时机可靠，不会丢失
- 磁盘存储优化，避免重复数据

### 4. **简化架构**
- 移除了组件间不必要的VFS依赖
- UI组件专注于用户交互，VFS服务专注于数据持久化

## 数据流程

```
用户上传图片
    ↓
保存到 backgroundImageData (内存)
    ↓
响应式系统同步
    ↓
用户保存地图
    ↓
saveStickyNote() 调用 saveAsset()
    ↓
磁盘存储 backgroundImageHash
    ↓
下次加载时恢复 backgroundImageData
    ↓
UI 显示图片
```

## 修复验证

1. **上传测试**: 上传便签背景图片，应立即显示
2. **保存测试**: 保存地图，验证资产正确存储
3. **重载测试**: 重新打开地图，验证背景图片正确加载
4. **资产测试**: 检查资产文件夹，验证图片按哈希存储

## 修复时间
2025年6月16日

## 修复状态
✅ 已完成

便签背景图片现在使用与图层背景一致的资产存储时机，确保了数据的可靠性和架构的一致性。
