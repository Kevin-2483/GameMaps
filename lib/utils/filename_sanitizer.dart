/// 文件名安全化工具
/// 用于将地图标题转换为安全的文件名
class FilenameSanitizer {
  /// 将标题转换为安全的文件名
  ///
  /// 规则：
  /// 1. 移除或替换不安全字符: <>:"/\|?*
  /// 2. 替换空格为下划线
  /// 3. 移除连续的下划线
  /// 4. 限制长度为100字符
  /// 5. 移除首尾的点和空格
  static String sanitize(String title) {
    if (title.isEmpty) {
      return 'untitled_map';
    }

    String sanitized = title
        // 替换不安全的字符为下划线
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        // 替换空格为下划线
        .replaceAll(RegExp(r'\s+'), '_')
        // 移除连续的下划线
        .replaceAll(RegExp(r'_+'), '_')
        // 移除首尾的点和下划线
        .replaceAll(RegExp(r'^[._]+|[._]+$'), '')
        // 限制长度
        .substring(0, title.length > 100 ? 100 : title.length);

    // 如果处理后为空，使用默认名称
    if (sanitized.isEmpty) {
      return 'untitled_map';
    }

    return sanitized;
  }

  /// 检查文件名是否安全
  static bool isSafe(String filename) {
    if (filename.isEmpty) return false;

    // 检查是否包含不安全字符
    if (RegExp(r'[<>:"/\\|?*]').hasMatch(filename)) return false;

    // 检查是否以点开头或结尾
    if (filename.startsWith('.') || filename.endsWith('.')) return false;

    // 检查长度
    if (filename.length > 100) return false;

    return true;
  }

  /// 从安全文件名中提取可能的原始标题
  /// 注意：这只是尝试性的，不能保证完全恢复
  static String desanitize(String filename) {
    return filename.replaceAll('_', ' ').trim();
  }

  /// 为重复的文件名添加数字后缀
  static String makeUnique(
    String baseFilename,
    List<String> existingFilenames,
  ) {
    if (!existingFilenames.contains(baseFilename)) {
      return baseFilename;
    }

    int counter = 1;
    String uniqueName;
    do {
      uniqueName = '${baseFilename}_$counter';
      counter++;
    } while (existingFilenames.contains(uniqueName));

    return uniqueName;
  }
}
