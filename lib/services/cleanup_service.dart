import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'virtual_file_system/vfs_service_provider.dart';
import 'user_preferences/user_preferences_database_service.dart';
import 'map_localization_service.dart';
import 'virtual_file_system/vfs_storage_service.dart';
import 'map_database_service.dart';
import 'legend_database_service.dart';
import 'user_preferences/user_preferences_service.dart';
// 脚本执行器相关导入已移除，因为当前实现中没有直接停止脚本执行器
// 如果需要停止脚本执行器，可以在这里添加相应的导入和清理逻辑
import 'audio/audio_player_service.dart';
import 'tts_service.dart';
import 'legend_cache_manager.dart';

/// 应用清理服务
/// 负责在应用关闭时清理临时文件、缓存、日志等
class CleanupService {
  static final CleanupService _instance = CleanupService._internal();
  factory CleanupService() => _instance;
  CleanupService._internal();

  bool _isCleanupInProgress = false;

  /// 执行应用关闭前的清理操作
  Future<void> performCleanup() async {
    if (_isCleanupInProgress) {
      if (kDebugMode) {
        debugPrint('清理操作已在进行中，跳过重复执行');
      }
      return;
    }

    _isCleanupInProgress = true;
    final totalStopwatch = Stopwatch()..start();

    try {
      if (kDebugMode) {
        debugPrint('开始执行应用清理操作...');
      }

      // 1. 关闭所有数据库连接
      final dbStopwatch = Stopwatch()..start();
      await _closeDatabaseConnections();
      dbStopwatch.stop();
      if (kDebugMode) {
        debugPrint('数据库连接关闭耗时: ${dbStopwatch.elapsedMilliseconds}ms');
      }

      // 2. 停止所有脚本执行器
      final scriptStopwatch = Stopwatch()..start();
      await _stopScriptExecutors();
      scriptStopwatch.stop();
      if (kDebugMode) {
        debugPrint('脚本执行器停止耗时: ${scriptStopwatch.elapsedMilliseconds}ms');
      }

      // 3. 停止音频服务
      final audioStopwatch = Stopwatch()..start();
      await _stopAudioServices();
      audioStopwatch.stop();
      if (kDebugMode) {
        debugPrint('音频服务停止耗时: ${audioStopwatch.elapsedMilliseconds}ms');
      }

      // 4. 清理缓存
      final cacheStopwatch = Stopwatch()..start();
      await _cleanupCaches();
      cacheStopwatch.stop();
      if (kDebugMode) {
        debugPrint('缓存清理耗时: ${cacheStopwatch.elapsedMilliseconds}ms');
      }

      // 5. 清理临时文件
      final tempStopwatch = Stopwatch()..start();
      await _cleanupTemporaryFiles();
      tempStopwatch.stop();
      if (kDebugMode) {
        debugPrint('临时文件清理耗时: ${tempStopwatch.elapsedMilliseconds}ms');
      }

      // 6. 清理日志文件（可选）
      final logStopwatch = Stopwatch()..start();
      await _cleanupLogFiles();
      logStopwatch.stop();
      if (kDebugMode) {
        debugPrint('日志文件清理耗时: ${logStopwatch.elapsedMilliseconds}ms');
      }

      // 7. 关闭VFS系统
      final vfsStopwatch = Stopwatch()..start();
      await _closeVfsSystem();
      vfsStopwatch.stop();
      if (kDebugMode) {
        debugPrint('VFS系统关闭耗时: ${vfsStopwatch.elapsedMilliseconds}ms');
      }

      totalStopwatch.stop();
      if (kDebugMode) {
        debugPrint('应用清理操作完成，总耗时: ${totalStopwatch.elapsedMilliseconds}ms');
      }
    } catch (e) {
      totalStopwatch.stop();
      if (kDebugMode) {
        debugPrint('清理操作过程中发生错误: $e，已耗时: ${totalStopwatch.elapsedMilliseconds}ms');
      }
    } finally {
      _isCleanupInProgress = false;
    }
  }

  /// 关闭所有数据库连接
  Future<void> _closeDatabaseConnections() async {
    try {
      if (kDebugMode) {
        debugPrint('正在关闭数据库连接...');
      }

      // 关闭用户偏好数据库
      try {
        await UserPreferencesDatabaseService().close();
      } catch (e) {
        if (kDebugMode) debugPrint('关闭用户偏好数据库失败: $e');
      }

      // 关闭地图本地化数据库
      try {
        await MapLocalizationService().close();
      } catch (e) {
        if (kDebugMode) debugPrint('关闭地图本地化数据库失败: $e');
      }

      // 关闭VFS存储数据库
      try {
        await VfsStorageService().close();
      } catch (e) {
        if (kDebugMode) debugPrint('关闭VFS存储数据库失败: $e');
      }

      // 关闭地图数据库
      try {
        await MapDatabaseService().close();
      } catch (e) {
        if (kDebugMode) debugPrint('关闭地图数据库失败: $e');
      }

      // 关闭图例数据库
      try {
        await LegendDatabaseService().close();
      } catch (e) {
        if (kDebugMode) debugPrint('关闭图例数据库失败: $e');
      }

      // 关闭用户偏好服务
      try {
        await UserPreferencesService().close();
      } catch (e) {
        if (kDebugMode) debugPrint('关闭用户偏好服务失败: $e');
      }

      if (kDebugMode) {
        debugPrint('数据库连接关闭完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('关闭数据库连接时发生错误: $e');
      }
    }
  }

  /// 停止所有脚本执行器
  Future<void> _stopScriptExecutors() async {
    try {
      if (kDebugMode) {
        debugPrint('正在停止脚本执行器...');
      }

      // 停止各种脚本执行器
      // 注意：这些可能是单例，需要谨慎处理
      try {
        // 这些服务可能需要特定的停止方法
        // 由于它们可能是单例，我们只能尝试调用dispose方法
      } catch (e) {
        if (kDebugMode) debugPrint('停止脚本执行器失败: $e');
      }

      if (kDebugMode) {
        debugPrint('脚本执行器停止完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('停止脚本执行器时发生错误: $e');
      }
    }
  }

  /// 停止音频服务
  Future<void> _stopAudioServices() async {
    try {
      if (kDebugMode) {
        debugPrint('正在停止音频服务...');
      }

      // 停止音频播放服务
      try {
        await AudioPlayerService().dispose();
      } catch (e) {
        if (kDebugMode) debugPrint('停止音频播放服务失败: $e');
      }

      // 停止TTS服务
      try {
        await TtsService().dispose();
      } catch (e) {
        if (kDebugMode) debugPrint('停止TTS服务失败: $e');
      }

      if (kDebugMode) {
        debugPrint('音频服务停止完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('停止音频服务时发生错误: $e');
      }
    }
  }

  /// 清理缓存
  Future<void> _cleanupCaches() async {
    try {
      if (kDebugMode) {
        debugPrint('正在清理缓存...');
      }

      // 清理图例缓存
      try {
        LegendCacheManager().clearAllCache();
      } catch (e) {
        if (kDebugMode) debugPrint('清理图例缓存失败: $e');
      }

      if (kDebugMode) {
        debugPrint('缓存清理完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理缓存时发生错误: $e');
      }
    }
  }

  /// 清理临时文件
  Future<void> _cleanupTemporaryFiles() async {
    try {
      if (kDebugMode) {
        debugPrint('正在清理临时文件...');
      }

      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // 只清理应用内部临时目录的子目录，保留temp目录本身
        final appDocDir = await getApplicationDocumentsDirectory();
        final appTempDir = Directory(path.join(appDocDir.path, 'r6box'));
        
        if (await appTempDir.exists()) {
          // 清理VFS临时文件子目录
          final vfsFilesDir = Directory(path.join(appTempDir.path, 'vfs_files'));
          if (await vfsFilesDir.exists()) {
            await _cleanupDirectory(vfsFilesDir);
          }
          
          // 清理剪贴板临时文件子目录
          final clipboardFilesDir = Directory(path.join(appTempDir.path, 'clipboard_files'));
          if (await clipboardFilesDir.exists()) {
            await _cleanupDirectory(clipboardFilesDir);
          }
          
          // 清理其他可能的临时文件（直接在temp目录下的文件）
          await for (final entity in appTempDir.list()) {
            if (entity is File) {
              try {
                await entity.delete();
                if (kDebugMode) {
                  debugPrint('删除临时文件: ${entity.path}');
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('删除临时文件失败: ${entity.path}, 错误: $e');
                }
              }
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint('临时文件清理完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理临时文件时发生错误: $e');
      }
    }
  }

  /// 清理日志文件（可选）
  Future<void> _cleanupLogFiles() async {
    try {
      if (kDebugMode) {
        debugPrint('正在清理过期日志文件...');
      }

      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // 获取应用文档目录
        final appDocDir = await getApplicationDocumentsDirectory();
        final logsDir = Directory(path.join(appDocDir.path, 'logs'));
        
        if (await logsDir.exists()) {
          // 清理超过7天的日志文件
          final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
          
          await for (final entity in logsDir.list()) {
            if (entity is File && entity.path.endsWith('.log')) {
              try {
                final stat = await entity.stat();
                if (stat.modified.isBefore(cutoffDate)) {
                  await entity.delete();
                  if (kDebugMode) {
                    debugPrint('删除过期日志文件: ${entity.path}');
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('删除日志文件失败: ${entity.path}, 错误: $e');
                }
              }
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint('日志文件清理完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理日志文件时发生错误: $e');
      }
    }
  }

  /// 关闭VFS系统
  Future<void> _closeVfsSystem() async {
    try {
      if (kDebugMode) {
        debugPrint('正在关闭VFS系统...');
      }

      // 关闭VFS服务提供者
      try {
        await VfsServiceProvider().close();
      } catch (e) {
        if (kDebugMode) debugPrint('关闭VFS服务提供者失败: $e');
      }

      if (kDebugMode) {
        debugPrint('VFS系统关闭完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('关闭VFS系统时发生错误: $e');
      }
    }
  }

  /// 清理指定目录
  Future<void> _cleanupDirectory(Directory directory, {List<String>? patterns}) async {
    try {
      if (!await directory.exists()) {
        return;
      }

      await for (final entity in directory.list()) {
        try {
          if (entity is File) {
            bool shouldDelete = false;
            
            if (patterns != null) {
              final fileName = path.basename(entity.path);
              for (final pattern in patterns) {
                if (pattern.contains('*')) {
                  // 简单的通配符匹配
                  final regex = RegExp(pattern.replaceAll('*', '.*'));
                  if (regex.hasMatch(fileName)) {
                    shouldDelete = true;
                    break;
                  }
                } else if (fileName == pattern) {
                  shouldDelete = true;
                  break;
                }
              }
            } else {
              // 如果没有指定模式，删除所有文件
              shouldDelete = true;
            }

            if (shouldDelete) {
              await entity.delete();
              if (kDebugMode) {
                debugPrint('删除临时文件: ${entity.path}');
              }
            }
          } else if (entity is Directory) {
            // 检查目录名是否匹配模式
            bool shouldProcessDir = false;
            
            if (patterns != null) {
              final dirName = path.basename(entity.path);
              for (final pattern in patterns) {
                if (pattern.contains('*')) {
                  final regex = RegExp(pattern.replaceAll('*', '.*'));
                  if (regex.hasMatch(dirName)) {
                    shouldProcessDir = true;
                    break;
                  }
                } else if (dirName == pattern) {
                  shouldProcessDir = true;
                  break;
                }
              }
            } else {
              // 如果没有指定模式，处理所有目录
              shouldProcessDir = true;
            }
            
            if (shouldProcessDir) {
              // 递归清理匹配的子目录
              await _cleanupDirectory(entity, patterns: patterns);
              
              // 如果目录为空，删除它
              try {
                final isEmpty = await entity.list().isEmpty;
                if (isEmpty) {
                  await entity.delete();
                  if (kDebugMode) {
                    debugPrint('删除空目录: ${entity.path}');
                  }
                }
              } catch (e) {
                // 忽略删除目录的错误
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('清理文件/目录失败: ${entity.path}, 错误: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理目录失败: ${directory.path}, 错误: $e');
      }
    }
  }

  /// 获取清理状态
  bool get isCleanupInProgress => _isCleanupInProgress;
}