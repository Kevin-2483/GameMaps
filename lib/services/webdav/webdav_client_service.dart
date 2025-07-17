import 'package:flutter/foundation.dart';
import 'package:lpinyin/lpinyin.dart';
import '../../models/webdav_config.dart';
import 'webdav_database_service.dart';
import 'webdav_secure_storage_service.dart';

// 条件导入WebDAV客户端（仅非web平台）
import 'webdav_client/webdav_client_stub.dart'
    if (dart.library.io) 'webdav_client/webdav_client_io.dart'
    if (dart.library.html) 'webdav_client/webdav_client_web.dart';

/// WebDAV客户端服务
/// 提供WebDAV连接、文件操作和测试功能
class WebDavClientService {
  static final WebDavClientService _instance = WebDavClientService._internal();
  factory WebDavClientService() => _instance;
  WebDavClientService._internal();

  final WebDavDatabaseService _dbService = WebDavDatabaseService();
  final WebDavSecureStorageService _secureStorage = WebDavSecureStorageService();

  /// 初始化服务
  Future<void> initialize() async {
    await _dbService.initialize();
    await _secureStorage.initialize();
    
    if (kDebugMode) {
      debugPrint('WebDAV客户端服务初始化完成');
    }
  }

  /// 创建WebDAV客户端实例
  Future<Client?> _createClient(String configId) async {
    try {
      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        if (kDebugMode) {
          debugPrint('WebDAV配置未找到: $configId');
        }
        return null;
      }

      final authAccount = await _dbService.getAuthAccountById(config.authAccountId);
      if (authAccount == null) {
        if (kDebugMode) {
          debugPrint('WebDAV认证账户未找到: ${config.authAccountId}');
        }
        return null;
      }

      final password = await _secureStorage.getPassword(config.authAccountId);
      if (password == null) {
        if (kDebugMode) {
          debugPrint('WebDAV密码未找到: ${config.authAccountId}');
        }
        return null;
      }

      // 创建WebDAV客户端
      final client = newClient(
        config.serverUrl,
        user: authAccount.username,
        password: password,
        debug: kDebugMode,
      );

      // 设置连接超时
      client.setConnectTimeout(8000);
      client.setSendTimeout(8000);
      client.setReceiveTimeout(8000);

      return client;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('创建WebDAV客户端失败: $e');
      }
      return null;
    }
  }

  /// 测试WebDAV连接
  Future<WebDavTestResult> testConnection(String configId) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final client = await _createClient(configId);
      if (client == null) {
        return const WebDavTestResult(
          success: false,
          errorMessage: '无法创建WebDAV客户端，请检查配置',
        );
      }

      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        return const WebDavTestResult(
          success: false,
          errorMessage: '配置未找到',
        );
      }

      // 测试连接 - 尝试列出根目录
      await client.readDir('/');
      
      // 测试存储路径是否存在，如果不存在则尝试创建
      final storagePath = config.storagePath.startsWith('/') 
          ? config.storagePath 
          : '/${config.storagePath}';
      
      try {
        await client.readDir(storagePath);
      } catch (e) {
        // 如果目录不存在，尝试创建
        if (e.toString().contains('404') || e.toString().contains('Not Found')) {
          await client.mkdirAll(storagePath);
          if (kDebugMode) {
            debugPrint('WebDAV存储目录已创建: $storagePath');
          }
        } else {
          rethrow;
        }
      }

      stopwatch.stop();
      
      // 尝试获取服务器信息
      String? serverInfo;
      try {
        // 这里可以添加获取服务器信息的逻辑
        serverInfo = 'WebDAV Server';
      } catch (e) {
        // 忽略获取服务器信息的错误
      }

      return WebDavTestResult(
        success: true,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        serverInfo: serverInfo,
      );
    } catch (e) {
      stopwatch.stop();
      
      String errorMessage = '连接失败';
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        errorMessage = '认证失败，请检查用户名和密码';
      } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        errorMessage = '服务器地址不正确或路径不存在';
      } else if (e.toString().contains('timeout')) {
        errorMessage = '连接超时，请检查网络和服务器地址';
      } else {
        errorMessage = '连接失败: ${e.toString()}';
      }

      return WebDavTestResult(
        success: false,
        errorMessage: errorMessage,
        responseTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// 上传文件到WebDAV
  Future<bool> uploadFile(
    String configId,
    String localFilePath,
    String remoteFilePath,
  ) async {
    try {
      final client = await _createClient(configId);
      if (client == null) {
        return false;
      }

      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        return false;
      }

      // 构建完整的远程路径
      final fullRemotePath = _buildFullPath(config.storagePath, remoteFilePath);
      
      // 确保目录存在
      final remoteDirPath = _getDirectoryPath(fullRemotePath);
      if (remoteDirPath.isNotEmpty) {
        await client.mkdirAll(remoteDirPath);
      }

      // 上传文件
      await client.writeFromFile(localFilePath, fullRemotePath);
      
      if (kDebugMode) {
        debugPrint('文件上传成功: $localFilePath -> $fullRemotePath');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('文件上传失败: $e');
      }
      return false;
    }
  }

  /// 下载文件从WebDAV
  Future<bool> downloadFile(
    String configId,
    String remoteFilePath,
    String localFilePath,
  ) async {
    try {
      final client = await _createClient(configId);
      if (client == null) {
        return false;
      }

      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        return false;
      }

      // 构建完整的远程路径
      final fullRemotePath = _buildFullPath(config.storagePath, remoteFilePath);
      
      // 下载文件
      await client.read2File(fullRemotePath, localFilePath);
      
      if (kDebugMode) {
        debugPrint('文件下载成功: $fullRemotePath -> $localFilePath');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('文件下载失败: $e');
      }
      return false;
    }
  }

  /// 列出WebDAV目录内容
  Future<List<dynamic>?> listDirectory(
    String configId,
    String remotePath,
  ) async {
    try {
      final client = await _createClient(configId);
      if (client == null) {
        return null;
      }

      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        return null;
      }

      // 构建完整的远程路径
      final fullRemotePath = _buildFullPath(config.storagePath, remotePath);
      
      // 列出目录内容
      final files = await client.readDir(fullRemotePath);
      
      if (kDebugMode) {
        debugPrint('目录列表获取成功: $fullRemotePath (${files.length} 个项目)');
      }
      
      return files;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取目录列表失败: $e');
      }
      return null;
    }
  }

  /// 删除WebDAV文件或目录
  Future<bool> delete(
    String configId,
    String remotePath,
  ) async {
    try {
      final client = await _createClient(configId);
      if (client == null) {
        return false;
      }

      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        return false;
      }

      // 构建完整的远程路径
      final fullRemotePath = _buildFullPath(config.storagePath, remotePath);
      
      // 删除文件或目录
      await client.remove(fullRemotePath);
      
      if (kDebugMode) {
        debugPrint('删除成功: $fullRemotePath');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('删除失败: $e');
      }
      return false;
    }
  }

  /// 创建WebDAV目录
  Future<bool> createDirectory(
    String configId,
    String remotePath,
  ) async {
    try {
      final client = await _createClient(configId);
      if (client == null) {
        return false;
      }

      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        return false;
      }

      // 构建完整的远程路径
      final fullRemotePath = _buildFullPath(config.storagePath, remotePath);
      
      // 创建目录
      await client.mkdirAll(fullRemotePath);
      
      if (kDebugMode) {
        debugPrint('目录创建成功: $fullRemotePath');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('目录创建失败: $e');
      }
      return false;
    }
  }

  /// 检查WebDAV路径是否存在
  Future<bool> checkPathExists(
    String configId,
    String remotePath,
  ) async {
    try {
      final client = await _createClient(configId);
      if (client == null) {
        return false;
      }

      final config = await _dbService.getConfigById(configId);
      if (config == null) {
        return false;
      }

      // 构建完整的远程路径
      final fullRemotePath = _buildFullPath(config.storagePath, remotePath);
      
      // 尝试读取路径信息来检查是否存在
      await client.readDir(fullRemotePath);
      
      if (kDebugMode) {
        debugPrint('路径存在: $fullRemotePath');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('路径检查失败: $remotePath - $e');
      }
      return false;
    }
  }

  // ==================== 私有辅助方法 ====================

  /// 检查字符串是否包含中文字符
  bool _containsChinese(String input) {
    final regex = RegExp(r'[\u4e00-\u9fa5]');
    return regex.hasMatch(input);
  }

  /// 将中文字符转换为拼音，无法转换的使用简单字符替代
  String _convertChineseToPinyin(String input) {
    if (!_containsChinese(input)) {
      return input;
    }

    try {
      // 使用getPinyinE方法，无法转换的字符用'a'替代
      return PinyinHelper.getPinyinE(
        input,
        separator: '',
        defPinyin: 'a',
        format: PinyinFormat.WITHOUT_TONE,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('拼音转换失败: $e');
      }
      // 如果转换失败，将中文字符替换为'a'
      return input.replaceAll(RegExp(r'[\u4e00-\u9fa5]'), 'a');
    }
  }

  /// 处理路径中的中文字符，转换为拼音
  String _processPathForWebDAV(String path) {
    if (path.isEmpty) {
      return path;
    }

    // 分割路径为各个部分
    final parts = path.split('/');
    final processedParts = parts.map((part) {
      if (part.isEmpty) {
        return part;
      }
      return _convertChineseToPinyin(part);
    }).toList();

    return processedParts.join('/');
  }

  /// 构建完整路径
  String _buildFullPath(String storagePath, String relativePath) {
    // 确保存储路径以 / 开头
    final normalizedStoragePath = storagePath.startsWith('/') 
        ? storagePath 
        : '/$storagePath';
    
    // 确保存储路径以 / 结尾（如果不是根路径）
    final baseStoragePath = normalizedStoragePath == '/' 
        ? '/' 
        : normalizedStoragePath.endsWith('/') 
            ? normalizedStoragePath 
            : '$normalizedStoragePath/';
    
    // 处理相对路径
    if (relativePath.isEmpty || relativePath == '/') {
      return _processPathForWebDAV(normalizedStoragePath);
    }
    
    // 移除相对路径开头的 /
    final normalizedRelativePath = relativePath.startsWith('/') 
        ? relativePath.substring(1) 
        : relativePath;
    
    final fullPath = '$baseStoragePath$normalizedRelativePath';
    return _processPathForWebDAV(fullPath);
  }

  /// 获取路径的目录部分
  String _getDirectoryPath(String filePath) {
    final lastSlashIndex = filePath.lastIndexOf('/');
    if (lastSlashIndex <= 0) {
      return '';
    }
    return filePath.substring(0, lastSlashIndex);
  }
}