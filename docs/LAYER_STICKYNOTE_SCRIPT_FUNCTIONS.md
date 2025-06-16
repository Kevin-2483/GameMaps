# 图层和便签管理脚本函数文档

## 概述

新增了完整的图层和便签管理功能，支持通过脚本对图层和便签进行全面的属性更新和管理，包括可见性控制、透明度调整、位置变更、颜色主题等。所有操作都通过响应式数据流进行，确保数据一致性和界面实时更新。

## 数据结构

### 图层对象增强
```javascript
{
  id: "layer-123",
  name: "建筑底图",
  isVisible: true,
  opacity: 1.0,
  order: 1,
  tags: ["建筑", "底图"],
  elements: [...],              // 图层中的绘图元素
  elementsCount: 15,            // 元素总数
  // 图层基本信息
}
```

### 便签对象增强
```javascript
{
  id: "note-456",
  title: "重要提醒",
  content: "这是便签内容...",
  position: {x: 100, y: 200},   // 屏幕坐标
  size: {width: 200, height: 150},
  opacity: 1.0,
  isVisible: true,
  isCollapsed: false,
  backgroundColor: 4294967295,   // 背景颜色（ARGB格式）
  titleBarColor: 4294198554,     // 标题栏颜色
  textColor: 4278190080,         // 文字颜色
  tags: ["重要", "提醒"],
  elements: [...],               // 便签上的绘图元素
  createdAt: "2025-06-16T...",
  updatedAt: "2025-06-16T..."
}
```

## 图层管理函数

### 1. 图层属性更新

#### updateLayer(layerId, properties)
更新图层的综合属性。

```javascript
// 更新图层的多个属性
var result = updateLayer('layer-123', {
  'name': '新的图层名称',
  'isVisible': true,
  'opacity': 0.8,
  'order': 5,
  'tags': ['新标签', '重要', '修改']
});

if (result) {
  print('图层更新成功');
}
```

#### updateLayerVisibility(layerId, isVisible)
快速切换图层可见性。

```javascript
// 显示图层
var showResult = updateLayerVisibility('layer-123', true);

// 隐藏图层
var hideResult = updateLayerVisibility('layer-123', false);

// 切换可见性
var layer = getLayerById('layer-123');
var toggleResult = updateLayerVisibility('layer-123', !layer.isVisible);
```

#### updateLayerOpacity(layerId, opacity)
设置图层透明度。

```javascript
// 设置透明度为 75%
var result = updateLayerOpacity('layer-123', 0.75);

// 设置为完全不透明
var result2 = updateLayerOpacity('layer-123', 1.0);

// 设置为半透明
var result3 = updateLayerOpacity('layer-123', 0.5);
```

#### updateLayerName(layerId, name)
更新图层名称。

```javascript
// 更新图层名称
var result = updateLayerName('layer-123', '重要图层');

// 添加前缀
var layer = getLayerById('layer-123');
var result2 = updateLayerName('layer-123', '[重要] ' + layer.name);
```

#### updateLayerOrder(layerId, order)
调整图层显示顺序。

```javascript
// 设置图层顺序为最顶层
var result = updateLayerOrder('layer-123', 999);

// 向上移动一层
var layer = getLayerById('layer-123');
var result2 = updateLayerOrder('layer-123', layer.order + 1);
```

### 2. 图层查询和过滤

#### getVisibleLayers()
获取所有可见图层。

```javascript
var visibleLayers = getVisibleLayers();
print('可见图层数量: ' + visibleLayers.length);

for (var i = 0; i < visibleLayers.length; i = i + 1) {
  var layer = visibleLayers[i];
  print('可见图层: ' + layer.name + ' (顺序: ' + layer.order + ')');
}
```

#### filterLayersByTags(tagFilter, filterType)
根据标签过滤图层。

**过滤模式：**
- `'contains'` - 包含任意指定标签
- `'exact'` - 标签完全匹配
- `'excludes'` - 不包含任何指定标签
- `'any'` - 不过滤，返回所有

```javascript
// 查找包含"建筑"标签的图层
var buildingLayers = filterLayersByTags('建筑', 'contains');

// 查找包含"重要"或"关键"标签的图层
var importantLayers = filterLayersByTags(['重要', '关键'], 'contains');

// 查找标签完全为["底图", "建筑"]的图层
var exactLayers = filterLayersByTags(['底图', '建筑'], 'exact');

// 查找不包含"临时"标签的图层
var permanentLayers = filterLayersByTags('临时', 'excludes');
```

## 便签管理函数

### 1. 便签综合属性更新

#### updateStickyNote(noteId, properties)
更新便签的综合属性。

```javascript
var result = updateStickyNote('note-456', {
  'title': '新的便签标题',
  'content': '更新后的便签内容\n\n支持多行文本',
  'position': {x: 150, y: 100},
  'size': {width: 250, height: 200},
  'opacity': 0.9,
  'isVisible': true,
  'isCollapsed': false,
  'backgroundColor': 0xFFF1F8E9,  // 浅绿色背景
  'titleBarColor': 0xFF4CAF50,   // 绿色标题栏
  'textColor': 0xFF1B5E20,       // 深绿色文字
  'tags': ['重要', '更新', '脚本']
});
```

### 2. 便签基本属性更新

#### updateStickyNoteVisibility(noteId, isVisible)
控制便签可见性。

```javascript
// 显示便签
var showResult = updateStickyNoteVisibility('note-456', true);

// 隐藏便签
var hideResult = updateStickyNoteVisibility('note-456', false);
```

#### updateStickyNoteOpacity(noteId, opacity)
设置便签透明度。

```javascript
// 设置为半透明
var result = updateStickyNoteOpacity('note-456', 0.7);

// 设置为完全不透明
var result2 = updateStickyNoteOpacity('note-456', 1.0);
```

#### updateStickyNotePosition(noteId, x, y)
移动便签位置。

```javascript
// 移动到指定位置
var result = updateStickyNotePosition('note-456', 200, 150);

// 相对移动
var note = getStickyNoteById('note-456');
var result2 = updateStickyNotePosition('note-456', note.position.x + 50, note.position.y + 30);
```

#### updateStickyNoteSize(noteId, width, height)
调整便签大小。

```javascript
// 设置固定大小
var result = updateStickyNoteSize('note-456', 300, 200);

// 按比例缩放
var note = getStickyNoteById('note-456');
var result2 = updateStickyNoteSize('note-456', note.size.width * 1.2, note.size.height * 1.1);
```

#### updateStickyNoteTitle(noteId, title)
更新便签标题。

```javascript
// 设置新标题
var result = updateStickyNoteTitle('note-456', '重要提醒');

// 添加前缀
var note = getStickyNoteById('note-456');
var result2 = updateStickyNoteTitle('note-456', '[紧急] ' + note.title);
```

#### updateStickyNoteContent(noteId, content)
更新便签内容。

```javascript
// 设置新内容
var result = updateStickyNoteContent('note-456', '这是新的便签内容\n\n支持多行文本');

// 追加内容
var note = getStickyNoteById('note-456');
var result2 = updateStickyNoteContent('note-456', note.content + '\n\n[脚本添加]');
```

#### collapseStickyNote(noteId, isCollapsed)
控制便签折叠状态。

```javascript
// 折叠便签
var collapseResult = collapseStickyNote('note-456', true);

// 展开便签
var expandResult = collapseStickyNote('note-456', false);

// 切换折叠状态
var note = getStickyNoteById('note-456');
var toggleResult = collapseStickyNote('note-456', !note.isCollapsed);
```

### 3. 便签颜色管理

#### updateStickyNoteColors(noteId, backgroundColor, titleBarColor, textColor)
批量设置便签颜色主题。

```javascript
// 蓝色主题
var blueTheme = updateStickyNoteColors('note-456', 
  0xFFE3F2FD,  // 浅蓝色背景
  0xFF1976D2,  // 蓝色标题栏
  0xFF0D47A1   // 深蓝色文字
);

// 绿色主题
var greenTheme = updateStickyNoteColors('note-456',
  0xFFE8F5E8,  // 浅绿色背景
  0xFF4CAF50,  // 绿色标题栏
  0xFF1B5E20   // 深绿色文字
);

// 红色警告主题
var redTheme = updateStickyNoteColors('note-456',
  0xFFFFEBEE,  // 浅红色背景
  0xFFF44336,  // 红色标题栏
  0xFFB71C1C   // 深红色文字
);
```

#### updateStickyNoteBackgroundColor(noteId, color)
单独设置背景颜色。

```javascript
// 设置为浅黄色背景
var result = updateStickyNoteBackgroundColor('note-456', 0xFFFFF9C4);

// 设置为透明背景
var result2 = updateStickyNoteBackgroundColor('note-456', 0x00FFFFFF);
```

#### updateStickyNoteTitleBarColor(noteId, color)
单独设置标题栏颜色。

```javascript
// 设置为橙色标题栏
var result = updateStickyNoteTitleBarColor('note-456', 0xFFFF9800);
```

#### updateStickyNoteTextColor(noteId, color)
单独设置文字颜色。

```javascript
// 设置为深灰色文字
var result = updateStickyNoteTextColor('note-456', 0xFF424242);
```

### 4. 便签查询函数

#### getVisibleStickyNotes()
获取所有可见便签。

```javascript
var visibleNotes = getVisibleStickyNotes();
print('可见便签数量: ' + visibleNotes.length);

for (var i = 0; i < visibleNotes.length; i = i + 1) {
  var note = visibleNotes[i];
  print('可见便签: ' + note.title + ' (' + note.position.x + ', ' + note.position.y + ')');
}
```

## 高级应用示例

### 1. 图层批量管理

```javascript
// 批量优化图层显示
function optimizeLayerDisplay() {
  var allLayers = getLayers();
  var optimizedCount = 0;
  
  for (var i = 0; i < allLayers.length; i = i + 1) {
    var layer = allLayers[i];
    
    // 确保重要图层可见且不透明
    if (layer.tags && layer.tags.indexOf('重要') >= 0) {
      updateLayer(layer.id, {
        'isVisible': true,
        'opacity': 1.0
      });
      optimizedCount = optimizedCount + 1;
    }
    // 临时图层设为半透明
    else if (layer.tags && layer.tags.indexOf('临时') >= 0) {
      updateLayerOpacity(layer.id, 0.6);
      optimizedCount = optimizedCount + 1;
    }
  }
  
  print('优化了 ' + optimizedCount + ' 个图层的显示');
}

// 执行优化
optimizeLayerDisplay();
```

### 2. 便签智能主题管理

```javascript
// 根据标签自动应用颜色主题
function applySmartThemes() {
  var allNotes = getStickyNotes();
  var themeCount = 0;
  
  for (var i = 0; i < allNotes.length; i = i + 1) {
    var note = allNotes[i];
    var tags = note.tags || [];
    
    // 重要便签 - 红色主题
    if (tags.indexOf('重要') >= 0 || tags.indexOf('紧急') >= 0) {
      updateStickyNoteColors(note.id, 0xFFFFEBEE, 0xFFF44336, 0xFFB71C1C);
      themeCount = themeCount + 1;
    }
    // 完成便签 - 绿色主题
    else if (tags.indexOf('完成') >= 0 || tags.indexOf('已完成') >= 0) {
      updateStickyNoteColors(note.id, 0xFFE8F5E8, 0xFF4CAF50, 0xFF1B5E20);
      themeCount = themeCount + 1;
    }
    // 想法便签 - 蓝色主题
    else if (tags.indexOf('想法') >= 0 || tags.indexOf('创意') >= 0) {
      updateStickyNoteColors(note.id, 0xFFE3F2FD, 0xFF2196F3, 0xFF0D47A1);
      themeCount = themeCount + 1;
    }
    // 工作便签 - 橙色主题
    else if (tags.indexOf('工作') >= 0) {
      updateStickyNoteColors(note.id, 0xFFFFF3E0, 0xFFFF9800, 0xFFE65100);
      themeCount = themeCount + 1;
    }
  }
  
  print('应用了 ' + themeCount + ' 个便签的智能主题');
}

// 执行智能主题应用
applySmartThemes();
```

### 3. 便签智能布局

```javascript
// 根据优先级自动排列便签
function arrangeNotesByPriority() {
  var allNotes = getStickyNotes();
  var importantNotes = [];
  var normalNotes = [];
  
  // 分类便签
  for (var i = 0; i < allNotes.length; i = i + 1) {
    var note = allNotes[i];
    var tags = note.tags || [];
    
    if (tags.indexOf('重要') >= 0 || tags.indexOf('紧急') >= 0) {
      importantNotes.push(note);
    } else {
      normalNotes.push(note);
    }
  }
  
  // 重要便签排列在左侧
  for (var i = 0; i < importantNotes.length; i = i + 1) {
    var note = importantNotes[i];
    var x = 50;
    var y = 50 + i * 220;  // 220像素间距
    updateStickyNotePosition(note.id, x, y);
    updateStickyNoteSize(note.id, 200, 150);  // 统一大小
  }
  
  // 普通便签排列在右侧
  for (var i = 0; i < normalNotes.length; i = i + 1) {
    var note = normalNotes[i];
    var x = 300;
    var y = 50 + i * 180;  // 180像素间距
    updateStickyNotePosition(note.id, x, y);
    updateStickyNoteSize(note.id, 180, 120);  // 较小尺寸
  }
  
  print('重新排列了 ' + (importantNotes.length + normalNotes.length) + ' 个便签');
}

// 执行智能布局
arrangeNotesByPriority();
```

### 4. 条件式管理

```javascript
// 根据时间和条件自动管理便签
function autoManageNotes() {
  var allNotes = getStickyNotes();
  var managedCount = 0;
  
  for (var i = 0; i < allNotes.length; i = i + 1) {
    var note = allNotes[i];
    var tags = note.tags || [];
    
    // 折叠已完成的便签
    if (tags.indexOf('完成') >= 0) {
      collapseStickyNote(note.id, true);
      updateStickyNoteOpacity(note.id, 0.7);
      managedCount = managedCount + 1;
    }
    
    // 突出显示紧急便签
    if (tags.indexOf('紧急') >= 0) {
      updateStickyNote(note.id, {
        'isVisible': true,
        'isCollapsed': false,
        'opacity': 1.0,
        'size': {'width': 250, 'height': 180}
      });
      managedCount = managedCount + 1;
    }
    
    // 隐藏临时便签
    if (tags.indexOf('临时') >= 0) {
      updateStickyNoteOpacity(note.id, 0.5);
      managedCount = managedCount + 1;
    }
  }
  
  print('自动管理了 ' + managedCount + ' 个便签');
}

// 执行自动管理
autoManageNotes();
```

### 5. 数据统计和清理

```javascript
// 清理和优化数据
function cleanupAndOptimize() {
  var allLayers = getLayers();
  var allNotes = getStickyNotes();
  
  // 统计分析
  var stats = {
    'hiddenLayers': 0,
    'transparentLayers': 0,
    'hiddenNotes': 0,
    'collapsedNotes': 0,
    'untaggedNotes': 0
  };
  
  // 分析图层
  for (var i = 0; i < allLayers.length; i = i + 1) {
    var layer = allLayers[i];
    if (!layer.isVisible) stats.hiddenLayers = stats.hiddenLayers + 1;
    if (layer.opacity < 1.0) stats.transparentLayers = stats.transparentLayers + 1;
  }
  
  // 分析便签
  for (var i = 0; i < allNotes.length; i = i + 1) {
    var note = allNotes[i];
    if (!note.isVisible) stats.hiddenNotes = stats.hiddenNotes + 1;
    if (note.isCollapsed) stats.collapsedNotes = stats.collapsedNotes + 1;
    if (!note.tags || note.tags.length == 0) stats.untaggedNotes = stats.untaggedNotes + 1;
  }
  
  print('=== 数据统计 ===');
  print('隐藏图层: ' + stats.hiddenLayers + '/' + allLayers.length);
  print('透明图层: ' + stats.transparentLayers + '/' + allLayers.length);
  print('隐藏便签: ' + stats.hiddenNotes + '/' + allNotes.length);
  print('折叠便签: ' + stats.collapsedNotes + '/' + allNotes.length);
  print('无标签便签: ' + stats.untaggedNotes + '/' + allNotes.length);
  
  // 自动清理建议
  if (stats.untaggedNotes > 0) {
    print('建议为 ' + stats.untaggedNotes + ' 个便签添加标签');
  }
  
  if (stats.hiddenLayers > allLayers.length / 2) {
    print('建议检查隐藏图层的必要性');
  }
}

// 执行清理分析
cleanupAndOptimize();
```

## 颜色值说明

便签颜色使用 ARGB 格式的32位整数值：

### 常用颜色值
```javascript
// 基础颜色
var 白色 = 0xFFFFFFFF;
var 黑色 = 0xFF000000;
var 红色 = 0xFFFF0000;
var 绿色 = 0xFF00FF00;
var 蓝色 = 0xFF0000FF;

// 主题颜色
var 浅蓝色背景 = 0xFFE3F2FD;
var 蓝色标题栏 = 0xFF1976D2;
var 深蓝色文字 = 0xFF0D47A1;

var 浅绿色背景 = 0xFFE8F5E8;
var 绿色标题栏 = 0xFF4CAF50;
var 深绿色文字 = 0xFF1B5E20;

var 浅红色背景 = 0xFFFFEBEE;
var 红色标题栏 = 0xFFF44336;
var 深红色文字 = 0xFFB71C1C;

var 浅橙色背景 = 0xFFFFF3E0;
var 橙色标题栏 = 0xFFFF9800;
var 深橙色文字 = 0xFFE65100;
```

## 注意事项

1. **坐标系统**：便签位置使用屏幕像素坐标，原点(0,0)在左上角
2. **透明度范围**：透明度值范围为 0.0-1.0，函数会自动限制在此范围内
3. **颜色格式**：颜色值使用32位 ARGB 格式整数 (Alpha-Red-Green-Blue)
4. **数据实时性**：所有操作都通过响应式数据流进行，确保界面实时更新
5. **错误处理**：当图层或便签不存在时，函数会抛出异常
6. **标签匹配**：标签匹配区分大小写
7. **性能考虑**：批量操作时建议逐个处理，避免同时修改大量对象
8. **状态保持**：所有修改都会保存到地图文件中

---

更新时间：2025年6月16日  
功能版本：v1.0 - 图层和便签全功能管理支持
