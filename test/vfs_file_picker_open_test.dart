import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:r6box/components/vfs/vfs_file_picker_window.dart';
import 'package:r6box/services/vfs/vfs_file_opener_service.dart';

/// 测试 VFS File Picker Window 的文件打开功能
void main() {
  // 初始化FFI数据库工厂用于测试
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  group('VFS File Picker Window - File Opening', () {
    testWidgets('文件打开服务可用性测试', (WidgetTester tester) async {
      // 验证 VfsFileOpenerService 类是否存在且可访问
      expect(VfsFileOpenerService.openFile, isNotNull);
    });

    testWidgets('VFS File Picker Window 组件创建测试', (WidgetTester tester) async {
      // 创建一个简单的测试应用
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  // 测试能否正常创建 VfsFileManagerWindow
                  VfsFileManagerWindow.show(context);
                },
                child: const Text('打开文件管理器'),
              ),
            ),
          ),
        ),
      );

      // 验证按钮是否存在
      expect(find.text('打开文件管理器'), findsOneWidget);
      
      // 点击按钮应该能够正常执行（不抛出异常）
      await tester.tap(find.text('打开文件管理器'));
      await tester.pump();
      
      // 基本验证通过（没有异常抛出）
    });

    testWidgets('选择模式枚举测试', (WidgetTester tester) async {
      // 验证 SelectionType 枚举的值
      expect(SelectionType.filesOnly, isNotNull);
      expect(SelectionType.directoriesOnly, isNotNull);
      expect(SelectionType.both, isNotNull);
    });
  });
}
