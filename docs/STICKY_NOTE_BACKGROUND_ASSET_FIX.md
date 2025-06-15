# 便签背景图片资产管理修复

## 问题描述
便签的背景颜色/图片信息发生改变时：
1. 不会被版本管理器检测触发未保存状态
2. 不会被保存到VFS资产系统
3. 没有实现响应式数据系统的同步
4. 图像直接存储而非使用hash引用避免重复存储

## 解决方案

### 1. 修复版本管理器检测逻辑

**文件**: `lib/services/reactive_version_adapter.dart`

**问题**: `_isSameMapData()` 方法在比较便签时没有检查背景样式属性变化。

**修复**: 在便签比较逻辑中添加了所有背景相关属性的检查：

```dart
// 检查便签ID和所有属性（包括背景样式）
if (note1.backgroundColor != note2.backgroundColor || // 背景颜色比较
    note1.titleBarColor != note2.titleBarColor || // 标题栏颜色比较
    note1.textColor != note2.textColor || // 文字颜色比较
    note1.backgroundImageFit != note2.backgroundImageFit || // 背景图片适应方式比较
    note1.backgroundImageOpacity != note2.backgroundImageOpacity || // 背景图片透明度比较
    note1.backgroundImageHash != note2.backgroundImageHash || // 背景图片哈希比较
    // ... 其他属性
    ) {
  return false;
}

// 检查背景图片数据变化（用于旧格式兼容性）
if ((note1.backgroundImageData == null) != (note2.backgroundImageData == null)) {
  return false;
}
```

### 2. 实现VFS资产系统集成

**文件**: `lib/pages/map_editor/widgets/sticky_note_panel.dart`

**修复**: 
- 添加VFS服务和地图标题参数
- 修改图片上传逻辑使用资产系统

```dart
class StickyNotePanel extends StatefulWidget {
  final VfsMapService? vfsMapService; // VFS地图服务
  final String? mapTitle; // 当前地图标题

  // 处理图片上传
  Future<void> _handleImageUpload(StickyNote note) async {
    final Uint8List? imageData = await ImageUtils.pickAndEncodeImage();
    if (imageData != null) {
      // 如果有VFS服务，使用资产系统
      if (widget.vfsMapService != null && widget.mapTitle != null) {
        final hash = await widget.vfsMapService!.saveAsset(
          widget.mapTitle!,
          imageData,
          'image/png',
        );
        
        // 创建使用哈希引用的便签副本
        updatedNote = note.copyWith(
          backgroundImageHash: hash,
          clearBackgroundImageData: true, // 清除直接图像数据
        );
      }
    }
  }
}
```

**文件**: `lib/pages/map_editor/map_editor_page.dart`

**修复**: 传递VFS服务给StickyNotePanel

```dart
StickyNotePanel(
  // ... 其他参数
  vfsMapService: _vfsMapService, // 传递VFS服务
  mapTitle: _currentMap?.title, // 传递地图标题
)
```

### 3. VFS地图服务背景图片处理

**文件**: `lib/services/vfs_map_storage/vfs_map_service_impl.dart`

**修复**: 在便签保存和加载时处理背景图片哈希引用

#### 保存时处理
```dart
Future<void> saveStickyNote(String mapTitle, StickyNote stickyNote, [String version = 'default']) async {
  StickyNote stickyNoteToSave = stickyNote;
  
  // 1. 处理便签背景图片
  if (stickyNote.backgroundImageData != null && stickyNote.backgroundImageData!.isNotEmpty) {
    // 保存背景图片到资产系统并获取哈希
    final hash = await saveAsset(mapTitle, stickyNote.backgroundImageData!, 'image/png');
    
    // 创建使用哈希引用而不是直接数据的便签副本
    stickyNoteToSave = stickyNote.copyWith(
      backgroundImageHash: hash,
      clearBackgroundImageData: true, // 清除直接图像数据
    );
  }
  
  // 2. 处理便签中绘画元素的图片资产
  // ... 现有逻辑
}
```

#### 加载时处理
```dart
Future<StickyNote?> getStickyNoteById(String mapTitle, String stickyNoteId, [String version = 'default']) async {
  StickyNote stickyNote = StickyNote.fromJson(noteJson);
  
  // 1. 处理便签背景图片的图片资产恢复
  if (stickyNote.backgroundImageHash != null && stickyNote.backgroundImageHash!.isNotEmpty) {
    final imageData = await getAsset(mapTitle, stickyNote.backgroundImageHash!);
    if (imageData != null) {
      // 将资产数据恢复到便签的backgroundImageData字段
      stickyNote = stickyNote.copyWith(backgroundImageData: imageData);
    }
  }
  
  // 2. 处理便签中绘画元素的图片资产恢复
  // ... 现有逻辑
}
```

### 4. 便签显示组件兼容性改进

**文件**: `lib/pages/map_editor/widgets/sticky_note_display.dart`

**修复**: 支持两种背景图片存储方式

```dart
Widget _buildBackgroundImage() {
  // 检查是否有背景图片（直接数据或VFS哈希引用）
  final hasDirectData = widget.note.backgroundImageData != null && 
                       widget.note.backgroundImageData!.isNotEmpty;
  final hasHashReference = widget.note.backgroundImageHash != null && 
                          widget.note.backgroundImageHash!.isNotEmpty;
  
  if (!hasDirectData && !hasHashReference) {
    return const SizedBox.shrink();
  }

  return Positioned.fill(
    child: hasDirectData
        ? Image.memory(widget.note.backgroundImageData!, fit: widget.note.backgroundImageFit)
        : _buildVfsBackgroundImage(), // 使用VFS哈希引用加载
  );
}
```

## 优势

### 1. **完整的版本管理检测**
- 所有便签背景属性变化都能被版本管理器正确检测
- 触发未保存状态提示
- 自动保存到版本历史

### 2. **资产去重和优化**
- 背景图片使用SHA-256哈希引用
- 相同内容的图片只存储一份
- 减少存储空间占用

### 3. **响应式数据同步**
- 背景属性变化自动触发响应式系统更新
- UI、状态管理和版本系统保持同步
- 支持撤销/重做操作

### 4. **向后兼容性**
- 支持旧格式的直接图像数据存储
- 新数据自动转换为hash引用格式
- 渐进式迁移，不破坏现有数据

### 5. **错误处理和降级**
- VFS服务不可用时回退到直接存储
- 资产加载失败时显示错误占位符
- 详细的调试日志记录

## 影响范围

### 修改的文件
1. `lib/services/reactive_version_adapter.dart` - 版本比较逻辑增强
2. `lib/pages/map_editor/widgets/sticky_note_panel.dart` - 图片上传逻辑改进
3. `lib/pages/map_editor/map_editor_page.dart` - 传递VFS服务参数
4. `lib/pages/map_editor/widgets/sticky_note_display.dart` - 背景图片显示兼容性
5. `lib/services/vfs_map_storage/vfs_map_service_impl.dart` - VFS服务背景图片处理

### 测试建议
1. **背景颜色变化**: 修改便签背景颜色，验证未保存状态和版本保存
2. **背景图片上传**: 上传背景图片，验证资产系统存储和哈希引用
3. **版本切换**: 在不同版本间切换，验证背景图片正确加载
4. **资产去重**: 上传相同图片到不同便签，验证只存储一份
5. **兼容性**: 加载旧格式数据，验证向后兼容性

## 修复时间
2025年6月16日

## 修复状态
✅ 已完成

所有问题已修复，便签背景颜色/图片变化现在能够：
- 被版本管理器正确检测
- 触发未保存状态提示
- 使用VFS资产系统进行优化存储
- 在响应式数据系统中正确同步
