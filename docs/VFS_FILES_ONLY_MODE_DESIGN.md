# VFS文件选择器"仅文件模式"设计文档

## 问题背景

在原始的VFS文件选择器设计中，当设置为 `SelectionType.filesOnly`（仅文件模式）时，存在一个重要的用户体验问题：

**问题**：文件夹被完全过滤掉，用户无法看到文件夹，因此无法导航到子目录来寻找文件。

**影响**：用户只能在当前目录选择文件，无法浏览深层目录结构，严重限制了文件选择器的实用性。

## 解决方案

### 设计原则

采用"**显示但不可选**"的设计原则：

1. **保持可见性**：文件夹在界面中正常显示
2. **区分选择性**：文件夹不能被选中，但文件可以
3. **保持导航性**：文件夹可以被点击进行目录导航
4. **提供反馈**：通过视觉样式和提示文本明确当前模式

### 技术实现

#### 1. 文件过滤逻辑优化

```dart
List<VfsFileInfo> _filterFiles(List<VfsFileInfo> files) {
  if (widget.onFilesSelected == null) {
    return files;
  }

  List<VfsFileInfo> filteredFiles = [];

  for (final file in files) {
    bool shouldInclude = true;

    // 在仅文件模式下，文件夹仍然显示（用于导航），但不能被选中
    // 只有在明确禁止选择目录时才过滤掉目录
    if (file.isDirectory && 
        widget.allowDirectorySelection == false && 
        widget.selectionType != SelectionType.filesOnly) {
      shouldInclude = false;
    }

    // 如果指定了文件扩展名限制，过滤文件
    if (!file.isDirectory &&
        widget.allowedExtensions != null &&
        widget.allowedExtensions!.isNotEmpty) {
      final extension = file.name.split('.').last.toLowerCase();
      if (!widget.allowedExtensions!.contains(extension)) {
        shouldInclude = false;
      }
    }

    if (shouldInclude) {
      filteredFiles.add(file);
    }
  }

  return filteredFiles;
}
```

**关键变更**：
- 在 `SelectionType.filesOnly` 模式下，文件夹不再被过滤掉
- 文件夹保留在列表中，用于用户导航
- 扩展名限制仍然正常应用于文件

#### 2. 选择逻辑增强

```dart
bool _canSelectFile(VfsFileInfo file) {
  if (widget.onFilesSelected == null) {
    return true;
  }

  // 检查新的选择类型限制
  switch (widget.selectionType) {
    case SelectionType.filesOnly:
      if (file.isDirectory) {
        return false; // 文件夹不可选
      }
      break;
    case SelectionType.directoriesOnly:
      if (!file.isDirectory) {
        return false;
      }
      break;
    case SelectionType.both:
      // 允许选择文件和目录，继续其他检查
      break;
  }

  // 其他选择限制检查...
  return true;
}
```

**关键变更**：
- 明确区分"显示"和"可选择"的概念
- 文件夹在仅文件模式下返回 `false`，表示不可选择

#### 3. 交互逻辑优化

```dart
onTap: () {
  if (_selectedFiles.isNotEmpty) {
    // 如果有已选择的文件，优先处理选择逻辑
    _toggleFileSelection(file);
  } else if (file.isDirectory) {
    // 文件夹总是可以导航，无论选择模式如何
    final newPath = _currentPath.isEmpty
        ? file.name
        : '$_currentPath/${file.name}';
    _navigateToPath(newPath);
  } else {
    // 对于文件，根据模式决定行为
    if (widget.onFilesSelected == null) {
      // 浏览模式：打开文件
      _openFile(file);
    } else {
      // 选择模式：如果可以选择则选择，否则显示元数据
      if (_canSelectFile(file)) {
        _toggleFileSelection(file);
      } else {
        _showFileMetadata(file);
      }
    }
  }
},
```

**关键变更**：
- 文件夹的点击行为独立于选择模式
- 文件的点击行为根据是否可选择进行分支处理

#### 4. 视觉反馈优化

```dart
cursor: widget.canBeSelected || widget.file.isDirectory
    ? SystemMouseCursors.click
    : SystemMouseCursors.forbidden,

onTap: widget.canBeSelected || widget.file.isDirectory ? widget.onTap : null,
```

**关键变更**：
- 文件夹始终显示可点击的鼠标样式
- 文件夹始终可以响应点击事件

#### 5. 提示信息增强

```dart
String _buildSelectionModeDescription() {
  switch (widget.selectionType) {
    case SelectionType.filesOnly:
      if (widget.allowedExtensions != null &&
          widget.allowedExtensions!.isNotEmpty) {
        restrictions.add('仅指定类型文件 (${widget.allowedExtensions!.join(', ')}) • 文件夹可导航');
      } else {
        restrictions.add('仅文件 • 文件夹可导航');
      }
      break;
    // ...
  }
}
```

**关键变更**：
- 在提示文本中明确说明"文件夹可导航"
- 帮助用户理解当前模式的行为

## 用户体验改进

### 改进前的问题

1. **导航受限**：无法看到文件夹，无法进入子目录
2. **功能受限**：只能在初始目录选择文件
3. **用户困惑**：不明白为什么看不到文件夹

### 改进后的优势

1. **完整导航**：可以浏览完整的目录结构
2. **清晰区分**：文件夹显示但明显不可选择
3. **直观操作**：点击文件夹导航，点击文件选择
4. **明确提示**：界面提示明确说明当前模式

## 测试用例

### 功能测试

1. **文件夹显示测试**：验证文件夹在仅文件模式下正常显示
2. **文件夹导航测试**：验证点击文件夹可以正常导航
3. **文件选择测试**：验证只有文件可以被选择
4. **扩展名限制测试**：验证文件扩展名过滤正常工作
5. **提示信息测试**：验证界面提示文本正确显示

### 边界测试

1. **空目录测试**：只有文件夹的目录显示正常
2. **深层目录测试**：多层嵌套目录导航正常
3. **混合内容测试**：文件和文件夹混合的目录处理正常

## 向后兼容性

- ✅ 现有的 `allowDirectorySelection` 参数继续有效
- ✅ 默认的 `SelectionType.both` 行为保持不变
- ✅ 其他选择模式行为不受影响
- ✅ API接口完全兼容

## 最佳实践

### 使用建议

1. **明确用途**：根据实际需要选择合适的 `SelectionType`
2. **提供引导**：在界面中为用户提供操作指引
3. **合理限制**：使用 `allowedExtensions` 限制文件类型
4. **测试验证**：充分测试各种目录结构和文件类型

### 示例代码

```dart
// 选择配置文件
final configFile = await VfsFileManagerWindow.showFilePicker(
  context,
  selectionType: SelectionType.filesOnly,
  allowedExtensions: ['json', 'yaml', 'toml'],
  allowMultipleSelection: false,
);

// 选择多个图片文件
final imageFiles = await VfsFileManagerWindow.showMultiFilePicker(
  context,
  selectionType: SelectionType.filesOnly,
  allowedExtensions: ['jpg', 'png', 'gif', 'webp'],
  allowMultipleSelection: true,
);
```

## 总结

通过"显示但不可选"的设计原则，成功解决了仅文件模式下的导航问题，在保持选择限制的同时，确保了用户可以正常浏览和导航文件系统，大大提升了文件选择器的实用性和用户体验。
