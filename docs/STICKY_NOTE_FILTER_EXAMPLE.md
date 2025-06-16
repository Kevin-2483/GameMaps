# 便签过滤功能使用示例

## 示例脚本：便签内容分析

下面是一个使用新增便签过滤功能的实际示例脚本：

```javascript
// 便签分析报告脚本
// 此脚本展示如何使用新增的便签过滤功能

print('=== 便签分析报告 ===');
print('');

// 1. 获取所有便签
var allNotes = getStickyNotes();
print('便签总数: ' + allNotes.length);

// 2. 分析便签标签使用情况
print('');
print('--- 便签标签分析 ---');
var tagCounts = {};
for (var i = 0; i < allNotes.length; i = i + 1) {
  var note = allNotes[i];
  var tags = note.tags;
  for (var j = 0; j < tags.length; j = j + 1) {
    var tag = tags[j];
    if (tagCounts[tag] == null) {
      tagCounts[tag] = 0;
    }
    tagCounts[tag] = tagCounts[tag] + 1;
  }
}

// 显示常见标签统计
var commonTags = ['重要', '紧急', '完成', '待办', '想法', '问题'];
for (var i = 0; i < commonTags.length; i = i + 1) {
  var tag = commonTags[i];
  var count = tagCounts[tag] || 0;
  if (count > 0) {
    print('标签 "' + tag + '": ' + count + ' 个便签');
  }
}

// 3. 查找重要便签
print('');
print('--- 重要便签列表 ---');
var importantNotes = filterStickyNotesByTags('重要', 'contains');
if (importantNotes.length > 0) {
  for (var i = 0; i < importantNotes.length; i = i + 1) {
    var note = importantNotes[i];
    print('* ' + note.title + ' (' + note.elementsCount + ' 个绘制元素)');
  }
} else {
  print('没有找到标记为重要的便签');
}

// 4. 分析便签中的绘制元素
print('');
print('--- 便签绘制元素分析 ---');
var allStickyElements = filterElements(fun(element) {
  return element.sourceType == 'stickyNote';
});

print('便签中绘制元素总数: ' + allStickyElements.length);

// 按类型统计便签中的元素
var elementTypeCounts = {};
for (var i = 0; i < allStickyElements.length; i = i + 1) {
  var element = allStickyElements[i];
  var type = element.type;
  if (elementTypeCounts[type] == null) {
    elementTypeCounts[type] = 0;
  }
  elementTypeCounts[type] = elementTypeCounts[type] + 1;
}

// 显示元素类型统计
var elementTypes = ['text', 'rectangle', 'line', 'freeDrawing'];
for (var i = 0; i < elementTypes.length; i = i + 1) {
  var type = elementTypes[i];
  var count = elementTypeCounts[type] || 0;
  if (count > 0) {
    print(type + ' 元素: ' + count + ' 个');
  }
}

// 5. 查找有标签的便签元素
print('');
print('--- 标记元素分析 ---');
var taggedElements = filterStickyNoteElementsByTags([], 'excludes');
if (taggedElements.length > 0) {
  print('有标签的便签元素数量: ' + taggedElements.length);
  
  // 显示前5个有标签的元素
  var showCount = taggedElements.length > 5 ? 5 : taggedElements.length;
  for (var i = 0; i < showCount; i = i + 1) {
    var element = taggedElements[i];
    print('- ' + element.type + ' 在便签 "' + element.stickyNoteTitle + '"');
  }
  
  if (taggedElements.length > 5) {
    print('... 还有 ' + (taggedElements.length - 5) + ' 个有标签的元素');
  }
} else {
  print('没有找到有标签的便签元素');
}

// 6. 查找特定便签中的元素
print('');
print('--- 便签内容详情 ---');
if (allNotes.length > 0) {
  var firstNote = allNotes[0];
  print('便签 "' + firstNote.title + '" 详情:');
  print('- 位置: x=' + firstNote.position.x + ', y=' + firstNote.position.y);
  print('- 大小: ' + firstNote.size.width + ' x ' + firstNote.size.height);
  print('- 透明度: ' + firstNote.opacity);
  print('- 可见性: ' + (firstNote.isVisible ? '可见' : '隐藏'));
  print('- 标签: ' + firstNote.tags.join(', '));
  
  var noteElements = getElementsInStickyNote(firstNote.id);
  print('- 绘制元素数量: ' + noteElements.length);
  
  if (noteElements.length > 0) {
    print('  元素列表:');
    for (var i = 0; i < noteElements.length; i = i + 1) {
      var element = noteElements[i];
      var tagsText = element.tags.length > 0 ? ' [' + element.tags.join(', ') + ']' : '';
      print('  * ' + element.type + tagsText);
    }
  }
}

print('');
print('=== 分析完成 ===');
```

## 功能展示

这个示例脚本展示了以下新功能：

### 1. 便签基础信息获取
- `getStickyNotes()` - 获取所有可见便签
- `getStickyNoteById(id)` - 获取特定便签
- `getElementsInStickyNote(noteId)` - 获取便签中的所有元素

### 2. 便签过滤功能
- `filterStickyNotesByTags(tagFilter, filterType)` - 根据标签过滤便签
- `filterStickyNoteElementsByTags(tagFilter, filterType)` - 根据标签过滤便签中的元素

### 3. 增强的元素过滤
- `filterElements()` 现在支持便签中的元素，通过 `sourceType` 字段区分来源

### 4. 数据结构增强
便签对象现在包含：
- `elementsCount` - 绘制元素数量
- `tags` - 便签标签数组
- 位置、大小、可见性等属性

元素对象现在包含：
- `sourceType` - 'layer' 或 'stickyNote'
- `stickyNoteId`, `stickyNoteTitle`, `stickyNoteTags` - 便签来源信息

## 实际应用场景

1. **项目管理分析** - 统计不同类型的便签和任务进度
2. **内容审查** - 查找未标记或需要关注的便签
3. **数据清理** - 找出空白或重复的便签
4. **可视化分析** - 统计绘制元素的分布和使用情况
5. **自动化标记** - 根据内容自动为便签添加标签

---

更新时间：2025年6月16日  
功能版本：v1.0 - 便签过滤功能完整支持
