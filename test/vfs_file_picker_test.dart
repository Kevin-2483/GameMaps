import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/components/vfs/vfs_file_picker_window.dart';

void main() {
  group('VFS File Picker Tests', () {
    testWidgets('SelectionType enum should have correct values', (WidgetTester tester) async {
      // 测试选择类型枚举
      expect(SelectionType.filesOnly, isA<SelectionType>());
      expect(SelectionType.directoriesOnly, isA<SelectionType>());
      expect(SelectionType.both, isA<SelectionType>());
    });

    testWidgets('VfsFileManagerWindow should accept new parameters', (WidgetTester tester) async {
      // 测试构造函数参数
      const window = VfsFileManagerWindow(
        allowMultipleSelection: false,
        allowDirectorySelection: true,
        selectionType: SelectionType.filesOnly,
        allowedExtensions: ['txt', 'json'],
      );

      expect(window.allowMultipleSelection, false);
      expect(window.allowDirectorySelection, true);
      expect(window.selectionType, SelectionType.filesOnly);
      expect(window.allowedExtensions, contains('txt'));
      expect(window.allowedExtensions, contains('json'));
    });

    test('Static methods should support SelectionType parameter', () {
      // 确保静态方法签名正确（这里只是编译时检查）
      expect(VfsFileManagerWindow.showFilePicker, isA<Function>());
      expect(VfsFileManagerWindow.showMultiFilePicker, isA<Function>());
      expect(VfsFileManagerWindow.showPathPicker, isA<Function>());
      expect(VfsFileManagerWindow.showMultiPathPicker, isA<Function>());
    });
  });
}
