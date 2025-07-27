// preview_queue_manager.dart - 绘制预览队列管理器
// 用于管理图层锁定状态下的绘制预览队列

import 'package:flutter/material.dart';
import '../../../models/map_layer.dart';
import '../../../models/sticky_note.dart';
import '../../../collaboration/collaboration.dart';
import '../widgets/map_canvas.dart';
import '../../../collaboration/global_collaboration_service.dart';

/// 预览队列项
class PreviewQueueItem {
  final String id;
  final DrawingPreviewData previewData;
  final String targetLayerId;
  final DateTime createdAt;
  final bool isWaitingForLayer; // 是否等待图层解锁

  const PreviewQueueItem({
    required this.id,
    required this.previewData,
    required this.targetLayerId,
    required this.createdAt,
    this.isWaitingForLayer = false,
  });

  PreviewQueueItem copyWith({
    String? id,
    DrawingPreviewData? previewData,
    String? targetLayerId,
    DateTime? createdAt,
    bool? isWaitingForLayer,
  }) {
    return PreviewQueueItem(
      id: id ?? this.id,
      previewData: previewData ?? this.previewData,
      targetLayerId: targetLayerId ?? this.targetLayerId,
      createdAt: createdAt ?? this.createdAt,
      isWaitingForLayer: isWaitingForLayer ?? this.isWaitingForLayer,
    );
  }
}

/// 便签预览队列项
class StickyNotePreviewQueueItem {
  final String id;
  final StickyNote stickyNote;
  final MapDrawingElement element;
  final Function(StickyNote) onStickyNoteUpdated;
  final DateTime createdAt;
  final bool isWaitingForStickyNote; // 是否等待便签解锁

  const StickyNotePreviewQueueItem({
    required this.id,
    required this.stickyNote,
    required this.element,
    required this.onStickyNoteUpdated,
    required this.createdAt,
    this.isWaitingForStickyNote = false,
  });

  StickyNotePreviewQueueItem copyWith({
    String? id,
    StickyNote? stickyNote,
    MapDrawingElement? element,
    Function(StickyNote)? onStickyNoteUpdated,
    DateTime? createdAt,
    bool? isWaitingForStickyNote,
  }) {
    return StickyNotePreviewQueueItem(
      id: id ?? this.id,
      stickyNote: stickyNote ?? this.stickyNote,
      element: element ?? this.element,
      onStickyNoteUpdated: onStickyNoteUpdated ?? this.onStickyNoteUpdated,
      createdAt: createdAt ?? this.createdAt,
      isWaitingForStickyNote:
          isWaitingForStickyNote ?? this.isWaitingForStickyNote,
    );
  }
}

/// 预览队列管理器
/// 基于协作状态管理系统，管理绘制预览的队列
/// 当图层被其他用户锁定时保持预览状态，等待解锁后自动提交
/// 使用按图层隔离的队列结构，便于图层删除时快速清理对应队列
class PreviewQueueManager {
  // 按图层ID隔离的预览队列
  final Map<String, List<PreviewQueueItem>> _layerQueues = {};

  // 按便签ID隔离的预览队列
  final Map<String, List<StickyNotePreviewQueueItem>> _stickyNoteQueues = {};

  // 预览队列变化通知器
  final ValueNotifier<List<PreviewQueueItem>> _queueNotifier = ValueNotifier(
    [],
  );

  // 便签预览队列变化通知器
  final ValueNotifier<List<StickyNotePreviewQueueItem>>
  _stickyNoteQueueNotifier = ValueNotifier([]);

  // 协作状态管理器
  final CollaborationStateManager _collaborationManager;

  // 回调函数
  Function(MapDrawingElement, String)? onElementReadyToAdd;
  Function()? onQueueChanged;
  Function(String)? onGetLayerMaxZIndex; // 获取图层最大z值的回调
  Function(String)? onGetStickyNoteMaxZIndex; // 获取便签最大z值的回调

  PreviewQueueManager({
    CollaborationStateManager? collaborationManager,
    this.onElementReadyToAdd,
    this.onQueueChanged,
    this.onGetLayerMaxZIndex,
    this.onGetStickyNoteMaxZIndex,
  }) : _collaborationManager =
           collaborationManager ?? _getGlobalCollaborationStateManager();

  /// 获取全局协作状态管理器实例
  static CollaborationStateManager _getGlobalCollaborationStateManager() {
    try {
      return GlobalCollaborationService.instance.collaborationStateManager;
    } catch (e) {
      // 如果全局服务未初始化，返回一个新的实例
      print('[PreviewQueueManager] 全局协作服务未初始化，使用本地实例: $e');
      return CollaborationStateManager();
    }
  }

  /// 获取预览队列通知器
  ValueNotifier<List<PreviewQueueItem>> get queueNotifier => _queueNotifier;

  /// 获取当前队列（所有图层的队列项合并）
  List<PreviewQueueItem> get currentQueue {
    final allItems = <PreviewQueueItem>[];
    for (final layerQueue in _layerQueues.values) {
      allItems.addAll(layerQueue);
    }
    return allItems;
  }

  /// 获取指定图层的队列
  List<PreviewQueueItem> getLayerQueue(String layerId) {
    return List.from(_layerQueues[layerId] ?? []);
  }

  /// 检查图层是否被锁定（基于协作状态）
  bool isLayerLocked(String layerId) {
    return _collaborationManager.isElementLocked(layerId);
  }

  /// 尝试锁定图层
  bool tryLockLayer(String layerId) {
    return _collaborationManager.tryLockElement(
      elementId: layerId,
      elementType: 'layer',
      timeoutSeconds: 30,
    );
  }

  /// 释放图层锁定
  bool unlockLayer(String layerId) {
    return _collaborationManager.unlockElement(layerId);
  }

  /// 获取指定图层的锁定状态信息
  ElementLockState? getLayerLockState(String layerId) {
    return _collaborationManager.getElementLockState(layerId);
  }

  /// 添加预览到队列
  /// 如果图层未被锁定，立即处理；否则加入队列等待
  void addPreviewToQueue({
    required DrawingPreviewData previewData,
    required String targetLayerId,
  }) {
    // 检查用户是否离线，如果离线则直接提交，不使用队列
    final isUserOffline = _collaborationManager.isCurrentUserOffline();
    if (isUserOffline) {
      // 用户离线，直接处理预览项，不需要锁定机制
      final queueItem = PreviewQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        previewData: previewData,
        targetLayerId: targetLayerId,
        createdAt: DateTime.now(),
        isWaitingForLayer: false,
      );
      _processPreviewItem(queueItem);
      print('[PreviewQueueManager] 用户离线，预览已直接处理并添加到图层 $targetLayerId');
      return;
    }

    // 用户在线，使用原有的锁定和队列机制
    final isLocked = isLayerLocked(targetLayerId);

    final queueItem = PreviewQueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      previewData: previewData,
      targetLayerId: targetLayerId,
      createdAt: DateTime.now(),
      isWaitingForLayer: isLocked,
    );

    if (isLocked) {
      // 图层被锁定，加入对应图层的队列等待
      _layerQueues.putIfAbsent(targetLayerId, () => []).add(queueItem);
      print('[PreviewQueueManager] 图层 $targetLayerId 被锁定，预览已加入队列');
    } else {
      // 图层未锁定，尝试锁定并立即处理
      if (tryLockLayer(targetLayerId)) {
        _processPreviewItem(queueItem);
        unlockLayer(targetLayerId);
        print('[PreviewQueueManager] 预览已立即处理并添加到图层 $targetLayerId');
      } else {
        // 锁定失败，加入对应图层的队列
        _layerQueues.putIfAbsent(targetLayerId, () => []).add(queueItem);
        print('[PreviewQueueManager] 无法锁定图层 $targetLayerId，预览已加入队列');
      }
    }

    _updateQueueNotifier();
  }

  /// 添加预览项到队列（兼容旧接口）
  void addPreviewItem(PreviewQueueItem item) {
    addPreviewToQueue(
      previewData: item.previewData,
      targetLayerId: item.targetLayerId,
    );
  }

  /// 从DrawingPreviewData创建预览项
  PreviewQueueItem createPreviewItem(
    DrawingPreviewData previewData,
    String targetLayerId,
  ) {
    return PreviewQueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      previewData: previewData,
      targetLayerId: targetLayerId,
      createdAt: DateTime.now(),
    );
  }

  /// 将预览项转换为绘制元素
  MapDrawingElement convertToDrawingElement(PreviewQueueItem item, int zIndex) {
    final previewData = item.previewData;

    // 处理不同类型的绘制元素
    List<Offset> points;
    if (previewData.freeDrawingPath != null) {
      // 自由绘制路径
      points = previewData.freeDrawingPath!;
    } else {
      // 标准绘制元素
      points = [previewData.start, previewData.end];
    }

    return MapDrawingElement(
      id: item.id,
      type: previewData.elementType,
      points: points,
      color: previewData.color,
      strokeWidth: previewData.strokeWidth,
      density: previewData.density,
      curvature: previewData.curvature,
      triangleCut: previewData.triangleCut,
      zIndex: zIndex,
      text: previewData.text,
      fontSize: previewData.fontSize,
      createdAt: item.createdAt,
    );
  }

  /// 处理队列中等待的预览项
  /// 当图层解锁时调用
  /// 按照队列顺序处理，确保z值按添加顺序递增
  void processWaitingPreviews() {
    bool hasProcessedItems = false;

    // 遍历所有图层队列
    for (final entry in _layerQueues.entries) {
      final layerId = entry.key;
      final layerQueue = entry.value;

      // 跳过空队列或被锁定的图层
      if (layerQueue.isEmpty || isLayerLocked(layerId)) {
        continue;
      }

      // 尝试锁定图层并处理队列
      if (tryLockLayer(layerId)) {
        // 按创建时间排序，确保按队列顺序处理
        layerQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // 处理该图层的所有预览项
        final itemsToProcess = List<PreviewQueueItem>.from(layerQueue);
        for (final item in itemsToProcess) {
          // 在添加每个元素时重新获取图层的当前最大z值
          final currentMaxZIndex = onGetLayerMaxZIndex?.call(layerId) ?? 0;
          final zIndex = currentMaxZIndex + 1;

          // 直接转换并添加元素
          final element = convertToDrawingElement(item, zIndex);
          onElementReadyToAdd?.call(element, item.targetLayerId);

          print(
            '[PreviewQueueManager] 队列中的预览已处理: ${item.id}, z值: $zIndex (基于实时图层状态)',
          );
        }

        // 清空该图层的队列
        layerQueue.clear();
        hasProcessedItems = true;

        unlockLayer(layerId);
      }
    }

    // 清理空的图层队列
    _layerQueues.removeWhere((layerId, queue) => queue.isEmpty);

    if (hasProcessedItems) {
      _updateQueueNotifier();
    }
  }

  /// 处理指定图层的等待预览项
  void processLayerWaitingPreviews(String layerId) {
    final layerQueue = _layerQueues[layerId];
    if (layerQueue == null || layerQueue.isEmpty || isLayerLocked(layerId)) {
      return;
    }

    if (tryLockLayer(layerId)) {
      // 按创建时间排序
      layerQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 处理该图层的所有预览项
      final itemsToProcess = List<PreviewQueueItem>.from(layerQueue);
      for (final item in itemsToProcess) {
        final currentMaxZIndex = onGetLayerMaxZIndex?.call(layerId) ?? 0;
        final zIndex = currentMaxZIndex + 1;

        final element = convertToDrawingElement(item, zIndex);
        onElementReadyToAdd?.call(element, item.targetLayerId);

        print(
          '[PreviewQueueManager] 图层 $layerId 队列中的预览已处理: ${item.id}, z值: $zIndex',
        );
      }

      // 清空该图层的队列
      layerQueue.clear();
      _layerQueues.remove(layerId);

      unlockLayer(layerId);
      _updateQueueNotifier();
    }
  }

  /// 处理单个预览项
  void _processPreviewItem(PreviewQueueItem item) {
    // 计算正确的z值
    final zIndex = _calculateNextZIndex(item.targetLayerId);

    // 转换为绘制元素并通知外部添加
    final element = convertToDrawingElement(item, zIndex);
    onElementReadyToAdd?.call(element, item.targetLayerId);
  }

  /// 计算下一个z值
  /// 基于目标图层中现有元素的最大z值+1
  int _calculateNextZIndex(String layerId) {
    // 这里需要通过回调获取图层信息
    // 由于PreviewQueueManager不直接访问图层数据，
    // 我们需要添加一个回调来获取图层的最大z值
    if (onGetLayerMaxZIndex != null) {
      return onGetLayerMaxZIndex!(layerId) + 1;
    }

    // 如果没有回调，返回默认值
    return 0;
  }

  /// 提交预览项（将其转换为实际元素）
  void commitPreviewItem(String itemId, int zIndex) {
    PreviewQueueItem? foundItem;
    String? foundLayerId;

    // 在所有图层队列中查找指定的预览项
    for (final entry in _layerQueues.entries) {
      final layerId = entry.key;
      final layerQueue = entry.value;
      final itemIndex = layerQueue.indexWhere((item) => item.id == itemId);

      if (itemIndex != -1) {
        foundItem = layerQueue[itemIndex];
        foundLayerId = layerId;
        layerQueue.removeAt(itemIndex);
        break;
      }
    }

    if (foundItem == null || foundLayerId == null) return;

    // 转换为绘制元素
    final element = convertToDrawingElement(foundItem, zIndex);

    // 通知外部添加元素
    onElementReadyToAdd?.call(element, foundItem.targetLayerId);

    // 清理空的图层队列
    if (_layerQueues[foundLayerId]?.isEmpty == true) {
      _layerQueues.remove(foundLayerId);
    }

    _updateQueueNotifier();
    print('[PreviewQueueManager] 预览已提交: $itemId');
  }

  /// 强制提交预览项（忽略锁定状态）
  void forceCommitPreview(PreviewQueueItem item) {
    final layerQueue = _layerQueues[item.targetLayerId];
    if (layerQueue != null && layerQueue.contains(item)) {
      _processPreviewItem(item);
      layerQueue.remove(item);

      // 清理空的图层队列
      if (layerQueue.isEmpty) {
        _layerQueues.remove(item.targetLayerId);
      }

      _updateQueueNotifier();
      print('[PreviewQueueManager] 强制提交预览: ${item.id}');
    }
  }

  /// 移除预览项
  void removePreviewItem(String itemId) {
    bool removed = false;

    for (final entry in _layerQueues.entries) {
      final layerId = entry.key;
      final layerQueue = entry.value;

      final initialLength = layerQueue.length;
      layerQueue.removeWhere((item) => item.id == itemId);
      final removedCount = initialLength - layerQueue.length;
      if (removedCount > 0) {
        removed = true;

        // 清理空的图层队列
        if (layerQueue.isEmpty) {
          _layerQueues.remove(layerId);
        }
        break;
      }
    }

    if (removed) {
      _updateQueueNotifier();
      print('[PreviewQueueManager] 预览已移除: $itemId');
    }
  }

  /// 清空队列
  void clearQueue() {
    _layerQueues.clear();
    _updateQueueNotifier();
    print('[PreviewQueueManager] 预览队列已清空');
  }

  /// 清空指定图层的队列
  void clearLayerQueue(String layerId) {
    final removed = _layerQueues.remove(layerId);
    if (removed != null && removed.isNotEmpty) {
      _updateQueueNotifier();
      print('[PreviewQueueManager] 图层 $layerId 的预览队列已清空');
    }
  }

  /// 获取队列中的总预览数量
  int get totalQueueCount {
    int total = 0;
    for (final layerQueue in _layerQueues.values) {
      total += layerQueue.length;
    }
    return total;
  }

  /// 获取指定图层的队列数量
  int getLayerQueueCount(String layerId) {
    return _layerQueues[layerId]?.length ?? 0;
  }

  /// 获取特定图层的预览项
  List<PreviewQueueItem> getPreviewItemsForLayer(String layerId) {
    return List.from(_layerQueues[layerId] ?? []);
  }

  /// 获取等待中的预览项
  List<PreviewQueueItem> getWaitingItems() {
    final waitingItems = <PreviewQueueItem>[];
    for (final layerQueue in _layerQueues.values) {
      waitingItems.addAll(layerQueue.where((item) => item.isWaitingForLayer));
    }
    return waitingItems;
  }

  /// 获取所有有队列的图层ID列表
  List<String> getLayersWithQueue() {
    return _layerQueues.keys
        .where((layerId) => _layerQueues[layerId]?.isNotEmpty == true)
        .toList();
  }

  /// 更新队列通知器
  void _updateQueueNotifier() {
    // 合并所有图层的队列项
    final allItems = <PreviewQueueItem>[];
    for (final layerQueue in _layerQueues.values) {
      allItems.addAll(layerQueue);
    }
    _queueNotifier.value = allItems;
    onQueueChanged?.call();
  }

  /// 更新便签队列通知器
  void _updateStickyNoteQueueNotifier() {
    // 合并所有便签的队列项
    final allItems = <StickyNotePreviewQueueItem>[];
    for (final stickyNoteQueue in _stickyNoteQueues.values) {
      allItems.addAll(stickyNoteQueue);
    }
    _stickyNoteQueueNotifier.value = allItems;
    onQueueChanged?.call();
  }

  // ========== 便签队列管理方法 ==========

  /// 获取便签预览队列通知器
  ValueNotifier<List<StickyNotePreviewQueueItem>> get stickyNoteQueueNotifier =>
      _stickyNoteQueueNotifier;

  /// 获取当前便签队列（所有便签的队列项合并）
  List<StickyNotePreviewQueueItem> get currentStickyNoteQueue {
    final allItems = <StickyNotePreviewQueueItem>[];
    for (final stickyNoteQueue in _stickyNoteQueues.values) {
      allItems.addAll(stickyNoteQueue);
    }
    return allItems;
  }

  /// 获取指定便签的队列
  List<StickyNotePreviewQueueItem> getStickyNoteQueue(String stickyNoteId) {
    return List.from(_stickyNoteQueues[stickyNoteId] ?? []);
  }

  /// 检查便签是否被锁定
  bool isStickyNoteLocked(String stickyNoteId) {
    final elementId = 'sticky_note_$stickyNoteId';
    return _collaborationManager.isElementLocked(elementId);
  }

  /// 尝试锁定便签
  bool tryLockStickyNote(String stickyNoteId) {
    final elementId = 'sticky_note_$stickyNoteId';
    return _collaborationManager.tryLockElement(
      elementId: elementId,
      elementType: 'sticky_note',
      timeoutSeconds: 30,
    );
  }

  /// 释放便签锁定
  bool unlockStickyNote(String stickyNoteId) {
    final elementId = 'sticky_note_$stickyNoteId';
    return _collaborationManager.unlockElement(elementId);
  }

  /// 添加便签预览到队列
  void addStickyNotePreviewToQueue(
    StickyNote stickyNote,
    MapDrawingElement element,
    Function(StickyNote) onStickyNoteUpdated,
  ) {
    final stickyNoteId = stickyNote.id;

    // 检查用户是否离线，如果离线则直接提交，不使用队列
    final isUserOffline = _collaborationManager.isCurrentUserOffline();
    if (isUserOffline) {
      // 用户离线，直接处理预览项，不需要锁定机制
      final queueItem = StickyNotePreviewQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stickyNote: stickyNote,
        element: element,
        onStickyNoteUpdated: onStickyNoteUpdated,
        createdAt: DateTime.now(),
        isWaitingForStickyNote: false,
      );
      _processStickyNotePreviewItem(queueItem);
      print('[PreviewQueueManager] 用户离线，便签预览已直接处理并添加到便签 $stickyNoteId');
      return;
    }

    // 用户在线，使用原有的锁定和队列机制
    final isLocked = isStickyNoteLocked(stickyNoteId);

    final queueItem = StickyNotePreviewQueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      stickyNote: stickyNote,
      element: element,
      onStickyNoteUpdated: onStickyNoteUpdated,
      createdAt: DateTime.now(),
      isWaitingForStickyNote: isLocked,
    );

    if (isLocked) {
      // 便签被锁定，加入对应便签的队列等待
      _stickyNoteQueues.putIfAbsent(stickyNoteId, () => []).add(queueItem);
      final queueLength = _stickyNoteQueues[stickyNoteId]!.length;
      print(
        '[PreviewQueueManager] 便签 $stickyNoteId 被锁定，预览已加入队列，当前队列长度: $queueLength',
      );
    } else {
      // 便签未锁定，尝试锁定并立即处理
      if (tryLockStickyNote(stickyNoteId)) {
        _processStickyNotePreviewItem(queueItem);
        unlockStickyNote(stickyNoteId);
        print('[PreviewQueueManager] 便签预览已立即处理并添加到便签 $stickyNoteId');
      } else {
        // 锁定失败，加入对应便签的队列
        _stickyNoteQueues.putIfAbsent(stickyNoteId, () => []).add(queueItem);
        final queueLength = _stickyNoteQueues[stickyNoteId]!.length;
        print(
          '[PreviewQueueManager] 无法锁定便签 $stickyNoteId，预览已加入队列，当前队列长度: $queueLength',
        );
      }
    }

    _updateStickyNoteQueueNotifier();
  }

  /// 处理便签队列中等待的预览项
  void processStickyNoteWaitingPreviews(String stickyNoteId) {
    final stickyNoteQueue = _stickyNoteQueues[stickyNoteId];
    if (stickyNoteQueue == null || stickyNoteQueue.isEmpty) return;

    if (tryLockStickyNote(stickyNoteId)) {
      // 按创建时间排序
      stickyNoteQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 处理该便签的所有预览项
      final itemsToProcess = List<StickyNotePreviewQueueItem>.from(
        stickyNoteQueue,
      );
      final totalItems = itemsToProcess.length;
      print('[PreviewQueueManager] 开始处理便签 $stickyNoteId 队列，共 $totalItems 个项目');

      for (int i = 0; i < itemsToProcess.length; i++) {
        final item = itemsToProcess[i];
        _processStickyNotePreviewItem(item);
        print(
          '[PreviewQueueManager] 便签 $stickyNoteId 队列项目 ${i + 1}/$totalItems 已处理: ${item.id}',
        );
      }

      // 清空该便签的队列
      stickyNoteQueue.clear();
      _stickyNoteQueues.remove(stickyNoteId);
      print(
        '[PreviewQueueManager] 便签 $stickyNoteId 队列已清空，所有 $totalItems 个项目处理完成',
      );

      unlockStickyNote(stickyNoteId);
      _updateStickyNoteQueueNotifier();
    }
  }

  /// 处理单个便签预览项
  void _processStickyNotePreviewItem(StickyNotePreviewQueueItem item) {
    // 实时计算便签元素的z值，确保不会冲突
    final currentMaxZIndex =
        onGetStickyNoteMaxZIndex?.call(item.stickyNote.id) ?? 0;
    final elementWithUpdatedZIndex = item.element.copyWith(
      zIndex: currentMaxZIndex + 1,
    );

    // 添加更新了z值的元素到便签
    final updatedStickyNote = item.stickyNote.addElement(
      elementWithUpdatedZIndex,
    );
    item.onStickyNoteUpdated(updatedStickyNote);
  }

  /// 移除便签预览项
  void removeStickyNotePreviewItem(String itemId) {
    bool removed = false;

    for (final entry in _stickyNoteQueues.entries) {
      final stickyNoteId = entry.key;
      final stickyNoteQueue = entry.value;

      final initialLength = stickyNoteQueue.length;
      stickyNoteQueue.removeWhere((item) => item.id == itemId);
      final removedCount = initialLength - stickyNoteQueue.length;
      if (removedCount > 0) {
        removed = true;

        // 清理空的便签队列
        if (stickyNoteQueue.isEmpty) {
          _stickyNoteQueues.remove(stickyNoteId);
        }
        break;
      }
    }

    if (removed) {
      _updateStickyNoteQueueNotifier();
      print('[PreviewQueueManager] 便签预览已移除: $itemId');
    }
  }

  /// 清空便签队列
  void clearStickyNoteQueue() {
    _stickyNoteQueues.clear();
    _updateStickyNoteQueueNotifier();
    print('[PreviewQueueManager] 便签预览队列已清空');
  }

  /// 清空指定便签的队列
  void clearStickyNoteQueueById(String stickyNoteId) {
    final removed = _stickyNoteQueues.remove(stickyNoteId);
    if (removed != null && removed.isNotEmpty) {
      _updateStickyNoteQueueNotifier();
      print('[PreviewQueueManager] 便签 $stickyNoteId 的预览队列已清空');
    }
  }

  /// 获取便签队列中的总预览数量
  int get totalStickyNoteQueueCount {
    int total = 0;
    for (final stickyNoteQueue in _stickyNoteQueues.values) {
      total += stickyNoteQueue.length;
    }
    return total;
  }

  /// 获取指定便签的队列数量
  int getStickyNoteQueueCount(String stickyNoteId) {
    return _stickyNoteQueues[stickyNoteId]?.length ?? 0;
  }

  /// 获取所有有队列的便签ID列表
  List<String> getStickyNotesWithQueue() {
    return _stickyNoteQueues.keys
        .where(
          (stickyNoteId) => _stickyNoteQueues[stickyNoteId]?.isNotEmpty == true,
        )
        .toList();
  }

  /// 清理资源
  void dispose() {
    _queueNotifier.dispose();
    _stickyNoteQueueNotifier.dispose();
  }
}
