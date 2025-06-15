# 便签版本切换消失问题修复

## 问题描述
在地图编辑器中，当用户切换版本时，便签会消失。这个问题影响了版本管理功能的完整性。

## 问题根因分析

### 1. 版本数据同步问题
在 `ReactiveVersionAdapter` 的 `_onMapDataChanged` 方法中，当地图数据发生变化时，代码会创建一个新的 `MapItem` 副本来保存到版本中。但是，原始代码只复制了 `layers` 和 `legendGroups`，**没有复制 `stickyNotes`**：

```dart
// 问题代码
final newMapItem = state.mapItem.copyWith(
  layers: state.layers,
  legendGroups: state.legendGroups,
  updatedAt: DateTime.now(),
);
```

这导致便签数据在版本保存时丢失。

### 2. 版本比较逻辑缺陷
`_isSameMapData` 方法用于检查两个版本的数据是否相同，避免无意义的更新。但是该方法只比较了图层和图例组，没有比较便签数据，可能导致便签变化不被正确识别。

### 3. 版本切换时选择状态问题
版本切换时，选中的便签状态没有被正确重置，可能导致UI显示不一致。

## 修复方案

### 1. 修复版本数据同步
在 `ReactiveVersionAdapter._onMapDataChanged` 方法中，确保便签数据也被复制到版本中：

```dart
final newMapItem = state.mapItem.copyWith(
  layers: state.layers,
  legendGroups: state.legendGroups,
  stickyNotes: state.mapItem.stickyNotes, // 添加便签数据复制
  updatedAt: DateTime.now(),
);
```

### 2. 增强版本比较逻辑
更新 `_isSameMapData` 方法，添加便签数据的比较：

```dart
bool _isSameMapData(MapItem data1, MapItem data2) {
  if (data1.layers.length != data2.layers.length) return false;
  if (data1.legendGroups.length != data2.legendGroups.length) return false;
  if (data1.stickyNotes.length != data2.stickyNotes.length) return false; // 添加便签数量比较
  
  // 添加便签内容比较
  for (int i = 0; i < data1.stickyNotes.length; i++) {
    final note1 = data1.stickyNotes[i];
    final note2 = data2.stickyNotes[i];
    if (note1.id != note2.id || 
        note1.title != note2.title ||
        note1.content != note2.content ||
        note1.position != note2.position) {
      return false;
    }
  }
  
  return true;
}
```

### 3. 修复版本切换时的选择状态
在 `MapEditorPage._switchVersion` 方法中，添加便签选择状态的重置：

```dart
setState(() {
  // 重置选择状态
  _selectedLayer = null;
  _selectedLayerGroup = null;
  _selectedElementId = null;
  _selectedStickyNote = null; // 添加便签选择状态重置
  
  // 更新显示顺序
  _updateDisplayOrderAfterLayerChange();
});
```

## 修复文件列表

1. `lib/services/reactive_version_adapter.dart`
   - 修复 `_onMapDataChanged` 方法，添加便签数据复制
   - 增强 `_isSameMapData` 方法，添加便签比较逻辑

2. `lib/pages/map_editor/map_editor_page.dart`
   - 修复 `_switchVersion` 方法，添加便签选择状态重置

## 测试验证

修复完成后，请按以下步骤验证：

1. 在地图中添加一些便签
2. 创建一个新版本
3. 在新版本中修改便签或添加新便签
4. 切换回原版本，验证便签是否正确显示
5. 再次切换到新版本，验证便签变化是否被保留

## 影响范围

这个修复确保了：
- 便签数据在版本切换时不会丢失
- 版本管理系统正确跟踪便签的变化
- 版本切换后UI状态正确重置
- 便签的撤销/重做功能正常工作

## 修复时间
2025年6月15日

## 修复状态
✅ 已完成
