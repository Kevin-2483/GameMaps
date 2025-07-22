# 协作工具类 (Collaboration Utils)

## 📋 模块职责

提供协作系统所需的通用工具类、辅助函数、常量定义和扩展方法，为其他模块提供基础支持功能。

## 🏗️ 架构设计

### 工具类架构图
```
┌─────────────────────────────────────────────────────────┐
│                 Collaboration Utils                     │
├─────────────────────────────────────────────────────────┤
│  Serialization     │  Encryption       │  Validation    │
│  ┌───────────────┐ │ ┌───────────────┐ │ ┌────────────┐ │
│  │ JSON Utils    │ │ │ Crypto Utils  │ │ │ Validators │ │
│  │ Binary Utils  │ │ │ Hash Utils    │ │ │ Sanitizers │ │
│  │ Compression   │ │ │ Key Manager   │ │ │ Formatters │ │
│  └───────────────┘ │ └───────────────┘ │ └────────────┘ │
├─────────────────────────────────────────────────────────┤
│  Time & ID Utils   │  Network Utils    │  Debug Utils   │
│  ┌───────────────┐ │ ┌───────────────┐ │ ┌────────────┐ │
│  │ UUID Gen      │ │ │ IP Utils      │ │ │ Logger     │ │
│  │ Timestamp     │ │ │ URL Utils     │ │ │ Profiler   │ │
│  │ Clock Sync    │ │ │ Connectivity  │ │ │ Debugger   │ │
│  └───────────────┘ │ └───────────────┘ │ └────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 设计原则
- **可复用性**：提供通用的工具函数
- **高性能**：优化常用操作的性能
- **类型安全**：强类型定义和验证
- **易测试**：纯函数和可测试的设计
- **文档完善**：详细的使用说明和示例

## 📁 文件结构

```
utils/
├── serialization/                # 序列化工具
│   ├── json_serializer.dart
│   ├── binary_serializer.dart
│   ├── message_codec.dart
│   ├── compression_utils.dart
│   └── serialization_extensions.dart
├── encryption/                   # 加密工具
│   ├── crypto_utils.dart
│   ├── hash_utils.dart
│   ├── key_manager.dart
│   ├── signature_utils.dart
│   └── encryption_extensions.dart
├── validation/                   # 验证工具
│   ├── validators.dart
│   ├── sanitizers.dart
│   ├── formatters.dart
│   ├── input_validators.dart
│   └── data_validators.dart
├── time/                        # 时间工具
│   ├── time_utils.dart
│   ├── timestamp_manager.dart
│   ├── clock_synchronizer.dart
│   ├── duration_formatter.dart
│   └── timezone_utils.dart
├── id/                          # ID生成工具
│   ├── uuid_generator.dart
│   ├── id_utils.dart
│   ├── sequence_generator.dart
│   └── collision_detector.dart
├── network/                     # 网络工具
│   ├── network_utils.dart
│   ├── ip_utils.dart
│   ├── url_utils.dart
│   ├── connectivity_checker.dart
│   └── bandwidth_calculator.dart
├── debug/                       # 调试工具
│   ├── collaboration_logger.dart
│   ├── performance_profiler.dart
│   ├── debug_utils.dart
│   ├── error_tracker.dart
│   └── metrics_collector.dart
├── extensions/                  # 扩展方法
│   ├── string_extensions.dart
│   ├── list_extensions.dart
│   ├── map_extensions.dart
│   ├── datetime_extensions.dart
│   └── stream_extensions.dart
├── constants/                   # 常量定义
│   ├── collaboration_constants.dart
│   ├── network_constants.dart
│   ├── error_codes.dart
│   └── default_configs.dart
└── helpers/                     # 辅助类
    ├── async_helpers.dart
    ├── collection_helpers.dart
    ├── math_helpers.dart
    ├── file_helpers.dart
    └── platform_helpers.dart
```

## 🔧 核心工具类说明

### JsonSerializer (JSON序列化器)
**职责**：处理协作数据的JSON序列化和反序列化
**功能**：
- 类型安全的序列化
- 自定义序列化规则
- 性能优化
- 错误处理

```dart
class JsonSerializer {
  static final Map<Type, JsonConverter> _converters = {};
  
  // 注册自定义转换器
  static void registerConverter<T>(JsonConverter<T> converter) {
    _converters[T] = converter;
  }
  
  // 序列化对象
  static String serialize<T>(T object) {
    try {
      if (_converters.containsKey(T)) {
        final converter = _converters[T] as JsonConverter<T>;
        return jsonEncode(converter.toJson(object));
      }
      
      if (object is JsonSerializable) {
        return jsonEncode(object.toJson());
      }
      
      return jsonEncode(object);
    } catch (e) {
      throw SerializationException('Failed to serialize $T: $e');
    }
  }
  
  // 反序列化对象
  static T deserialize<T>(String json) {
    try {
      final data = jsonDecode(json);
      
      if (_converters.containsKey(T)) {
        final converter = _converters[T] as JsonConverter<T>;
        return converter.fromJson(data);
      }
      
      throw SerializationException('No converter registered for type $T');
    } catch (e) {
      throw SerializationException('Failed to deserialize $T: $e');
    }
  }
  
  // 批量序列化
  static String serializeList<T>(List<T> objects) {
    final serialized = objects.map((obj) => 
        _converters.containsKey(T) 
            ? (_converters[T] as JsonConverter<T>).toJson(obj)
            : (obj as JsonSerializable).toJson()
    ).toList();
    
    return jsonEncode(serialized);
  }
  
  // 批量反序列化
  static List<T> deserializeList<T>(String json) {
    final List<dynamic> data = jsonDecode(json);
    final converter = _converters[T] as JsonConverter<T>?;
    
    if (converter == null) {
      throw SerializationException('No converter registered for type $T');
    }
    
    return data.map((item) => converter.fromJson(item)).toList();
  }
}

// 自定义转换器接口
abstract class JsonConverter<T> {
  Map<String, dynamic> toJson(T object);
  T fromJson(Map<String, dynamic> json);
}

// 可序列化接口
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}

// 操作转换器示例
class OperationConverter implements JsonConverter<Operation> {
  @override
  Map<String, dynamic> toJson(Operation operation) {
    return {
      'id': operation.id,
      'type': operation.runtimeType.toString(),
      'clientId': operation.clientId,
      'timestamp': operation.timestamp.toIso8601String(),
      'vectorClock': operation.vectorClock.toJson(),
      'data': _serializeOperationData(operation),
    };
  }
  
  @override
  Operation fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final data = json['data'] as Map<String, dynamic>;
    
    switch (type) {
      case 'InsertOperation':
        return InsertOperation.fromJson(json, data);
      case 'UpdateOperation':
        return UpdateOperation.fromJson(json, data);
      case 'DeleteOperation':
        return DeleteOperation.fromJson(json, data);
      default:
        throw SerializationException('Unknown operation type: $type');
    }
  }
  
  Map<String, dynamic> _serializeOperationData(Operation operation) {
    if (operation is InsertOperation) {
      return {
        'elementId': operation.elementId,
        'element': operation.element.toJson(),
        'position': operation.position,
      };
    } else if (operation is UpdateOperation) {
      return {
        'elementId': operation.elementId,
        'changes': operation.changes,
      };
    } else if (operation is DeleteOperation) {
      return {
        'elementId': operation.elementId,
      };
    }
    
    throw SerializationException('Unsupported operation type: ${operation.runtimeType}');
  }
}
```

### CompressionUtils (压缩工具)
**职责**：数据压缩和解压缩
**功能**：
- 多种压缩算法支持
- 自适应压缩策略
- 性能监控
- 压缩率统计

```dart
class CompressionUtils {
  static const int _compressionThreshold = 1024; // 1KB
  
  // 压缩数据
  static Uint8List compress(
    Uint8List data, {
    CompressionLevel level = CompressionLevel.balanced,
    CompressionAlgorithm algorithm = CompressionAlgorithm.gzip,
  }) {
    if (data.length < _compressionThreshold) {
      return data; // 小数据不压缩
    }
    
    switch (algorithm) {
      case CompressionAlgorithm.gzip:
        return _compressGzip(data, level);
      case CompressionAlgorithm.deflate:
        return _compressDeflate(data, level);
      case CompressionAlgorithm.lz4:
        return _compressLZ4(data, level);
      default:
        throw UnsupportedError('Unsupported compression algorithm: $algorithm');
    }
  }
  
  // 解压缩数据
  static Uint8List decompress(
    Uint8List compressedData,
    CompressionAlgorithm algorithm,
  ) {
    switch (algorithm) {
      case CompressionAlgorithm.gzip:
        return _decompressGzip(compressedData);
      case CompressionAlgorithm.deflate:
        return _decompressDeflate(compressedData);
      case CompressionAlgorithm.lz4:
        return _decompressLZ4(compressedData);
      default:
        throw UnsupportedError('Unsupported compression algorithm: $algorithm');
    }
  }
  
  // 自适应压缩
  static CompressionResult adaptiveCompress(Uint8List data) {
    if (data.length < _compressionThreshold) {
      return CompressionResult(
        data: data,
        algorithm: CompressionAlgorithm.none,
        originalSize: data.length,
        compressedSize: data.length,
        compressionRatio: 1.0,
      );
    }
    
    // 尝试不同算法，选择最佳结果
    final results = <CompressionResult>[];
    
    for (final algorithm in CompressionAlgorithm.values) {
      if (algorithm == CompressionAlgorithm.none) continue;
      
      try {
        final compressed = compress(data, algorithm: algorithm);
        results.add(CompressionResult(
          data: compressed,
          algorithm: algorithm,
          originalSize: data.length,
          compressedSize: compressed.length,
          compressionRatio: compressed.length / data.length,
        ));
      } catch (e) {
        // 忽略失败的算法
      }
    }
    
    // 选择压缩率最好的结果
    results.sort((a, b) => a.compressionRatio.compareTo(b.compressionRatio));
    return results.isNotEmpty ? results.first : CompressionResult(
      data: data,
      algorithm: CompressionAlgorithm.none,
      originalSize: data.length,
      compressedSize: data.length,
      compressionRatio: 1.0,
    );
  }
  
  static Uint8List _compressGzip(Uint8List data, CompressionLevel level) {
    final codec = GZipCodec(level: _mapCompressionLevel(level));
    return Uint8List.fromList(codec.encode(data));
  }
  
  static Uint8List _decompressGzip(Uint8List data) {
    final codec = GZipCodec();
    return Uint8List.fromList(codec.decode(data));
  }
  
  static int _mapCompressionLevel(CompressionLevel level) {
    switch (level) {
      case CompressionLevel.fast:
        return 1;
      case CompressionLevel.balanced:
        return 6;
      case CompressionLevel.best:
        return 9;
    }
  }
}

enum CompressionAlgorithm {
  none,
  gzip,
  deflate,
  lz4,
}

enum CompressionLevel {
  fast,
  balanced,
  best,
}

class CompressionResult {
  final Uint8List data;
  final CompressionAlgorithm algorithm;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  
  CompressionResult({
    required this.data,
    required this.algorithm,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
  });
  
  double get spaceSaved => 1.0 - compressionRatio;
  bool get isCompressed => algorithm != CompressionAlgorithm.none;
}
```

### UuidGenerator (UUID生成器)
**职责**：生成唯一标识符
**功能**：
- 多种UUID版本支持
- 冲突检测
- 性能优化
- 自定义前缀支持

```dart
class UuidGenerator {
  static final Random _random = Random.secure();
  static final Set<String> _usedIds = <String>{};
  static const int _maxRetries = 10;
  
  // 生成UUID v4
  static String generateV4({String? prefix}) {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      final uuid = _generateUuidV4();
      final id = prefix != null ? '$prefix-$uuid' : uuid;
      
      if (!_usedIds.contains(id)) {
        _usedIds.add(id);
        return id;
      }
    }
    
    throw Exception('Failed to generate unique UUID after $_maxRetries attempts');
  }
  
  // 生成短ID（用于临时标识）
  static String generateShortId({int length = 8}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      final id = String.fromCharCodes(Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ));
      
      if (!_usedIds.contains(id)) {
        _usedIds.add(id);
        return id;
      }
    }
    
    throw Exception('Failed to generate unique short ID after $_maxRetries attempts');
  }
  
  // 生成时间戳ID
  static String generateTimestampId({String? prefix}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
    final id = '$timestamp-$random';
    
    return prefix != null ? '$prefix-$id' : id;
  }
  
  // 生成序列ID
  static String generateSequenceId(String category) {
    final sequence = SequenceGenerator.getNext(category);
    return '$category-${sequence.toString().padLeft(6, '0')}';
  }
  
  // 验证ID格式
  static bool isValidUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }
  
  // 清理已使用的ID（定期清理以防内存泄漏）
  static void cleanup() {
    if (_usedIds.length > 10000) {
      _usedIds.clear();
    }
  }
  
  static String _generateUuidV4() {
    final bytes = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }
    
    // 设置版本号 (4) 和变体位
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    return _formatUuid(bytes);
  }
  
  static String _formatUuid(Uint8List bytes) {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}

class SequenceGenerator {
  static final Map<String, int> _sequences = {};
  
  static int getNext(String category) {
    _sequences[category] = (_sequences[category] ?? 0) + 1;
    return _sequences[category]!;
  }
  
  static int getCurrent(String category) {
    return _sequences[category] ?? 0;
  }
  
  static void reset(String category) {
    _sequences[category] = 0;
  }
  
  static void resetAll() {
    _sequences.clear();
  }
}
```

### CollaborationLogger (协作日志器)
**职责**：协作系统的日志记录和调试
**功能**：
- 分级日志记录
- 性能监控
- 错误追踪
- 日志过滤和搜索

```dart
class CollaborationLogger {
  static final CollaborationLogger _instance = CollaborationLogger._internal();
  factory CollaborationLogger() => _instance;
  CollaborationLogger._internal();
  
  final List<LogEntry> _logs = [];
  final StreamController<LogEntry> _logController = StreamController.broadcast();
  LogLevel _minLevel = LogLevel.info;
  bool _enabled = true;
  
  Stream<LogEntry> get logs => _logController.stream;
  
  // 配置日志器
  void configure({
    LogLevel? minLevel,
    bool? enabled,
    int? maxLogEntries,
  }) {
    if (minLevel != null) _minLevel = minLevel;
    if (enabled != null) _enabled = enabled;
    if (maxLogEntries != null && _logs.length > maxLogEntries) {
      _logs.removeRange(0, _logs.length - maxLogEntries);
    }
  }
  
  // 记录日志
  void log(
    LogLevel level,
    String message, {
    String? category,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled || level.index < _minLevel.index) return;
    
    final entry = LogEntry(
      level: level,
      message: message,
      category: category ?? 'General',
      timestamp: DateTime.now(),
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
    
    _logs.add(entry);
    _logController.add(entry);
    
    // 输出到控制台（开发模式）
    if (kDebugMode) {
      _printToConsole(entry);
    }
  }
  
  // 便捷方法
  void debug(String message, {String? category, Map<String, dynamic>? data}) {
    log(LogLevel.debug, message, category: category, data: data);
  }
  
  void info(String message, {String? category, Map<String, dynamic>? data}) {
    log(LogLevel.info, message, category: category, data: data);
  }
  
  void warning(String message, {String? category, Map<String, dynamic>? data}) {
    log(LogLevel.warning, message, category: category, data: data);
  }
  
  void error(
    String message, {
    String? category,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.error,
      message,
      category: category,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }
  
  // 性能监控
  PerformanceTimer startTimer(String operation, {String? category}) {
    return PerformanceTimer._(this, operation, category);
  }
  
  // 搜索日志
  List<LogEntry> search({
    String? query,
    LogLevel? level,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return _logs.where((entry) {
      if (level != null && entry.level != level) return false;
      if (category != null && entry.category != category) return false;
      if (startTime != null && entry.timestamp.isBefore(startTime)) return false;
      if (endTime != null && entry.timestamp.isAfter(endTime)) return false;
      if (query != null && !entry.message.toLowerCase().contains(query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }
  
  // 导出日志
  String exportLogs({
    LogLevel? minLevel,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final filteredLogs = search(
      level: minLevel,
      category: category,
      startTime: startTime,
      endTime: endTime,
    );
    
    return filteredLogs.map((entry) => entry.toString()).join('\n');
  }
  
  void _printToConsole(LogEntry entry) {
    final timestamp = entry.timestamp.toIso8601String();
    final level = entry.level.name.toUpperCase();
    final category = entry.category;
    final message = entry.message;
    
    print('[$timestamp] [$level] [$category] $message');
    
    if (entry.data != null) {
      print('  Data: ${entry.data}');
    }
    
    if (entry.error != null) {
      print('  Error: ${entry.error}');
    }
    
    if (entry.stackTrace != null) {
      print('  Stack Trace: ${entry.stackTrace}');
    }
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LogEntry {
  final LogLevel level;
  final String message;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final Object? error;
  final StackTrace? stackTrace;
  
  LogEntry({
    required this.level,
    required this.message,
    required this.category,
    required this.timestamp,
    this.data,
    this.error,
    this.stackTrace,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name.toUpperCase()}] ');
    buffer.write('[$category] ');
    buffer.write(message);
    
    if (data != null) {
      buffer.write(' | Data: $data');
    }
    
    if (error != null) {
      buffer.write(' | Error: $error');
    }
    
    return buffer.toString();
  }
}

class PerformanceTimer {
  final CollaborationLogger _logger;
  final String _operation;
  final String? _category;
  final Stopwatch _stopwatch;
  
  PerformanceTimer._(
    this._logger,
    this._operation,
    this._category,
  ) : _stopwatch = Stopwatch()..start();
  
  void stop({Map<String, dynamic>? additionalData}) {
    _stopwatch.stop();
    
    final data = <String, dynamic>{
      'operation': _operation,
      'duration_ms': _stopwatch.elapsedMilliseconds,
      'duration_us': _stopwatch.elapsedMicroseconds,
    };
    
    if (additionalData != null) {
      data.addAll(additionalData);
    }
    
    _logger.info(
      'Performance: $_operation completed in ${_stopwatch.elapsedMilliseconds}ms',
      category: _category ?? 'Performance',
      data: data,
    );
  }
}
```

## 🔧 扩展方法

### StringExtensions (字符串扩展)
```dart
extension StringExtensions on String {
  // 验证是否为有效的用户ID
  bool get isValidClientId {
    return RegExp(r'^[a-zA-Z0-9_-]{3,50}$').hasMatch(this);
  }
  
  // 验证是否为有效的房间ID
  bool get isValidRoomId {
    return RegExp(r'^[a-zA-Z0-9_-]{6,100}$').hasMatch(this);
  }
  
  // 截断字符串
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
  
  // 安全的JSON解析
  Map<String, dynamic>? tryParseJson() {
    try {
      return jsonDecode(this) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  // 计算字符串哈希
  int get fastHash {
    int hash = 0;
    for (int i = 0; i < length; i++) {
      hash = ((hash << 5) - hash + codeUnitAt(i)) & 0xffffffff;
    }
    return hash;
  }
}
```

### ListExtensions (列表扩展)
```dart
extension ListExtensions<T> on List<T> {
  // 安全获取元素
  T? safeGet(int index) {
    return index >= 0 && index < length ? this[index] : null;
  }
  
  // 批量处理
  List<List<T>> batch(int size) {
    final batches = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      batches.add(sublist(i, math.min(i + size, length)));
    }
    return batches;
  }
  
  // 去重（保持顺序）
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((element) => seen.add(keySelector(element))).toList();
  }
  
  // 查找第一个匹配项（可空）
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
```

## 📊 常量定义

### CollaborationConstants (协作常量)
```dart
class CollaborationConstants {
  // 网络配置
  static const Duration defaultConnectionTimeout = Duration(seconds: 10);
  static const Duration defaultHeartbeatInterval = Duration(seconds: 30);
  static const int maxConcurrentConnections = 100;
  static const int maxMessageSize = 64 * 1024; // 64KB
  
  // 同步配置
  static const Duration syncBatchInterval = Duration(milliseconds: 100);
  static const int maxPendingOperations = 1000;
  static const Duration operationTimeout = Duration(seconds: 30);
  
  // UI配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration notificationDuration = Duration(seconds: 5);
  static const int maxVisibleUsers = 10;
  
  // 性能配置
  static const int compressionThreshold = 1024; // 1KB
  static const Duration performanceLogInterval = Duration(minutes: 1);
  static const int maxLogEntries = 10000;
}

class ErrorCodes {
  // 网络错误
  static const String connectionFailed = 'CONN_FAILED';
  static const String connectionTimeout = 'CONN_TIMEOUT';
  static const String networkUnavailable = 'NET_UNAVAILABLE';
  
  // 同步错误
  static const String syncFailed = 'SYNC_FAILED';
  static const String conflictResolutionFailed = 'CONFLICT_FAILED';
  static const String operationInvalid = 'OP_INVALID';
  
  // 认证错误
  static const String authenticationFailed = 'AUTH_FAILED';
  static const String permissionDenied = 'PERM_DENIED';
  static const String sessionExpired = 'SESSION_EXPIRED';
  
  // 数据错误
  static const String serializationFailed = 'SERIAL_FAILED';
  static const String dataCorrupted = 'DATA_CORRUPT';
  static const String versionMismatch = 'VERSION_MISMATCH';
}
```

## 🧪 测试工具

### TestUtils (测试工具)
```dart
class TestUtils {
  // 生成测试数据
  static NodeInfo generateTestNode(String id) {
    return NodeInfo(
      id: id,
      networkQuality: NetworkQuality.good(),
      cpuPerformance: 0.8,
      bandwidth: 50.0,
      stability: 0.9,
      uptime: Duration(hours: 2),
    );
  }
  
  static List<NodeInfo> generateTestNodes(int count) {
    return List.generate(count, (i) => generateTestNode('node$i'));
  }
  
  static Operation generateTestOperation(String clientId) {
    return UpdateOperation(
      id: UuidGenerator.generateV4(),
      elementId: 'element_${Random().nextInt(100)}',
      changes: {'color': 'red', 'size': Random().nextInt(100)},
      clientId: clientId,
      timestamp: DateTime.now(),
      vectorClock: VectorClock(),
    );
  }
  
  // 模拟网络延迟
  static Future<void> simulateNetworkDelay([Duration? delay]) {
    return Future.delayed(delay ?? Duration(milliseconds: Random().nextInt(100)));
  }
  
  // 模拟网络错误
  static void simulateNetworkError({double probability = 0.1}) {
    if (Random().nextDouble() < probability) {
      throw NetworkException('Simulated network error');
    }
  }
}
```

## 📋 开发清单

### 第一阶段：基础工具
- [ ] JsonSerializer序列化器
- [ ] UuidGenerator ID生成器
- [ ] CollaborationLogger日志器
- [ ] 基础扩展方法

### 第二阶段：高级工具
- [ ] CompressionUtils压缩工具
- [ ] CryptoUtils加密工具
- [ ] NetworkUtils网络工具
- [ ] 验证和格式化工具

### 第三阶段：性能工具
- [ ] PerformanceProfiler性能分析器
- [ ] MetricsCollector指标收集器
- [ ] DebugUtils调试工具
- [ ] 测试辅助工具

### 第四阶段：完善和优化
- [ ] 更多扩展方法
- [ ] 平台特定工具
- [ ] 文档和示例
- [ ] 性能优化

## 🔗 依赖关系

- **上游依赖**：无（基础模块）
- **下游依赖**：所有其他协作模块
- **外部依赖**：crypto, uuid
- **系统依赖**：dart:io, dart:convert

## 📝 开发规范

1. **纯函数优先**：尽量使用纯函数，便于测试
2. **类型安全**：使用强类型定义，避免dynamic
3. **性能考虑**：优化常用操作的性能
4. **错误处理**：完善的异常处理和错误信息
5. **文档完善**：每个工具类都要有详细文档
6. **测试覆盖**：确保高测试覆盖率