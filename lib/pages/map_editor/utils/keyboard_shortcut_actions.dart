// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/map_item.dart';
import '../../../models/map_layer.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../services/clipboard_service.dart';
import '../../../services/notification/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

/// 快捷键动作实现类
/// 包含所有快捷键回调方法的具体实现
class KeyboardShortcutActions {
  final BuildContext context;
  final VoidCallback? setState;

  // 地图相关状态
  final MapItem? Function() getCurrentMap;
  final MapLayer? Function() getSelectedLayer;
  final List<MapLayer>? Function() getSelectedLayerGroup;
  final MapLayer? Function() getCurrentDrawingTargetLayer;
  final LegendGroup? Function() getCurrentLegendGroupForManagement;
  final bool Function() getIsLegendGroupManagementDrawerOpen;
  final bool Function() getIsLayerLegendBindingDrawerOpen;
  final bool Function() getIsSidebarCollapsed;
  final bool Function() getIsZIndexInspectorOpen;
  final GlobalKey Function() getMapCanvasKey;

  // 响应式系统方法
  final bool Function() canUndoReactive;
  final bool Function() canRedoReactive;
  final VoidCallback undoReactive;
  final VoidCallback redoReactive;

  // 状态更新方法
  final void Function(MapLayer) updateLayer;
  final void Function(LegendGroup) updateLegendGroup;
  final void Function(MapLayer?) setSelectedLayer;
  final void Function(List<MapLayer>?) setSelectedLayerGroup;
  final void Function(bool) setIsSidebarCollapsed;
  final void Function(bool) setIsZIndexInspectorOpen;
  final void Function(bool) setIsLegendGroupManagementDrawerOpen;
  final void Function(bool) setIsLayerLegendBindingDrawerOpen;
  final void Function(LegendGroup?) setCurrentLegendGroupForManagement;
  final void Function(MapLayer?) setCurrentLayerForBinding;
  final void Function(List<LegendGroup>?) setAllLegendGroupsForBinding;
  final void Function(String?) setInitialSelectedLegendItemId;

  // 版本管理方法
  final List<dynamic> Function() getAllVersionStates;
  final String? Function() getCurrentVersionId;
  final Future<void> Function(String) switchVersion;
  final Future<void> Function(String) createVersion;

  // 其他方法
  final VoidCallback prioritizeLayerAndGroupDisplay;
  final VoidCallback clearCanvasSelection;
  final List<List<MapLayer>> Function() getLayerGroups;
  final List<LegendGroup> Function() getBoundLegendGroups;
  final void Function(LegendGroup) showLegendGroupManagementDrawer;
  final VoidCallback closeLegendGroupManagementDrawer;
  final Future<void> Function(MapItem) saveWithReactiveVersions;
  final dynamic vfsMapService;
  final String folderPath;

  KeyboardShortcutActions({
    required this.context,
    required this.setState,
    required this.getCurrentMap,
    required this.getSelectedLayer,
    required this.getSelectedLayerGroup,
    required this.getCurrentDrawingTargetLayer,
    required this.getCurrentLegendGroupForManagement,
    required this.getIsLegendGroupManagementDrawerOpen,
    required this.getIsLayerLegendBindingDrawerOpen,
    required this.getIsSidebarCollapsed,
    required this.getIsZIndexInspectorOpen,
    required this.getMapCanvasKey,
    required this.canUndoReactive,
    required this.canRedoReactive,
    required this.undoReactive,
    required this.redoReactive,
    required this.updateLayer,
    required this.updateLegendGroup,
    required this.setSelectedLayer,
    required this.setSelectedLayerGroup,
    required this.setIsSidebarCollapsed,
    required this.setIsZIndexInspectorOpen,
    required this.setIsLegendGroupManagementDrawerOpen,
    required this.setIsLayerLegendBindingDrawerOpen,
    required this.setCurrentLegendGroupForManagement,
    required this.setCurrentLayerForBinding,
    required this.setAllLegendGroupsForBinding,
    required this.setInitialSelectedLegendItemId,
    required this.getAllVersionStates,
    required this.getCurrentVersionId,
    required this.switchVersion,
    required this.createVersion,
    required this.prioritizeLayerAndGroupDisplay,
    required this.clearCanvasSelection,
    required this.getLayerGroups,
    required this.getBoundLegendGroups,
    required this.showLegendGroupManagementDrawer,
    required this.closeLegendGroupManagementDrawer,
    required this.saveWithReactiveVersions,
    required this.vfsMapService,
    required this.folderPath,
  });

  // 撤销/重做相关
  bool canUndo() {
    try {
      return canUndoReactive();
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.checkUndoStatusFailed_4821 +
            ': $e',
      );
      return false;
    }
  }

  bool canRedo() {
    try {
      return canRedoReactive();
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.checkRedoStatusFailed_4821(e),
      );
      return false;
    }
  }

  void undo() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    try {
      if (canUndoReactive()) {
        undoReactive();
        debugPrint(
          LocalizationService.instance.current.useReactiveSystemUndo_7281,
        );
        return;
      }
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.responsiveSystemUndoFailed_7421(e),
      );
    }
  }

  void redo() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    try {
      if (canRedoReactive()) {
        redoReactive();
        debugPrint(
          LocalizationService.instance.current.redoWithReactiveSystem_4821,
        );
        return;
      }
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.responsiveSystemRedoFailed_7421(e),
      );
    }
  }

  Future<void> handleCopySelection() async {
    final mapCanvasKey = getMapCanvasKey();
    final mapCanvas = mapCanvasKey.currentState;
    if (mapCanvas == null) {
      return;
    }

    // 使用反射或动态调用来获取选区
    try {
      final selectionRect = (mapCanvas as dynamic).currentSelectionRect;
      if (selectionRect == null) {
        if (context.mounted) {
          NotificationService.instance.showInfo(
            LocalizationService.instance.current.selectRegionBeforeCopy_7281,
          );
        }
        return;
      }

      final imageData = await (mapCanvas as dynamic)
          .captureCanvasAreaToRgbaUint8List(selectionRect);
      if (imageData == null) {
        throw Exception(
          LocalizationService.instance.current.canvasCaptureError_4821,
        );
      }

      final success = await ClipboardService.copyCanvasSelectionToClipboard(
        rgbaData: imageData,
        width: selectionRect.width.round(),
        height: selectionRect.height.round(),
      );

      if (context.mounted) {
        if (success) {
          NotificationService.instance.showSuccess(
            LocalizationService
                .instance
                .current
                .selectionCopiedToClipboard_4821,
          );
        } else {
          NotificationService.instance.showError(
            LocalizationService.instance.current.copyToClipboardFailed_4821,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService.instance.showError(
          LocalizationService.instance.current.copyToClipboardFailed(e),
        );
      }
    }
  }

  // 图层相关
  void selectPreviousLayer() {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.layers.isEmpty) return;

    final layers = currentMap.layers;
    layers.sort((a, b) => a.order.compareTo(b.order));

    final selectedLayer = getSelectedLayer();
    if (selectedLayer == null) {
      final lastLayer = layers.last;
      setState?.call();
      setSelectedLayer(lastLayer);
      setSelectedLayerGroup(null);
      prioritizeLayerAndGroupDisplay();
    } else {
      final currentIndex = layers.indexWhere(
        (layer) => layer.id == selectedLayer.id,
      );
      if (currentIndex > 0) {
        final previousLayer = layers[currentIndex - 1];
        setState?.call();
        setSelectedLayer(previousLayer);
        setSelectedLayerGroup(null);
        prioritizeLayerAndGroupDisplay();
      }
    }
  }

  void selectNextLayer() {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.layers.isEmpty) return;

    final layers = currentMap.layers;
    layers.sort((a, b) => a.order.compareTo(b.order));

    final selectedLayer = getSelectedLayer();
    if (selectedLayer == null) {
      final firstLayer = layers.first;
      setState?.call();
      setSelectedLayer(firstLayer);
      setSelectedLayerGroup(null);
      prioritizeLayerAndGroupDisplay();
    } else {
      final currentIndex = layers.indexWhere(
        (layer) => layer.id == selectedLayer.id,
      );
      if (currentIndex < layers.length - 1) {
        final nextLayer = layers[currentIndex + 1];
        setState?.call();
        setSelectedLayer(nextLayer);
        setSelectedLayerGroup(null);
        prioritizeLayerAndGroupDisplay();
      }
    }
  }

  void selectPreviousLayerGroup() {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.layers.isEmpty) return;

    final layerGroups = getLayerGroups();
    if (layerGroups.isEmpty) return;

    final selectedLayerGroup = getSelectedLayerGroup();
    if (selectedLayerGroup == null || selectedLayerGroup.isEmpty) {
      final lastGroup = layerGroups.last;
      setState?.call();
      setSelectedLayerGroup(lastGroup);
      setSelectedLayer(null);
      prioritizeLayerAndGroupDisplay();
    } else {
      final currentGroupFirstLayerId = selectedLayerGroup.first.id;
      final currentIndex = layerGroups.indexWhere(
        (group) => group.first.id == currentGroupFirstLayerId,
      );
      if (currentIndex > 0) {
        final previousGroup = layerGroups[currentIndex - 1];
        setState?.call();
        setSelectedLayerGroup(previousGroup);
        setSelectedLayer(null);
        prioritizeLayerAndGroupDisplay();
      }
    }
  }

  void selectNextLayerGroup() {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.layers.isEmpty) return;

    final layerGroups = getLayerGroups();
    if (layerGroups.isEmpty) return;

    final selectedLayerGroup = getSelectedLayerGroup();
    if (selectedLayerGroup == null || selectedLayerGroup.isEmpty) {
      final firstGroup = layerGroups.first;
      setState?.call();
      setSelectedLayerGroup(firstGroup);
      setSelectedLayer(null);
      prioritizeLayerAndGroupDisplay();
    } else {
      final currentGroupFirstLayerId = selectedLayerGroup.first.id;
      final currentIndex = layerGroups.indexWhere(
        (group) => group.first.id == currentGroupFirstLayerId,
      );
      if (currentIndex < layerGroups.length - 1) {
        final nextGroup = layerGroups[currentIndex + 1];
        setState?.call();
        setSelectedLayerGroup(nextGroup);
        setSelectedLayer(null);
        prioritizeLayerAndGroupDisplay();
      }
    }
  }

  void selectLayerGroupByIndex(int index) {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.layers.isEmpty) return;

    final layerGroups = getLayerGroups();
    if (index < 0 || index >= layerGroups.length) return;

    final selectedGroup = layerGroups[index];
    setState?.call();
    setSelectedLayerGroup(selectedGroup);
    setSelectedLayer(null);

    // 检查用户偏好设置，是否自动选择图层组的最后一层
    final userPreferences = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );

    if (userPreferences.mapEditor.autoSelectLastLayerInGroup &&
        selectedGroup.isNotEmpty) {
      MapLayer? lastLayer;
      for (final layer in selectedGroup) {
        if (!layer.isLinkedToNext) {
          lastLayer = layer;
        }
      }
      if (lastLayer != null) {
        setSelectedLayer(lastLayer);
      }
    }

    prioritizeLayerAndGroupDisplay();
    _autoSwitchToFirstBoundLegendGroup();
  }

  void selectLayerByIndex(int index) {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.layers.isEmpty) return;

    final layers = currentMap.layers;
    layers.sort((a, b) => a.order.compareTo(b.order));

    if (index < 0 || index >= layers.length) return;

    final selectedLayer = layers[index];
    setState?.call();
    setSelectedLayer(selectedLayer);
    prioritizeLayerAndGroupDisplay();
  }

  void clearLayerSelection() {
    setState?.call();
    setSelectedLayer(null);
    setSelectedLayerGroup(null);
    prioritizeLayerAndGroupDisplay();
    clearCanvasSelection();
  }

  void hideOtherLayers() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    final selectedLayer = getSelectedLayer();
    if (selectedLayer != null) {
      for (final layer in currentMap.layers) {
        if (layer.id != selectedLayer.id) {
          final updatedLayer = layer.copyWith(
            isVisible: false,
            updatedAt: DateTime.now(),
          );
          updateLayer(updatedLayer);
        }
      }
    } else {
      for (final layer in currentMap.layers) {
        final updatedLayer = layer.copyWith(
          isVisible: false,
          updatedAt: DateTime.now(),
        );
        updateLayer(updatedLayer);
      }
    }
  }

  void hideOtherLayerGroups() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    final selectedLayerGroup = getSelectedLayerGroup();
    if (selectedLayerGroup != null && selectedLayerGroup.isNotEmpty) {
      final selectedGroupIds = selectedLayerGroup
          .map((layer) => layer.id)
          .toSet();
      for (final layer in currentMap.layers) {
        if (!selectedGroupIds.contains(layer.id)) {
          final updatedLayer = layer.copyWith(
            isVisible: false,
            updatedAt: DateTime.now(),
          );
          updateLayer(updatedLayer);
        }
      }
    } else {
      for (final layer in currentMap.layers) {
        final updatedLayer = layer.copyWith(
          isVisible: false,
          updatedAt: DateTime.now(),
        );
        updateLayer(updatedLayer);
      }
    }
  }

  void showCurrentLayer() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    final selectedLayer = getSelectedLayer();
    if (selectedLayer != null) {
      final updatedLayer = selectedLayer.copyWith(
        isVisible: true,
        updatedAt: DateTime.now(),
      );
      updateLayer(updatedLayer);
    } else {
      for (final layer in currentMap.layers) {
        final updatedLayer = layer.copyWith(
          isVisible: true,
          updatedAt: DateTime.now(),
        );
        updateLayer(updatedLayer);
      }
    }
  }

  void showCurrentLayerGroup() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    final selectedLayerGroup = getSelectedLayerGroup();
    if (selectedLayerGroup != null && selectedLayerGroup.isNotEmpty) {
      for (final layer in selectedLayerGroup) {
        final updatedLayer = layer.copyWith(
          isVisible: true,
          updatedAt: DateTime.now(),
        );
        updateLayer(updatedLayer);
      }
    } else {
      for (final layer in currentMap.layers) {
        final updatedLayer = layer.copyWith(
          isVisible: true,
          updatedAt: DateTime.now(),
        );
        updateLayer(updatedLayer);
      }
    }
  }

  // 图例相关
  void openPreviousLegendGroup() {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.legendGroups.isEmpty) return;

    final selectedLayer = getSelectedLayer();
    final selectedLayerGroup = getSelectedLayerGroup();
    final legendGroups =
        (selectedLayer != null ||
            (selectedLayerGroup != null && selectedLayerGroup.isNotEmpty))
        ? getBoundLegendGroups()
        : currentMap.legendGroups;

    if (legendGroups.isEmpty) {
      if (context.mounted) {
        NotificationService.instance.showInfo(
          LocalizationService.instance.current.noLegendGroupsAvailable_4821,
        );
      }
      return;
    }

    final currentLegendGroup = getCurrentLegendGroupForManagement();
    if (currentLegendGroup == null) {
      final lastGroup = legendGroups.last;
      showLegendGroupManagementDrawer(lastGroup);
    } else {
      final currentIndex = legendGroups.indexWhere(
        (group) => group.id == currentLegendGroup.id,
      );
      if (currentIndex > 0) {
        final previousGroup = legendGroups[currentIndex - 1];
        showLegendGroupManagementDrawer(previousGroup);
      } else if (currentIndex == 0 && legendGroups.length > 1) {
        final lastGroup = legendGroups.last;
        showLegendGroupManagementDrawer(lastGroup);
      }
    }
  }

  void openNextLegendGroup() {
    final currentMap = getCurrentMap();
    if (currentMap == null || currentMap.legendGroups.isEmpty) return;

    final selectedLayer = getSelectedLayer();
    final selectedLayerGroup = getSelectedLayerGroup();
    final legendGroups =
        (selectedLayer != null ||
            (selectedLayerGroup != null && selectedLayerGroup.isNotEmpty))
        ? getBoundLegendGroups()
        : currentMap.legendGroups;

    if (legendGroups.isEmpty) {
      if (context.mounted) {
        NotificationService.instance.showInfo(
          LocalizationService.instance.current.noLegendGroupsAvailable_4821,
        );
      }
      return;
    }

    final currentLegendGroup = getCurrentLegendGroupForManagement();
    if (currentLegendGroup == null) {
      final firstGroup = legendGroups.first;
      showLegendGroupManagementDrawer(firstGroup);
    } else {
      final currentIndex = legendGroups.indexWhere(
        (group) => group.id == currentLegendGroup.id,
      );
      if (currentIndex < legendGroups.length - 1) {
        final nextGroup = legendGroups[currentIndex + 1];
        showLegendGroupManagementDrawer(nextGroup);
      } else if (currentIndex == legendGroups.length - 1 &&
          legendGroups.length > 1) {
        final firstGroup = legendGroups.first;
        showLegendGroupManagementDrawer(firstGroup);
      }
    }
  }

  void toggleLegendGroupManagementDrawer() {
    final isOpen = getIsLegendGroupManagementDrawerOpen();
    if (isOpen) {
      closeLegendGroupManagementDrawer();
    } else {
      final currentMap = getCurrentMap();
      final selectedLayer = getSelectedLayer();
      final selectedLayerGroup = getSelectedLayerGroup();

      // 优先级1：当前选中图层绑定的图例组
      if (selectedLayer != null) {
        if (selectedLayer.legendGroupIds.isNotEmpty) {
          final boundLegendGroupId = selectedLayer.legendGroupIds.first;
          final boundLegendGroup = currentMap?.legendGroups
              .where((group) => group.id == boundLegendGroupId)
              .firstOrNull;
          if (boundLegendGroup != null) {
            showLegendGroupManagementDrawer(boundLegendGroup);
            return;
          }
        } else {
          if (context.mounted) {
            NotificationService.instance.showInfo(
              LocalizationService.instance.current.noLegendGroupBound_7281,
            );
          }
          return;
        }
      }

      // 优先级2：当前选中图层组包含的图层绑定的图例组
      if (selectedLayerGroup != null && selectedLayerGroup.isNotEmpty) {
        final allBoundGroupIds = <String>{};
        for (final layer in selectedLayerGroup) {
          allBoundGroupIds.addAll(layer.legendGroupIds);
        }
        if (allBoundGroupIds.isNotEmpty) {
          final firstBoundGroupId = allBoundGroupIds.first;
          final boundLegendGroup = currentMap?.legendGroups
              .where((group) => group.id == firstBoundGroupId)
              .firstOrNull;
          if (boundLegendGroup != null) {
            showLegendGroupManagementDrawer(boundLegendGroup);
            return;
          }
        } else {
          if (context.mounted) {
            NotificationService.instance.showInfo(
              LocalizationService
                  .instance
                  .current
                  .noLegendGroupBoundToLayerGroup_4821,
            );
          }
          return;
        }
      }

      // 优先级3：没有选择时，默认到最后一个图层或图层组的第一个图例组
      if (currentMap != null && currentMap.legendGroups.isNotEmpty) {
        // 获取所有图层组
        final layerGroups = getLayerGroups();

        if (layerGroups.isNotEmpty) {
          // 获取最后一个图层组
          final lastLayerGroup = layerGroups.last;

          // 收集最后一个图层组中所有图层绑定的图例组ID
          final allBoundGroupIds = <String>{};
          for (final layer in lastLayerGroup) {
            allBoundGroupIds.addAll(layer.legendGroupIds);
          }

          if (allBoundGroupIds.isNotEmpty) {
            // 找到第一个绑定的图例组
            final firstBoundGroupId = allBoundGroupIds.first;
            final boundLegendGroup = currentMap.legendGroups
                .where((group) => group.id == firstBoundGroupId)
                .firstOrNull;
            if (boundLegendGroup != null) {
              showLegendGroupManagementDrawer(boundLegendGroup);
              return;
            }
          }
        }

        // 如果最后一个图层组没有绑定图例组，则使用第一个可用的图例组
        final firstGroup = currentMap.legendGroups.first;
        showLegendGroupManagementDrawer(firstGroup);
      } else {
        if (context.mounted) {
          NotificationService.instance.showInfo(
            LocalizationService.instance.current.noLegendGroupInCurrentMap_4821,
          );
        }
      }
    }
  }

  void toggleLegendGroupBindingDrawer() {
    final isOpen = getIsLayerLegendBindingDrawerOpen();
    setState?.call();
    if (isOpen) {
      setIsLayerLegendBindingDrawerOpen(false);
      setCurrentLayerForBinding(null);
      setAllLegendGroupsForBinding(null);
    } else {
      final selectedLayer = getSelectedLayer();
      if (selectedLayer == null) {
        if (context.mounted) {
          NotificationService.instance.showInfo(
            LocalizationService.instance.current.selectLayerFirst_4281,
          );
        }
        return;
      }

      // 关闭其他抽屉
      setIsLegendGroupManagementDrawerOpen(false);
      setIsZIndexInspectorOpen(false);
      setCurrentLegendGroupForManagement(null);
      setInitialSelectedLegendItemId(null);

      // 打开抽屉并绑定当前图层
      setIsLayerLegendBindingDrawerOpen(true);
      setCurrentLayerForBinding(selectedLayer);
      // 这里需要从外部获取legendGroups，暂时设为空列表
      setAllLegendGroupsForBinding([]);
    }
  }

  void hideOtherLegendGroups() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    final selectedLayer = getSelectedLayer();
    final selectedLayerGroup = getSelectedLayerGroup();
    Set<String> boundLegendGroupIds = {};

    if (selectedLayer != null) {
      for (final groupId in selectedLayer.legendGroupIds) {
        boundLegendGroupIds.add(groupId);
      }
    } else if (selectedLayerGroup != null && selectedLayerGroup.isNotEmpty) {
      for (final layer in selectedLayerGroup) {
        for (final groupId in layer.legendGroupIds) {
          boundLegendGroupIds.add(groupId);
        }
      }
    }

    if (boundLegendGroupIds.isNotEmpty) {
      for (final legendGroup in currentMap.legendGroups) {
        if (!boundLegendGroupIds.contains(legendGroup.id)) {
          final updatedGroup = legendGroup.copyWith(
            isVisible: false,
            updatedAt: DateTime.now(),
          );
          updateLegendGroup(updatedGroup);
        }
      }
    } else {
      for (final legendGroup in currentMap.legendGroups) {
        final updatedGroup = legendGroup.copyWith(
          isVisible: false,
          updatedAt: DateTime.now(),
        );
        updateLegendGroup(updatedGroup);
      }
    }
  }

  void showCurrentLegendGroup() {
    final currentMap = getCurrentMap();
    if (currentMap == null) return;

    final selectedLayer = getSelectedLayer();
    final selectedLayerGroup = getSelectedLayerGroup();
    Set<String> boundLegendGroupIds = {};

    if (selectedLayer != null) {
      for (final groupId in selectedLayer.legendGroupIds) {
        boundLegendGroupIds.add(groupId);
      }
    } else if (selectedLayerGroup != null && selectedLayerGroup.isNotEmpty) {
      for (final layer in selectedLayerGroup) {
        for (final groupId in layer.legendGroupIds) {
          boundLegendGroupIds.add(groupId);
        }
      }
    }

    if (boundLegendGroupIds.isNotEmpty) {
      for (final legendGroup in currentMap.legendGroups) {
        if (boundLegendGroupIds.contains(legendGroup.id)) {
          final updatedGroup = legendGroup.copyWith(
            isVisible: true,
            updatedAt: DateTime.now(),
          );
          updateLegendGroup(updatedGroup);
        }
      }
    } else {
      for (final legendGroup in currentMap.legendGroups) {
        final updatedGroup = legendGroup.copyWith(
          isVisible: true,
          updatedAt: DateTime.now(),
        );
        updateLegendGroup(updatedGroup);
      }
    }
  }

  // UI相关
  void toggleSidebar() {
    setState?.call();
    setIsSidebarCollapsed(!getIsSidebarCollapsed());
  }

  void openZInspector() {
    final isOpen = getIsZIndexInspectorOpen();

    if (isOpen) {
      setState?.call();
      setIsZIndexInspectorOpen(false);
    } else {
      // 优先使用选中的图层，如果没有则尝试获取默认绘制目标图层
      MapLayer? targetLayer = getSelectedLayer();
      if (targetLayer == null) {
        targetLayer = getCurrentDrawingTargetLayer();
        if (targetLayer == null) {
          if (context.mounted) {
            NotificationService.instance.showInfo(
              LocalizationService.instance.current.noAvailableLayers_4821,
            );
          }
          return;
        }

        // 自动选择默认图层
        setSelectedLayer(targetLayer);
      }

      setState?.call();
      setIsZIndexInspectorOpen(true);
    }
  }

  // 地图相关
  Future<void> saveMapAction() async {
    final currentMap = getCurrentMap();
    if (currentMap == null) {
      if (context.mounted) {
        NotificationService.instance.showError(
          LocalizationService.instance.current.noMapDataToSave_4821,
        );
      }
      return;
    }

    try {
      if (context.mounted) {
        NotificationService.instance.showInfo(
          LocalizationService.instance.current.savingMap_7281,
        );
      }

      // 直接调用响应式版本保存逻辑，避免循环调用
      await saveWithReactiveVersions(currentMap);

      if (context.mounted) {
        NotificationService.instance.showSuccess(
          LocalizationService.instance.current.mapSavedSuccessfully_7281,
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService.instance.showError(
          LocalizationService.instance.current.mapSaveFailed_7285(e),
        );
      }
    }
  }

  // 版本相关
  void switchToPreviousVersion() {
    final versions = getAllVersionStates();
    if (versions.isEmpty) return;

    final currentId = getCurrentVersionId();
    if (currentId == null) return;

    // 按创建时间排序版本
    versions.sort(
      (a, b) => (a as dynamic).createdAt.compareTo((b as dynamic).createdAt),
    );

    final currentIndex = versions.indexWhere(
      (v) => (v as dynamic).versionId == currentId,
    );
    if (currentIndex > 0) {
      final previousVersion = versions[currentIndex - 1];
      switchVersion((previousVersion as dynamic).versionId).catchError((error) {
        if (context.mounted) {
          NotificationService.instance.showError(
            LocalizationService.instance.current.versionSwitchFailed(error),
          );
        }
      });
    }
  }

  void switchToNextVersion() {
    final versions = getAllVersionStates();
    if (versions.isEmpty) return;

    final currentId = getCurrentVersionId();
    if (currentId == null) return;

    // 按创建时间排序版本
    versions.sort(
      (a, b) => (a as dynamic).createdAt.compareTo((b as dynamic).createdAt),
    );

    final currentIndex = versions.indexWhere(
      (v) => (v as dynamic).versionId == currentId,
    );
    if (currentIndex >= 0 && currentIndex < versions.length - 1) {
      final nextVersion = versions[currentIndex + 1];
      switchVersion((nextVersion as dynamic).versionId).catchError((error) {
        if (context.mounted) {
          NotificationService.instance.showError(
            LocalizationService.instance.current.versionSwitchFailed(error),
          );
        }
      });
    }
  }

  void createNewVersionWithShortcut() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final versionName =
        '${LocalizationService.instance.current.shortcutVersion_4821}_$timestamp';

    createVersion(versionName).catchError((error) {
      if (context.mounted) {
        NotificationService.instance.showError(
          LocalizationService.instance.current.versionCreationFailed(error),
        );
      }
    });
  }

  // 私有辅助方法
  void _autoSwitchToFirstBoundLegendGroup() {
    if (!getIsLegendGroupManagementDrawerOpen()) return;

    final boundLegendGroups = getBoundLegendGroups();
    if (boundLegendGroups.isNotEmpty) {
      final firstBoundGroup = boundLegendGroups.first;
      debugPrint(
        LocalizationService.instance.current.autoSwitchLegendGroupDrawer(
          firstBoundGroup.name,
        ),
      );
      showLegendGroupManagementDrawer(firstBoundGroup);
    } else {
      debugPrint(
        LocalizationService.instance.current.noLegendGroupSelected_4821,
      );
    }
  }
}
