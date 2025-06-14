import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/services/script_engine.dart';
import '../lib/models/script_data.dart';
import '../lib/models/map_layer.dart';

void main() {
  group('ScriptEngine Tests', () {
    late ScriptEngine scriptEngine;

    setUp(() {
      scriptEngine = ScriptEngine();
    });

    test('Should initialize script engine', () async {
      await scriptEngine.initialize();
      expect(scriptEngine, isNotNull);
    });

    test('Should execute simple script', () async {
      await scriptEngine.initialize();
      
      final now = DateTime.now();
      final testLayers = <MapLayer>[
        MapLayer(
          id: 'test-layer',
          name: 'Test Layer',
          order: 0,
          isVisible: true,
          opacity: 1.0,
          createdAt: now,
          updatedAt: now,
          elements: [
            MapDrawingElement(
              id: 'test-element',
              type: DrawingElementType.rectangle,
              color: Colors.red,
              strokeWidth: 2.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 0,
              text: '',
              fontSize: 14.0,
              createdAt: now,
              points: [
                const Offset(0, 0),
                const Offset(100, 100),
              ],
            ),
          ],
        ),
      ];

      scriptEngine.setMapDataAccessor(testLayers, (updatedLayers) {
        // 测试更新回调
      });      final script = ScriptData(
        id: 'test-script',
        name: 'Test Script',
        type: ScriptType.automation,
        content: '''
        external fun getLayers
        var layers = getLayers();
        print('Found layers: ' + layers.length.toString());
        ''',
        parameters: {},
        createdAt: now,
        updatedAt: now,
      );final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Script execution failed: ${result.error}');
      }
      expect(result.success, isTrue);
    });

    test('Should handle function calls in scripts', () async {
      await scriptEngine.initialize();
      
      final now = DateTime.now();
      final testLayers = <MapLayer>[
        MapLayer(
          id: 'test-layer',
          name: 'Test Layer',
          order: 0,
          isVisible: true,
          opacity: 1.0,
          createdAt: now,
          updatedAt: now,
          elements: [
            MapDrawingElement(
              id: 'test-element-1',
              type: DrawingElementType.rectangle,
              color: Colors.red,
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
            MapDrawingElement(
              id: 'test-element-2',
              type: DrawingElementType.line,
              color: Colors.blue,
              strokeWidth: 3.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 1,
              text: '',
              fontSize: 14.0,
              createdAt: now,
              points: [const Offset(50, 50), const Offset(75, 75)],
            ),
          ],
        ),
      ];

      scriptEngine.setMapDataAccessor(testLayers, (updatedLayers) {
        // 测试更新回调
      });      final script = ScriptData(
        id: 'filter-test-script',
        name: 'Filter Test Script',
        type: ScriptType.filter,
        content: '''
        external fun filterElements
        
        fun isRectangle(element) {
          return element['type'] == 'rectangle';
        }
        
        var rectangles = filterElements(isRectangle);
        print('Found rectangles: ' + rectangles.length.toString());
        ''',
        parameters: {},
        createdAt: now,
        updatedAt: now,
      );final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Filter script execution failed: ${result.error}');
      }
      expect(result.success, isTrue);
    });

    tearDown(() {
      scriptEngine.dispose();
    });
  });
}
