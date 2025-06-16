# 便签过滤函数文档

## 概述

脚本引擎现在支持过滤便签里的元素，提供了强大的标签匹配功能，包括包含标签、标签相同、不包含标签以及不过滤标签（任意）等过滤模式。数据访问由响应式数据流提供，确保数据的实时性和一致性。

## 新增功能

### 1. 增强的 filterElements 函数

原有的 `filterElements` 函数现在支持过滤便签中的元素：

```javascript
// 过滤所有元素（包括图层和便签中的元素）
var allFilteredElements = filterElements(fun(element) {
  // element 现在包含以下额外字段：
  // - sourceType: 'layer' 或 'stickyNote'
  // - layerId: 图层ID（如果来自图层）
  // - stickyNoteId: 便签ID（如果来自便签）
  // - stickyNoteTitle: 便签标题（如果来自便签）
  // - stickyNoteTags: 便签标签列表（如果来自便签）
  
  return element.sourceType == 'stickyNote';
});
```

### 2. 便签相关的新函数

#### getStickyNotes()
获取所有可见便签的信息：

```javascript
var allNotes = getStickyNotes();
print('便签数量: ' + allNotes.length);

for (var i = 0; i < allNotes.length; i = i + 1) {
  var note = allNotes[i];
  print('便签: ' + note.title + ', 元素数量: ' + note.elementsCount);
}
```

#### getStickyNoteById(id)
根据ID获取特定便签：

```javascript
var note = getStickyNoteById('note-123');
if (note != null) {
  print('便签标题: ' + note.title);
  print('便签标签: ' + note.tags.join(', '));
}
```

#### getElementsInStickyNote(noteId)
获取指定便签中的所有元素：

```javascript
var elements = getElementsInStickyNote('note-123');
print('便签中的元素数量: ' + elements.length);
```

#### filterStickyNotesByTags(tagFilter, filterType)
根据标签过滤便签，支持四种过滤模式：

```javascript
// 1. 包含指定标签（contains）
var notesWithImportant = filterStickyNotesByTags('重要', 'contains');
var notesWithAnyTag = filterStickyNotesByTags(['重要', '紧急'], 'contains');

// 2. 标签完全相同（exact）
var exactMatches = filterStickyNotesByTags(['重要', '紧急'], 'exact');

// 3. 不包含指定标签（excludes）
var notImportant = filterStickyNotesByTags('重要', 'excludes');
var notUrgent = filterStickyNotesByTags(['重要', '紧急'], 'excludes');

// 4. 任意标签，不过滤（any）
var allNotes = filterStickyNotesByTags(null, 'any');
```

#### filterStickyNoteElementsByTags(tagFilter, filterType)
根据标签过滤便签中的元素：

```javascript
// 查找便签中所有带有"重要"标签的元素
var importantElements = filterStickyNoteElementsByTags('重要', 'contains');

for (var i = 0; i < importantElements.length; i = i + 1) {
  var element = importantElements[i];
  print('元素类型: ' + element.type + ', 所属便签: ' + element.stickyNoteTitle);
}
```

## 使用示例

### 示例1：统计不同类型的便签元素

```javascript
// 统计便签中各类型元素的数量
var elementCounts = {};
var stickyNoteElements = filterElements(fun(element) {
  return element.sourceType == 'stickyNote';
});

for (var i = 0; i < stickyNoteElements.length; i = i + 1) {
  var element = stickyNoteElements[i];
  var type = element.type;
  
  if (elementCounts[type] == null) {
    elementCounts[type] = 0;
  }
  elementCounts[type] = elementCounts[type] + 1;
}

print('便签元素统计:');
print('文本元素: ' + (elementCounts['text'] || 0));
print('矩形元素: ' + (elementCounts['rectangle'] || 0));
print('线条元素: ' + (elementCounts['line'] || 0));
```

### 示例2：查找包含特定标签的便签和元素

```javascript
// 查找所有标记为"重要"的内容
print('=== 重要内容报告 ===');

// 1. 查找重要便签
var importantNotes = filterStickyNotesByTags('重要', 'contains');
print('重要便签数量: ' + importantNotes.length);

for (var i = 0; i < importantNotes.length; i = i + 1) {
  var note = importantNotes[i];
  print('- ' + note.title + ' (' + note.elementsCount + '个元素)');
}

// 2. 查找重要元素
var importantElements = filterStickyNoteElementsByTags('重要', 'contains');
print('重要元素数量: ' + importantElements.length);

for (var i = 0; i < importantElements.length; i = i + 1) {
  var element = importantElements[i];
  print('- ' + element.type + ' 在便签 "' + element.stickyNoteTitle + '"');
}
```

### 示例3：清理没有标签的元素

```javascript
// 查找所有没有标签的便签元素
var untaggedElements = filterStickyNoteElementsByTags([], 'exact');

print('未标记的便签元素数量: ' + untaggedElements.length);

if (untaggedElements.length > 0) {
  print('建议为以下元素添加标签:');
  for (var i = 0; i < untaggedElements.length; i = i + 1) {
    var element = untaggedElements[i];
    print('- ' + element.type + ' (ID: ' + element.id + ') 在便签 "' + element.stickyNoteTitle + '"');
  }
}
```

### 示例4：便签内容分析

```javascript
// 分析便签的标签使用情况
var allNotes = getStickyNotes();
var tagUsage = {};

for (var i = 0; i < allNotes.length; i = i + 1) {
  var note = allNotes[i];
  var tags = note.tags;
  
  for (var j = 0; j < tags.length; j = j + 1) {
    var tag = tags[j];
    if (tagUsage[tag] == null) {
      tagUsage[tag] = 0;
    }
    tagUsage[tag] = tagUsage[tag] + 1;
  }
}

print('便签标签使用统计:');
// 注意：由于脚本语言限制，这里只能手动检查常见标签
var commonTags = ['重要', '紧急', '完成', '待办', '想法'];
for (var i = 0; i < commonTags.length; i = i + 1) {
  var tag = commonTags[i];
  var count = tagUsage[tag] || 0;
  if (count > 0) {
    print('- ' + tag + ': ' + count + '个便签');
  }
}
```

## 过滤模式详解

### 1. contains（包含）
- 单个标签：`filterStickyNotesByTags('重要', 'contains')`
- 多个标签：`filterStickyNotesByTags(['重要', '紧急'], 'contains')`
- 逻辑：只要包含任意一个指定标签就匹配

### 2. exact（完全相同）
- 必须是数组：`filterStickyNotesByTags(['重要', '紧急'], 'exact')`
- 逻辑：标签集合必须完全相同（数量和内容都一致）

### 3. excludes（排除）
- 单个标签：`filterStickyNotesByTags('临时', 'excludes')`
- 多个标签：`filterStickyNotesByTags(['临时', '草稿'], 'excludes')`
- 逻辑：不包含任何指定标签的项目

### 4. any（任意）
- 参数可以为任意值：`filterStickyNotesByTags(null, 'any')`
- 逻辑：不进行标签过滤，返回所有项目

## 数据字段说明

### 便签对象字段
```javascript
{
  id: "便签ID",
  title: "便签标题",
  content: "便签内容",
  position: {x: 0.5, y: 0.3},  // 相对位置坐标
  size: {width: 0.2, height: 0.15},  // 相对尺寸
  opacity: 1.0,  // 透明度
  isVisible: true,  // 是否可见
  isCollapsed: false,  // 是否折叠
  zIndex: 0,  // 层级
  backgroundColor: 4294956740,  // 背景色（数值）
  titleBarColor: 4290823221,  // 标题栏颜色
  textColor: 4282664004,  // 文字颜色
  tags: ["重要", "想法"],  // 标签数组
  elements: [...],  // 绘制元素数组
  elementsCount: 5,  // 元素数量
  createdAt: "2025-06-16T...",  // 创建时间
  updatedAt: "2025-06-16T..."   // 更新时间
}
```

### 元素对象字段（便签中的元素）
```javascript
{
  id: "元素ID",
  type: "rectangle",  // 元素类型
  color: 4278190080,  // 颜色值
  strokeWidth: 2.0,  // 描边宽度
  density: 3.0,  // 密度
  rotation: 0.0,  // 旋转角度
  curvature: 0.0,  // 弧度
  zIndex: 1,  // 元素层级
  text: "文本内容",  // 文本内容（文本元素）
  fontSize: 14.0,  // 字体大小（文本元素）
  tags: ["重要"],  // 元素标签
  points: [{x: 0.1, y: 0.2}, {x: 0.8, y: 0.7}],  // 坐标点
  
  // 便签来源信息
  stickyNoteId: "便签ID",
  stickyNoteTitle: "便签标题",
  stickyNoteTags: ["便签标签"],
  sourceType: "stickyNote"
}
```

## 注意事项

1. **数据实时性**：所有函数都通过响应式数据流访问数据，确保获取的是最新状态
2. **可见性过滤**：便签过滤函数会自动跳过不可见的便签
3. **标签大小写**：标签匹配是大小写敏感的
4. **性能考虑**：大量便签和元素时，建议使用具体的过滤条件而不是获取所有数据
5. **错误处理**：当便签或元素不存在时，相关函数会抛出异常

---

更新时间：2025年6月16日
功能版本：v1.0 - 便签元素过滤支持
