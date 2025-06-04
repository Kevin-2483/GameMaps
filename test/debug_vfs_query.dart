import 'dart:io';

void main() {
  // 模拟SQL查询逻辑
  testSqlLogic();
}

void testSqlLogic() {
  // 测试数据
  final testCases = [
    {
      'file_path': '2/ww',
      'query_path': '2',
      'expected': true, // 应该被包含
    },
    {
      'file_path': '2/subfolder/file',
      'query_path': '2',
      'expected': false, // 不应该被包含（深层嵌套）
    },
    {
      'file_path': '2',
      'query_path': '2',
      'expected': false, // 不应该被包含（自身）
    },
    {
      'file_path': '20/something',
      'query_path': '2',
      'expected': false, // 不应该被包含（不同路径）
    },
  ];

  for (final testCase in testCases) {
    final filePath = testCase['file_path'] as String;
    final queryPath = testCase['query_path'] as String;
    final expected = testCase['expected'] as bool;

    // 模拟修复后的SQL逻辑
    final pathPrefix = queryPath.isEmpty ? '' : '$queryPath/';

    // 检查 LIKE 条件
    final likesCondition = filePath.startsWith(pathPrefix);

    // 检查不等于条件
    final notEqualsCondition = filePath != queryPath;

    // 检查斜杠数量条件（修复后的逻辑）
    final fileSlashCount = countSlashes(filePath);
    final expectedSlashCount = pathPrefix.split('/').length - 1;
    final slashCondition = fileSlashCount == expectedSlashCount;

    final result = likesCondition && notEqualsCondition && slashCondition;

    print('Test: $filePath (query: $queryPath)');
    print('  LIKE "$pathPrefix%": $likesCondition');
    print('  != "$queryPath": $notEqualsCondition');
    print(
      '  Slash count: $fileSlashCount == $expectedSlashCount: $slashCondition',
    );
    print('  Result: $result (Expected: $expected)');
    print('  ${result == expected ? "✅ PASS" : "❌ FAIL"}');
    print('');
  }
}

int countSlashes(String path) {
  return path.length - path.replaceAll('/', '').length;
}
