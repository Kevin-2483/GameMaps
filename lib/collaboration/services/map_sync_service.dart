// This file has been processed by AI for internationalization
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../blocs/presence/presence_bloc.dart';
import '../blocs/presence/presence_event.dart';
import '../utils/image_compression_utils.dart';
import '../../models/map_item.dart';
import '../../models/map_item_summary.dart';

import '../../services/localization_service.dart';

/// 地图信息同步服务
/// 负责处理地图封面压缩和在线状态同步
class MapSyncService {
  final PresenceBloc _presenceBloc;

  MapSyncService(this._presenceBloc);

  /// 同步当前编辑的地图信息到在线状态
  ///
  /// [mapId] 地图ID
  /// [mapTitle] 地图标题
  /// [mapCover] 地图封面图片数据（可选）
  /// [coverQuality] 封面压缩质量（可选，默认70）
  Future<bool> syncCurrentMapInfo({
    required String mapId,
    required String mapTitle,
    Uint8List? mapCover,
    int coverQuality = 70,
  }) async {
    try {
      String? compressedCoverBase64;

      // 如果提供了封面图片，进行压缩
      if (mapCover != null && mapCover.isNotEmpty) {
        compressedCoverBase64 = await ImageCompressionUtils.adaptiveCompress(
          mapCover,
          maxSizeKB: 50, // 限制为50KB以确保网络传输效率
          initialQuality: coverQuality,
          maxWidth: 200, // 在线状态显示的封面不需要太大
          maxHeight: 200,
        );

        if (compressedCoverBase64 == null) {
          debugPrint(
            LocalizationService.instance.current.mapCoverCompressionFailed_4821,
          );
        }
      }

      // 发送更新事件到PresenceBloc
      debugPrint(
        '[MapSyncService] ${LocalizationService.instance.current.syncMapInfoToPresenceBloc_7421}:',
      );
      debugPrint('[MapSyncService]   - mapId: $mapId');
      debugPrint('[MapSyncService]   - mapTitle: $mapTitle');
      debugPrint(
        '[MapSyncService]   - ' +
            LocalizationService.instance.current.coverSizeInfo_4821(
              compressedCoverBase64 != null
                  ? '${(compressedCoverBase64.length * 0.75 / 1024).toStringAsFixed(1)}KB'
                  : LocalizationService.instance.current.none_5729,
            ),
      );

      _presenceBloc.add(
        UpdateCurrentMapInfo(
          mapId: mapId,
          mapTitle: mapTitle,
          mapCoverBase64: compressedCoverBase64,
          coverQuality: coverQuality,
        ),
      );

      return true;
    } catch (e) {
      debugPrint(LocalizationService.instance.current.mapSyncFailed_7285(e));
      return false;
    }
  }

  /// 从MapItem同步地图信息
  Future<bool> syncFromMapItem(MapItem mapItem) async {
    return await syncCurrentMapInfo(
      mapId: mapItem.id?.toString() ?? 'unknown',
      mapTitle: mapItem.title,
      mapCover: mapItem.imageData,
    );
  }

  /// 从MapItemSummary同步地图信息
  Future<bool> syncFromMapItemSummary(MapItemSummary mapSummary) async {
    return await syncCurrentMapInfo(
      mapId: mapSummary.id.toString(),
      mapTitle: mapSummary.title,
      mapCover: mapSummary.imageData,
    );
  }

  /// 清除当前地图信息（当用户停止编辑地图时调用）
  Future<void> clearCurrentMapInfo() async {
    _presenceBloc.add(
      const UpdateCurrentMapInfo(
        mapId: null,
        mapTitle: null,
        mapCoverBase64: null,
      ),
    );
  }

  /// 仅更新地图标题（当用户重命名地图时）
  Future<bool> updateMapTitle(String mapId, String newTitle) async {
    try {
      _presenceBloc.add(UpdateCurrentMapInfo(mapId: mapId, mapTitle: newTitle));
      return true;
    } catch (e) {
      debugPrint(LocalizationService.instance.current.updateMapTitleFailed(e));
      return false;
    }
  }

  /// 仅更新地图封面（当用户更改地图封面时）
  Future<bool> updateMapCover(
    String mapId,
    Uint8List newCover, {
    int coverQuality = 70,
  }) async {
    try {
      final compressedCoverBase64 =
          await ImageCompressionUtils.adaptiveCompress(
            newCover,
            maxSizeKB: 50,
            initialQuality: coverQuality,
            maxWidth: 200,
            maxHeight: 200,
          );

      if (compressedCoverBase64 == null) {
        debugPrint(
          LocalizationService.instance.current.mapCoverCompressionFailed_7281,
        );
        return false;
      }

      _presenceBloc.add(
        UpdateCurrentMapInfo(
          mapId: mapId,
          mapCoverBase64: compressedCoverBase64,
          coverQuality: coverQuality,
        ),
      );

      return true;
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.mapCoverUpdateFailed(
          'MapSyncService',
          e,
        ),
      );
      return false;
    }
  }
}
