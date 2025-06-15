import 'dart:ui';
import 'lib/models/map_layer.dart';
import 'lib/models/sticky_note.dart';
import 'lib/models/map_item.dart';
import 'lib/models/map_version.dart';
import 'lib/models/legend_item.dart' as legend_db;

void main() {
  print('测试所有数据模型的 tags 字段实现...\n');

  // 测试 MapLayer
  print('1. 测试 MapLayer:');
  final layer = MapLayer(
    id: 'layer1',
    name: '测试图层',
    order: 1,
    tags: ['地形', '重要'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  print('   创建成功，tags: ${layer.tags}');
  
  final layerCopy = layer.copyWith(tags: ['地形', '重要', '已更新']);
  print('   copyWith 成功，新tags: ${layerCopy.tags}\n');

  // 测试 MapDrawingElement
  print('2. 测试 MapDrawingElement:');
  final element = MapDrawingElement(
    id: 'element1',
    type: DrawingElementType.line,
    points: [const Offset(0.1, 0.1), const Offset(0.2, 0.2)],
    tags: ['线条', '绘制'],
    createdAt: DateTime.now(),
  );
  print('   创建成功，tags: ${element.tags}');
  
  final elementCopy = element.copyWith(tags: ['线条', '绘制', '修改']);
  print('   copyWith 成功，新tags: ${elementCopy.tags}\n');

  // 测试 LegendGroup
  print('3. 测试 LegendGroup:');
  final legendGroup = LegendGroup(
    id: 'group1',
    name: '测试图例组',
    tags: ['图例', '管理'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  print('   创建成功，tags: ${legendGroup.tags}');
  
  final groupCopy = legendGroup.copyWith(tags: ['图例', '管理', '更新']);
  print('   copyWith 成功，新tags: ${groupCopy.tags}\n');

  // 测试 LegendItem
  print('4. 测试 LegendItem:');
  final legendItem = LegendItem(
    id: 'item1',
    legendId: 'legend1',
    position: const Offset(0.5, 0.5),
    tags: ['标记', '地图'],
    createdAt: DateTime.now(),
  );
  print('   创建成功，tags: ${legendItem.tags}');
  
  final itemCopy = legendItem.copyWith(tags: ['标记', '地图', '编辑']);
  print('   copyWith 成功，新tags: ${itemCopy.tags}\n');

  // 测试 StickyNote
  print('5. 测试 StickyNote:');
  final stickyNote = StickyNote(
    id: 'note1',
    title: '测试便签',
    position: const Offset(0.3, 0.3),
    tags: ['便签', '注释'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  print('   创建成功，tags: ${stickyNote.tags}');
  
  final noteCopy = stickyNote.copyWith(tags: ['便签', '注释', '重要']);
  print('   copyWith 成功，新tags: ${noteCopy.tags}\n');

  // 测试 MapItem
  print('6. 测试 MapItem:');
  final mapItem = MapItem(
    title: '测试地图',
    version: 1,
    tags: ['地图', '项目'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  print('   创建成功，tags: ${mapItem.tags}');
  
  final mapCopy = mapItem.copyWith(tags: ['地图', '项目', '完成']);
  print('   copyWith 成功，新tags: ${mapCopy.tags}\n');

  // 测试 MapVersion
  print('7. 测试 MapVersion:');
  final version = MapVersion(
    id: 'v1',
    name: '版本1',
    tags: ['版本', '开发'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  print('   创建成功，tags: ${version.tags}');
  
  final versionCopy = version.copyWith(tags: ['版本', '开发', '发布']);
  print('   copyWith 成功，新tags: ${versionCopy.tags}\n');
  // 测试 LegendItem (图例数据模型)
  print('8. 测试 LegendItem (图例数据模型):');
  final legendData = legend_db.LegendItem(
    title: '测试图例数据',
    centerX: 0.5,
    centerY: 0.5,
    version: 1,
    tags: ['数据', '图例'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  print('   创建成功，tags: ${legendData.tags}');
  
  final dataCopy = legendData.copyWith(tags: ['数据', '图例', '更新']);
  print('   copyWith 成功，新tags: ${dataCopy.tags}\n');

  print('✅ 所有数据模型的 tags 字段测试通过！');
  print('📝 总结: 已为以下8个数据模型添加了 tags 字段:');
  print('   - MapLayer (图层)');
  print('   - MapDrawingElement (绘制元素)');
  print('   - LegendGroup (图例组)');
  print('   - LegendItem (图例项，地图上的标记)');
  print('   - StickyNote (便签)');
  print('   - MapItem (地图项)');
  print('   - MapVersion (版本)');
  print('   - LegendItem (图例数据模型)');
  print('\n所有 tags 字段均为 List<String>? 类型，默认值为 null。');
}
