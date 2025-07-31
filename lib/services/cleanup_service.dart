// This file has been processed by AI for internationalization
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

import 'localization_service.dart';

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
        debugPrint(
          LocalizationService.instance.current.skipDuplicateExecution_4821,
        );
      }
      return;
    }

    _isCleanupInProgress = true;
    final totalStopwatch = Stopwatch()..start();

    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.startCleanupOperation_7281,
        );
      }

      // 1. 关闭所有数据库连接
      final dbStopwatch = Stopwatch()..start();
      await _closeDatabaseConnections();
      dbStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.dbConnectionCloseTime(
            dbStopwatch.elapsedMilliseconds,
          ),
        );
      }

      // 2. 停止所有脚本执行器
      final scriptStopwatch = Stopwatch()..start();
      await _stopScriptExecutors();
      scriptStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.scriptExecutionTime(
            scriptStopwatch.elapsedMilliseconds,
          ),
        );
      }

      // 3. 停止音频服务
      final audioStopwatch = Stopwatch()..start();
      await _stopAudioServices();
      audioStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.audioServiceStopTime(
            audioStopwatch.elapsedMilliseconds,
          ),
        );
      }

      // 4. 清理缓存
      final cacheStopwatch = Stopwatch()..start();
      await _cleanupCaches();
      cacheStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.cacheCleanupTime(
            cacheStopwatch.elapsedMilliseconds,
          ),
        );
      }

      // 5. 清理临时文件
      final tempStopwatch = Stopwatch()..start();
      await _cleanupTemporaryFiles();
      tempStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.tempFileCleanupTime(
            tempStopwatch.elapsedMilliseconds,
          ),
        );
      }

      // 6. 清理日志文件（可选）
      final logStopwatch = Stopwatch()..start();
      await _cleanupLogFiles();
      logStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.logCleanupTime(
            logStopwatch.elapsedMilliseconds,
          ),
        );
      }

      // 7. 关闭VFS系统
      final vfsStopwatch = Stopwatch()..start();
      await _closeVfsSystem();
      vfsStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.vfsShutdownTime(
            vfsStopwatch.elapsedMilliseconds,
          ),
        );
      }

      totalStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.cleanupCompleted(
            totalStopwatch.elapsedMilliseconds,
          ),
        );
      }
    } catch (e) {
      totalStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.cleanupErrorWithDuration(
            e,
            totalStopwatch.elapsedMilliseconds,
          ),
        );
      }
    } finally {
      _isCleanupInProgress = false;
    }
  }

  /// 关闭所有数据库连接
  Future<void> _closeDatabaseConnections() async {
    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.closingDbConnection_7281,
        );
      }

      // 关闭用户偏好数据库
      try {
        await UserPreferencesDatabaseService().close();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.closeUserPrefDbFailed(e),
          );
      }

      // 关闭地图本地化数据库
      try {
        await MapLocalizationService().close();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.mapLocalizationDbCloseFailed(
              e,
            ),
          );
      }

      // 关闭VFS存储数据库
      try {
        await VfsStorageService().close();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.vfsDatabaseCloseFailure(e),
          );
      }

      // 关闭地图数据库
      try {
        await MapDatabaseService().close();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.mapDatabaseCloseFailed(e),
          );
      }

      // 关闭图例数据库
      try {
        await LegendDatabaseService().close();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.closeLegendDatabaseFailed(e),
          );
      }

      // 关闭用户偏好服务
      try {
        await UserPreferencesService().close();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.userPreferenceCloseFailed(e),
          );
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.databaseConnectionClosed_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.databaseCloseError_4821(e),
        );
      }
    }
  }

  /// 停止所有脚本执行器
  Future<void> _stopScriptExecutors() async {
    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.stoppingScriptExecutor_7421,
        );
      }

      // 停止各种脚本执行器
      // 注意：这些可能是单例，需要谨慎处理
      try {
        // 这些服务可能需要特定的停止方法
        // 由于它们可能是单例，我们只能尝试调用dispose方法
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.scriptExecutorFailure_4829(e),
          );
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.scriptExecutorStopped_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.scriptExecutorError_7425(e),
        );
      }
    }
  }

  /// 停止音频服务
  Future<void> _stopAudioServices() async {
    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.stoppingAudioService_7421,
        );
      }

      // 停止音频播放服务
      try {
        await AudioPlayerService().dispose();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.audioServiceStopFailed(e),
          );
      }

      // 停止TTS服务
      try {
        await TtsService().dispose();
      } catch (e) {
        if (kDebugMode)
          debugPrint(LocalizationService.instance.current.ttsServiceFailed(e));
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.audioServiceStopped_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.audioServiceError_4829(e),
        );
      }
    }
  }

  /// 清理缓存
  Future<void> _cleanupCaches() async {
    try {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.clearingCache_7421);
      }

      // 清理图例缓存
      try {
        LegendCacheManager().clearAllCache();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.clearLegendCacheFailed(e),
          );
      }

      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.cacheCleared_7281);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.cacheCleanError_7284(e),
        );
      }
    }
  }

  /// 清理临时文件
  Future<void> _cleanupTemporaryFiles() async {
    try {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.cleaningTempFiles_7421);
      }

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // 只清理应用内部临时目录的子目录，保留temp目录本身
        final appDocDir = await getApplicationDocumentsDirectory();
        final appTempDir = Directory(path.join(appDocDir.path, 'r6box'));

        if (await appTempDir.exists()) {
          // 清理VFS临时文件子目录
          final vfsFilesDir = Directory(
            path.join(appTempDir.path, 'vfs_files'),
          );
          if (await vfsFilesDir.exists()) {
            await _cleanupDirectory(vfsFilesDir);
          }

          // 清理剪贴板临时文件子目录
          final clipboardFilesDir = Directory(
            path.join(appTempDir.path, 'clipboard_files'),
          );
          if (await clipboardFilesDir.exists()) {
            await _cleanupDirectory(clipboardFilesDir);
          }

          // 清理WebDAV导入临时文件子目录
          final webdavImportDir = Directory(
            path.join(appTempDir.path, 'webdav_import'),
          );
          if (await webdavImportDir.exists()) {
            await _cleanupDirectory(webdavImportDir);
          }

          // 清理其他可能的临时文件（直接在temp目录下的文件）
          await for (final entity in appTempDir.list()) {
            if (entity is File) {
              try {
                await entity.delete();
                if (kDebugMode) {
                  debugPrint(
                    LocalizationService.instance.current.deleteTempFile(
                      entity.path,
                    ),
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint(
                    LocalizationService.instance.current
                        .deleteTempFileFailed_7421(entity.path, e),
                  );
                }
              }
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.tempFileCleaned_7281);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.tempFileCleanupError_4821(e),
        );
      }
    }
  }

  /// 清理日志文件（可选）
  Future<void> _cleanupLogFiles() async {
    try {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.cleaningExpiredLogs_7281,
        );
      }

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
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
                    debugPrint(
                      LocalizationService.instance.current.deleteExpiredLogFile(
                        entity.path,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint(
                    LocalizationService.instance.current.logDeletionFailed_7421(
                      entity.path,
                      e,
                    ),
                  );
                }
              }
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.logCleanupComplete_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.logCleanupError_5421(e),
        );
      }
    }
  }

  /// 关闭VFS系统
  Future<void> _closeVfsSystem() async {
    try {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.closingVfsSystem_7281);
      }

      // 关闭VFS服务提供者
      try {
        await VfsServiceProvider().close();
      } catch (e) {
        if (kDebugMode)
          debugPrint(
            LocalizationService.instance.current.vfsProviderCloseFailed(e),
          );
      }

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.vfsShutdownComplete_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.vfsErrorClosing_5421(e),
        );
      }
    }
  }

  /// 清理指定目录
  Future<void> _cleanupDirectory(
    Directory directory, {
    List<String>? patterns,
  }) async {
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
                debugPrint(
                  LocalizationService.instance.current.deleteTempFile(
                    entity.path,
                  ),
                );
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
                    debugPrint(
                      LocalizationService.instance.current
                          .deleteEmptyDirectory_7281(entity.path),
                    );
                  }
                }
              } catch (e) {
                // 忽略删除目录的错误
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              LocalizationService.instance.current.cleanupFailedMessage(
                entity.path,
                e,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.cleanDirectoryFailed(
            directory.path,
            e,
          ),
        );
      }
    }
  }

  /// 获取清理状态
  bool get isCleanupInProgress => _isCleanupInProgress;
}
