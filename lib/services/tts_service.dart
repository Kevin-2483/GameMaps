// This file has been processed by AI for internationalization
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import '../models/user_preferences.dart';
import 'user_preferences/user_preferences_service.dart';
import '../l10n/app_localizations.dart';
import 'localization_service.dart';

/// TTS 播放请求
class TtsRequest {
  final String text;
  final String? language;
  final double? speechRate;
  final double? volume;
  final double? pitch;
  final Map<String, String>? voice;
  final Completer<void> completer;
  final String? sourceId; // 用于识别请求来源

  TtsRequest({
    required this.text,
    this.language,
    this.speechRate,
    this.volume,
    this.pitch,
    this.voice,
    this.sourceId,
  }) : completer = Completer<void>();
}

/// 文本转语音服务
/// 封装 flutter_tts 功能，支持从用户偏好设置读取配置
/// 使用队列管理多个语音请求，避免并发冲突
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  final UserPreferencesService _preferencesService = UserPreferencesService();

  bool _isInitialized = false;
  List<dynamic>? _availableLanguages;
  List<dynamic>? _availableVoices;

  // 队列管理
  final Queue<TtsRequest> _requestQueue = Queue<TtsRequest>();
  bool _isProcessing = false;
  TtsRequest? _currentRequest;

  /// 初始化 TTS 服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // 设置事件回调
      _setupCallbacks();

      // 获取可用语言和语音
      await _loadAvailableOptions();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.ttsInitializationComplete_7281,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.ttsInitializationFailed(e),
        );
      }
      rethrow;
    }
  }

  /// 设置事件回调
  void _setupCallbacks() {
    if (_flutterTts == null) return;

    _flutterTts!.setStartHandler(() {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.ttsStartPlaying_7281);
      }
    });

    _flutterTts!.setCompletionHandler(() {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.ttsPlaybackComplete_7281,
        );
      }
      _onSpeechComplete();
    });

    _flutterTts!.setErrorHandler((msg) {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.ttsError_7285(msg));
      }
      _onSpeechError(msg);
    });

    _flutterTts!.setCancelHandler(() {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.ttsPlaybackCancelled_7421,
        );
      }
      _onSpeechComplete();
    });
  }

  /// 处理语音播放完成
  void _onSpeechComplete() {
    if (_currentRequest != null) {
      _currentRequest!.completer.complete();
      _currentRequest = null;
    }
    _isProcessing = false;
    _processNextRequest();
  }

  /// 处理语音播放错误
  void _onSpeechError(String error) {
    if (_currentRequest != null) {
      _currentRequest!.completer.completeError(error);
      _currentRequest = null;
    }
    _isProcessing = false;
    _processNextRequest();
  }

  /// 处理队列中的下一个请求
  void _processNextRequest() async {
    // 如果已经在处理或队列为空，则返回
    if (_isProcessing || _requestQueue.isEmpty) {
      return;
    }

    _isProcessing = true;
    _currentRequest = _requestQueue.removeFirst();

    try {
      await _playCurrent();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.ttsRequestFailed_7421(e),
        );
      }
      _onSpeechError(e.toString());
    }
  }

  /// 播放当前请求
  Future<void> _playCurrent() async {
    if (_currentRequest == null || _flutterTts == null) return;

    final request = _currentRequest!;

    // 获取用户偏好设置作为默认值
    final userPrefs = await _preferencesService.getCurrentPreferences();
    final defaultTtsPrefs = userPrefs.tools.tts;

    // 如果TTS被禁用，则直接完成
    if (!defaultTtsPrefs.enabled) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.ttsDisabledSkipPlayRequest_4821,
        );
      }
      // 直接完成当前请求并处理下一个
      if (_currentRequest != null) {
        _currentRequest!.completer.complete();
        _currentRequest = null;
      }
      _isProcessing = false;
      _processNextRequest();
      return;
    }

    // 应用配置（使用请求参数覆盖默认设置）
    if (request.language != null) {
      await _flutterTts!.setLanguage(request.language!);
    } else if (defaultTtsPrefs.language != null) {
      await _flutterTts!.setLanguage(defaultTtsPrefs.language!);
    }

    await _flutterTts!.setSpeechRate(
      request.speechRate ?? defaultTtsPrefs.speechRate,
    );
    await _flutterTts!.setVolume(request.volume ?? defaultTtsPrefs.volume);
    await _flutterTts!.setPitch(request.pitch ?? defaultTtsPrefs.pitch);

    if (request.voice != null) {
      await _flutterTts!.setVoice(request.voice!);
    } else if (defaultTtsPrefs.voice != null) {
      await _flutterTts!.setVoice(defaultTtsPrefs.voice!);
    }

    // 开始播放
    await _flutterTts!.speak(request.text);

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.ttsPlaybackStart(
          request.text,
          request.sourceId ??
              LocalizationService.instance.current.unknownSource_3632,
        ),
      );
    }
  }

  /// 加载可用的语言和语音选项
  Future<void> _loadAvailableOptions() async {
    if (_flutterTts == null) return;

    try {
      _availableLanguages = await _flutterTts!.getLanguages;
      _availableVoices = await _flutterTts!.getVoices;

      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.availableLanguages_7421(
            _availableLanguages ?? [],
          ),
        );
        debugPrint(
          LocalizationService.instance.current.availableVoicesMessage(
            _availableVoices ?? [],
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.ttsLoadFailed_7285(e));
      }
    }
  }

  /// 语音合成文本 (使用队列管理)
  ///
  /// [text] 要合成的文本
  /// [language] 可选的语言设置，如果不提供则使用用户偏好设置
  /// [speechRate] 可选的语音速度设置 (0.0-1.0)
  /// [volume] 可选的音量设置 (0.0-1.0)
  /// [pitch] 可选的音调设置 (0.5-2.0)
  /// [voice] 可选的语音设置
  /// [sourceId] 请求来源标识，用于调试和日志
  Future<void> speak(
    String text, {
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
    Map<String, String>? voice,
    String? sourceId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null) {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.ttsNotInitialized_7281);
      }
      return;
    }

    if (text.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.ttsEmptySkipPlay_4821);
      }
      return;
    }

    // 创建请求并添加到队列
    final request = TtsRequest(
      text: text,
      language: language,
      speechRate: speechRate,
      volume: volume,
      pitch: pitch,
      voice: voice,
      sourceId: sourceId,
    );

    _requestQueue.add(request);

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.ttsRequestQueued(
          text,
          sourceId ?? LocalizationService.instance.current.unknown,
          _requestQueue.length,
        ),
      );
    }

    // 开始处理队列
    _processNextRequest();

    // 等待请求完成 (可选)
    return request.completer.future;
  }

  /// 立即停止当前播放并清空队列
  Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }

    // 清空队列
    while (_requestQueue.isNotEmpty) {
      final request = _requestQueue.removeFirst();
      if (!request.completer.isCompleted) {
        request.completer.complete();
      }
    }

    _currentRequest = null;
    _isProcessing = false;

    if (kDebugMode) {
      debugPrint(
        LocalizationService.instance.current.ttsStoppedQueueCleared_4821,
      );
    }
  }

  /// 停止特定来源的播放请求
  Future<void> stopBySource(String sourceId) async {
    // 从队列中移除特定来源的请求
    final toRemove = <TtsRequest>[];
    for (final request in _requestQueue) {
      if (request.sourceId == sourceId) {
        toRemove.add(request);
      }
    }

    for (final request in toRemove) {
      _requestQueue.remove(request);
      if (!request.completer.isCompleted) {
        request.completer.complete();
      }
    }

    // 如果当前播放的是该来源的请求，停止播放
    if (_currentRequest?.sourceId == sourceId) {
      await _flutterTts?.stop();
    }

    if (kDebugMode && toRemove.isNotEmpty) {
      debugPrint(
        LocalizationService.instance.current.stoppedTtsRequests(
          sourceId,
          toRemove.length,
        ),
      );
    }
  }

  /// 暂停语音播放 (仅部分平台支持)
  Future<void> pause() async {
    if (_flutterTts != null) {
      await _flutterTts!.pause();
    }
  }

  /// 获取可用语言列表
  List<dynamic>? get availableLanguages => _availableLanguages;

  /// 获取可用语音列表
  List<dynamic>? get availableVoices => _availableVoices;

  /// 检查是否支持指定语言
  Future<bool> isLanguageAvailable(String language) async {
    if (_flutterTts == null) return false;

    try {
      return await _flutterTts!.isLanguageAvailable(language);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.languageCheckFailed_4821(e),
        );
      }
      return false;
    }
  }

  /// 获取语音速度有效范围
  Future<Map<String, double>?> getSpeechRateRange() async {
    if (_flutterTts == null) return null;

    try {
      final range = await _flutterTts!.getSpeechRateValidRange;
      return {'min': range.min, 'normal': range.normal, 'max': range.max};
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.failedToGetVoiceSpeedRange(e),
        );
      }
      return null;
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
      _flutterTts = null;
    }
    _isInitialized = false;
  }
}
