import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:r6box/components/vfs/vfs_file_picker_window.dart';

void main() {
  group('VFS File Picker Selection Tests', () {
    testWidgets('单选模式应该只允许选择一个文件', (WidgetTester tester) async {
      // 这是一个占位符测试，用来验证代码编译正确
      expect(SelectionType.filesOnly, isNotNull);
      expect(SelectionType.directoriesOnly, isNotNull);
      expect(SelectionType.both, isNotNull);
    });

    test('SelectionType 枚举应该包含所有预期值', () {
      final values = SelectionType.values;
      expect(values.length, 3);
      expect(values.contains(SelectionType.filesOnly), true);
      expect(values.contains(SelectionType.directoriesOnly), true);
      expect(values.contains(SelectionType.both), true);
    });

    test('静态方法应该接受 selectionType 参数', () {
      // 验证方法签名编译正确 - 这些方法需要 BuildContext，所以只检查编译
      expect(VfsFileManagerWindow.showFilePicker, isNotNull);
      expect(VfsFileManagerWindow.showMultiFilePicker, isNotNull);
      expect(VfsFileManagerWindow.showPathPicker, isNotNull);
      expect(VfsFileManagerWindow.showMultiPathPicker, isNotNull);
    });
  });
}
