import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/services/script_engine.dart';
import '../lib/models/script_data.dart';
import '../lib/models/map_layer.dart';

void main() {
  test('Script Engine Debug Test', () async {
    final scriptEngine = ScriptEngine();
    await scriptEngine.initialize();
    
    final now = DateTime.now();
    final testLayers = [
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
            points: [const Offset(0, 0), const Offset(100, 100)],
          ),
        ],
      ),
    ];

    scriptEngine.setMapDataAccessor(testLayers, (updatedLayers) {});

    final script = ScriptData(
      id: 'debug-script',
      name: 'Debug Script',
      type: ScriptType.automation,      content: '''
      external fun countElements();
      external fun print(message);
      
      print('Starting script...');
      var totalCount = countElements();
      print('Total elements: ' + totalCount.toString());
      totalCount;
      ''',
      parameters: {},
      createdAt: now,
      updatedAt: now,
    );

    final result = await scriptEngine.executeScript(script);
    debugPrint('Script result: success=${result.success}, result=${result.result}, error=${result.error}');
    
    expect(result.success, isTrue);
    expect(result.result, equals(1));
  });
}
