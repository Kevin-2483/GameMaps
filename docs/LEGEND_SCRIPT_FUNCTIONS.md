# 图例和图例组脚本函数文档

## 概述

新增了完整的图例和图例组管理功能，支持通过脚本对图例进行全面的操作和管理，包括属性更新、标签过滤、可见性控制、位置旋转等。所有操作都通过响应式数据流进行，确保数据一致性。

## 数据结构

### 图例组对象
```javascript
{
  id: "group-123",
  name: "建筑标记",
  isVisible: true,
  opacity: 1.0,
  tags: ["建筑", "重要"],
  legendItems: [...],           // 图例项数组
  legendItemsCount: 5,          // 图例项总数
  visibleItemsCount: 4,         // 可见图例项数量
  createdAt: "2025-06-16T...",
  updatedAt: "2025-06-16T..."
}
```

### 图例项对象
```javascript
{
  id: "item-456",
  legendId: "legend-789",       // 关联的图例数据库ID
  position: {x: 0.5, y: 0.3},   // 地图上的位置 (0.0-1.0)
  size: 1.0,                    // 大小缩放比例
  rotation: 45.0,               // 旋转角度 (度)
  opacity: 1.0,                 // 透明度 (0.0-1.0)
  isVisible: true,              // 是否可见
  url: "vfs://icons/door.png",  // 链接URL (支持网络和VFS)
  tags: ["入口", "重要"],        // 标签数组
  createdAt: "2025-06-16T..."
}
```

## 核心函数

### 1. 图例组管理函数

#### getLegendGroups()
获取所有图例组列表。

```javascript
var allGroups = getLegendGroups();
print('图例组数量: ' + allGroups.length);

for (var i = 0; i < allGroups.length; i = i + 1) {
  var group = allGroups[i];
  print('图例组: ' + group.name + ' (可见: ' + group.isVisible + ')');
}
```

#### getLegendGroupById(groupId)
根据ID获取特定图例组。

```javascript
var group = getLegendGroupById('group-123');
if (group != null) {
  print('图例组名称: ' + group.name);
  print('图例项数量: ' + group.legendItemsCount);
}
```

#### updateLegendGroup(groupId, properties)
更新图例组的综合属性。

```javascript
// 更新名称、可见性、透明度和标签
var result = updateLegendGroup('group-123', {
  'name': '新的图例组名称',
  'isVisible': true,
  'opacity': 0.8,
  'tags': ['新标签', '重要', '建筑']
});

if (result) {
  print('图例组更新成功');
}
```

#### updateLegendGroupVisibility(groupId, isVisible)
快速切换图例组可见性。

```javascript
// 显示图例组
var showResult = updateLegendGroupVisibility('group-123', true);

// 隐藏图例组  
var hideResult = updateLegendGroupVisibility('group-123', false);
```

#### updateLegendGroupOpacity(groupId, opacity)
设置图例组透明度。

```javascript
// 设置透明度为 75%
var result = updateLegendGroupOpacity('group-123', 0.75);

// 设置为完全不透明
var result2 = updateLegendGroupOpacity('group-123', 1.0);
```

### 2. 图例项管理函数

#### getLegendItems(groupId)
获取指定图例组中的所有图例项。

```javascript
var items = getLegendItems('group-123');
print('图例项数量: ' + items.length);

for (var i = 0; i < items.length; i = i + 1) {
  var item = items[i];
  print('图例项: ' + item.id + ', 位置: (' + item.position.x + ', ' + item.position.y + ')');
}
```

#### getLegendItemById(groupId, itemId)
获取特定图例项的详细信息。

```javascript
var item = getLegendItemById('group-123', 'item-456');
if (item != null) {
  print('图例项位置: (' + item.position.x + ', ' + item.position.y + ')');
  print('大小: ' + item.size + ', 旋转: ' + item.rotation + '°');
  print('标签: ' + item.tags.join(', '));
}
```

#### updateLegendItem(groupId, itemId, properties)
更新图例项的综合属性。

```javascript
var result = updateLegendItem('group-123', 'item-456', {
  'position': {x: 0.6, y: 0.4},  // 新位置
  'size': 1.5,                   // 1.5倍大小
  'rotation': 90,                // 旋转90度
  'opacity': 0.9,                // 90%透明度
  'isVisible': true,             // 设为可见
  'url': 'https://example.com/icon.png',  // 设置链接
  'tags': ['重要', '入口', '主要']  // 设置标签
});
```

#### updateLegendItemPosition(groupId, itemId, x, y)
快速更新图例项位置。

```javascript
// 移动到地图中心
var result = updateLegendItemPosition('group-123', 'item-456', 0.5, 0.5);

// 移动到右上角
var result2 = updateLegendItemPosition('group-123', 'item-456', 0.8, 0.2);
```

#### updateLegendItemRotation(groupId, itemId, rotation)
设置图例项旋转角度。

```javascript
// 旋转45度
var result = updateLegendItemRotation('group-123', 'item-456', 45);

// 旋转180度（倒转）
var result2 = updateLegendItemRotation('group-123', 'item-456', 180);
```

#### updateLegendItemSize(groupId, itemId, size)
调整图例项大小。

```javascript
// 放大到1.5倍
var result = updateLegendItemSize('group-123', 'item-456', 1.5);

// 缩小到0.8倍
var result2 = updateLegendItemSize('group-123', 'item-456', 0.8);
```

#### updateLegendItemVisibility(groupId, itemId, isVisible)
控制图例项可见性。

```javascript
// 显示图例项
var result = updateLegendItemVisibility('group-123', 'item-456', true);

// 隐藏图例项
var result2 = updateLegendItemVisibility('group-123', 'item-456', false);
```

#### updateLegendItemOpacity(groupId, itemId, opacity)
设置图例项透明度。

```javascript
// 设置为半透明
var result = updateLegendItemOpacity('group-123', 'item-456', 0.5);

// 设置为完全不透明
var result2 = updateLegendItemOpacity('group-123', 'item-456', 1.0);
```

### 3. 标签过滤函数

#### filterLegendGroupsByTags(tagFilter, filterType)
根据标签过滤图例组。

**过滤模式：**
- `'contains'` - 包含任意指定标签
- `'exact'` - 标签完全匹配
- `'excludes'` - 不包含任何指定标签
- `'any'` - 不过滤，返回所有

```javascript
// 查找包含"建筑"标签的图例组
var buildingGroups = filterLegendGroupsByTags('建筑', 'contains');

// 查找包含"重要"或"关键"标签的图例组
var importantGroups = filterLegendGroupsByTags(['重要', '关键'], 'contains');

// 查找标签完全为["建筑", "重要"]的图例组
var exactGroups = filterLegendGroupsByTags(['建筑', '重要'], 'exact');

// 查找不包含"临时"标签的图例组
var permanentGroups = filterLegendGroupsByTags('临时', 'excludes');

// 获取所有图例组
var allGroups = filterLegendGroupsByTags(null, 'any');
```

#### filterLegendItemsByTags(tagFilter, filterType)
根据标签过滤图例项。

```javascript
// 查找所有标记为"重要"的图例项
var importantItems = filterLegendItemsByTags('重要', 'contains');

for (var i = 0; i < importantItems.length; i = i + 1) {
  var item = importantItems[i];
  print('重要图例项: ' + item.id + ' 在图例组 "' + item.groupName + '"');
  print('  位置: (' + item.position.x + ', ' + item.position.y + ')');
  print('  图例组标签: ' + item.groupTags.join(', '));
}

// 查找入口相关的图例项
var entranceItems = filterLegendItemsByTags(['入口', '门', '通道'], 'contains');

// 查找没有标签的图例项
var untaggedItems = filterLegendItemsByTags([], 'exact');
```

### 4. 搜索和查询函数

#### findLegendGroupsByName(namePattern)
按名称模式搜索图例组。

```javascript
// 搜索名称包含"建筑"的图例组
var buildingGroups = findLegendGroupsByName('建筑');

// 搜索名称包含"门"的图例组
var doorGroups = findLegendGroupsByName('门');

// 不区分大小写搜索
var weaponGroups = findLegendGroupsByName('weapon');  // 可以找到 "Weapon" 或 "WEAPON"
```

#### getVisibleLegendGroups()
获取所有可见的图例组。

```javascript
var visibleGroups = getVisibleLegendGroups();
print('可见图例组数量: ' + visibleGroups.length);

var totalItems = 0;
for (var i = 0; i < visibleGroups.length; i = i + 1) {
  var group = visibleGroups[i];
  totalItems = totalItems + group.legendItemsCount;
  print('可见图例组: ' + group.name + ' (' + group.legendItemsCount + '个图例项)');
}
print('可见图例组总计图例项: ' + totalItems);
```

#### getVisibleLegendItems(groupId)
获取指定图例组中的可见图例项。

```javascript
var visibleItems = getVisibleLegendItems('group-123');
print('可见图例项数量: ' + visibleItems.length);

for (var i = 0; i < visibleItems.length; i = i + 1) {
  var item = visibleItems[i];
  print('可见图例项: ' + item.id + ', 大小: ' + item.size + ', 透明度: ' + item.opacity);
}
```

## 高级应用示例

### 1. 图例组批量管理

```javascript
// 批量显示所有隐藏的图例组
var allGroups = getLegendGroups();
var showCount = 0;

for (var i = 0; i < allGroups.length; i = i + 1) {
  var group = allGroups[i];
  if (!group.isVisible) {
    var result = updateLegendGroupVisibility(group.id, true);
    if (result) showCount = showCount + 1;
  }
}
print('批量显示了 ' + showCount + ' 个图例组');

// 批量调整透明度到最佳可见性
var adjustCount = 0;
for (var i = 0; i < allGroups.length; i = i + 1) {
  var group = allGroups[i];
  if (group.opacity < 0.9) {
    var result = updateLegendGroupOpacity(group.id, 0.9);
    if (result) adjustCount = adjustCount + 1;
  }
}
print('调整了 ' + adjustCount + ' 个图例组的透明度');
```

### 2. 图例项智能布局

```javascript
// 将图例项排列在地图边缘
function arrangeItemsOnEdge(groupId) {
  var items = getLegendItems(groupId);
  var edgePositions = [
    {x: 0.1, y: 0.1}, {x: 0.5, y: 0.1}, {x: 0.9, y: 0.1},  // 顶部
    {x: 0.1, y: 0.9}, {x: 0.5, y: 0.9}, {x: 0.9, y: 0.9},  // 底部
    {x: 0.1, y: 0.5}, {x: 0.9, y: 0.5}                      // 左右中间
  ];
  
  for (var i = 0; i < items.length && i < edgePositions.length; i = i + 1) {
    var item = items[i];
    var pos = edgePositions[i];
    updateLegendItemPosition(groupId, item.id, pos.x, pos.y);
  }
}

// 使用示例
var groups = getLegendGroups();
if (groups.length > 0) {
  arrangeItemsOnEdge(groups[0].id);
  print('已重新排列图例项布局');
}
```

### 3. 条件式图例管理

```javascript
// 根据标签自动设置图例项属性
var importantItems = filterLegendItemsByTags('重要', 'contains');

for (var i = 0; i < importantItems.length; i = i + 1) {
  var item = importantItems[i];
  // 重要图例项: 放大、高亮、确保可见
  updateLegendItem(item.groupId, item.id, {
    'size': 1.3,        // 放大30%
    'opacity': 1.0,     // 完全不透明
    'isVisible': true   // 确保可见
  });
}
print('已优化 ' + importantItems.length + ' 个重要图例项的显示');

// 临时图例项: 设为半透明
var tempItems = filterLegendItemsByTags('临时', 'contains');
for (var i = 0; i < tempItems.length; i = i + 1) {
  var item = tempItems[i];
  updateLegendItemOpacity(item.groupId, item.id, 0.6);
}
print('已设置 ' + tempItems.length + ' 个临时图例项为半透明');
```

### 4. 图例统计和分析

```javascript
// 图例使用情况分析
function analyzeLegendUsage() {
  var allGroups = getLegendGroups();
  var totalItems = 0;
  var visibleItems = 0;
  var taggedItems = 0;
  var linkedItems = 0;
  
  for (var i = 0; i < allGroups.length; i = i + 1) {
    var group = allGroups[i];
    var items = getLegendItems(group.id);
    
    for (var j = 0; j < items.length; j = j + 1) {
      var item = items[j];
      totalItems = totalItems + 1;
      
      if (item.isVisible) visibleItems = visibleItems + 1;
      if (item.tags.length > 0) taggedItems = taggedItems + 1;
      if (item.url != null && item.url != '') linkedItems = linkedItems + 1;
    }
  }
  
  print('=== 图例使用情况分析 ===');
  print('图例组总数: ' + allGroups.length);
  print('图例项总数: ' + totalItems);
  print('可见图例项: ' + visibleItems + ' (' + (totalItems > 0 ? (visibleItems * 100 / totalItems).toFixed(1) : '0') + '%)');
  print('有标签图例项: ' + taggedItems + ' (' + (totalItems > 0 ? (taggedItems * 100 / totalItems).toFixed(1) : '0') + '%)');
  print('有链接图例项: ' + linkedItems + ' (' + (totalItems > 0 ? (linkedItems * 100 / totalItems).toFixed(1) : '0') + '%)');
}

// 执行分析
analyzeLegendUsage();
```

### 5. 标签系统优化

```javascript
// 为未标记的图例项自动添加标签
var untaggedItems = filterLegendItemsByTags([], 'exact');

for (var i = 0; i < untaggedItems.length; i = i + 1) {
  var item = untaggedItems[i];
  var autoTags = ['自动标记'];
  
  // 根据位置自动添加区域标签
  if (item.position.x < 0.3) autoTags.push('左侧');
  else if (item.position.x > 0.7) autoTags.push('右侧');
  else autoTags.push('中央');
  
  if (item.position.y < 0.3) autoTags.push('上方');
  else if (item.position.y > 0.7) autoTags.push('下方');
  else autoTags.push('中间');
  
  // 根据大小添加重要性标签
  if (item.size > 1.2) autoTags.push('大型');
  else if (item.size < 0.8) autoTags.push('小型');
  
  updateLegendItem(item.groupId, item.id, {
    'tags': autoTags
  });
}

print('已为 ' + untaggedItems.length + ' 个图例项自动添加标签');
```

## 注意事项

1. **坐标系统**：图例项位置使用相对坐标 (0.0-1.0)，(0,0) 为左上角，(1,1) 为右下角
2. **透明度范围**：透明度值范围为 0.0-1.0，函数会自动限制在此范围内
3. **旋转角度**：旋转角度以度为单位，正值为顺时针旋转
4. **大小缩放**：大小为缩放比例，1.0 为原始大小，2.0 为两倍大小
5. **数据实时性**：所有操作都通过响应式数据流进行，确保界面实时更新
6. **错误处理**：当图例组或图例项不存在时，函数会抛出异常
7. **可见性过滤**：过滤函数会自动跳过不可见的图例组和图例项
8. **标签匹配**：标签匹配区分大小写
9. **URL支持**：支持网络链接 (http/https) 和 VFS 协议链接

---

更新时间：2025年6月16日  
功能版本：v1.0 - 图例和图例组全功能支持
