/// 图例路径解析器
/// 处理图例路径的占位符机制，支持相对于地图目录的路径转换
class LegendPathResolver {
  /// 占位符前缀，表示相对于当前地图目录的路径
  static const String mapRelativePrefix = '{{MAP_DIR}}';
  
  /// 将绝对路径转换为可能包含占位符的路径
  /// 如果图例路径是地图目录的子目录，则使用占位符
  static String convertToStoragePath(String legendPath, String? mapAbsolutePath) {
    if (mapAbsolutePath == null || !legendPath.startsWith('indexeddb://')) {
      return legendPath;
    }
    
    // 地图路径应该是目录路径，确保以/结尾
    String mapDirPath = mapAbsolutePath;
    if (!mapDirPath.endsWith('/')) {
      mapDirPath += '/';
    }
    
    // 检查图例路径是否在地图目录下
    if (legendPath.startsWith(mapDirPath)) {
      // 提取相对路径
      final relativePath = legendPath.substring(mapDirPath.length);
      return '$mapRelativePrefix/$relativePath';
    }
    
    return legendPath; // 不在地图目录下，保持原路径
  }
  
  /// 将存储路径转换为实际的绝对路径
  /// 如果路径包含占位符，则根据当前地图目录进行替换
  static String convertToActualPath(String storagePath, String? mapAbsolutePath) {
    if (!storagePath.startsWith(mapRelativePrefix) || mapAbsolutePath == null) {
      return storagePath;
    }
    
    // 地图路径应该是目录路径，确保以/结尾
    String mapDirPath = mapAbsolutePath;
    if (!mapDirPath.endsWith('/')) {
      mapDirPath += '/';
    }
    
    // 提取占位符后的相对路径
    final relativePath = storagePath.substring(mapRelativePrefix.length + 1);
    
    // 构建实际的绝对路径
    return '$mapDirPath$relativePath';
  }
  
  /// 检查路径是否包含占位符
  static bool hasPlaceholder(String path) {
    return path.startsWith(mapRelativePrefix);
  }
  
  /// 获取占位符路径的相对部分
  static String? getRelativePart(String placeholderPath) {
    if (!hasPlaceholder(placeholderPath)) {
      return null;
    }
    return placeholderPath.substring(mapRelativePrefix.length + 1);
  }
}