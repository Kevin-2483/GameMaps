# R6Box 脚本引擎 API 文档

## 概述

R6Box 使用 Hetu 脚本语言作为脚本引擎，提供了丰富的外部函数来操作地图数据、控制 TTS、管理图例等功能。本文档详细介绍了所有可用的外部函数及其使用方法。

## 函数分类

### 1. 基础函数

#### log(message)
记录日志信息
- **参数**: 
  - `message` (String): 要记录的日志消息
- **返回值**: 无
- **示例**:
```hetu
log('脚本开始执行');
```

#### delay(milliseconds)
延迟执行
- **参数**: 
  - `milliseconds` (Number): 延迟的毫秒数
- **返回值**: 无
- **示例**:
```hetu
delay(1000); // 延迟1秒
```

### 2. 数学函数

#### sin(x), cos(x), tan(x)
三角函数
- **参数**: 
  - `x` (Number): 角度值（弧度）
- **返回值**: Number - 计算结果
- **示例**:
```hetu
var result = sin(3.14159 / 2); // 结果为 1
```

#### sqrt(x), abs(x)
数学运算函数
- **参数**: 
  - `x` (Number): 输入数值
- **返回值**: Number - 计算结果
- **示例**:
```hetu
var squareRoot = sqrt(16); // 结果为 4
var absolute = abs(-5); // 结果为 5
```

#### pow(base, exponent)
幂运算
- **参数**: 
  - `base` (Number): 底数
  - `exponent` (Number): 指数
- **返回值**: Number - 计算结果
- **示例**:
```hetu
var power = pow(2, 3); // 结果为 8
```

#### random()
生成随机数
- **参数**: 无
- **返回值**: Number - 0到1之间的随机数
- **示例**:
```hetu
var randomValue = random();
```

### 3. 地图数据访问函数

#### getLayers() [异步]
获取所有地图图层
- **参数**: 无
- **返回值**: List - 图层对象列表
- **示例**:
```hetu
fun main() {
    var layers = getLayers();
    log('图层数量: ${layers.length}');
    
    for (var layer in layers) {
        log('图层ID: ${layer.id}, 名称: ${layer.name}');
    }
}
```

#### getLayerById(layerId) [异步]
根据ID获取特定图层
- **参数**: 
  - `layerId` (String): 图层ID
- **返回值**: Object - 图层对象，如果未找到则为null
- **示例**:
```hetu
var layer = getLayerById('layer_001');
if (layer != null) {
    log('找到图层: ${layer.name}');
}
```

#### getElementsInLayer(layerId) [异步]
获取指定图层中的所有元素
- **参数**: 
  - `layerId` (String): 图层ID
- **返回值**: List - 元素对象列表
- **示例**:
```hetu
var elements = getElementsInLayer('layer_001');
for (var element in elements) {
    log('元素ID: ${element.id}, 类型: ${element.type}');
}
```

#### getAllElements() [异步]
获取所有元素（包括图层和便签中的元素）
- **参数**: 无
- **返回值**: List - 所有元素对象列表
- **示例**:
```hetu
var allElements = getAllElements();
log('总元素数量: ${allElements.length}');
```

### 4. 元素操作函数

#### updateElementProperty(elementId, property, value)
更新元素属性
- **参数**: 
  - `elementId` (String): 元素ID
  - `property` (String): 属性名称
  - `value` (Any): 新的属性值
- **返回值**: 无
- **支持的属性**:
  - `text`: 文本内容
  - `fontSize`: 字体大小
  - `color`: 颜色（整数值）
  - `strokeWidth`: 线条宽度
  - `density`: 密度
  - `rotation`: 旋转角度
  - `curvature`: 曲率
  - `zIndex`: 层级
  - `tags`: 标签列表
- **示例**:
```hetu
// 更新文本内容
updateElementProperty('text_001', 'text', '新的文本内容');

// 更新字体大小
updateElementProperty('text_001', 'fontSize', 20.0);

// 更新颜色（红色）
updateElementProperty('text_001', 'color', 0xFFFF0000);

// 更新标签
updateElementProperty('element_001', 'tags', ['重要', '标记']);
```

#### moveElement(elementId, positionJson)
移动元素位置
- **参数**: 
  - `elementId` (String): 元素ID
  - `positionJson` (String): JSON格式的位置偏移量
- **返回值**: 无
- **JSON格式**: `{"deltaX": 数值, "deltaY": 数值}`
- **示例**:
```hetu
// 向右移动50像素，向下移动30像素
moveElement('element_001', '{"deltaX": 50.0, "deltaY": 30.0}');

// 向左上角移动
moveElement('element_002', '{"deltaX": -20.0, "deltaY": -15.0}');
```

### 5. 文本元素函数

#### createTextElement(text, x, y, optionsJson)
创建文本元素
- **参数**: 
  - `text` (String): 文本内容
  - `x` (Number): X坐标
  - `y` (Number): Y坐标
  - `optionsJson` (String, 可选): JSON格式的选项
- **返回值**: 无
- **选项JSON格式**:
```json
{
  "fontSize": 16.0,
  "color": 0xFF000000,
  "tags": ["标签1", "标签2"]
}
```
- **示例**:
```hetu
// 创建简单文本
createTextElement('Hello World', 100.0, 200.0);

// 创建带选项的文本
var options = '{
  "fontSize": 24.0,
  "color": 0xFF0000FF,
  "tags": ["重要", "标题"]
}';
createTextElement('重要标题', 150.0, 100.0, options);
```

#### updateTextContent(elementId, newText)
更新文本内容
- **参数**: 
  - `elementId` (String): 文本元素ID
  - `newText` (String): 新的文本内容
- **返回值**: 无
- **示例**:
```hetu
updateTextContent('text_001', '更新后的文本');
```

#### updateTextSize(elementId, newSize)
更新文本大小
- **参数**: 
  - `elementId` (String): 文本元素ID
  - `newSize` (Number): 新的字体大小
- **返回值**: 无
- **示例**:
```hetu
updateTextSize('text_001', 18.0);
```

#### getTextElements() [异步]
获取所有文本元素
- **参数**: 无
- **返回值**: List - 文本元素列表
- **示例**:
```hetu
var textElements = getTextElements();
for (var element in textElements) {
    log('文本: ${element.text}, 大小: ${element.fontSize}');
}
```

#### findTextElementsByContent(searchText) [异步]
根据内容查找文本元素
- **参数**: 
  - `searchText` (String): 要搜索的文本内容
- **返回值**: List - 匹配的文本元素列表
- **示例**:
```hetu
var foundElements = findTextElementsByContent('重要');
log('找到 ${foundElements.length} 个包含"重要"的文本元素');
```

### 6. 便签操作函数

#### getStickyNotes() [异步]
获取所有便签
- **参数**: 无
- **返回值**: List - 便签对象列表
- **示例**:
```hetu
var stickyNotes = getStickyNotes();
for (var note in stickyNotes) {
    log('便签ID: ${note.id}, 元素数量: ${note.elements.length}');
}
```

#### getStickyNoteById(noteId) [异步]
根据ID获取特定便签
- **参数**: 
  - `noteId` (String): 便签ID
- **返回值**: Object - 便签对象，如果未找到则为null
- **示例**:
```hetu
var note = getStickyNoteById('note_001');
if (note != null) {
    log('便签包含 ${note.elements.length} 个元素');
}
```

#### getElementsInStickyNote(noteId) [异步]
获取指定便签中的所有元素
- **参数**: 
  - `noteId` (String): 便签ID
- **返回值**: List - 元素对象列表
- **示例**:
```hetu
var elements = getElementsInStickyNote('note_001');
for (var element in elements) {
    log('便签元素: ${element.id}');
}
```

### 7. 图例管理函数

#### getLegendGroups() [异步]
获取所有图例组
- **参数**: 无
- **返回值**: List - 图例组对象列表
- **示例**:
```hetu
var legendGroups = getLegendGroups();
for (var group in legendGroups) {
    log('图例组: ${group.name}, 可见: ${group.isVisible}');
}
```

#### getLegendGroupById(groupId) [异步]
根据ID获取特定图例组
- **参数**: 
  - `groupId` (String): 图例组ID
- **返回值**: Object - 图例组对象，如果未找到则为null

#### updateLegendGroup(groupId, updatesJson)
更新图例组
- **参数**: 
  - `groupId` (String): 图例组ID
  - `updatesJson` (String): JSON格式的更新数据
- **返回值**: 无
- **更新JSON格式**:
```json
{
  "name": "新名称",
  "isVisible": true,
  "opacity": 0.8,
  "tags": ["标签1", "标签2"]
}
```
- **示例**:
```hetu
var updates = '{
  "name": "更新的图例组",
  "isVisible": true,
  "opacity": 0.9
}';
updateLegendGroup('group_001', updates);
```

#### updateLegendGroupVisibility(groupId, isVisible)
更新图例组可见性
- **参数**: 
  - `groupId` (String): 图例组ID
  - `isVisible` (Boolean): 是否可见
- **返回值**: 无
- **示例**:
```hetu
updateLegendGroupVisibility('group_001', false); // 隐藏图例组
```

#### updateLegendGroupOpacity(groupId, opacity)
更新图例组透明度
- **参数**: 
  - `groupId` (String): 图例组ID
  - `opacity` (Number): 透明度值（0.0-1.0）
- **返回值**: 无
- **示例**:
```hetu
updateLegendGroupOpacity('group_001', 0.5); // 设置50%透明度
```

### 8. TTS 语音合成函数

#### say(text, optionsJson)
播放语音
- **参数**: 
  - `text` (String): 要播放的文本
  - `optionsJson` (String, 可选): JSON格式的TTS选项
- **返回值**: 无
- **选项JSON格式**:
```json
{
  "language": "zh-CN",
  "speechRate": 1.0,
  "volume": 1.0,
  "pitch": 1.0,
  "voice": {"name": "voice_name"}
}
```
- **示例**:
```hetu
// 简单播放
say('Hello World');

// 带选项播放
var options = '{
  "language": "zh-CN",
  "speechRate": 0.8,
  "volume": 0.9,
  "pitch": 1.2
}';
say('你好，世界！', options);
```

#### ttsStop()
停止TTS播放
- **参数**: 无
- **返回值**: 无
- **示例**:
```hetu
ttsStop();
```

#### ttsGetLanguages() [异步]
获取可用的TTS语言列表
- **参数**: 无
- **返回值**: List - 语言代码列表
- **示例**:
```hetu
var languages = ttsGetLanguages();
for (var lang in languages) {
    log('可用语言: ${lang}');
}
```

#### ttsGetVoices() [异步]
获取可用的TTS语音列表
- **参数**: 无
- **返回值**: List - 语音对象列表
- **示例**:
```hetu
var voices = ttsGetVoices();
for (var voice in voices) {
    log('语音: ${voice.name}, 语言: ${voice.language}');
}
```

#### ttsIsLanguageAvailable(language) [异步]
检查指定语言是否可用
- **参数**: 
  - `language` (String): 语言代码
- **返回值**: Boolean - 是否可用
- **示例**:
```hetu
var isAvailable = ttsIsLanguageAvailable('zh-CN');
if (isAvailable) {
    log('中文TTS可用');
}
```

#### ttsGetSpeechRateRange() [异步]
获取语音速率范围
- **参数**: 无
- **返回值**: Object - 包含min和max的对象
- **示例**:
```hetu
var rateRange = ttsGetSpeechRateRange();
log('语音速率范围: ${rateRange.min} - ${rateRange.max}');
```

### 9. 标签过滤函数

#### filterElementsByTags(tagsJson, mode) [异步]
根据标签过滤元素
- **参数**: 
  - `tagsJson` (String): JSON格式的标签数组
  - `mode` (String, 可选): 过滤模式（"contains", "equals", "excludes"），默认为"contains"
- **返回值**: List - 过滤后的元素列表
- **示例**:
```hetu
// 包含指定标签的元素（默认模式）
var elements = filterElementsByTags('["重要", "标记"]');

// 包含指定标签的元素（显式指定模式）
var elements2 = filterElementsByTags('["重要", "标记"]', 'contains');

// 完全匹配标签的元素
var exactElements = filterElementsByTags('["重要"]', 'equals');

// 排除指定标签的元素
var excludedElements = filterElementsByTags('["隐藏"]', 'excludes');
```

#### filterStickyNotesByTags(tagsJson) [异步]
根据标签过滤便签
- **参数**: 
  - `tagsJson` (String): JSON格式的标签数组
- **返回值**: List - 过滤后的便签列表
- **示例**:
```hetu
var filteredNotes = filterStickyNotesByTags('["重要", "标记"]');
```

#### filterStickyNoteElementsByTags(tagsJson) [异步]
根据标签过滤便签中的元素
- **参数**: 
  - `tagsJson` (String): JSON格式的标签数组
- **返回值**: List - 过滤后的元素列表
- **示例**:
```hetu
var filteredElements = filterStickyNoteElementsByTags('["重要"]');
```

#### filterLegendGroupsByTags(tagsJson) [异步]
根据标签过滤图例组
- **参数**: 
  - `tagsJson` (String): JSON格式的标签数组
- **返回值**: List - 过滤后的图例组列表
- **示例**:
```hetu
var filteredGroups = filterLegendGroupsByTags('["显示", "重要"]');
```

#### filterLegendItemsByTags(tagsJson) [异步]
根据标签过滤图例项
- **参数**: 
  - `tagsJson` (String): JSON格式的标签数组
- **返回值**: List - 过滤后的图例项列表
- **示例**:
```hetu
var filteredItems = filterLegendItemsByTags('["显示"]');
```

#### filterElementsInStickyNotesByTags(tagsJson, mode) [异步]
根据标签过滤便签中的元素
- **参数**: 
  - `tagsJson` (String): JSON格式的标签数组
  - `mode` (String, 可选): 过滤模式（"contains", "equals", "excludes"），默认为"contains"
- **返回值**: List - 过滤后的元素列表
- **示例**:
```hetu
var elements = filterElementsInStickyNotesByTags('["重要"]', 'contains');
```

#### filterLegendItemsInGroupByTags(groupId, tagsJson, mode) [异步]
根据标签过滤指定图例组中的图例项
- **参数**: 
  - `groupId` (String): 图例组ID
  - `tagsJson` (String): JSON格式的标签数组
  - `mode` (String, 可选): 过滤模式（"contains", "equals", "excludes"），默认为"contains"
- **返回值**: List - 过滤后的图例项列表
- **示例**:
```hetu
var items = filterLegendItemsInGroupByTags('group_001', '["重要"]', 'contains');
```

### 10. 文件操作函数

#### readjson(filePath) [异步]
读取JSON文件
- **参数**: 
  - `filePath` (String): 文件路径
- **返回值**: Object - 解析后的JSON对象
- **示例**:
```hetu
var data = readjson('config.json');
log('配置数据: ${data}');
```

#### writetext(filePath, content)
写入文本文件
- **参数**: 
  - `filePath` (String): 文件路径
  - `content` (String): 文件内容
- **返回值**: 无
- **示例**:
```hetu
writetext('output.txt', '这是输出内容');
```

## 完整示例脚本

### 示例1：地图元素操作脚本

```hetu
// 地图元素操作示例
fun main() {
    log('开始地图元素操作脚本');
    
    // 获取所有图层
    var layers = getLayers();
    log('找到 ${layers.length} 个图层');
    
    // 遍历每个图层
    for (var layer in layers) {
        log('处理图层: ${layer.name}');
        
        // 获取图层中的元素
        var elements = getElementsInLayer(layer.id);
        log('图层 ${layer.name} 包含 ${elements.length} 个元素');
        
        // 处理文本元素
        for (var element in elements) {
            if (element.type == 'text') {
                // 更新文本大小
                updateElementProperty(element.id, 'fontSize', 18.0);
                
                // 添加标签
                updateElementProperty(element.id, 'tags', ['处理过', '文本']);
                
                log('更新了文本元素: ${element.id}');
            }
        }
    }
    
    // 创建新的文本元素
    createTextElement('脚本生成的文本', 100.0, 100.0, 
        '{"fontSize": 20.0, "color": 0xFF0000FF, "tags": ["脚本生成"]}');
    
    log('地图元素操作完成');
}
```

### 示例2：TTS 语音播放脚本

```hetu
// TTS语音播放示例
fun main() {
    log('开始TTS语音播放脚本');
    
    // 检查TTS系统状态
    var languages = ttsGetLanguages();
    log('可用语言数量: ${languages.length}');
    
    var voices = ttsGetVoices();
    log('可用语音数量: ${voices.length}');
    
    // 检查中文是否可用
    var chineseAvailable = ttsIsLanguageAvailable('zh-CN');
    if (chineseAvailable) {
        log('中文TTS可用');
        
        // 播放中文语音
        var chineseOptions = '{
            "language": "zh-CN",
            "speechRate": 0.9,
            "volume": 0.8,
            "pitch": 1.0
        }';
        say('欢迎使用R6Box脚本引擎', chineseOptions);
        
        delay(3000); // 等待3秒
    }
    
    // 检查英文是否可用
    var englishAvailable = ttsIsLanguageAvailable('en-US');
    if (englishAvailable) {
        log('英文TTS可用');
        
        // 播放英文语音
        var englishOptions = '{
            "language": "en-US",
            "speechRate": 1.0,
            "volume": 0.9,
            "pitch": 1.1
        }';
        say('Welcome to R6Box Script Engine', englishOptions);
        
        delay(3000); // 等待3秒
    }
    
    log('TTS语音播放脚本完成');
}
```

### 示例3：标签过滤和数据分析脚本

```hetu
// 标签过滤和数据分析示例
fun main() {
    log('开始标签过滤和数据分析脚本');
    
    // 获取所有元素
    var allElements = getAllElements();
    log('总元素数量: ${allElements.length}');
    
    // 按标签分类统计
    var importantElements = filterElementsByTags('["重要"]', 'contains');
    var textElements = filterElementsByTags('["文本"]', 'contains');
    var hiddenElements = filterElementsByTags('["隐藏"]', 'excludes');
    
    log('重要元素数量: ${importantElements.length}');
    log('文本元素数量: ${textElements.length}');
    log('隐藏元素数量: ${hiddenElements.length}');
    
    // 分析便签
    var stickyNotes = getStickyNotes();
    log('便签数量: ${stickyNotes.length}');
    
    var totalElementsInNotes = 0;
    for (var note in stickyNotes) {
        var elementsInNote = getElementsInStickyNote(note.id);
        totalElementsInNotes += elementsInNote.length;
        log('便签 ${note.id} 包含 ${elementsInNote.length} 个元素');
    }
    log('便签中总元素数量: ${totalElementsInNotes}');
    
    // 分析图例组
    var legendGroups = getLegendGroups();
    log('图例组数量: ${legendGroups.length}');
    
    var visibleGroups = 0;
    for (var group in legendGroups) {
        if (group.isVisible) {
            visibleGroups++;
        }
        log('图例组 ${group.name}: 可见=${group.isVisible}, 透明度=${group.opacity}');
    }
    log('可见图例组数量: ${visibleGroups}');
    
    // 生成报告
    var report = '数据分析报告:\n';
    report += '- 总元素: ${allElements.length}\n';
    report += '- 重要元素: ${importantElements.length}\n';
    report += '- 便签: ${stickyNotes.length}\n';
    report += '- 图例组: ${legendGroups.length} (可见: ${visibleGroups})\n';
    
    // 播放报告
    say(report);
    
    // 保存报告到文件
    writetext('analysis_report.txt', report);
    
    log('标签过滤和数据分析脚本完成');
}
```

### 示例4：交互式图例控制脚本

```hetu
// 交互式图例控制示例
fun main() {
    log('开始交互式图例控制脚本');
    
    // 获取所有图例组
    var legendGroups = getLegendGroups();
    
    if (legendGroups.length == 0) {
        log('没有找到图例组');
        say('没有找到图例组');
        return;
    }
    
    log('找到 ${legendGroups.length} 个图例组');
    say('找到 ${legendGroups.length} 个图例组，开始控制演示');
    
    // 逐个控制图例组
    for (var i = 0; i < legendGroups.length; i++) {
        var group = legendGroups[i];
        log('控制图例组: ${group.name}');
        
        // 播放当前操作
        say('正在控制图例组: ${group.name}');
        delay(1000);
        
        // 隐藏图例组
        updateLegendGroupVisibility(group.id, false);
        say('隐藏图例组');
        delay(1500);
        
        // 显示图例组
        updateLegendGroupVisibility(group.id, true);
        say('显示图例组');
        delay(1000);
        
        // 调整透明度
        updateLegendGroupOpacity(group.id, 0.3);
        say('设置透明度为30%');
        delay(1500);
        
        updateLegendGroupOpacity(group.id, 0.7);
        say('设置透明度为70%');
        delay(1500);
        
        // 恢复原始透明度
        updateLegendGroupOpacity(group.id, group.opacity);
        say('恢复原始透明度');
        delay(1000);
        
        log('图例组 ${group.name} 控制完成');
    }
    
    say('图例控制演示完成');
    log('交互式图例控制脚本完成');
}
```

## 最佳实践

### 1. 错误处理
```hetu
fun safeGetLayer(layerId) {
    try {
        var layer = getLayerById(layerId);
        if (layer == null) {
            log('警告: 未找到图层 ${layerId}');
            return null;
        }
        return layer;
    } catch (e) {
        log('错误: 获取图层失败 - ${e}');
        return null;
    }
}
```

### 2. 参数验证
```hetu
fun updateElementSafely(elementId, property, value) {
    if (elementId == null || elementId.isEmpty) {
        log('错误: 元素ID不能为空');
        return false;
    }
    
    if (property == null || property.isEmpty) {
        log('错误: 属性名不能为空');
        return false;
    }
    
    updateElementProperty(elementId, property, value);
    return true;
}
```

### 3. 异步函数处理
```hetu
fun processLayersAsync() {
    // 获取图层（异步）
    var layers = getLayers();
    
    // 处理每个图层
    for (var layer in layers) {
        // 获取元素（异步）
        var elements = getElementsInLayer(layer.id);
        
        // 处理元素（同步）
        for (var element in elements) {
            updateElementProperty(element.id, 'tags', ['处理过']);
        }
    }
}
```

### 4. JSON 数据处理
```hetu
fun createTtsOptions(language, speechRate, volume, pitch) {
    var options = {
        'language': language,
        'speechRate': speechRate,
        'volume': volume,
        'pitch': pitch
    };
    
    // 转换为JSON字符串
    return jsonEncode(options);
}

fun parsePosition(positionJson) {
    try {
        var position = jsonDecode(positionJson);
        return {
            'x': position['x'] ?? 0.0,
            'y': position['y'] ?? 0.0
        };
    } catch (e) {
        log('JSON解析错误: ${e}');
        return {'x': 0.0, 'y': 0.0};
    }
}
```

## 注意事项

1. **异步函数**: 标记为 `[异步]` 的函数需要等待结果返回
2. **JSON 参数**: 某些函数需要 JSON 格式的字符串参数，注意格式正确性
3. **颜色值**: 颜色使用 32 位整数表示，格式为 0xAARRGGBB
4. **坐标系**: 使用屏幕坐标系，原点在左上角
5. **错误处理**: 建议使用 try-catch 处理可能的异常
6. **性能考虑**: 避免在循环中频繁调用异步函数

## 调试技巧

1. 使用 `log()` 函数记录执行过程
2. 检查异步函数的返回值是否为 null
3. 验证 JSON 参数的格式
4. 使用延迟函数控制执行节奏
5. 分步测试复杂的操作流程