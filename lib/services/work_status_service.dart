// This file has been processed by AI for internationalization
import 'package:flutter/foundation.dart';
import 'work_status_action.dart';

import 'localization_service.dart';

/// 工作状态管理服务
/// 用于管理应用程序的工作状态，当应用处于工作状态时：
/// - 托盘导航按钮将被禁用
/// - 关闭按钮会显示确认对话框
/// - 最大化和最小化功能仍然可用
/// - 可选的操作控件（如取消、暂停等）
class WorkStatusService extends ChangeNotifier {
  static final WorkStatusService _instance = WorkStatusService._internal();
  factory WorkStatusService() => _instance;
  WorkStatusService._internal();

  bool _isWorking = false;
  String _workDescription = '';
  final List<String> _workingTasks = [];
  List<WorkStatusAction> _actions = [];

  /// 当前是否处于工作状态
  bool get isWorking => _isWorking;

  /// 当前工作描述
  String get workDescription => _workDescription;

  /// 当前工作任务列表
  List<String> get workingTasks => List.unmodifiable(_workingTasks);

  /// 当前操作控件列表
  List<WorkStatusAction> get actions => List.unmodifiable(_actions);

  /// 开始工作状态
  /// [description] 工作描述，用于在对话框中显示
  /// [taskId] 可选的任务ID，用于标识特定任务
  /// [actions] 可选的操作控件列表，如取消、暂停等
  void startWorking(
    String description, {
    String? taskId,
    List<WorkStatusAction>? actions,
  }) {
    if (taskId != null && !_workingTasks.contains(taskId)) {
      _workingTasks.add(taskId);
    }

    // 更新操作控件
    _actions = actions ?? [];

    if (!_isWorking) {
      _isWorking = true;
      _workDescription = description;
      notifyListeners();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.workStatusStart_7285(
            description,
          ),
        );
      }
    } else if (_workDescription != description) {
      _workDescription = description;
      notifyListeners();
    }
  }

  /// 结束工作状态
  /// [taskId] 可选的任务ID，如果提供则只移除该任务
  void stopWorking({String? taskId}) {
    if (taskId != null) {
      _workingTasks.remove(taskId);
      // 如果还有其他任务在进行，不结束工作状态
      if (_workingTasks.isNotEmpty) {
        return;
      }
    } else {
      // 如果没有指定taskId，清空所有任务
      _workingTasks.clear();
    }

    if (_isWorking) {
      _isWorking = false;
      _workDescription = '';
      _actions = []; // 清空操作控件
      notifyListeners();
      if (kDebugMode) {
        debugPrint(LocalizationService.instance.current.workStatusEnded_7281);
      }
    }
  }

  /// 更新工作描述
  void updateWorkDescription(String description) {
    if (_isWorking && _workDescription != description) {
      _workDescription = description;
      notifyListeners();
    }
  }

  /// 更新操作控件
  void updateActions(List<WorkStatusAction> actions) {
    if (_isWorking) {
      _actions = actions;
      notifyListeners();
    }
  }

  /// 强制结束所有工作状态（用于紧急情况）
  void forceStopAllWork() {
    _workingTasks.clear();
    if (_isWorking) {
      _isWorking = false;
      _workDescription = '';
      _actions = []; // 清空操作控件
      notifyListeners();
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.forceTerminateAllWorkStatus_4821,
        );
      }
    }
  }
}
