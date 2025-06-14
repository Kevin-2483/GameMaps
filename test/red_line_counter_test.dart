import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/services/script_engine.dart';
import '../lib/models/script_data.dart';
import '../lib/models/map_layer.dart';

void main() {
  test('Red Line Counter Script Test', () async {
    final scriptEngine = ScriptEngine();
    await scriptEngine.initialize();
    
    final now = DateTime.now();
    
    // 创建测试数据，包含一些红色线条和带"num"的文本元素
    final testLayers = [
      MapLayer(
        id: 'test-layer-1',
        name: 'Test Layer 1',
        order: 0,
        isVisible: true,
        opacity: 1.0,
        createdAt: now,
        updatedAt: now,
        elements: [
          // 红色线条
          MapDrawingElement(
            id: 'red-line-1',
            type: DrawingElementType.line,
            color: const Color(0xFFFF0000), // 红色
            strokeWidth: 2.0,
            density: 1.0,
            rotation: 0.0,
            curvature: 0.0,
            zIndex: 0,
            text: '',
            fontSize: 14.0,
            createdAt: now,
            points: [const Offset(0, 0), const Offset(100, 100)],
          ),
          // 蓝色线条（不应被计算）
          MapDrawingElement(
            id: 'blue-line-1',
            type: DrawingElementType.line,
            color: Colors.blue,
            strokeWidth: 2.0,
            density: 1.0,
            rotation: 0.0,
            curvature: 0.0,
            zIndex: 0,
            text: '',
            fontSize: 14.0,
            createdAt: now,
            points: [const Offset(200, 200), const Offset(300, 300)],
          ),
          // 包含"num"的文本元素
          MapDrawingElement(
            id: 'text-num-1',
            type: DrawingElementType.text,
            color: Colors.black,
            strokeWidth: 1.0,
            density: 1.0,
            rotation: 0.0,
            curvature: 0.0,
            zIndex: 0,
            text: 'Count: num',
            fontSize: 14.0,
            createdAt: now,
            points: [const Offset(50, 50)],
          ),
        ],
      ),
      MapLayer(
        id: 'test-layer-2',
        name: 'Test Layer 2',
        order: 1,
        isVisible: true,
        opacity: 1.0,
        createdAt: now,
        updatedAt: now,
        elements: [
          // 另一条红色线条
          MapDrawingElement(
            id: 'red-line-2',
            type: DrawingElementType.arrow,
            color: const Color(0xFFFF0000), // 红色
            strokeWidth: 3.0,
            density: 1.0,
            rotation: 0.0,
            curvature: 0.0,
            zIndex: 0,
            text: '',
            fontSize: 14.0,
            createdAt: now,
            points: [const Offset(400, 400), const Offset(500, 500)],
          ),
          // 另一个包含"num"的文本元素
          MapDrawingElement(
            id: 'text-num-2',
            type: DrawingElementType.text,
            color: Colors.black,
            strokeWidth: 1.0,
            density: 1.0,
            rotation: 0.0,
            curvature: 0.0,
            zIndex: 0,
            text: 'Total num items',
            fontSize: 16.0,
            createdAt: now,
            points: [const Offset(150, 150)],
          ),
        ],
      ),
    ];

    scriptEngine.setMapDataAccessor(testLayers, (updatedLayers) {
      // 测试回调
    });

    // 读取红色线条统计脚本
    final scriptContent = '''
// 使用过滤函数的版本：统计红色线条并更新文本

// 定义过滤红色线条的函数
fun isRedLine(element) {
    var type = element['type'];
    var color = element['color'];
    var redColor = 4294901760; // 0xFFFF0000
    
    // 检查是否为线条类型
    var isLine = (type == 'line' || type == 'dashedLine' || type == 'arrow' || type == 'freeDrawing');
    
    // 检查是否为红色
    var isRed = (color == redColor);
    
    return isLine && isRed;
}

// 主函数
fun main() {
    log('=== 红色线条统计脚本 ===');
    
    // 使用过滤函数获取所有红色线条
    var redLines = filterElements(isRedLine);
    var redLineCount = redLines.length;
    
    log('在所有图层中找到 ' + redLineCount.toString() + ' 条红色线条');
    
    // 打印每条红色线条的详细信息
    for (var i = 0; i < redLines.length; i = i + 1) {
        var line = redLines[i];
        log('  红色线条 ' + (i + 1).toString() + ': ' + 
            line['type'] + ' (图层: ' + line['layerId'] + ')');
    }
    
    // 获取包含"num"的文本元素
    var numTexts = findTextElementsByContent('num');
    log('找到 ' + numTexts.length.toString() + ' 个包含"num"的文本元素');
    
    var updateCount = 0;
    
    // 更新每个包含"num"的文本元素
    for (var i = 0; i < numTexts.length; i = i + 1) {
        var textElement = numTexts[i];
        var elementId = textElement['id'];
        var currentText = textElement['text'];
        
        // 构建新的文本内容
        var newText = 'Red lines: ' + redLineCount.toString();
        
        // 如果当前文本不仅仅是"num"，则替换"num"部分
        if (currentText.length > 3) {
            newText = currentText.replace('num', redLineCount.toString());
        }
        
        // 执行更新
        if (updateTextContent(elementId, newText)) {
            updateCount = updateCount + 1;
            log('  已更新: "' + newText + '"');
        } else {
            log('  更新失败: ' + elementId);
        }
    }
    
    // 输出结果摘要
    log('=== 执行完成 ===');
    log('红色线条总数: ' + redLineCount.toString());
    log('更新文本元素: ' + updateCount.toString());
    
    return {
        'redLineCount': redLineCount,
        'updatedTexts': updateCount,
        'success': true
    };
}

// 执行脚本
main();
    ''';

    final script = ScriptData(
      id: 'red-line-counter-test',
      name: 'Red Line Counter Test',
      type: ScriptType.automation,
      content: scriptContent,
      parameters: {},
      createdAt: now,
      updatedAt: now,
    );

    final result = await scriptEngine.executeScript(script);
    debugPrint('Script result: success=${result.success}, result=${result.result}, error=${result.error}');
    
    // 获取执行日志
    final logs = scriptEngine.getExecutionLogs();
    debugPrint('Execution logs (${logs.length} entries):');
    for (final log in logs) {
      debugPrint('  $log');
    }
    
    expect(result.success, isTrue);
    // 应该找到2条红色线条
    // 应该更新2个文本元素
  });
}
