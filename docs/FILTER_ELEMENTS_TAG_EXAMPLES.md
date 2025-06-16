# filterElements 标签过滤功能使用示例

## 概述

增强后的 `filterElements` 函数现在支持：
1. 过滤图层中的元素
2. 过滤便签中的元素  
3. 基于元素标签进行过滤
4. 基于便签标签进行过滤

## 元素数据结构

每个元素现在包含以下标签相关字段：

```javascript
{
  "id": "element-123",
  "type": "rectangle",
  "tags": ["重要", "标记"],  // 元素自身的标签
  "sourceType": "stickyNote",  // 或 "layer"
  
  // 如果来自便签，还包含：
  "stickyNoteId": "note-456",
  "stickyNoteTitle": "我的便签",
  "stickyNoteTags": ["工作", "紧急"],  // 便签的标签
  
  // 如果来自图层，还包含：
  "layerId": "layer-789"
}
```

## 标签过滤示例

### 1. 过滤包含特定标签的元素

```javascript
// 查找所有标记为"重要"的元素（元素标签）
var importantElements = filterElements(fun(element) {
  var tags = element.tags || [];
  for (var i = 0; i < tags.length; i = i + 1) {
    if (tags[i] == '重要') {
      return true;
    }
  }
  return false;
});

print('重要元素数量: ' + importantElements.length);
```

### 2. 过滤便签中包含特定标签的元素

```javascript
// 查找便签中所有带有"标记"标签的元素
var markedElements = filterElements(fun(element) {
  // 只处理便签中的元素
  if (element.sourceType != 'stickyNote') {
    return false;
  }
  
  var tags = element.tags || [];
  for (var i = 0; i < tags.length; i = i + 1) {
    if (tags[i] == '标记') {
      return true;
    }
  }
  return false;
});

print('便签中标记元素数量: ' + markedElements.length);
```

### 3. 基于便签标签过滤元素

```javascript
// 查找所有来自"紧急"便签的元素
var urgentNoteElements = filterElements(fun(element) {
  if (element.sourceType != 'stickyNote') {
    return false;
  }
  
  var stickyNoteTags = element.stickyNoteTags || [];
  for (var i = 0; i < stickyNoteTags.length; i = i + 1) {
    if (stickyNoteTags[i] == '紧急') {
      return true;
    }
  }
  return false;
});

print('紧急便签中的元素数量: ' + urgentNoteElements.length);
```

### 4. 复合标签过滤

```javascript
// 查找重要便签中的重要元素
var criticalElements = filterElements(fun(element) {
  if (element.sourceType != 'stickyNote') {
    return false;
  }
  
  // 检查便签是否标记为"重要"
  var stickyNoteTags = element.stickyNoteTags || [];
  var isImportantNote = false;
  for (var i = 0; i < stickyNoteTags.length; i = i + 1) {
    if (stickyNoteTags[i] == '重要') {
      isImportantNote = true;
      break;
    }
  }
  
  // 检查元素是否标记为"关键"
  var elementTags = element.tags || [];
  var isCriticalElement = false;
  for (var i = 0; i < elementTags.length; i = i + 1) {
    if (elementTags[i] == '关键') {
      isCriticalElement = true;
      break;
    }
  }
  
  return isImportantNote && isCriticalElement;
});

print('关键重要元素数量: ' + criticalElements.length);
```

### 5. 多标签匹配

```javascript
// 查找包含任意指定标签的元素
var taggedElements = filterElements(fun(element) {
  var targetTags = ['重要', '紧急', '完成'];
  var elementTags = element.tags || [];
  
  for (var i = 0; i < elementTags.length; i = i + 1) {
    for (var j = 0; j < targetTags.length; j = j + 1) {
      if (elementTags[i] == targetTags[j]) {
        return true;
      }
    }
  }
  return false;
});

print('带标签元素数量: ' + taggedElements.length);
```

### 6. 排除特定标签

```javascript
// 查找不包含"临时"标签的元素
var permanentElements = filterElements(fun(element) {
  var elementTags = element.tags || [];
  
  for (var i = 0; i < elementTags.length; i = i + 1) {
    if (elementTags[i] == '临时') {
      return false;  // 排除临时元素
    }
  }
  return true;
});

print('永久元素数量: ' + permanentElements.length);
```

### 7. 按元素类型和标签过滤

```javascript
// 查找所有重要的文本元素
var importantTexts = filterElements(fun(element) {
  // 必须是文本元素
  if (element.type != 'text') {
    return false;
  }
  
  // 必须包含"重要"标签
  var elementTags = element.tags || [];
  for (var i = 0; i < elementTags.length; i = i + 1) {
    if (elementTags[i] == '重要') {
      return true;
    }
  }
  return false;
});

print('重要文本数量: ' + importantTexts.length);
```

### 8. 空标签过滤

```javascript
// 查找没有标签的元素
var untaggedElements = filterElements(fun(element) {
  var elementTags = element.tags || [];
  return elementTags.length == 0;
});

print('未标记元素数量: ' + untaggedElements.length);

// 为这些元素添加建议
if (untaggedElements.length > 0) {
  print('建议为以下元素添加标签:');
  for (var i = 0; i < untaggedElements.length; i = i + 1) {
    var element = untaggedElements[i];
    if (element.sourceType == 'stickyNote') {
      print('- ' + element.type + ' 在便签 "' + element.stickyNoteTitle + '"');
    } else {
      print('- ' + element.type + ' 在图层 ' + element.layerId);
    }
  }
}
```

### 9. 统计标签使用情况

```javascript
// 统计所有元素标签的使用频率
var tagCounts = {};
var allElements = filterElements(fun(element) {
  return true;  // 获取所有元素
});

for (var i = 0; i < allElements.length; i = i + 1) {
  var element = allElements[i];
  var tags = element.tags || [];
  
  for (var j = 0; j < tags.length; j = j + 1) {
    var tag = tags[j];
    if (tagCounts[tag] == null) {
      tagCounts[tag] = 0;
    }
    tagCounts[tag] = tagCounts[tag] + 1;
  }
}

print('标签使用统计:');
// 手动检查常见标签
var commonTags = ['重要', '紧急', '完成', '临时', '标记', '关键'];
for (var i = 0; i < commonTags.length; i = i + 1) {
  var tag = commonTags[i];
  var count = tagCounts[tag] || 0;
  if (count > 0) {
    print('- ' + tag + ': ' + count + '个元素');
  }
}
```

### 10. 便签标签和元素标签的组合分析

```javascript
// 分析便签标签与其内部元素标签的关系
var stickyNoteElements = filterElements(fun(element) {
  return element.sourceType == 'stickyNote';
});

print('便签元素标签分析:');

for (var i = 0; i < stickyNoteElements.length; i = i + 1) {
  var element = stickyNoteElements[i];
  var noteTitle = element.stickyNoteTitle;
  var noteTags = element.stickyNoteTags || [];
  var elementTags = element.tags || [];
  
  if (noteTags.length > 0 || elementTags.length > 0) {
    print('便签: ' + noteTitle);
    print('  便签标签: ' + noteTags.join(', '));
    print('  元素(' + element.type + ')标签: ' + elementTags.join(', '));
    print('');
  }
}
```

## 专用便签过滤函数

除了增强的 `filterElements`，还提供了专门的便签过滤函数：

### filterStickyNotesByTags()

```javascript
// 查找包含"工作"标签的便签
var workNotes = filterStickyNotesByTags('工作', 'contains');

// 查找标签完全为["重要", "紧急"]的便签
var exactNotes = filterStickyNotesByTags(['重要', '紧急'], 'exact');

// 查找不包含"完成"标签的便签
var incompleteNotes = filterStickyNotesByTags('完成', 'excludes');
```

### filterStickyNoteElementsByTags()

```javascript
// 查找便签中包含"标记"标签的元素
var markedElements = filterStickyNoteElementsByTags('标记', 'contains');

// 这些元素自动包含便签信息
for (var i = 0; i < markedElements.length; i = i + 1) {
  var element = markedElements[i];
  print(element.type + ' 在便签 "' + element.stickyNoteTitle + '"');
}
```

## 注意事项

1. **标签匹配**：所有标签匹配都是大小写敏感的
2. **空标签**：如果元素没有标签，`tags` 字段会是空数组 `[]`
3. **便签可见性**：只会处理可见的便签中的元素
4. **性能**：大量元素时建议使用更具体的过滤条件
5. **数据实时性**：所有数据都通过响应式数据流获取，确保最新状态

---

更新时间：2025年6月16日
