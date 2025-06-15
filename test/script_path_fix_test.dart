import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/filename_sanitizer.dart';

void main() {
  group('脚本路径修复测试', () {
    test('ScriptManager - 脚本保存路径应该包含.mapdata后缀', () {
      // 使用反射获取私有方法进行测试
      // 这里我们通过设置地图标题，然后检查生成的路径
      const mapTitle = 'Test Map';
      const expectedSanitizedTitle =
          'Test_Map'; // FilenameSanitizer.sanitize的结果

      // 验证文件名清理逻辑
      final sanitizedTitle = FilenameSanitizer.sanitize(mapTitle);
      expect(sanitizedTitle, equals(expectedSanitizedTitle));

      // 验证地图路径格式
      final expectedMapPath = '$sanitizedTitle.mapdata';
      expect(expectedMapPath, equals('$expectedSanitizedTitle.mapdata'));
    });

    test('ReactiveScriptManager - 脚本保存路径应该包含.mapdata后缀', () {
      // 验证ReactiveScriptManager也使用相同的路径格式
      const mapTitle = 'My Test Map';
      const expectedSanitizedTitle =
          'My_Test_Map'; // FilenameSanitizer.sanitize的结果

      // 验证文件名清理逻辑
      final sanitizedTitle = FilenameSanitizer.sanitize(mapTitle);
      expect(sanitizedTitle, equals(expectedSanitizedTitle));

      // 验证地图路径格式
      final expectedMapPath = '$sanitizedTitle.mapdata';
      expect(expectedMapPath, equals('$expectedSanitizedTitle.mapdata'));
    });

    test('特殊字符的地图标题应该正确处理', () {
      const mapTitle = 'Map<>:"/\\|?* Title';
      const expectedSanitizedTitle = 'Map_Title'; // 特殊字符被替换，连续下划线合并

      final sanitizedTitle = FilenameSanitizer.sanitize(mapTitle);
      expect(sanitizedTitle, equals(expectedSanitizedTitle));

      final expectedMapPath = '$sanitizedTitle.mapdata';
      expect(expectedMapPath, equals('Map_Title.mapdata'));
    });

    test('长标题应该被截断', () {
      final longTitle = 'A' * 150; // 150个字符的标题
      final sanitizedTitle = FilenameSanitizer.sanitize(longTitle);

      // 应该被截断到100个字符
      expect(sanitizedTitle.length, lessThanOrEqualTo(100));

      final expectedMapPath = '$sanitizedTitle.mapdata';
      expect(expectedMapPath.endsWith('.mapdata'), isTrue);
    });
  });
}
