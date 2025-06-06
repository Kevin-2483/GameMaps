# VFS 文件选择器使用指南

## 概述

VFS文件选择器已经升级，支持更灵活的选择模式和类型控制。

## 新功能

### 1. 选择类型控制 (SelectionType)

新增了 `SelectionType` 枚举来控制可选择的内容类型：

```dart
enum SelectionType {
  /// 只能选择文件
  filesOnly,
  /// 只能选择目录
  directoriesOnly,
  /// 可以选择文件和目录
  both,
}
```

### 2. 改进的单选模式

当 `allowMultipleSelection = false` 时：
- 选择新文件会自动清除之前的选择
- 批量操作栏的全选复选框被禁用
- 显示适合单选的提示文本

### 3. 禁用多选功能

在单选模式下，多选按钮和全选功能会被自动禁用。

## 使用示例

### 单选文件（仅文件）

```dart
final selectedFile = await VfsFileManagerWindow.showFilePicker(
  context,
  initialDatabase: 'myDatabase',
  initialCollection: 'myCollection',
  allowMultipleSelection: false,
  selectionType: SelectionType.filesOnly,
  allowedExtensions: ['txt', 'json'],
);
```

### 单选目录

```dart
final selectedDir = await VfsFileManagerWindow.showFilePicker(
  context,
  initialDatabase: 'myDatabase',
  initialCollection: 'myCollection',
  allowMultipleSelection: false,
  selectionType: SelectionType.directoriesOnly,
);
```

### 多选混合模式

```dart
final selectedPaths = await VfsFileManagerWindow.showMultiFilePicker(
  context,
  initialDatabase: 'myDatabase',
  initialCollection: 'myCollection',
  allowMultipleSelection: true,
  selectionType: SelectionType.both,
);
```

### 解压缩目标选择

```dart
final extractPath = await VfsFileManagerWindow.showFilePicker(
  context,
  initialDatabase: _selectedDatabase,
  initialCollection: _selectedCollection,
  initialPath: _currentPath,
  allowDirectorySelection: true,
  selectionType: SelectionType.directoriesOnly,
);
```

## 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `allowMultipleSelection` | `bool` | `false` | 是否允许多选 |
| `allowDirectorySelection` | `bool` | `true` | 是否允许选择目录（向后兼容） |
| `selectionType` | `SelectionType` | `SelectionType.both` | 选择类型控制 |
| `allowedExtensions` | `List<String>?` | `null` | 允许的文件扩展名 |

## 行为变化

### 单选模式 (`allowMultipleSelection = false`)

1. **自动清除选择**：选择新项目时自动清除之前的选择
2. **禁用批量操作**：全选复选框和批量操作按钮被禁用
3. **优化提示文本**：显示"单选模式"相关的提示

### 选择类型控制

- `SelectionType.filesOnly`：只显示和允许选择文件
- `SelectionType.directoriesOnly`：只显示和允许选择目录
- `SelectionType.both`：允许选择文件和目录（默认行为）

## 向后兼容性

现有代码无需修改即可继续工作：
- `allowDirectorySelection` 参数仍然有效
- 默认 `selectionType` 为 `SelectionType.both`
- 现有的选择逻辑保持不变

## 最佳实践

1. **明确选择类型**：根据用途明确指定 `selectionType`
2. **合理使用单选**：对于只需要一个结果的场景使用单选模式
3. **扩展名限制**：为文件选择器指定合适的扩展名限制
4. **用户体验**：提供清晰的提示告知用户当前的选择模式

## 故障排除

### 常见问题

1. **选择不生效**：检查 `selectionType` 是否与实际需求匹配
2. **多选被禁用**：确认 `allowMultipleSelection` 设置为 `true`
3. **文件类型限制**：检查 `allowedExtensions` 和 `selectionType` 的配置

### 调试提示

使用浏览器开发者工具查看控制台输出，文件选择器会输出详细的调试信息。
