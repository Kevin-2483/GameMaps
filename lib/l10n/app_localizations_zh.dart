// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get home => '首页';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '浅色模式';

  @override
  String get systemMode => '跟随系统';

  @override
  String get about => '关于';

  @override
  String get error => '错误';

  @override
  String pageNotFound(Object uri) {
    return '页面未找到：$uri';
  }

  @override
  String get goHome => '回到首页';

  @override
  String get features => '功能特性';

  @override
  String get windowsPlatform => 'Windows 平台';

  @override
  String get windowsFeatures => 'Windows 功能：';

  @override
  String get windowsSpecificFeatures => '可以在此处实现 Windows 特定功能。';

  @override
  String get nativeWindowsUI => '原生 Windows UI';

  @override
  String get fileSystemAccess => '文件系统访问';

  @override
  String get systemTrayIntegration => '系统托盘集成';

  @override
  String get windowsNotifications => 'Windows 通知';

  @override
  String get macOSPlatform => 'macOS 平台';

  @override
  String get macOSFeatures => 'macOS 功能：';

  @override
  String get macOSSpecificFeatures => '可以在此处实现 macOS 特定功能。';

  @override
  String get nativeMacOSUI => '原生 macOS UI';

  @override
  String get menuBarIntegration => '菜单栏集成';

  @override
  String get touchBarSupport => 'Touch Bar 支持';

  @override
  String get macOSNotifications => 'macOS 通知';

  @override
  String get androidPlatform => 'Android 平台';

  @override
  String get androidFeatures => 'Android 功能：';

  @override
  String get androidSpecificFeatures => '可以在此处实现 Android 特定功能。';

  @override
  String get materialDesign => 'Material Design';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get appShortcuts => '应用快捷方式';

  @override
  String get backgroundServices => '后台服务';

  @override
  String get iOSPlatform => 'iOS 平台';

  @override
  String get iOSFeatures => 'iOS 功能：';

  @override
  String get iOSSpecificFeatures => '可以在此处实现 iOS 特定功能。';

  @override
  String get cupertinoDesign => 'Cupertino 设计';

  @override
  String get appClips => 'App Clips';

  @override
  String get siriShortcuts => 'Siri 快捷指令';

  @override
  String get linuxPlatform => 'Linux 平台';

  @override
  String get linuxFeatures => 'Linux 功能：';

  @override
  String get linuxSpecificFeatures => 'Linux 特定功能可以在这里实现。';

  @override
  String get nativeGtkIntegration => '原生 GTK 集成';

  @override
  String get systemTraySupport => '系统托盘支持';

  @override
  String get desktopFiles => '桌面文件';

  @override
  String get packageManagement => '包管理';

  @override
  String get webPlatform => 'Web 平台';

  @override
  String get webFeatures => 'Web 功能：';

  @override
  String get webSpecificFeatures => 'Web 特定功能可以在这里实现。';

  @override
  String get progressiveWebApp => '渐进式Web应用';

  @override
  String get browserStorage => '浏览器存储';

  @override
  String get urlRouting => 'URL路由';

  @override
  String get webApis => 'Web API';

  @override
  String get configEditor => '配置编辑器';

  @override
  String get configUpdated => '配置已更新';

  @override
  String currentPlatform(Object platform) {
    return '当前平台：$platform';
  }

  @override
  String availablePages(Object pages) {
    return '可用页面：$pages';
  }

  @override
  String availableFeatures(Object features) {
    return '可用功能：$features';
  }

  @override
  String get pageConfiguration => '页面配置';

  @override
  String get featureConfiguration => '功能配置';

  @override
  String get debugInfo => '调试信息';

  @override
  String get printConfigInfo => '打印配置信息';

  @override
  String get saveConfig => '保存配置';

  @override
  String get mapAtlas => '地图册';

  @override
  String get mapAtlasEmpty => '暂无地图';

  @override
  String get addMap => '添加地图';

  @override
  String get mapTitle => '地图标题';

  @override
  String get enterMapTitle => '请输入地图标题';

  @override
  String get deleteMap => '删除地图';

  @override
  String confirmDeleteMap(Object title) {
    return '确认删除地图 \"$title\"？';
  }

  @override
  String get exportDatabase => '导出数据库';

  @override
  String get importDatabase => '导入数据库';

  @override
  String get resourceManagement => '资源管理';

  @override
  String importFailed(Object error) {
    return '导入失败：$error';
  }

  @override
  String get mapAddedSuccessfully => '地图添加成功';

  @override
  String get mapDeletedSuccessfully => '地图删除成功';

  @override
  String addMapFailed(Object error) {
    return '添加地图失败：$error';
  }

  @override
  String deleteMapFailed(Object error) {
    return '删除地图失败：$error';
  }

  @override
  String loadMapsFailed(Object error) {
    return '加载地图失败：$error';
  }

  @override
  String get legendManager => '图例管理';

  @override
  String get legendManagerEmpty => '暂无图例';

  @override
  String get addLegend => '添加图例';

  @override
  String legendTitle(Object count) {
    return '图例: $count';
  }

  @override
  String get enterLegendTitle => '请输入图例标题';

  @override
  String get legendVersion => '图例版本';

  @override
  String get selectCenterPoint => '选择中心点:';

  @override
  String get deleteLegend => '删除图例';

  @override
  String confirmDeleteLegend(Object title) {
    return '确认删除图例 \"$title\" 吗？';
  }

  @override
  String get legendDeletedSuccessfully => '图例删除成功';

  @override
  String deleteLegendFailed(Object e, Object title) {
    return '删除图例失败: $title, 错误: $e';
  }

  @override
  String get uploadLocalizationFile => '上传本地化文件';

  @override
  String get mapEditor => '地图编辑器';

  @override
  String get mapPreview => '地图预览';

  @override
  String get close => '关闭';

  @override
  String get layers => '图层';

  @override
  String get legend => '图例';

  @override
  String get addLayer => '添加图层';

  @override
  String get deleteLayer => '删除图层';

  @override
  String get opacity => '不透明度';

  @override
  String get elements => '个元素';

  @override
  String get drawingTools => '绘制工具';

  @override
  String get line => '直线';

  @override
  String get dashedLine => '虚线';

  @override
  String get arrow => '箭头';

  @override
  String get rectangle => '矩形';

  @override
  String get hollowRectangle => '空心矩形';

  @override
  String get diagonalLines => '对角线';

  @override
  String get crossLines => '十字线';

  @override
  String get dotGrid => '点网格';

  @override
  String get strokeWidth => '笔触宽度';

  @override
  String get color => '颜色';

  @override
  String get addLegendGroup => '添加图例组';

  @override
  String get deleteLegendGroup => '删除图例组';

  @override
  String get saveMap => '保存地图';

  @override
  String get mode => '模式';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get userPreferences => '用户偏好设置';

  @override
  String get layerSelectionSettings => '图层选择设置';

  @override
  String get autoSelectLastLayerInGroup => '自动选择图层组的最后一层';

  @override
  String get autoSelectLastLayerInGroupDescription => '选择图层组时自动选择该组的最后一层';

  @override
  String get primaryColor => '主色调';

  @override
  String get accentColor => '强调色';

  @override
  String get autoSave => '自动保存';

  @override
  String get gridSize => '网格大小';

  @override
  String get compactMode => '紧凑模式';

  @override
  String get showTooltips => '显示工具提示';

  @override
  String get enableAnimations => '启用动画';

  @override
  String get animationDuration => '动画持续时间（毫秒）';

  @override
  String get recentColors => '最近使用的颜色';

  @override
  String get favoriteStrokeWidths => '常用线条宽度';

  @override
  String get showAdvancedTools => '显示高级工具';

  @override
  String get currentUser => '当前用户';

  @override
  String get userProfiles => '用户配置文件';

  @override
  String get exportSettings => '导出设置';

  @override
  String get importSettings => '导入设置';

  @override
  String get resetSettings => '重置为默认值';

  @override
  String get confirmResetSettings => '确定要将所有设置重置为默认值吗？此操作不可撤销。';

  @override
  String get settingsExported => '设置导出成功';

  @override
  String get settingsImported => '设置导入成功';

  @override
  String get settingsReset => '设置已重置为默认值';

  @override
  String get collaborationStateInitialized_7281 => '协作状态初始化完成';

  @override
  String collaborationInitFailed_7281(Object error) {
    return '初始化协作状态失败: $error';
  }

  @override
  String get elementLockFailed_7281 => '元素锁定失败';

  @override
  String get websocketNotConnectedSkipBroadcast_7281 =>
      'WebSocket未连接，跳过广播用户状态更新（离线模式）';

  @override
  String get userStateInitFailed_4821 => '初始化用户状态失败';

  @override
  String userStatusChangeBroadcast(Object currentStatus, Object newStatus) {
    return '用户状态发生变化，准备广播: $currentStatus -> $newStatus';
  }

  @override
  String get userStatusUnchangedSkipBroadcast_4821 => '用户状态无变化，跳过广播';

  @override
  String mapInfoChangedBroadcast(Object mapId, Object mapTitle) {
    return '地图信息发生变化，准备广播: mapId=$mapId, mapTitle=$mapTitle';
  }

  @override
  String get mapInfoUnchangedSkipBroadcast_4821 => '地图信息无变化，跳过广播';

  @override
  String websocketError_4829(Object error) {
    return '处理WebSocket消息时出错: $error';
  }

  @override
  String userStatusBroadcastError_4821(Object error) {
    return '处理用户状态广播时出错: $error';
  }

  @override
  String handleOnlineStatusError_4821(Object error) {
    return '处理在线状态列表响应时出错: $error';
  }

  @override
  String onlineStatusProcessed(Object count) {
    return '成功处理在线状态列表，共 $count 个用户';
  }

  @override
  String fetchOnlineStatusFailed(Object error) {
    return '获取在线状态列表失败: $error';
  }

  @override
  String get unknownError => '未知错误';

  @override
  String get mapCoverCompressionFailed_7281 => '地图封面压缩失败';

  @override
  String mapCoverRecompressed(Object newSize, Object oldSize) {
    return '地图封面已重新压缩: ${oldSize}KB -> ${newSize}KB';
  }

  @override
  String broadcastStatusUpdateFailed(Object error) {
    return '广播用户状态更新失败: $error';
  }

  @override
  String mapCoverCompressionFailed_7421(Object compressionError) {
    return '地图封面压缩失败: $compressionError，跳过发送';
  }

  @override
  String requestOnlineStatusFailed(Object error) {
    return '请求在线状态列表失败: $error';
  }

  @override
  String fetchUserPreferencesFailed_4821(Object e) {
    return '获取用户偏好设置失败: $e';
  }

  @override
  String userStatusWithName(Object statusText) {
    return '我: $statusText';
  }

  @override
  String get mapContentArea_7281 => '地图内容区域';

  @override
  String usersEditingCount(Object count) {
    return '$count 人正在编辑';
  }

  @override
  String get editingStatus_4821 => '编辑中';

  @override
  String get viewingStatus_7532 => '查看中';

  @override
  String get idleStatus_6194 => '在线';

  @override
  String get offlineStatus_3087 => '离线';

  @override
  String get mapSyncDemoTitle_7281 => '地图信息同步演示:';

  @override
  String get syncMap1_1234 => '同步地图1';

  @override
  String get updateTitle_4271 => '更新标题';

  @override
  String get clearMapInfo_4821 => '清除地图信息';

  @override
  String get syncMap2_7421 => '同步地图2';

  @override
  String get demoMapSynced_7281 => '已同步演示地图1信息';

  @override
  String get demoMapBlueTheme_4821 => '演示地图 - 蓝色主题';

  @override
  String get demoMapGreenTheme_7281 => '演示地图 - 绿色主题';

  @override
  String get mapTitleUpdated_7281 => '已更新地图标题';

  @override
  String get demoMapSynced_7421 => '已同步演示地图2信息';

  @override
  String renamedDemoMap(Object timestamp) {
    return '演示地图 - 已重命名 $timestamp';
  }

  @override
  String get onlineUsers_4821 => '在线用户';

  @override
  String get mapClearedMessage_4827 => '已清除地图信息';

  @override
  String get editingLabel_7421 => '正在编辑:';

  @override
  String get currentUserSuffix_7281 => '(我)';

  @override
  String get unknownMap_4821 => '未知地图';

  @override
  String get collaborativeMap_4271 => '协作地图';

  @override
  String get userName_7284 => '用户名';

  @override
  String get viewingStatus_5723 => '正在查看';

  @override
  String get idleStatus_6934 => '在线';

  @override
  String get offlineStatus_7845 => '离线';

  @override
  String get collaborationFeatureExample_4821 => '协作功能集成示例';

  @override
  String get controlPanel_4821 => '操作面板';

  @override
  String get clearSelection_4821 => '清除选择';

  @override
  String get unlockElement_4271 => '解锁元素';

  @override
  String get hidePointer_4271 => '隐藏指针';

  @override
  String get collaborationConflict_7281 => '协作冲突';

  @override
  String get closeButton_7281 => '关闭';

  @override
  String get demoUser_4721 => '演示用户';

  @override
  String get sendDataToRemote_7428 => '发送数据到远程';

  @override
  String userJoined_7425(Object displayName, Object userId) {
    return '用户$displayName ($userId)';
  }

  @override
  String userLeft_7421(Object userId) {
    return '用户$userId离开';
  }

  @override
  String get remoteUser_4521 => '远程用户';

  @override
  String get globalCollaborationServiceInitialized_4821 =>
      'GlobalCollaborationService 初始化完成';

  @override
  String globalCollaborationServiceInitFailed(Object e) {
    return '全局协作服务初始化失败: $e';
  }

  @override
  String get globalCollaborationNotInitialized_4821 =>
      'GlobalCollaborationService 未初始化';

  @override
  String get webSocketConnectionStart_7281 =>
      'GlobalCollaborationService 开始连接WebSocket';

  @override
  String get noActiveWebSocketConfigFound_7281 => '没有找到活跃的WebSocket配置，创建默认配置';

  @override
  String get websocketConnectedSuccess_4821 => 'WebSocket连接成功，请求在线状态列表';

  @override
  String get atlasClient_7421 => '地图集客户端';

  @override
  String get websocketConnectionFailed_4821 =>
      'GlobalCollaborationService WebSocket连接失败';

  @override
  String globalCollaborationServiceConnectionFailed(Object e) {
    return 'GlobalCollaborationService 连接失败: $e';
  }

  @override
  String get disconnectWebSocket_4821 =>
      'GlobalCollaborationService 断开WebSocket连接';

  @override
  String connectionFailed_7285(Object e) {
    return 'GlobalCollaborationService 断开连接失败: $e';
  }

  @override
  String get websocketDisconnected_7281 =>
      'GlobalCollaborationService WebSocket连接已断开';

  @override
  String get globalCollaborationNotInitialized_7281 =>
      'GlobalCollaborationService 未初始化';

  @override
  String get globalCollaborationServiceReleaseResources_7421 =>
      'GlobalCollaborationService 开始释放资源';

  @override
  String get resourceReleaseComplete_4821 =>
      'GlobalCollaborationService 资源释放完成';

  @override
  String resourceReleaseFailed_4821(Object e) {
    return 'GlobalCollaborationService 释放资源失败: $e';
  }

  @override
  String get serviceNotInitializedError_4821 =>
      'GlobalCollaborationService 未初始化，请先调用 initialize()';

  @override
  String get serviceNotInitializedError_7281 =>
      'GlobalCollaborationService 未初始化，请先调用 initialize()';

  @override
  String get userInfoSetSkipped_7281 => '用户信息已设置，跳过重复设置';

  @override
  String globalCollaborationUserInfoSet(Object displayName, Object userId) {
    return 'GlobalCollaborationService 用户信息已设置: userId=$userId, displayName=$displayName';
  }

  @override
  String get globalCollaborationServiceInitialized_7281 => '全局协作服务初始化成功';

  @override
  String get initializingGlobalCollaborationService_7281 =>
      '开始初始化 GlobalCollaborationService';

  @override
  String collaborationServiceInitFailed_4821(Object e) {
    return '协作服务初始化失败: $e';
  }

  @override
  String get collaborationServiceCleaned_7281 => '协作服务已清理';

  @override
  String collaborationServiceCleanupFailed_7421(Object e) {
    return '协作服务清理失败: $e';
  }

  @override
  String get collabServiceNotInitialized_4821 => '协作服务未初始化，跳过enterMapEditor';

  @override
  String get mapEditorCallComplete_7421 => '调用完成';

  @override
  String get autoPresenceEnterMapEditor_7421 =>
      '调用AutoPresenceManager.enterMapEditor';

  @override
  String get collaborationServiceNotInitialized_4821 => '协作服务未初始化';

  @override
  String get onlineUsers_4271 => '在线用户';

  @override
  String get loadingText_4821 => '加载中...';

  @override
  String get noOnlineUsers_4271 => '暂无在线用户';

  @override
  String editingMapTitle(Object currentMapTitle) {
    return '正在编辑: $currentMapTitle';
  }

  @override
  String collabServiceInitStatus(Object connectionState) {
    return '协作服务初始化完成，WebSocket连接状态: $connectionState';
  }

  @override
  String collabServiceStatus(Object status) {
    return '协作服务已初始化，WebSocket连接状态: $status';
  }

  @override
  String get connected_3632 => '已连接';

  @override
  String get disconnectedOffline_3632 => '未连接（离线模式）';

  @override
  String get onlineStatus_4821 => '在线';

  @override
  String get offlineStatus_5732 => '离线';

  @override
  String get viewingStatus_6943 => '查看中';

  @override
  String get editingStatus_7154 => '编辑中';

  @override
  String get websocketConnectedStatusRequest_4821 => 'WebSocket已连接，请求在线状态列表';

  @override
  String get hasAvatar_4821 => '[有头像]';

  @override
  String get noAvatar_4821 => '[无头像]';

  @override
  String get mapInfoSyncComplete_7281 => '地图信息同步完成';

  @override
  String get skipUpdateMapTitle_7421 => '跳过更新地图标题：不在编辑器中或mapId为空';

  @override
  String coverSizeLabel_7421(Object size) {
    return '封面大小: ${size}KB';
  }

  @override
  String get skipMapCoverUpdate_7421 => '跳过更新地图封面：不在编辑器中或mapId为空';

  @override
  String get saveCurrentMapId_7425 => '保存当前地图ID';

  @override
  String lockConflictDescription(Object userName) {
    return '用户 $userName 尝试锁定已被锁定的元素';
  }

  @override
  String get elementLockReleased_7425 => '元素锁定已释放';

  @override
  String elementLockedSuccessfully_7281(
    Object currentUserId,
    Object elementId,
  ) {
    return '[CollaborationStateManager] 元素锁定成功: $elementId by $currentUserId';
  }

  @override
  String selectedElementsUpdated(Object count) {
    return '[CollaborationStateManager] 用户选择已更新: $count 个元素';
  }

  @override
  String get conflictResolved_7421 => '冲突已解决';

  @override
  String get simulateCheckUserOfflineStatus_4821 => '模拟检查用户离线状态';

  @override
  String get offline_4821 => '离线';

  @override
  String get userStateRemoved_4821 => '已移除用户状态';

  @override
  String expiredLocksCleaned_4821(Object count) {
    return '已清理 $count 个过期锁定';
  }

  @override
  String get initializationComplete_7421 => '初始化完成';

  @override
  String cannotReleaseLock(Object elementId) {
    return '无法释放其他用户的锁定: $elementId';
  }

  @override
  String get syncServiceNotInitialized_7281 => '同步服务未初始化';

  @override
  String get syncEnabled_7421 => '同步已启用';

  @override
  String get syncDisabled_7421 => '同步已禁用';

  @override
  String get invalidRemoteDataFormat_7281 => '无效的远程数据格式';

  @override
  String get serviceNotInitializedIgnoreData_7283 => '服务未初始化，忽略远程数据';

  @override
  String unknownRemoteDataType_4721(Object type) {
    return '未知的远程数据类型: $type';
  }

  @override
  String get syncServiceCleanedUp_7421 => '同步服务已清理';

  @override
  String remoteDataProcessingFailed_7421(Object error) {
    return '处理远程数据失败: $error';
  }

  @override
  String syncDataFailed_7421(Object error) {
    return '发送同步数据失败: $error';
  }

  @override
  String get remotePointerError_4821 => '处理远程用户指针失败';

  @override
  String get remoteUserJoinFailure_4821 => '处理远程用户加入失败';

  @override
  String get serviceInitialized_7421 => '服务已初始化';

  @override
  String get syncServiceInitialized => '同步服务初始化完成';

  @override
  String syncServiceInitFailed(Object error) {
    return '初始化同步服务失败: $error';
  }

  @override
  String get remoteUserSelectionFailed_7421 => '处理远程用户选择失败';

  @override
  String updateMapTitleFailed(Object e) {
    return '更新地图标题失败: $e';
  }

  @override
  String mapCoverUpdateFailed(Object arg0, Object arg1) {
    return '更新地图封面失败 [$arg0]: $arg1';
  }

  @override
  String get mapCoverCompressionFailed_4821 => '地图封面压缩失败，将不同步封面信息';

  @override
  String get syncMapInfoToPresenceBloc_7421 => '同步地图信息到PresenceBloc';

  @override
  String coverSizeInfo_4821(Object size) {
    return '封面: $size';
  }

  @override
  String get none_5729 => '无';

  @override
  String mapSyncFailed_7285(Object e) {
    return '同步地图信息失败: $e';
  }

  @override
  String authProcessError_4821(Object e) {
    return '认证流程处理错误: $e';
  }

  @override
  String authMessageSent(Object type) {
    return '已发送认证消息: $type';
  }

  @override
  String get authenticationTimeout_7281 => '认证流程超时';

  @override
  String get serverChallengeReceived_4289 => '收到服务器挑战';

  @override
  String get authFailedChallengeDecrypt_7281 => '认证失败: 挑战解密失败';

  @override
  String challengeResponseSentResult(Object sendResult) {
    return '已发送挑战响应，结果: $sendResult';
  }

  @override
  String get authenticationSuccess_7421 => '认证成功';

  @override
  String authenticationFailed(Object reason) {
    return '认证失败: $reason';
  }

  @override
  String startWebSocketAuthProcess(Object clientId) {
    return '开始 WebSocket 认证流程: $clientId';
  }

  @override
  String serverErrorResponse(Object error) {
    return '服务器返回错误: $error';
  }

  @override
  String ignoredMessageType_7281(Object type) {
    return '忽略消息类型: $type';
  }

  @override
  String parseMessageFailed_7285(Object e) {
    return '解析消息失败: $e';
  }

  @override
  String streamError_7284(Object error) {
    return 'Stream 错误: $error';
  }

  @override
  String get streamClosed_8251 => 'Stream 已关闭';

  @override
  String get challengeDecryptedSuccess_7281 => '挑战解密成功';

  @override
  String challengeDecryptionFailed_7421(Object e) {
    return '挑战解密失败: $e';
  }

  @override
  String signatureVerificationResult_7425(Object result) {
    return '签名验证结果: $result';
  }

  @override
  String get valid_8421 => '有效';

  @override
  String get invalid_9352 => '无效';

  @override
  String get authenticationResult_7425 => '认证结果';

  @override
  String get success_8421 => '成功';

  @override
  String get failure_9352 => '失败';

  @override
  String signatureVerificationFailed(Object e) {
    return '验证消息签名失败: $e';
  }

  @override
  String get messageSignedSuccessfully_7281 => '消息签名成功';

  @override
  String signatureFailed_7285(Object e) {
    return '消息签名失败: $e';
  }

  @override
  String generateAuthToken(Object clientId) {
    return '生成认证令牌: $clientId';
  }

  @override
  String tokenVerificationFailed_7421(Object e) {
    return '令牌验证失败: $e';
  }

  @override
  String get tokenValidationFailedTimestampMissing_4821 => '令牌验证失败: 时间戳缺失';

  @override
  String authenticationError(Object e) {
    return '认证过程中发生错误: $e';
  }

  @override
  String get tokenValidationFailed_7281 => '令牌验证失败: 令牌已过期';

  @override
  String tokenValidationSuccess(Object clientId) {
    return '令牌验证成功: $clientId';
  }

  @override
  String startWebSocketAuthFlow(Object clientId) {
    return '开始 WebSocket 认证流程 (使用外部流): $clientId';
  }

  @override
  String authenticationError_7425(Object e) {
    return '认证过程中发生错误: $e';
  }

  @override
  String authMessageSent_7421(Object clientId) {
    return '已发送认证消息: $clientId';
  }

  @override
  String websocketDbUpgradeMessage(Object newVersion, Object oldVersion) {
    return 'WebSocket 客户端配置数据库从版本 $oldVersion 升级到 $newVersion';
  }

  @override
  String get websocketClientDbInitComplete_7281 => 'WebSocket 客户端数据库服务初始化完成';

  @override
  String websocketConfigSaved(Object displayName) {
    return 'WebSocket 客户端配置已保存: $displayName';
  }

  @override
  String websocketClientConfigDeleted(Object clientId) {
    return 'WebSocket 客户端配置已删除: $clientId';
  }

  @override
  String get websocketTableCreated_7281 => 'WebSocket 客户端配置数据库表创建完成';

  @override
  String activeWebSocketClientConfigSet(Object clientId) {
    return '活跃 WebSocket 客户端配置已设置: $clientId';
  }

  @override
  String clientInitializationSuccess_7421(Object displayName) {
    return '客户端初始化成功: $displayName';
  }

  @override
  String clientInitializationFailed_7281(Object e) {
    return '客户端初始化失败: $e';
  }

  @override
  String defaultClientConfigCreated_7421(Object displayName) {
    return '创建默认客户端配置: $displayName';
  }

  @override
  String defaultClientConfigCreated(Object displayName) {
    return '默认客户端配置创建成功: $displayName';
  }

  @override
  String clientConfigFailed_7285(Object e) {
    return '创建默认客户端配置失败: $e';
  }

  @override
  String clientConfigUpdated_7281(Object displayName) {
    return '客户端配置已更新: $displayName';
  }

  @override
  String updateClientConfigFailed_7421(Object e) {
    return '更新客户端配置失败: $e';
  }

  @override
  String clientConfigDeleted(Object clientId) {
    return '客户端配置已删除: $clientId';
  }

  @override
  String deleteClientConfigFailed(Object e) {
    return '删除客户端配置失败: $e';
  }

  @override
  String configValidationFailedWithError(Object error) {
    return '配置验证失败: 公钥格式错误 $error';
  }

  @override
  String configValidationFailedPrivateKeyMissing(Object privateKeyId) {
    return '配置验证失败: 私钥不存在 $privateKeyId';
  }

  @override
  String configValidationFailed_7281(Object e) {
    return '配置验证失败: $e';
  }

  @override
  String initializingClientWithKey(Object webApiKey) {
    return '开始使用 Web API Key 初始化客户端: $webApiKey';
  }

  @override
  String get rsaKeyGenerationStep1_4821 => '步骤1: 开始生成RSA密钥对...';

  @override
  String get step2StorePrivateKey_7281 => '步骤2: 开始存储私钥到安全存储...';

  @override
  String get rsaKeyPairGenerated_4821 => '步骤1: RSA密钥对生成完成';

  @override
  String requestUrl_4821(Object url) {
    return '请求 URL: $url';
  }

  @override
  String serverErrorWithDetails_7421(Object body, Object statusCode) {
    return '服务器返回错误状态码: $statusCode 响应内容: $body';
  }

  @override
  String step2PrivateKeyStored(Object privateKeyId) {
    return '步骤2: 私钥存储完成，ID: $privateKeyId';
  }

  @override
  String rawResponseContent(Object responseBody) {
    return '原始响应内容: $responseBody';
  }

  @override
  String unexpectedContentTypeWithResponse(
    Object contentType,
    Object responseBody,
  ) {
    return '意外的内容类型: $contentType 响应内容: $responseBody';
  }

  @override
  String apiResponseStatusError_7284(Object status) {
    return 'API 响应状态错误: $status';
  }

  @override
  String clientCreatedSuccessfully_7281(Object clientId) {
    return '客户端创建成功: $clientId';
  }

  @override
  String clientCreationFailed_5421(Object e) {
    return '创建客户端失败: $e';
  }

  @override
  String clientCreationFailed_7285(Object e) {
    return '创建默认客户端失败: $e';
  }

  @override
  String createDefaultClient_7281(Object displayName) {
    return '创建默认客户端: $displayName';
  }

  @override
  String clientSetSuccessfully_4821(Object clientId) {
    return '活跃客户端设置成功: $clientId';
  }

  @override
  String clientCreatedSuccessfully(Object clientId) {
    return '默认客户端创建成功: $clientId';
  }

  @override
  String setActiveClient_7421(Object clientId) {
    return '设置活跃客户端: $clientId';
  }

  @override
  String clientConfigNotFound_7285(Object clientId) {
    return '客户端配置不存在: $clientId';
  }

  @override
  String setActiveClientFailed_7285(Object e) {
    return '设置活跃客户端失败: $e';
  }

  @override
  String clientConfigUpdatedSuccessfully_7284(Object clientId) {
    return '客户端配置更新成功: $clientId';
  }

  @override
  String deleteClientConfig(Object clientId) {
    return '删除客户端配置: $clientId';
  }

  @override
  String clientConfigUpdateFailed(Object e) {
    return '更新客户端配置失败: $e';
  }

  @override
  String clientConfigDeletedSuccessfully_7421(Object clientId) {
    return '客户端配置删除成功: $clientId';
  }

  @override
  String clientConfigValidationFailed_4821(Object e) {
    return '验证客户端配置失败: $e';
  }

  @override
  String deleteClientConfigFailed_7421(Object e) {
    return '删除客户端配置失败: $e';
  }

  @override
  String startWebSocketConnection_7281(Object clientId) {
    return '开始连接 WebSocket 服务器: $clientId';
  }

  @override
  String get activeClient_7281 => '活跃客户端';

  @override
  String websocketDisconnectFailed(Object e) {
    return '断开 WebSocket 连接失败: $e';
  }

  @override
  String get disconnectWebSocket_7421 => '断开 WebSocket 连接';

  @override
  String websocketConnectionFailed(Object e) {
    return '连接 WebSocket 服务器失败: $e';
  }

  @override
  String exportClientConfigFailed(Object e) {
    return '导出客户端配置失败: $e';
  }

  @override
  String invalidConfigCleanup(Object clientId) {
    return '发现无效配置，准备清理: $clientId';
  }

  @override
  String get expiredDataCleaned_7281 => '过期数据清理完成';

  @override
  String get startCleaningExpiredData_1234 => '开始清理过期数据';

  @override
  String cleanupFailed_7285(Object e) {
    return '清理旧数据失败: $e';
  }

  @override
  String refreshConfigFailed_7284(Object e) {
    return '刷新配置列表失败: $e';
  }

  @override
  String get websocketNotInitializedError_7281 =>
      'WebSocket 客户端管理器未初始化，请先调用 initialize()';

  @override
  String get initializeWebSocketClientManager_4821 => '初始化 WebSocket 客户端管理器';

  @override
  String refreshConfigFailed_5421(Object e) {
    return '刷新活跃配置失败: $e';
  }

  @override
  String get websocketManagerInitialized_7281 => 'WebSocket 客户端管理器初始化完成';

  @override
  String webSocketInitFailed(Object e) {
    return 'WebSocket 客户端管理器初始化失败: $e';
  }

  @override
  String createClientWithWebApiKey(Object displayName) {
    return '使用 Web API Key 创建客户端: $displayName';
  }

  @override
  String get connectionInProgress_4821 => '连接正在进行中，忽略重复连接请求';

  @override
  String get clientConfigNotFound_7281 => '未找到客户端配置';

  @override
  String connectingToWebSocketServer(Object host, Object port) {
    return '开始连接到 WebSocket 服务器: $host:$port';
  }

  @override
  String privateKeyStoredSafely_4821(Object privateKeyId) {
    return '私钥已安全存储: $privateKeyId';
  }

  @override
  String privateKeyStoredMessage(Object platform, Object privateKeyId) {
    return '私钥已存储到 SharedPreferences $platform: $privateKeyId';
  }

  @override
  String storePrivateKeyFailed_7285(Object e) {
    return '存储私钥失败: $e';
  }

  @override
  String privateKeyRetrievedSuccessfully_7281(
    Object platform,
    Object privateKeyId,
  ) {
    return '私钥从 SharedPreferences 获取成功 $platform: $privateKeyId';
  }

  @override
  String privateKeyObtainedSuccessfully(Object privateKeyId) {
    return '私钥获取成功: $privateKeyId';
  }

  @override
  String privateKeyNotFound_7281(Object privateKeyId) {
    return '私钥未找到: $privateKeyId';
  }

  @override
  String privateKeyFetchFailed(Object e) {
    return '获取私钥失败: $e';
  }

  @override
  String privateKeyDeleted_7281(Object privateKeyId) {
    return '私钥已删除: $privateKeyId';
  }

  @override
  String privateKeyRemovedLog(Object platform, Object privateKeyId) {
    return '私钥已从 SharedPreferences 删除 $platform: $privateKeyId';
  }

  @override
  String deletePrivateKeyFailed(Object e) {
    return '删除私钥失败: $e';
  }

  @override
  String privateKeyDecryptionFailed_4821(Object e) {
    return '使用私钥解密失败: $e';
  }

  @override
  String privateKeyNotFound_7285(Object privateKeyId) {
    return '私钥未找到: $privateKeyId';
  }

  @override
  String checkPrivateKeyFailed_4821(Object e) {
    return '检查私钥存在性失败: $e';
  }

  @override
  String fetchPrivateKeyIdsFailed_7285(Object e) {
    return '获取所有私钥ID失败: $e';
  }

  @override
  String privateKeySignFailed_7285(Object e) {
    return '使用私钥签名失败: $e';
  }

  @override
  String cleanedPrivateKeysCount(Object count) {
    return '已清理 $count 个私钥';
  }

  @override
  String clearPrivateKeysFailed_7421(Object e) {
    return '清理所有私钥失败: $e';
  }

  @override
  String signatureVerificationFailed_4829(Object e) {
    return '验证签名失败: $e';
  }

  @override
  String storageStatsError_4821(Object e) {
    return '获取存储统计信息失败: $e';
  }

  @override
  String rsaKeyPairGenerationFailed(Object e) {
    return '生成 RSA 密钥对失败: $e';
  }

  @override
  String get webSocketInitComplete_4821 => 'WebSocket 安全存储服务初始化完成';

  @override
  String get publicKeyFormatConversionSuccess_7281 =>
      '公钥格式转换成功: RSA PUBLIC KEY → PUBLIC KEY';

  @override
  String publicKeyConversionFailed_7285(Object e) {
    return '公钥格式转换失败: $e';
  }

  @override
  String get rsaKeyPairGenerated_7281 => 'RSA密钥对生成完成，开始转换公钥格式...';

  @override
  String get generatingRsaKeyPair_7284 => '开始生成2048位RSA密钥对...';

  @override
  String get publicKeyConversionComplete_4821 => '公钥格式转换完成';

  @override
  String keyGenerationFailed_7285(Object e) {
    return '生成服务器兼容密钥对失败: $e';
  }

  @override
  String imageCompressionFailed_7284(Object e) {
    return '图片压缩失败: $e';
  }

  @override
  String base64DecodeFailed(Object e) {
    return '解码base64图片失败: $e';
  }

  @override
  String get ignore_4821 => '忽略';

  @override
  String occurrenceTime_4821(Object timestamp) {
    return '发生时间: $timestamp';
  }

  @override
  String get solve_7421 => '解决';

  @override
  String get justNow_4821 => '刚刚';

  @override
  String minutesAgo_7421(Object minutes) {
    return '$minutes分钟前';
  }

  @override
  String get hoursAgo_4827 => '小时前';

  @override
  String conflictCount(Object count) {
    return '$count个冲突';
  }

  @override
  String get elementLockConflict_4821 => '元素锁定冲突';

  @override
  String get simultaneousEditConflict_4822 => '同时编辑冲突';

  @override
  String get versionMismatch_4823 => '版本不匹配';

  @override
  String get permissionDenied_4824 => '权限被拒绝';

  @override
  String get networkError_4825 => '网络错误';

  @override
  String get collaborationConflict_4826 => '协作冲突';

  @override
  String get editConflict_4827 => '编辑冲突';

  @override
  String get lockConflict_4828 => '锁定冲突';

  @override
  String get deleteConflict_4829 => '删除冲突';

  @override
  String get permissionConflict_4830 => '权限冲突';

  @override
  String onlineUsersCount(Object count) {
    return '用户 ($count)';
  }

  @override
  String get noBackgroundImage_7421 => '无背景图片';

  @override
  String get currentSettings_4521 => '当前设置';

  @override
  String get zoomLabel_4821 => '缩放';

  @override
  String get xOffsetLabel_4821 => 'X偏移';

  @override
  String get yOffsetLabel_4821 => 'Y偏移';

  @override
  String get backgroundImageSettings_7421 => '背景图片设置';

  @override
  String get fillModeLabel_4821 => '填充模式: ';

  @override
  String zoomPercentage(Object percentage) {
    return '缩放: $percentage%';
  }

  @override
  String xAxisOffset(Object percentage) {
    return 'X轴偏移: $percentage%';
  }

  @override
  String get leftText_4821 => '左';

  @override
  String get chineseCharacter_4821 => '中';

  @override
  String yAxisOffset(Object percentage) {
    return 'Y轴偏移: $percentage%';
  }

  @override
  String get rightDirection_4821 => '右';

  @override
  String get upText_4821 => '上';

  @override
  String get downText_4821 => '下';

  @override
  String get fillMode_4821 => '填充模式';

  @override
  String get cancelButton_4271 => '取消';

  @override
  String get confirmButton_7281 => '确定';

  @override
  String get boxFitContain_4821 => '包含';

  @override
  String get boxFitCover_4822 => '覆盖';

  @override
  String get boxFitFill_4823 => '填充';

  @override
  String get boxFitFitWidth_4824 => '适宽';

  @override
  String get boxFitFitHeight_4825 => '适高';

  @override
  String get boxFitNone_4826 => '原始';

  @override
  String get boxFitScaleDown_4827 => '缩小';

  @override
  String get colorFilterSettingsTitle_4287 => '色彩滤镜设置';

  @override
  String get layerThemeDisabled_4821 => '您已禁用此图层的主题适配，当前使用自定义设置。';

  @override
  String get darkModeFilterApplied_4821 => '深色模式下已自动应用颜色反转，当前正在使用主题滤镜。';

  @override
  String get darkModeAutoInvertApplied_4821 => '深色模式下已自动应用颜色反转，当前显示您的自定义设置。';

  @override
  String get noFilterApplied_4821 => '当前未应用任何滤镜。';

  @override
  String get darkModeColorInversion_4821 => '深色模式下将自动应用颜色反转。';

  @override
  String get canvasThemeAdaptationEnabled_7421 => '画布主题适配已启用';

  @override
  String get resetToAutoSettings_4821 => '重置为自动设置';

  @override
  String get reapplyThemeFilter_7281 => '重新应用主题滤镜';

  @override
  String get clearAllFilters_4271 => '清除所有滤镜';

  @override
  String get filterType_4821 => '滤镜类型';

  @override
  String get filterPreview_4821 => '滤镜预览';

  @override
  String intensityPercentage(Object percentage) {
    return '强度: $percentage%';
  }

  @override
  String brightnessPercentage(Object percentage) {
    return '亮度: $percentage%';
  }

  @override
  String contrastPercentage(Object percentage) {
    return '对比度: $percentage%';
  }

  @override
  String saturationPercentage(Object percentage) {
    return '饱和度: $percentage%';
  }

  @override
  String hueValue(Object value) {
    return '色相: $value°';
  }

  @override
  String get noFilter_4821 => '无滤镜';

  @override
  String get grayscale_4822 => '灰度';

  @override
  String get sepia_4823 => '棕褐色';

  @override
  String get invert_4824 => '反色';

  @override
  String get brightness_4825 => '亮度';

  @override
  String get contrast_4826 => '对比度';

  @override
  String get saturation_4827 => '饱和度';

  @override
  String get hue_4828 => '色相';

  @override
  String get inputColorValue_4821 => '输入颜色值';

  @override
  String get supportedFormats_7281 => '支持以下格式：';

  @override
  String get argbColorDescription_7281 => '• ARGB: FFFF0000 (红色，不透明)';

  @override
  String get rgbColorDescription_7281 => '• RGB: FF0000 (红色)';

  @override
  String get colorWithHashTag_7281 => '带#号: #FF0000';

  @override
  String get cssColorNames_4821 => '• CSS颜色名: red, blue, green等';

  @override
  String get cancel_4821 => '取消';

  @override
  String get colorValueLabel_4821 => '颜色值';

  @override
  String get colorValueHint_4821 => '例如: FF0000, #FF0000, red';

  @override
  String get invalidColorFormat_4821 => '无效的颜色格式，请检查输入';

  @override
  String get colorPickerTitle_4821 => '选择颜色';

  @override
  String get brightness_7285 => '亮度';

  @override
  String get saturationLabel_4821 => '饱和度';

  @override
  String get opacityLabel_4821 => '透明度';

  @override
  String get brightnessLabel_4821 => '亮度';

  @override
  String get transparencyLabel_4821 => '透明度';

  @override
  String get clickToInputColorValue => '点击输入颜色值';

  @override
  String get cancelButton_7421 => '取消';

  @override
  String get directUse_4821 => '直接使用';

  @override
  String get addToCustom_7281 => '添加到自定义';

  @override
  String get cancelButton_7281 => '取消';

  @override
  String get xAxisLabel_7281 => 'X轴: ';

  @override
  String get yAxisLabel_7284 => 'Y轴: ';

  @override
  String get configurationInfo_7284 => '=== 配置信息 ===';

  @override
  String currentPlatform_7421(Object platform) {
    return '当前平台: $platform';
  }

  @override
  String availablePagesList_7281(Object pages) {
    return '可用页面: $pages';
  }

  @override
  String availableFeaturesMessage_7281(Object features) {
    return '可用功能: $features';
  }

  @override
  String get buildInfo_7421 => '构建时信息:';

  @override
  String get closeButton_7421 => '关闭';

  @override
  String showMenuAtPosition(Object position) {
    return '显示菜单于位置: $position';
  }

  @override
  String get hiddenMenu_7281 => '隐藏菜单';

  @override
  String get delayReturnToMenu_7281 => '延迟返回主菜单';

  @override
  String mouseStopAndEnterSubmenu(Object label) {
    return '鼠标停止移动，延迟进入子菜单: $label';
  }

  @override
  String enterSubMenuNow_7421(Object label) {
    return '立即进入子菜单: $label';
  }

  @override
  String hoverItem_7421(Object label) {
    return '悬停项目: $label';
  }

  @override
  String submenuDelayTimer(Object label) {
    return '设置子菜单延迟计时器: $label';
  }

  @override
  String selectedItemLabel(Object label) {
    return '选择项目: $label';
  }

  @override
  String subMenuInitialHoverItem(Object label) {
    return '子菜单初始悬停项目: $label';
  }

  @override
  String middleKeyPressedShowRadialMenu(Object localPosition) {
    return '中键按下，显示径向菜单于位置: $localPosition';
  }

  @override
  String fetchCustomTagFailed_7285(Object e) {
    return '获取自定义标签失败: $e';
  }

  @override
  String get tagAlreadyExists_7281 => '标签已存在';

  @override
  String get maxTagsLimit => '限制最多10个标签';

  @override
  String saveTagPreferenceFailed(Object e) {
    return '保存标签到偏好设置失败: $e';
  }

  @override
  String get addTagTooltip_7281 => '添加标签';

  @override
  String get suggestedTagsLabel_4821 => '建议标签：';

  @override
  String customTagLoadFailed_7421(Object e) {
    return '加载自定义标签失败: $e';
  }

  @override
  String get manageTagsTitle_4821 => '管理标签';

  @override
  String tagCountWithMax_7281(Object count, Object max) {
    return '$count / $max 个标签';
  }

  @override
  String tagCount_4592(Object count) {
    return '$count 个标签';
  }

  @override
  String addCustomTagFailed_7285(Object e) {
    return '添加自定义标签失败: $e';
  }

  @override
  String addCustomTagFailed(Object error) {
    return '添加自定义标签失败: $error';
  }

  @override
  String get customLabel_7281 => '自定义标签';

  @override
  String get manageCustomTags_7421 => '管理自定义标签';

  @override
  String get addTag_7421 => '添加';

  @override
  String get addCustomTagHint_4821 => '添加自定义标签';

  @override
  String get tagManagement_7281 => '标签管理';

  @override
  String get addNewTagHint_4821 => '添加新标签';

  @override
  String get tagCannotBeEmpty_4821 => '标签不能为空';

  @override
  String get tagLengthExceeded_4821 => '标签长度不能超过20个字符';

  @override
  String get tagNoSpacesAllowed_7281 => '标签不能包含空格';

  @override
  String get invalidTagCharacters_4821 => '标签包含非法字符';

  @override
  String deleteCustomTagFailed_7421(Object e) {
    return '删除自定义标签失败: $e';
  }

  @override
  String get manageCustomTags_4271 => '管理自定义标签';

  @override
  String get importantTag_1234 => '重要';

  @override
  String get urgentTag_5678 => '紧急';

  @override
  String get completedTag_9012 => '完成';

  @override
  String get temporaryTag_3456 => '临时';

  @override
  String get remarkTag_7890 => '备注';

  @override
  String get markTag_2345 => '标记';

  @override
  String get highPriorityTag_6789 => '高优先级';

  @override
  String get lowPriorityTag_0123 => '低优先级';

  @override
  String get planTag_4567 => '计划';

  @override
  String get ideaTag_8901 => '想法';

  @override
  String get referenceTag_1235 => '参考';

  @override
  String get customTagHintText_4521 => '输入自定义标签';

  @override
  String customTagCount(Object count) {
    return '自定义标签 ($count)';
  }

  @override
  String get noCustomTagsMessage_7421 => '暂无自定义标签\n点击上方输入框添加新标签';

  @override
  String get minimizeButton_7281 => '最小化';

  @override
  String get maximizeOrRestore_7281 => '最大化/还原';

  @override
  String fullscreenToggleFailed(Object e) {
    return '切换全屏模式失败: $e';
  }

  @override
  String get closeButton_4821 => '关闭';

  @override
  String fullScreenStatusError(Object error) {
    return '获取全屏状态失败: $error';
  }

  @override
  String get skipSaveMaximizedState => '跳过保存：当前处于最大化状态';

  @override
  String get windowSizeSaveRequestSent_7281 => '窗口大小保存请求已发送（非最大化状态）';

  @override
  String saveWindowSizeFailed_7285(Object e) {
    return '手动保存窗口大小失败: $e';
  }

  @override
  String scriptName_7421(Object scriptName) {
    return '脚本: $scriptName';
  }

  @override
  String get setParametersPrompt_4821 => '请设置以下参数：';

  @override
  String get checkAndCorrectInputError_4821 => '请检查并修正参数输入错误';

  @override
  String inputPrompt(Object name) {
    return '请输入$name';
  }

  @override
  String requiredParameter_7281(Object name) {
    return '$name是必填参数';
  }

  @override
  String get inputIntegerHint_4521 => '请输入整数';

  @override
  String get invalidIntegerError_4821 => '请输入有效的整数';

  @override
  String get enterNumberHint_4521 => '请输入数字';

  @override
  String requiredParameter(Object name) {
    return '$name是必填参数';
  }

  @override
  String get invalidNumberInput_4821 => '请输入有效的数字';

  @override
  String get yes_4821 => '是';

  @override
  String get no_4821 => '否';

  @override
  String selectParamPrompt(Object name) {
    return '请选择$name';
  }

  @override
  String requiredParamError_7421(Object name) {
    return '$name是必填参数';
  }

  @override
  String get scriptParameterSettings_4821 => '脚本参数设置';

  @override
  String get textType_1234 => '文本';

  @override
  String get integerType_5678 => '整数';

  @override
  String get numberType_9012 => '数字';

  @override
  String get booleanType_3456 => '布尔';

  @override
  String get enumType_7890 => '选择';

  @override
  String get programWorking_1234 => '程序正在工作中';

  @override
  String get currentOperation_7281 => '当前正在执行：';

  @override
  String get unknownTask_7421 => '未知任务';

  @override
  String get forceExitWarning_4821 => '强制退出可能会导致数据丢失或程序状态异常。建议等待当前任务完成后再退出。';

  @override
  String get confirmExit_7284 => '仍要退出';

  @override
  String get demoText_4271 => '演示';

  @override
  String get floatingWindowExample_4271 => '浮动窗口示例';

  @override
  String get basicFloatingWindowExample_4821 => '这是一个基础的浮动窗口示例';

  @override
  String get windowContentDescription_4821 => '窗口内容可以是任何Widget，包括文本、按钮、表单等。';

  @override
  String get windowSizeDescription_5739 => '窗口会自动适应屏幕大小，默认占用90%的屏幕宽度和高度。';

  @override
  String get exampleInputField_4521 => '示例输入框';

  @override
  String get cancelButton_7284 => '取消';

  @override
  String get confirmButton_4821 => '确定';

  @override
  String get notifications_4821 => '通知';

  @override
  String get darkMode_7285 => '深色模式';

  @override
  String get autoSave_7421 => '自动保存';

  @override
  String get dataSync_7284 => '数据同步';

  @override
  String get saveButton_7421 => '保存';

  @override
  String get operationSuccess_4821 => '操作成功';

  @override
  String get basicFloatingWindowTitle_4821 => '基础浮动窗口';

  @override
  String get basicFloatingWindowDescription_4821 => '最简单的浮动窗口，包含标题和内容';

  @override
  String get operationCompletedSuccessfully_7281 => '您的操作已成功完成';

  @override
  String get refreshOperation_7284 => '刷新操作';

  @override
  String get settingsOperation_4251 => '设置操作';

  @override
  String fileNameWithIndex(Object index) {
    return '文件 $index.txt';
  }

  @override
  String get createNewFile_7281 => '新建文件';

  @override
  String get uploadButton_7284 => '上传';

  @override
  String get cardWithIconAndSubtitle_4821 => '带图标和副标题';

  @override
  String get floatingWindowWithIconAndTitle_4821 => '包含图标、主标题和副标题的浮动窗口';

  @override
  String get dragFeature_4521 => '拖拽功能';

  @override
  String get windowDragHint_4821 => '这个窗口支持拖拽移动。您可以点击并拖拽标题栏来移动窗口位置。';

  @override
  String get windowBoundaryHint_4821 => '窗口会自动限制在屏幕边界内，但允许部分内容移出屏幕边缘。';

  @override
  String get usageHint_4521 => '使用提示：';

  @override
  String get clickAndDragWindowTitle_4821 => '• 点击标题栏并拖拽移动窗口';

  @override
  String get windowStayVisibleArea_4821 => '窗口会保持在屏幕可见区域内';

  @override
  String get releaseMouseToCompleteMove_7281 => '• 释放鼠标完成移动操作';

  @override
  String get builderPatternWindow_4821 => '构建器模式窗口';

  @override
  String get windowConfigChainCall_7284 => '使用链式调用配置窗口属性';

  @override
  String get helpInfo_4821 => '帮助信息';

  @override
  String get help_5732 => '帮助';

  @override
  String get builderPattern_4821 => '构建器模式';

  @override
  String get floatingWindowBuilderDescription_4821 =>
      'FloatingWindowBuilder提供了一种优雅的方式来配置浮动窗口的各种属性。您可以使用链式调用来设置窗口的标题、图标、尺寸、拖拽支持等功能。';

  @override
  String get customSizeTitle_4821 => '自定义尺寸';

  @override
  String get customSizeDescription_4821 => '指定具体宽高比例的浮动窗口';

  @override
  String get codeExample_7281 => '代码示例：';

  @override
  String get windowTitle_7421 => '窗口标题';

  @override
  String get quickCreate_7421 => '快速创建';

  @override
  String get buildContextExtensionTip_7281 =>
      '使用BuildContext扩展方法可以更快速地创建简单的浮动窗口';

  @override
  String get windowTitle_7281 => '窗口标题';

  @override
  String get draggableWindowTitle_4821 => '可拖拽窗口';

  @override
  String get draggableWindowDescription_4821 => '支持拖拽移动的浮动窗口';

  @override
  String get cardWithActionsTitle_4821 => '带操作按钮';

  @override
  String get floatingWindowWithActionsDesc_4821 => '头部包含自定义操作按钮的浮动窗口';

  @override
  String get builderPatternTitle_3821 => '构建器模式';

  @override
  String get builderPatternDescription_3821 => '使用构建器模式创建复杂配置的浮动窗口';

  @override
  String get extensionMethodsTitle_4821 => '扩展方法';

  @override
  String get extensionMethodsDescription_4821 => '使用BuildContext扩展方法快速创建浮动窗口';

  @override
  String get mergeLayers_7281 => '合并图层';

  @override
  String get layer_4821 => '图层';

  @override
  String get createGroup_4821 => '创建组';

  @override
  String get createLayerGroup_7532 => '创建图层组';

  @override
  String get ungroupAction_4821 => '取消分组';

  @override
  String get renameGroup_4821 => '重命名组';

  @override
  String get renameLayerGroup_7539 => '重命名图层组';

  @override
  String get layerGroup_7281 => '图层组';

  @override
  String get textNoteLabel_4821 => '文本便签';

  @override
  String get imageNoteLabel_4821 => '图片便签';

  @override
  String get voiceNote_7281 => '语音便签';

  @override
  String get deleteNote_7421 => '删除便签';

  @override
  String get noteItem_4821 => '便签';

  @override
  String selectedAction_7421(Object action) {
    return '选择了: $action';
  }

  @override
  String get rouletteGestureMenuExample_4271 => '轮盘手势菜单示例';

  @override
  String get toggleDebugMode_4721 => '切换调试模式';

  @override
  String menuSelection_7281(Object label) {
    return '菜单选择: $label';
  }

  @override
  String get wheelMenuInstruction_4521 => '使用中键或触摸板双指按下\n来调起轮盘菜单';

  @override
  String get currentSelection_4821 => '当前选择:';

  @override
  String get usageInstructions_4521 => '使用说明';

  @override
  String get smallBrush_4821 => '小画笔';

  @override
  String get mediumBrush_4821 => '中画笔';

  @override
  String get largeBrush_4821 => '大画笔';

  @override
  String get eraserItem_4821 => '橡皮擦';

  @override
  String get brushTool_4821 => '画笔';

  @override
  String get createNewLayer_4821 => '新建图层';

  @override
  String get copyLayer_4821 => '复制图层';

  @override
  String get deleteLayer_4821 => '删除图层';

  @override
  String get dragDemoTitle_4821 => '拖拽功能演示';

  @override
  String get dragToMoveHint_7281 => '💡 提示：在标题栏区域按住鼠标并拖拽';

  @override
  String get windowDragHint_4721 => '您可以通过拖拽标题栏来移动这个窗口。';

  @override
  String get windowAutoSnapHint_4721 => '窗口会自动保持在屏幕可见区域内。';

  @override
  String get floatingWindowDemo_4271 => '浮动窗口演示';

  @override
  String get fileManager_1234 => '文件管理器';

  @override
  String get vfsFilePickerStyle_4821 => 'VFS文件选择器风格';

  @override
  String get refreshFileList_4821 => '刷新文件列表';

  @override
  String get refresh_4822 => '刷新';

  @override
  String get switchView_4821 => '切换视图';

  @override
  String get view_4822 => '视图';

  @override
  String get pushNotifications_4821 => '推送通知';

  @override
  String get autoSaveSetting_7421 => '自动保存';

  @override
  String get darkModeTitle_4721 => '深色模式';

  @override
  String volumePercentage(Object percentage) {
    return '音量: $percentage%';
  }

  @override
  String get simpleWindow_7421 => '简单窗口';

  @override
  String get breadcrumbPath => '/ 根目录 / 文档 / 项目文件';

  @override
  String selectedFile(Object name) {
    return '选择了: $name';
  }

  @override
  String get folderLabel_5421 => '文件夹';

  @override
  String fileInfoWithSizeAndDate_5421(Object date, Object size) {
    return '$size • $date';
  }

  @override
  String get createNewFolder_4821 => '新建文件夹';

  @override
  String get selectOption_4271 => '选择';

  @override
  String get settingsWindow_4271 => '设置窗口';

  @override
  String get documentName_4821 => '文档';

  @override
  String get image_4821 => '图片';

  @override
  String get draggableWindow_4271 => '可拖拽窗口';

  @override
  String get fileManagerStyle_4821 => '文件管理器风格';

  @override
  String get floatingWindowTip_7281 => '点击按钮体验不同类型的浮动窗口';

  @override
  String get welcomeFloatingWidget_7421 => '欢迎使用浮动窗口组件！';

  @override
  String get floatingWindowExample_4521 => '这是一个简单的浮动窗口示例，模仿了VFS文件选择器的设计风格。';

  @override
  String get appSettings_4821 => '应用设置';

  @override
  String get configurePreferences_5732 => '配置您的首选项';

  @override
  String get imageEditMenuTitle_7421 => '示例2：图片编辑菜单';

  @override
  String get editLabel_4521 => '编辑';

  @override
  String get openEditorMessage_4521 => '打开编辑器';

  @override
  String get imageRotated_4821 => '图片已旋转';

  @override
  String get zoomImage_4821 => '缩放图片';

  @override
  String get saveAs_7421 => '另存为';

  @override
  String get exporting_7421 => '正在导出';

  @override
  String get showProperties_4281 => '显示属性';

  @override
  String get webContextMenuExample_7281 => 'Web兼容右键菜单示例';

  @override
  String get imageEditAreaRightClickOptions_4821 => '图片编辑区域 - 右键查看选项';

  @override
  String get example3ListItemMenu_7421 => '示例3：列表项菜单';

  @override
  String viewProjectDetails(Object index) {
    return '查看项目 $index 详情';
  }

  @override
  String get editLabel_4821 => '编辑';

  @override
  String editItemMessage_4821(Object itemNumber) {
    return '编辑项目 $itemNumber';
  }

  @override
  String copiedProjectLink(Object index) {
    return '已复制项目 $index 链接';
  }

  @override
  String shareProject(Object index) {
    return '分享项目 $index';
  }

  @override
  String get delete_4821 => '删除';

  @override
  String deleteItem_4822(Object itemNumber) {
    return '删除项目 $itemNumber';
  }

  @override
  String get rightClickOptions_4821 => '右键点击查看选项';

  @override
  String listItemTitle(Object itemNumber) {
    return '列表项 $itemNumber';
  }

  @override
  String get webPlatformMenuDescription_4821 =>
      '在Web平台上，浏览器默认会显示自己的右键菜单。通过我们的处理方案，可以禁用浏览器默认菜单，使用Flutter自定义菜单。';

  @override
  String get webPlatformRightClickMenuDescription_4821 => 'Web平台右键菜单说明';

  @override
  String get exampleRightClickMenu_4821 => '示例1：简单右键菜单';

  @override
  String get copiedMessage_7421 => '已复制';

  @override
  String get paste_4821 => '粘贴';

  @override
  String get pasted_4822 => '已粘贴';

  @override
  String get deletedMessage_7421 => '已删除';

  @override
  String get rightClickHereHint_4821 => '右键点击这里试试';

  @override
  String get closeButton_5421 => '关闭';

  @override
  String get minimizeButton_4821 => '最小化';

  @override
  String get exitFullscreen_4821 => '退出全屏';

  @override
  String get enterFullscreen_4822 => '全屏';

  @override
  String get skipSaveMaximizedState_4821 => '跳过保存：当前处于最大化状态';

  @override
  String get minimizeTooltip_7281 => '最小化';

  @override
  String get maximizeRestore_7281 => '最大化/还原';

  @override
  String saveWindowSizeFailed_7284(Object e) {
    return '保存窗口大小失败: $e';
  }

  @override
  String get exitFullscreen_4721 => '退出全屏';

  @override
  String get enterFullscreen_5832 => '全屏';

  @override
  String get nameCannotBeEmpty_4821 => '名称不能为空';

  @override
  String get invalidCharacters_4821 => '名称包含无效字符: < > : \" / \\ | ? *';

  @override
  String get copySuffix_7421 => '(副本)';

  @override
  String get invalidNameDotError_4821 => '名称不能以点号开头或结尾';

  @override
  String get reservedNameError_4821 => '不能使用系统保留名称';

  @override
  String get nameLengthExceeded_4821 => '名称长度不能超过255个字符';

  @override
  String get fileConflict_4821 => '文件冲突';

  @override
  String remainingConflictsToResolve(Object remainingConflicts) {
    return '还有 $remainingConflicts 个冲突需要处理';
  }

  @override
  String duplicateItemExists_7281(Object item) {
    return '目标位置已存在同名$item:';
  }

  @override
  String get folder_7281 => '文件夹';

  @override
  String get file_7281 => '文件';

  @override
  String get rename_4821 => '重命名';

  @override
  String get selectProcessingMethod_4821 => '请选择处理方式:';

  @override
  String get keepTwoFilesRenameNew_4821 => '保留两个文件，重命名新文件';

  @override
  String get overlayText_4821 => '覆盖';

  @override
  String get inputNewNameHint_4821 => '输入新名称';

  @override
  String get replaceExistingFileWithNew_7281 => '用新文件替换现有文件';

  @override
  String get mergeText_4821 => '合并';

  @override
  String get mergeFolderPrompt_4821 => '合并文件夹内容，子文件冲突时会再次询问';

  @override
  String get skip_4821 => '跳过';

  @override
  String get skipFileKeepExisting_7281 => '跳过此文件，保留现有文件';

  @override
  String get applyToAllConflicts_7281 => '应用到所有冲突';

  @override
  String get applySameResolutionToAllConflicts_4821 => '对剩余的所有冲突使用相同的处理方式';

  @override
  String get copySuffix_7285 => ' (副本)';

  @override
  String get metadataTitle_4821 => '元数据';

  @override
  String get mimeTypeLabel_4721 => 'MIME类型';

  @override
  String get unknownLabel_4721 => '未知';

  @override
  String get copyInfo_4821 => '复制信息';

  @override
  String get fileInfo_7281 => '文件信息';

  @override
  String fileNameLabel(Object fileName) {
    return '文件名: $fileName';
  }

  @override
  String fileSizeLabel(Object size) {
    return '文件大小: $size';
  }

  @override
  String filePathLabel(Object path) {
    return '路径: $path';
  }

  @override
  String get folderType_4821 => '文件夹';

  @override
  String get fileType_4821 => '文件类型';

  @override
  String creationTimeLabel_5421(Object createdTime) {
    return '创建时间: $createdTime';
  }

  @override
  String get metadataLabel_7281 => '\\n元数据:';

  @override
  String get modifiedTimeLabel_7421 => '修改时间';

  @override
  String mimeTypeLabel(Object mimeType) {
    return 'MIME类型: $mimeType';
  }

  @override
  String get fileInfoCopiedToClipboard_4821 => '文件信息已复制到剪贴板';

  @override
  String fileInfoTitle(Object name) {
    return '文件信息 - $name';
  }

  @override
  String get nameLabel_4821 => '名称';

  @override
  String get pathLabel_4821 => '路径';

  @override
  String get typeLabel_5421 => '类型';

  @override
  String get folderType_5421 => '文件夹';

  @override
  String get fileType_5421 => '文件';

  @override
  String get fileSize_4821 => '大小';

  @override
  String get modifiedTimeLabel_4821 => '修改时间';

  @override
  String creationTime_7281(Object date) {
    return '创建时间: $date';
  }

  @override
  String get renameSuccess_4821 => '重命名成功';

  @override
  String renameFailed_7285(Object e) {
    return '重命名失败: $e';
  }

  @override
  String get confirmDeletionTitle_4821 => '确认删除';

  @override
  String confirmDeletionMessage_4821(Object count) {
    return '确定要删除选中的 $count 个项目吗？此操作不可撤销。';
  }

  @override
  String fileOpenFailed_7285(Object e) {
    return '打开文件失败: $e';
  }

  @override
  String get permissionUpdated_4821 => '权限已更新';

  @override
  String permissionFailed_7284(Object e) {
    return '权限管理失败: $e';
  }

  @override
  String get createFolderTitle_4821 => '新建文件夹';

  @override
  String get folderNameHint_5732 => '文件夹名称';

  @override
  String get folderCreatedSuccessfully_4821 => '文件夹创建成功';

  @override
  String createFolderFailed(Object e) {
    return '创建文件夹失败: $e';
  }

  @override
  String folderCreationFailed_7285(Object e) {
    return '创建文件夹失败: $e';
  }

  @override
  String get selectDatabaseFirst_4821 => '请先选择数据库';

  @override
  String get rootDirectory_7421 => '根目录';

  @override
  String permissionViewError_4821(Object error) {
    return '无法查看权限: $error';
  }

  @override
  String get selectFileToViewMetadata_7281 => '选择文件以查看元数据';

  @override
  String selectedItemsCount(Object selectedCount, Object totalCount) {
    return '已选择 $selectedCount / $totalCount 项';
  }

  @override
  String get totalCount_7281 => '总数量';

  @override
  String get folderCount_4821 => '文件夹数量';

  @override
  String get fileCount_4821 => '文件数量';

  @override
  String get totalSize_4821 => '总大小';

  @override
  String get fileTypeStatistics_4821 => '文件类型统计';

  @override
  String get selectedFile_7281 => '选中的文件';

  @override
  String get typeLabel_4821 => '类型';

  @override
  String get creationTime_4821 => '创建时间';

  @override
  String get modifiedTime_4821 => '修改时间';

  @override
  String get mimeType_4821 => 'MIME类型';

  @override
  String get customMetadata_7281 => '自定义元数据';

  @override
  String get noExtension_7281 => '无扩展名';

  @override
  String get storageInfo_7281 => '存储信息';

  @override
  String fileCount(Object count) {
    return '$count 个文件';
  }

  @override
  String get databaseLabel_4821 => '数据库';

  @override
  String get collectionLabel_4821 => '集合';

  @override
  String get totalFiles_4821 => '文件总数';

  @override
  String get selectedCount_7284 => '选中数量';

  @override
  String get selectDatabaseAndCollection_7421 => '请选择数据库和集合';

  @override
  String get fileSelectionModeWarning_4821 => '当前选择模式只能选择文件';

  @override
  String get folderSelectionRequired_4821 => '当前选择模式只能选择文件夹';

  @override
  String get directorySelectionNotAllowed_4821 => '不允许选择文件夹';

  @override
  String unsupportedFileType(Object extension) {
    return '不支持的文件类型: .$extension';
  }

  @override
  String get userFile_4821 => '用户文件';

  @override
  String get systemProtectedFile_4821 => '系统保护文件';

  @override
  String selectAllWithCount(Object count) {
    return '全选 ($count 项)';
  }

  @override
  String singleSelectionModeWithCount(Object count) {
    return '单选模式 ($count 项)';
  }

  @override
  String get cutSelectedItems_4821 => '剪切选中项';

  @override
  String get copySelectedItems_4821 => '复制选中项';

  @override
  String get selectDatabaseAndCollectionFirst_7281 => '请先选择数据库和集合';

  @override
  String get deleteSelectedItems_4821 => '删除选中项';

  @override
  String uploadFailedWithError(Object error) {
    return '上传失败: $error';
  }

  @override
  String get folderNotExist_4821 => '选择的文件夹不存在';

  @override
  String fileUploadSuccess(Object successCount) {
    return '成功上传 $successCount 个文件';
  }

  @override
  String fileUploadFailed_7284(Object e) {
    return '文件上传失败: $e';
  }

  @override
  String initializationFailed(Object error) {
    return '初始化失败: $error';
  }

  @override
  String get selectDatabaseFirst_7281 => '请先选择数据库和集合';

  @override
  String downloadFailed_7285(Object e) {
    return '下载失败: $e';
  }

  @override
  String get selectFileOrFolderFirst_7281 => '请先选择要下载的文件或文件夹';

  @override
  String get emptyDirectory_7281 => '当前目录为空';

  @override
  String foldersDownloadedToPath_7281(Object downloadPath, Object folderCount) {
    return '已下载 $folderCount 个文件夹到 $downloadPath';
  }

  @override
  String filesDownloaded_7281(Object downloadPath, Object fileCount) {
    return '已下载 $fileCount 个文件到 $downloadPath';
  }

  @override
  String downloadSummary(
    Object downloadPath,
    Object fileCount,
    Object folderCount,
  ) {
    return '已下载 $fileCount 个文件和 $folderCount 个文件夹到 $downloadPath';
  }

  @override
  String filesCompressedInfo(Object fileSize, Object totalFiles) {
    return '已压缩下载 $totalFiles 个文件\n压缩包大小: $fileSize';
  }

  @override
  String get rootDirectory_5421 => '根目录';

  @override
  String get saveZipFileTitle_4821 => '保存压缩文件';

  @override
  String get rootDirectory_5732 => '根目录';

  @override
  String filesCompressedInfo_7281(
    Object fileSize,
    Object totalFiles,
    Object zipPath,
  ) {
    return '已压缩下载 $totalFiles 个文件到 $zipPath\n压缩包大小: $fileSize';
  }

  @override
  String get compressionFailed_7281 => '压缩失败';

  @override
  String compressionDownloadFailed(Object e) {
    return '压缩下载失败: $e';
  }

  @override
  String downloadedFilesAndDirectories(
    Object directoryCount,
    Object fileCount,
  ) {
    return '已下载 $fileCount 个文件和 $directoryCount 个目录';
  }

  @override
  String downloadedFilesFromDirectories(Object directoryCount) {
    return '已下载 $directoryCount 个目录中的文件';
  }

  @override
  String downloadedFilesCount(Object fileCount) {
    return '已下载 $fileCount 个文件';
  }

  @override
  String get supportMultipleSelection_7281 => '支持多选';

  @override
  String webDownloadFailed_7285(Object e) {
    return 'Web压缩包下载失败: $e';
  }

  @override
  String fileLoadFailed_7285(Object e) {
    return '加载文件失败: $e';
  }

  @override
  String get singleSelectionOnly_4821 => '仅单选';

  @override
  String get onlyFilesAndFoldersNavigable_7281 => '仅文件 • 文件夹可导航';

  @override
  String fileTypeRestriction_7421(Object extensions) {
    return '仅指定类型文件 ($extensions) • 文件夹可导航';
  }

  @override
  String get folderOnly_7281 => '仅文件夹';

  @override
  String get filesAndFolders_7281 => '文件和文件夹';

  @override
  String folderAndFileTypesRestriction(Object extensions) {
    return '文件夹和指定类型文件 ($extensions)';
  }

  @override
  String copiedItemsCount(Object count) {
    return '已复制 $count 个项目';
  }

  @override
  String itemsCutMessage(Object count) {
    return '已剪切 $count 个项目';
  }

  @override
  String fileProcessingError_7281(Object error, Object fileName) {
    return '处理文件 $fileName 时出错: $error';
  }

  @override
  String get copy_3632 => '副本';

  @override
  String pasteCompleteSuccessfully(Object successCount) {
    return '粘贴完成，成功处理 $successCount 个项目';
  }

  @override
  String pasteFailed_7285(Object e) {
    return '粘贴失败: $e';
  }

  @override
  String renameFileOrFolder_7421(String isDirectory) {
    String _temp0 = intl.Intl.selectLogic(isDirectory, {
      'true': '重命名 文件夹',
      'false': '重命名 文件',
      'other': '重命名',
    });
    return '$_temp0';
  }

  @override
  String get currentNameLabel_4821 => '当前名称:';

  @override
  String get newLabel_4821 => '新名称:';

  @override
  String fileExtensionNotice(Object extension) {
    return '注意: 文件扩展名 \"$extension\" 将保持不变';
  }

  @override
  String get invalidCharactersError_4821 => '名称包含无效字符: < > : \" / \\ | ? *';

  @override
  String get nameLengthExceedLimit_4829 => '名称长度不能超过255个字符';

  @override
  String get systemProtectedFileWarning_4821 => '系统保护文件 - 此文件受系统保护，不可删除或修改权限';

  @override
  String get permissionSettings_7281 => '权限设置';

  @override
  String currentPermissions_7421(Object permissions) {
    return '当前权限: $permissions';
  }

  @override
  String get userPermissionsTitle_7281 => '用户权限';

  @override
  String get otherPermissions_7281 => '其他权限';

  @override
  String get groupPermissions_7421 => '组权限';

  @override
  String get userPermissions_7281 => '用户权限';

  @override
  String get permissionDetails_7281 => '权限详情';

  @override
  String get groupPermissions_4821 => '组权限';

  @override
  String get saveButton_7284 => '保存';

  @override
  String get writePermission_4821 => '写入';

  @override
  String get executePermission_4821 => '执行';

  @override
  String get readPermission_4821 => '读取';

  @override
  String get readPermission_5421 => '读取';

  @override
  String get writePermission_7421 => '写入';

  @override
  String get executeAction_7421 => '执行';

  @override
  String get permissionSaved_7421 => '权限已保存';

  @override
  String savePermissionFailed(Object e) {
    return '保存权限失败: $e';
  }

  @override
  String filePermissionFailed_7285(Object e) {
    return '获取文件权限失败: $e';
  }

  @override
  String get permissionManagement_7421 => '权限管理';

  @override
  String get sleepTimer_4271 => '睡眠定时器';

  @override
  String get timerInDevelopment_7421 => '定时器功能正在开发中...';

  @override
  String get audioInfo_4271 => '音频信息';

  @override
  String get title_5421 => '标题';

  @override
  String get artistLabel_4821 => '艺术家';

  @override
  String get albumLabel_4821 => '专辑';

  @override
  String get durationLabel_4821 => '时长';

  @override
  String get sourceLabel_4821 => '源';

  @override
  String get vfsFileLabel_4822 => 'VFS文件';

  @override
  String get networkUrlLabel_4823 => '网络URL';

  @override
  String get currentPosition_4821 => '当前位置';

  @override
  String get playbackSpeed_7421 => '播放速度';

  @override
  String get volumeLabel_4821 => '音量';

  @override
  String playerInitFailed_4821(Object e) {
    return '初始化播放器失败: $e';
  }

  @override
  String checkPlayStatus(Object currentSource, Object targetSource) {
    return '🎵 检查播放状态 - 当前源: $currentSource, 目标源: $targetSource';
  }

  @override
  String get skipSameSourceAd_7285 => '🎵 插播请求与当前播放源一致，跳过插播。';

  @override
  String get connectionToPlayerComplete_7281 => '🎵 连接到现有播放器完成:';

  @override
  String currentPlaying(Object currentSource) {
    return '  - 当前播放: $currentSource';
  }

  @override
  String get playbackStatus_7421 => '播放状态';

  @override
  String playlistLength(Object length) {
    return '播放列表长度: $length';
  }

  @override
  String currentIndexLog(Object currentIndex) {
    return '  - 当前索引: $currentIndex';
  }

  @override
  String playbackProgress(Object currentPosition, Object totalDuration) {
    return '  - 播放进度: $currentPosition/$totalDuration';
  }

  @override
  String get playOurAudioPrompt_4821 => '是否播放我们的音频';

  @override
  String get isInPlaylistCheck_7425 => '是否在播放列表中';

  @override
  String playerConnectionFailed(Object e) {
    return '连接到播放器失败: $e';
  }

  @override
  String get expandPlayer_7281 => '展开播放器';

  @override
  String playerConnectionFailed_7285(Object e) {
    return '🎵 连接到播放器失败: $e';
  }

  @override
  String get audioPlayerTitle_7281 => '音频播放器';

  @override
  String get playlistTooltip_4271 => '播放列表';

  @override
  String get minimizePlayer_4821 => '最小化播放器';

  @override
  String get playlistTitle_4821 => '播放列表';

  @override
  String get playlistEmpty_7281 => '播放列表为空';

  @override
  String get remove_4821 => '移除';

  @override
  String progressBarDragFail_4821(Object e) {
    return '进度条拖拽跳转失败: $e';
  }

  @override
  String progressBarDraggedTo(Object currentPosition, Object totalDuration) {
    return '🎵 进度条拖拽到: $currentPosition / $totalDuration';
  }

  @override
  String get previousTrack_7281 => '上一首';

  @override
  String fastRewindFailed_4821(Object e) {
    return '快退操作失败: $e';
  }

  @override
  String get pauseButton_4821 => '暂停';

  @override
  String get playButton_4821 => '播放';

  @override
  String get fastForwardFailed_7285 => '快进操作失败';

  @override
  String get nextSong_7281 => '下一首';

  @override
  String get volumeControl_7281 => '音量控制';

  @override
  String get audioEqualizer_4821 => '音频均衡器';

  @override
  String get playbackSpeed_4821 => '播放速度';

  @override
  String get unmute_4721 => '取消静音';

  @override
  String get mute_5832 => '静音';

  @override
  String get addToPlaylist_4271 => '添加到播放列表';

  @override
  String get volumeControl_4821 => '音量控制';

  @override
  String get audioBalance_7281 => '音频平衡';

  @override
  String get sequentialPlayback_4271 => '顺序播放';

  @override
  String get circularList_7421 => '循环列表';

  @override
  String get singleCycleMode_4271 => '单曲循环';

  @override
  String get randomPlay_4271 => '随机播放';

  @override
  String audioPlaybackFailed(Object e) {
    return '停止音频播放失败: $e';
  }

  @override
  String audioServiceCleanupFailed(Object e) {
    return '清理音频服务失败: $e';
  }

  @override
  String playPauseFailed_4821(Object e) {
    return '播放/暂停操作失败: $e';
  }

  @override
  String playbackFailed_4821(Object e) {
    return '播放操作失败: $e';
  }

  @override
  String get audioBackgroundPlay_7281 => '🎵 窗口关闭，音频继续在后台播放';

  @override
  String get audioProcessorConvertStart_7281 =>
      '🎵 AudioProcessor.convertMarkdownAudios: 开始转换';

  @override
  String audioProcessorConvertMarkdownAudios(Object audioTag) {
    return 'AudioProcessor.convertMarkdownAudios: 生成标签 $audioTag';
  }

  @override
  String audioProcessorConvertMarkdownAudios_7428(Object src) {
    return 'AudioProcessor.convertMarkdownAudios: 转换 $src';
  }

  @override
  String get audioConversionComplete_7284 =>
      '🎵 AudioProcessor.convertMarkdownAudios: 转换完成';

  @override
  String audioNodeBuildStart_7421(Object src) {
    return '🎵 AudioNode.build: 开始构建 - src: \\$src';
  }

  @override
  String parseAttributesLog_7281(Object attributes) {
    return '解析属性 - $attributes';
  }

  @override
  String audioProcessorDebugInfo(Object result, Object textLength) {
    return '🎵 AudioProcessor.containsAudio: text长度=$textLength, 包含音频=$result';
  }

  @override
  String get audioProcessorCreated_4821 => '🎵 AudioProcessor: 创建音频生成器';

  @override
  String audioNodeGenerationLog(
    Object attributes,
    Object playerId,
    Object tag,
    Object textContent,
  ) {
    return '🎵 AudioProcessor: 生成AudioNode - tag: \\$tag, attributes: \\$attributes, textContent: \\$textContent, uuid: $playerId';
  }

  @override
  String audioPlayerError_4821(Object error) {
    return 'AudioNode: 播放器错误 - $error';
  }

  @override
  String audioPlayerInitFailed(Object e) {
    return '初始化音频播放器失败: $e';
  }

  @override
  String playPauseFailed_7285(Object e) {
    return '播放/暂停操作失败: $e';
  }

  @override
  String playbackFailed_7285(Object e) {
    return '播放失败: $e';
  }

  @override
  String get loadingAudio_7281 => '正在加载音频...';

  @override
  String rewindFailed_4821(Object error) {
    return '快退操作失败: $error';
  }

  @override
  String get rewind10Seconds_7539 => '快退10秒';

  @override
  String fastForwardFailed_4821(Object e) {
    return '快进操作失败: $e';
  }

  @override
  String get volumeLabel_8472 => '音量';

  @override
  String htmlParsingFailed_7285(Object e) {
    return 'HTML解析失败: $e';
  }

  @override
  String htmlToMarkdownFailed_4821(Object e) {
    return 'HTML转Markdown失败: $e';
  }

  @override
  String htmlParsingStart(Object content) {
    return '🔧 HtmlProcessor.parseHtml: 开始解析 - textContent: $content...';
  }

  @override
  String get htmlProcessorNoHtmlTags_4821 =>
      '🔧 HtmlProcessor.parseHtml: 不包含HTML标签，返回文本节点';

  @override
  String htmlTagProcessing(Object attributes, Object localName) {
    return '🔧 HtmlToSpanVisitor.visitElement: 处理标签 - $localName, attributes: $attributes';
  }

  @override
  String get videoTagDetected_7281 =>
      '🎥 HtmlToSpanVisitor: 发现video标签，创建VideoNode';

  @override
  String get videoNodeAddedToParent_7281 =>
      '🎥 HtmlToSpanVisitor: VideoNode已添加到父节点';

  @override
  String get htmlTagDetected_7281 =>
      '🔧 HtmlProcessor.parseHtml: 检测到HTML标签，开始解析';

  @override
  String htmlParseComplete(Object count) {
    return '🔧 HtmlProcessor.parseHtml: 解析完成，节点数量: $count';
  }

  @override
  String get imageLoadFailed_7281 => '图片加载失败';

  @override
  String htmlProcessingComplete(Object count) {
    return '🔧 HtmlProcessor.parseHtml: 转换完成，SpanNode数量: $count';
  }

  @override
  String imageLoadFailed(Object error) {
    return '图片加载失败: $error';
  }

  @override
  String latexErrorWarning(Object textContent) {
    return '⚠️ LaTeX错误: $textContent';
  }

  @override
  String playerInitFailed(Object e) {
    return '播放器初始化失败: $e';
  }

  @override
  String vfsFileInfoError_4821(Object e) {
    return '获取VFS文件信息失败: $e';
  }

  @override
  String audioLoadFailed_7421(Object e) {
    return '加载音频信息失败: $e';
  }

  @override
  String get loadingAudio_7421 => '正在加载音频...';

  @override
  String get retry_7284 => '重试';

  @override
  String get audioLoadFailed_7281 => '音频加载失败';

  @override
  String get copyLink_4821 => '复制链接';

  @override
  String copyAudioLink_4821(Object vfsPath) {
    return '复制音频链接: $vfsPath';
  }

  @override
  String get audioLinkCopiedToClipboard_4821 => '音频链接已复制到剪贴板';

  @override
  String modifiedAtTime_7281(Object time) {
    return '修改于 $time';
  }

  @override
  String get audioFile_7281 => '音频文件';

  @override
  String get failedToReadImageFile_4821 => '无法读取图片文件';

  @override
  String get zoomOutTooltip_7281 => '缩小';

  @override
  String get zoomInTooltip_4821 => '放大';

  @override
  String get fitWindowTooltip_4521 => '适应窗口';

  @override
  String get refreshButton_7421 => '刷新';

  @override
  String get loadingImage_7281 => '加载图片中...';

  @override
  String get actualSize_7421 => '实际大小';

  @override
  String get imageNotAvailable_7281 => '无法显示图片';

  @override
  String get retryButton_7281 => '重试';

  @override
  String get unsupportedOrCorruptedImage_7281 => '图片格式不支持或已损坏';

  @override
  String get fileSizeLabel_5421 => '大小';

  @override
  String get modifiedTimeLabel_5421 => '修改时间';

  @override
  String audioStatus_7421(Object status) {
    return '音频$status';
  }

  @override
  String videoStatusLabel_4829(Object status) {
    return '视频$status';
  }

  @override
  String get disabledInParentheses_4829 => '(禁用)';

  @override
  String videoCountLabel_7281(Object videoCount) {
    return '视频: $videoCount';
  }

  @override
  String audioCountLabel_7281(Object audioCount) {
    return '音频: $audioCount';
  }

  @override
  String fileSizeLabel_7281(Object size) {
    return '文件大小: $size';
  }

  @override
  String openLinkFailed_4821(Object e) {
    return '打开链接失败: $e';
  }

  @override
  String unableToOpenLink_7285(Object url) {
    return '无法打开链接: $url';
  }

  @override
  String vfsLinkOpenFailed(Object e) {
    return '打开VFS链接失败: $e';
  }

  @override
  String anchorJumpFailed_7285(Object e) {
    return '跳转到锚点失败: $e';
  }

  @override
  String jumpToDestination(Object headingText) {
    return '已跳转到: $headingText';
  }

  @override
  String anchorNotFound_7425(Object searchText) {
    return '未找到锚点: $searchText';
  }

  @override
  String anchorJumpFailed_4829(Object e) {
    return '锚点跳转失败: $e';
  }

  @override
  String openRelativePathFailed_7285(Object e) {
    return '打开相对路径链接失败: $e';
  }

  @override
  String get loadFailed_4821 => '加载失败';

  @override
  String get copiedToClipboard_4821 => '已复制到剪贴板';

  @override
  String vfsImageLoadFailed(Object e) {
    return '加载VFS图片失败: $e';
  }

  @override
  String get htmlContentInfo_7281 => 'HTML内容信息';

  @override
  String get htmlRenderingStatus_4821 => 'HTML渲染状态';

  @override
  String get disable_4821 => '禁用';

  @override
  String get enable_4821 => '启用';

  @override
  String get htmlContentStatistics_7281 => 'HTML内容统计';

  @override
  String get enabledStatus_4821 => '已启用';

  @override
  String get disabledStatus_4821 => '已禁用';

  @override
  String htmlLinkCount(Object count) {
    return 'HTML链接: $count个';
  }

  @override
  String htmlImageCount(Object count) {
    return 'HTML图片: $count个';
  }

  @override
  String get vfsMarkdownRendererCleanedTempFiles_7281 =>
      '🔗 VfsMarkdownRenderer: 已清理临时文件';

  @override
  String get supportedHtmlTags_7281 => '支持的HTML标签';

  @override
  String get tempFileCleanupFailed_4821 => '清理临时文件失败';

  @override
  String get latexRenderingStatus_4821 => 'LaTeX渲染状态';

  @override
  String get latexFormulaInfo_7281 => 'LaTeX公式信息';

  @override
  String get latexFormulaStatistics_4821 => 'LaTeX公式统计';

  @override
  String get inlineFormula_7284 => '行内公式';

  @override
  String get blockCountUnit_7281 => '个';

  @override
  String get blockFormula_4821 => '块级公式';

  @override
  String get inlineCountUnit_4821 => '个';

  @override
  String get documentWithoutLatex_4721 => '此文档不包含LaTeX公式';

  @override
  String get countUnit_7281 => '个';

  @override
  String get total_7284 => '总计';

  @override
  String get audioInfo_7284 => '音频信息';

  @override
  String audioCountLabel(Object audioCount) {
    return '音频数量: $audioCount';
  }

  @override
  String get audioList_7421 => '音频列表:';

  @override
  String remainingAudiosCount(Object count) {
    return '... 还有$count个音频';
  }

  @override
  String get documentNoAudioContent_4821 => '此文档不包含音频内容';

  @override
  String get preprocessHtmlContent_7281 => '🔧 _loadMarkdownFile: 预处理HTML内容';

  @override
  String openTextEditorFailed_7281(Object e) {
    return '打开文本编辑器失败: $e';
  }

  @override
  String get preprocessLatexContent_7281 => '🔧 _loadMarkdownFile: 预处理LaTeX内容';

  @override
  String get preprocessVideoContent_7281 => '🎥 _loadMarkdownFile: 预处理视频内容';

  @override
  String get preprocessAudioContent_7281 => '🎵 _loadMarkdownFile: 预处理音频内容';

  @override
  String get rendererAudioUuidMap_4821 => '渲染器: _audioUuidMap';

  @override
  String markdownLoadFailed_7421(Object error) {
    return '加载Markdown文件失败: $error';
  }

  @override
  String get markdownReadError_4821 => '无法读取Markdown文件';

  @override
  String get hideToc_4821 => '隐藏目录';

  @override
  String get showToc_7532 => '显示目录';

  @override
  String get autoThemeDark => '自动主题(当前深色)';

  @override
  String get autoThemeLight => '自动主题(当前浅色)';

  @override
  String get lightTheme_5421 => '浅色主题';

  @override
  String get darkTheme_7632 => '深色主题';

  @override
  String get disableHtmlRendering_4721 => '禁用HTML渲染';

  @override
  String get enableHtmlRendering_5832 => '启用HTML渲染';

  @override
  String get disableVideoRendering_4821 => '禁用视频渲染';

  @override
  String get enableVideoRendering_4822 => '启用视频渲染';

  @override
  String get disableLatexRendering_4821 => '禁用LaTeX渲染';

  @override
  String get enableLatexRendering_4822 => '启用LaTeX渲染';

  @override
  String get disableAudioRendering_4821 => '禁用音频渲染';

  @override
  String get enableAudioRendering_4821 => '启用音频渲染';

  @override
  String get resetZoomTooltip_4821 => '重置缩放';

  @override
  String get latexInfoTooltip_7281 => 'LaTeX信息';

  @override
  String get htmlInfo_7421 => 'HTML信息';

  @override
  String get videoInfo_7421 => '视频信息';

  @override
  String get audioInfo_7421 => '音频信息';

  @override
  String get copyMarkdownContent_7281 => '复制Markdown内容';

  @override
  String get openWithTextEditor_7421 => '使用文本编辑器打开';

  @override
  String get retry_4821 => '重试';

  @override
  String get catalogTitle_4821 => '目录';

  @override
  String get markdownFileEmpty_7281 => 'Markdown文件为空';

  @override
  String get buildMarkdownStart_7283 => '🔧 _buildMarkdownContent: 开始构建';

  @override
  String get videoSyntaxParserAdded_7281 =>
      '🎥 _buildMarkdownContent: 添加视频语法解析器和生成器';

  @override
  String markdownGeneratorCreation(
    Object generatorsLength,
    Object syntaxesLength,
  ) {
    return '🔧 _buildMarkdownContent: 创建MarkdownGenerator - generators: $generatorsLength, syntaxes: $syntaxesLength';
  }

  @override
  String get audioSyntaxParserAdded_7281 =>
      '🎵 _buildMarkdownContent: 添加音频语法解析器和生成器';

  @override
  String lineCountText(Object lineCount) {
    return '行数: $lineCount';
  }

  @override
  String wordCountLabel(Object wordCount) {
    return '字数: $wordCount';
  }

  @override
  String characterCount_4821(Object charCount) {
    return '字符数: $charCount';
  }

  @override
  String htmlStatusLabel_4821(Object status) {
    return 'HTML$status';
  }

  @override
  String linkCount_7281(Object linkCount) {
    return '链接: $linkCount';
  }

  @override
  String imageCountText_7281(Object imageCount) {
    return '图片: $imageCount';
  }

  @override
  String formulaWithCount_7421(Object totalCount) {
    return '公式: $totalCount';
  }

  @override
  String get latexDisabled_7421 => '(禁用)';

  @override
  String get loadingMarkdownFile_7421 => '加载Markdown文件中...';

  @override
  String fileSizeInfo_7425(Object fileSize, Object modifiedTime) {
    return '大小: $fileSize • 修改时间: $modifiedTime';
  }

  @override
  String loadTextFileFailed_7421(Object e) {
    return '加载文本文件失败: $e';
  }

  @override
  String get failedToReadTextFile_4821 => '无法读取文本文件';

  @override
  String get saveFileTooltip_4521 => '保存文件';

  @override
  String get enableEditing_5421 => '启用编辑';

  @override
  String get readOnlyMode_6732 => '只读模式';

  @override
  String get lightTheme_4821 => '浅色主题';

  @override
  String get darkTheme_5732 => '深色主题';

  @override
  String get formatJsonTooltip_7281 => '格式化JSON';

  @override
  String get refreshTooltip_7281 => '刷新';

  @override
  String get loadingTextFile_7281 => '加载文本文件中...';

  @override
  String get copyAllContent_7281 => '复制所有内容';

  @override
  String characterCount_7421(Object charCount) {
    return '字符数: $charCount';
  }

  @override
  String get retryButton_7284 => '重试';

  @override
  String get jsonFormatComplete_4821 => 'JSON格式化完成';

  @override
  String get readOnlyMode_5421 => '只读模式';

  @override
  String get editMode_5421 => '编辑模式';

  @override
  String jsonFormatFailed(Object e) {
    return 'JSON格式化失败: $e';
  }

  @override
  String get fileSavedSuccessfully_4821 => '文件保存成功';

  @override
  String fileSaveFailed(Object e) {
    return '保存文件失败: $e';
  }

  @override
  String get fileSizeLabel_7421 => '大小';

  @override
  String get modifiedTimeLabel_8532 => '修改时间';

  @override
  String videoInfoLoadFailed_7281(Object e) {
    return '加载视频信息失败: $e';
  }

  @override
  String get fullscreenMode_7281 => '全屏模式';

  @override
  String get unmute_4821 => '取消静音';

  @override
  String get mute_4821 => '静音';

  @override
  String get stopLooping_5421 => '关闭循环';

  @override
  String get startLooping_5422 => '循环播放';

  @override
  String get videoInfo_4271 => '视频信息';

  @override
  String get copyLink_1234 => '复制链接';

  @override
  String get loadingVideo_7421 => '正在加载视频...';

  @override
  String get autoPlayText_4821 => '自动播放';

  @override
  String get videoLoadFailed_4821 => '视频加载失败';

  @override
  String get retry_7281 => '重试';

  @override
  String get copyLink_4271 => '复制链接';

  @override
  String get fileName_4821 => '文件名';

  @override
  String copyVideoLink(Object vfsPath) {
    return '复制视频链接: $vfsPath';
  }

  @override
  String get videoFile_4821 => '视频文件';

  @override
  String get videoLinkCopiedToClipboard_4821 => '视频链接已复制到剪贴板';

  @override
  String modifiedAtText_7281(Object date) {
    return '修改于 $date';
  }

  @override
  String get videoFile_7421 => '视频文件';

  @override
  String get videoProcessorStartConversion_7281 =>
      '🎥 VideoProcessor.convertMarkdownVideos: 开始转换';

  @override
  String videoProcessorConvertMarkdownVideos_7425(Object src) {
    return 'VideoProcessor.convertMarkdownVideos: 转换 $src';
  }

  @override
  String generateTagMessage(Object videoTag) {
    return '生成标签 $videoTag';
  }

  @override
  String get videoConversionComplete_7281 =>
      '🎥 VideoProcessor.convertMarkdownVideos: 转换完成';

  @override
  String videoNodeBuildStart(Object src) {
    return '开始构建 - src: $src';
  }

  @override
  String videoNodeCreationLog(Object attributes, Object textContent) {
    return '🎥 VideoNode: 创建节点 - attributes: $attributes, textContent: $textContent';
  }

  @override
  String videoNodeBuildLog(Object src) {
    return '🎥 VideoNode.build: 返回WidgetSpan - MediaKitVideoPlayer(url: $src)';
  }

  @override
  String videoTagMatched(Object matchValue) {
    return '匹配到视频标签 - $matchValue';
  }

  @override
  String videoElementCreationLog(Object attributes, Object tag) {
    return '🎥 VideoSyntax.onMatch: 创建视频元素 - tag: $tag, attributes: $attributes';
  }

  @override
  String videoProcessorDebug(Object result, Object textLength) {
    return '🎥 VideoProcessor.containsVideo: text长度=$textLength, 包含视频=$result';
  }

  @override
  String get videoProcessorCreated_4821 => '🎥 VideoProcessor: 创建视频生成器';

  @override
  String videoNodeGenerationLog(
    Object attributes,
    Object tag,
    Object textContent,
  ) {
    return '🎥 VideoProcessor: 生成VideoNode - tag: $tag, attributes: $attributes, textContent: $textContent';
  }

  @override
  String get readOnlyMode_7421 => '只读模式';

  @override
  String get readOnlyMode_4821 => '只读模式';

  @override
  String webReadOnlyModeWithOperation_7421(Object operation) {
    return 'Web版本为只读模式，无法执行\"$operation\"操作。\n\n如需编辑功能，请使用桌面版本。';
  }

  @override
  String get learnMore_7421 => '了解';

  @override
  String updateNoteFailed(Object e) {
    return '更新便签失败: $e';
  }

  @override
  String updateNoteFailed_7284(Object e) {
    return '更新便签失败: $e';
  }

  @override
  String deleteNoteFailed_7281(Object e) {
    return '删除便签失败: $e';
  }

  @override
  String deleteNoteFailed(Object e) {
    return '删除便签失败: $e';
  }

  @override
  String reorderNotesFailed(Object e) {
    return '重新排序便签失败: $e';
  }

  @override
  String dragToReorderFailed_7285(Object e) {
    return '通过拖拽重新排序便签失败: $e';
  }

  @override
  String get timerIdExistsError_4821 => '计时器ID已存在';

  @override
  String reorderNotesFailed_4821(Object e) {
    return '重新排序便签失败: $e';
  }

  @override
  String timerCreated(Object id) {
    return '计时器已创建: $id';
  }

  @override
  String timerCreationFailed(Object e) {
    return '创建计时器失败: $e';
  }

  @override
  String timerUpdateFailed_7284(Object e) {
    return '计时器时间更新失败: $e';
  }

  @override
  String timerUpdateFailed(Object e) {
    return '更新计时器失败: $e';
  }

  @override
  String timerDeleted(Object timerId) {
    return '计时器已删除: $timerId';
  }

  @override
  String get mapNotFound_7281 => '地图不存在';

  @override
  String deleteTimerFailed_7281(Object e) {
    return '删除计时器失败: $e';
  }

  @override
  String deleteTimerFailed(Object e) {
    return '删除计时器失败: $e';
  }

  @override
  String get timerNotExist_7281 => '计时器不存在';

  @override
  String get timerCannotStartInCurrentState_4287 => '计时器当前状态无法启动';

  @override
  String timerStartFailed_7285(Object e) {
    return '启动计时器失败: $e';
  }

  @override
  String timerStartFailed(Object e) {
    return '启动计时器失败: $e';
  }

  @override
  String get timerNotExist_7283 => '计时器不存在';

  @override
  String timerPauseFailed_7285(Object e) {
    return '暂停计时器失败: $e';
  }

  @override
  String get timerCannotPauseCurrentState_7281 => '计时器当前状态无法暂停';

  @override
  String pauseTimerFailed(Object e) {
    return '暂停计时器失败: $e';
  }

  @override
  String get timerNotExist_7284 => '计时器不存在';

  @override
  String get timerCannotStopCurrentState_4821 => '计时器当前状态无法停止';

  @override
  String timerStopFailed_4821(Object e) {
    return '停止计时器失败: $e';
  }

  @override
  String stopTimerFailed(Object e) {
    return '停止计时器失败: $e';
  }

  @override
  String resetTimerFailed(Object error) {
    return '重置计时器失败: $error';
  }

  @override
  String batchUpdateTimerFailed(Object e) {
    return '批量更新计时器失败: $e';
  }

  @override
  String get allTimersCleared_4821 => '所有计时器已清空';

  @override
  String clearTimerFailed_4821(Object e) {
    return '清空计时器失败: $e';
  }

  @override
  String batchUpdateTimerFailed_7285(Object e) {
    return '批量更新计时器失败: $e';
  }

  @override
  String clearTimerFailed(Object e) {
    return '清空计时器失败: $e';
  }

  @override
  String mapDataLoadFailed_7421(Object error) {
    return '加载地图数据失败: $error';
  }

  @override
  String mapDataInitializationFailed_7421(Object error) {
    return '初始化地图数据失败: $error';
  }

  @override
  String addNoteFailed_7285(Object e) {
    return '添加便签失败: $e';
  }

  @override
  String mapDataSaveFailed_7421(Object error) {
    return '保存地图数据失败: $error';
  }

  @override
  String dataChangeListenerFailed_4821(Object e) {
    return '数据变更监听器执行失败: $e';
  }

  @override
  String addNoteFailed(Object e) {
    return '添加便签失败: $e';
  }

  @override
  String reorderLayerLog(Object newIndex, Object oldIndex) {
    return '重排序图层: oldIndex=$oldIndex, newIndex=$newIndex';
  }

  @override
  String groupLayerReorderLog(Object length, Object newIndex, Object oldIndex) {
    return '组内重排序图层: $oldIndex -> $newIndex，更新图层数量: $length';
  }

  @override
  String setLayerVisibility(Object isVisible, Object layerId) {
    return '设置图层可见性: $layerId = $isVisible';
  }

  @override
  String updateDrawingElement_7281(Object elementId, Object layerId) {
    return '更新绘制元素: $layerId/$elementId';
  }

  @override
  String setLayerOpacity(Object layerId, Object opacity) {
    return '设置图层透明度: $layerId = $opacity';
  }

  @override
  String addDrawingElement(Object elementId, Object layerId) {
    return '添加绘制元素: $layerId/$elementId';
  }

  @override
  String deleteDrawingElement(Object elementId, Object layerId) {
    return '删除绘制元素: $layerId/$elementId';
  }

  @override
  String integrationAdapterAddLegendGroup(Object name) {
    return '集成适配器: 添加图例组 $name';
  }

  @override
  String batchUpdateElements(Object count, Object layerId) {
    return '批量更新绘制元素: $layerId, 数量: $count';
  }

  @override
  String updateLegendGroup_7421(Object name) {
    return '集成适配器: 更新图例组 $name';
  }

  @override
  String integrationAdapterDeleteLegendGroup(Object legendGroupId) {
    return '集成适配器: 删除图例组 $legendGroupId';
  }

  @override
  String legendGroupVisibility(Object isVisible) {
    return '图例组可见性: $isVisible';
  }

  @override
  String addNoteDebug_7421(Object id) {
    return '添加便利贴: $id';
  }

  @override
  String updateNoteDebug(Object id) {
    return '更新便利贴: $id';
  }

  @override
  String deleteNoteDebug(Object noteId) {
    return '删除便利贴: $noteId';
  }

  @override
  String reorderStickyNote(Object newIndex, Object oldIndex) {
    return '重新排序便利贴: $oldIndex -> $newIndex';
  }

  @override
  String reorderStickyNotesCount(Object count) {
    return '通过拖拽重新排序便利贴，数量: $count';
  }

  @override
  String get undoOperation_7281 => '执行撤销操作';

  @override
  String get redoOperation_7421 => '执行重做操作';

  @override
  String saveMapDataWithForceUpdate(Object forceUpdate) {
    return '保存地图数据，强制更新: $forceUpdate';
  }

  @override
  String get resetScriptEngine_7281 => '重置脚本引擎';

  @override
  String get resetMapData_7421 => '重置地图数据';

  @override
  String updateMetadata_4829(Object metadata) {
    return '更新元数据: $metadata';
  }

  @override
  String get releaseMapEditorAdapter_4821 => '释放地图编辑器集成适配器资源';

  @override
  String mapInitialization(Object title) {
    return '初始化地图: $title';
  }

  @override
  String loadingMapDetails(Object folderPath, Object mapTitle, Object version) {
    return '加载地图: $mapTitle, 版本: $version, 文件夹: $folderPath';
  }

  @override
  String batchUpdateLayersCount(Object count) {
    return '批量更新图层，数量: $count';
  }

  @override
  String updateLayerLog_7421(Object name) {
    return '更新图层: $name';
  }

  @override
  String addLayerLog(Object name) {
    return '添加图层: $name';
  }

  @override
  String deleteLayer_7425(Object layerId) {
    return '删除图层: $layerId';
  }

  @override
  String get updateLayerReactiveCall_7281 => '=== updateLayerReactive 调用 ===';

  @override
  String get releaseMapEditorResources_7281 => '释放地图编辑器响应式系统资源';

  @override
  String updateLayerDebug(Object id, Object name) {
    return '更新图层: $name, ID: $id';
  }

  @override
  String updateLayerLog(Object isLinkedToNext, Object name) {
    return '执行更新图层: $name, isLinkedToNext: $isLinkedToNext';
  }

  @override
  String get throttleLayerUpdate_7281 => '=== 节流执行图层更新 ===';

  @override
  String get updateLayerReactiveComplete_7281 =>
      '=== updateLayerReactive 完成 ===';

  @override
  String get reorderLayersCall_7284 => '=== reorderLayersReactive 调用 ===';

  @override
  String get reorderLayersInGroupReactiveCall_7281 =>
      '=== reorderLayersInGroupReactive 调用 ===';

  @override
  String get reorderLayersComplete_7281 =>
      '=== reorderLayersInGroupReactive 完成 ===';

  @override
  String layerReorderDebug_7281(
    Object length,
    Object newIndex,
    Object oldIndex,
  ) {
    return '组内重排序图层: oldIndex=$oldIndex, newIndex=$newIndex, 更新图层数量: $length';
  }

  @override
  String get saveMapDataStart_7281 => '=== saveMapDataReactive 开始 ===';

  @override
  String forceUpdateMessage_7285(Object forceUpdate) {
    return '强制更新: $forceUpdate';
  }

  @override
  String get forceExecutePendingTasks_7281 => '强制执行所有待处理的节流任务...';

  @override
  String get saveMapDataComplete_7281 => '=== saveMapDataReactive 完成 ===';

  @override
  String forceExecuteThrottleTasks(Object activeCount) {
    return '强制执行$activeCount个待处理的节流任务';
  }

  @override
  String get initMapEditorSystem_7281 => '初始化地图编辑器响应式系统';

  @override
  String get responsiveSystemInitialized_7421 => '响应式系统初始化完成';

  @override
  String loadingMapToReactiveSystem(Object title) {
    return '加载地图到响应式系统: $title';
  }

  @override
  String stopScript_7285(Object scriptId) {
    return '停止脚本: $scriptId';
  }

  @override
  String get clearScriptEngineDataAccessor_7281 => '清空脚本引擎数据访问器';

  @override
  String scriptEngineDataUpdater(
    Object layersCount,
    Object notesCount,
    Object groupsCount,
  ) {
    return '更新脚本引擎数据访问器，图层数量: $layersCount，便签数量: $notesCount，图例组数量: $groupsCount';
  }

  @override
  String setVfsAccessorWithMapTitle(Object mapTitle) {
    return '设置VFS访问器，地图标题: $mapTitle';
  }

  @override
  String scriptError_7284(Object error) {
    return '脚本错误: $error';
  }

  @override
  String get scriptExecutionResult_7421 => '脚本执行结果';

  @override
  String get success_7422 => '成功';

  @override
  String get failure_7423 => '失败';

  @override
  String scriptExecutionError_7284(Object e) {
    return '脚本执行异常: $e';
  }

  @override
  String maxConcurrentScriptsReached(Object maxExecutors) {
    return '达到最大并发脚本数限制 ($maxExecutors)';
  }

  @override
  String scriptExecutorCreation_7281(Object poolSize, Object scriptId) {
    return '为脚本 $scriptId 创建新的执行器和函数处理器 (当前池大小: $poolSize)';
  }

  @override
  String initializingScriptEngine(Object maxConcurrentExecutors) {
    return '初始化新响应式脚本引擎 (支持 $maxConcurrentExecutors 个并发脚本)';
  }

  @override
  String get clearAllScriptLogs_7281 => '清空所有脚本执行日志';

  @override
  String get externalFunctionsRegisteredToIsolateExecutor_7281 =>
      '已注册所有外部函数到Isolate执行器';

  @override
  String scriptExecutorCleanup_7421(Object scriptId) {
    return '清理脚本执行器: $scriptId';
  }

  @override
  String cleanScriptHandler_7421(Object scriptId) {
    return '清理脚本函数处理器: $scriptId';
  }

  @override
  String get releaseScriptEngineResources_4821 => '释放新响应式脚本引擎资源';

  @override
  String mapScriptsLoaded(Object mapTitle, Object scriptCount) {
    return '为地图 $mapTitle 加载了 $scriptCount 个脚本';
  }

  @override
  String parseParamFailed(Object e, Object line) {
    return '解析参数定义失败: $line, 错误: $e';
  }

  @override
  String get scriptEngineResetDone_7281 => '脚本引擎重置完成';

  @override
  String get resetReactiveScriptEngine_4821 => '重置新响应式脚本引擎';

  @override
  String scriptEngineResetFailed_7285(Object e) {
    return '脚本引擎重置失败: $e';
  }

  @override
  String initReactiveScriptManager(Object mapTitle) {
    return '初始化新响应式脚本管理器，地图标题: $mapTitle';
  }

  @override
  String get releaseResourceManager_4821 => '释放新响应式脚本管理器资源';

  @override
  String mapQueryResult_7281(Object result) {
    return '地图数据查询结果: $result';
  }

  @override
  String mapScriptFailed_7285(Object e) {
    return '地图数据脚本执行失败: $e';
  }

  @override
  String get example3ConcurrentScriptExecution_7281 => '=== 示例3：并发脚本执行 ===';

  @override
  String get allScriptsCompleted_7281 => '所有并发脚本执行完成';

  @override
  String concurrentExecutionFailed_7285(Object e) {
    return '并发执行失败: $e';
  }

  @override
  String scriptStatusUpdate_7281(Object length) {
    return '脚本状态更新: 共$length个脚本';
  }

  @override
  String get example4ScriptStatusMonitoring_7281 => '=== 示例4：脚本状态监听 ===';

  @override
  String get example5ScriptErrorHandling_7891 => '=== 示例5：脚本错误处理 ===';

  @override
  String concurrentScriptName_4821(Object i) {
    return '并发脚本 $i';
  }

  @override
  String concurrentScriptDescription_7539(Object i) {
    return '第$i个并发执行的脚本';
  }

  @override
  String scriptStartExecution_1642(Object i) {
    return '脚本 $i 开始执行';
  }

  @override
  String get simulateAsyncWorkComment_2957 => '模拟一些异步工作';

  @override
  String scriptStep_6183(Object i, Object step) {
    return '脚本 $i - 步骤 $step';
  }

  @override
  String get delayImplementationComment_8476 => '这里在实际实现中会有延迟';

  @override
  String scriptCompleteExecution_1265(Object i) {
    return '脚本 $i 执行完成';
  }

  @override
  String get scriptSystemInitialized_7281 => '新脚本系统示例初始化完成';

  @override
  String get unexpectedSuccess_7281 => '意外：错误脚本执行成功了';

  @override
  String get errorTestScriptName_4821 => '错误测试脚本';

  @override
  String get errorTestScriptDesc_4821 => '故意产生错误的脚本';

  @override
  String get scriptStartLog_4821 => '开始错误测试脚本';

  @override
  String get scriptComment_4821 => '故意调用不存在的函数';

  @override
  String get scriptUnreachableLog_4821 => '这行不会被执行';

  @override
  String get scriptReturnValue_4821 => 'Should not reach here';

  @override
  String expectedError_7421(Object error) {
    return '预期的错误: $error';
  }

  @override
  String get errorHandlingWorking_7421 => '错误处理工作正常';

  @override
  String errorHandlingExampleFailed_7285(Object e) {
    return '错误处理示例执行失败: $e';
  }

  @override
  String get scriptSystemExampleStart_7281 => '🚀 开始运行新脚本系统示例...';

  @override
  String get allExamplesCompleted_7281 => '✅ 所有示例执行完成！';

  @override
  String exampleFailed_7285(Object e) {
    return '❌ 示例执行失败: $e';
  }

  @override
  String get scriptSystemExampleCleaned_4821 => '新脚本系统示例已清理';

  @override
  String get exampleLogScript_7281 => '=== 示例1：简单日志脚本 ===';

  @override
  String systemStatus_7281(Object status) {
    return '系统状态: $status';
  }

  @override
  String get exampleLogScriptName_4821 => '示例日志脚本';

  @override
  String get exampleLogScriptDescription_7539 => '一个简单的日志输出脚本';

  @override
  String get success_8423 => '成功';

  @override
  String get failure_9356 => '失败';

  @override
  String returnValue_7421(Object result) {
    return '返回值: $result';
  }

  @override
  String scriptAdded_7281(Object name) {
    return '脚本已添加: $name';
  }

  @override
  String executionTimeWithMs(Object executionTime) {
    return '执行时间: ${executionTime}ms';
  }

  @override
  String errorWithDetails(Object error) {
    return '错误: $error';
  }

  @override
  String executionLogsWithCount(Object count) {
    return '执行日志 ($count 条):';
  }

  @override
  String scriptExecutionFailed_7421(Object error, Object executionId) {
    return '脚本执行失败，任务ID $executionId: $error';
  }

  @override
  String get example2MapDataQueryScript_4821 => '=== 示例2：地图数据查询脚本 ===';

  @override
  String get mapDataQueryScript_4821 => '地图数据查询脚本';

  @override
  String get queryMapLayerInfo_5739 => '查询当前地图的图层和元素信息';

  @override
  String get newAsyncScriptEngine_4821 => '新异步脚本执行引擎';

  @override
  String get selectOrCreateScript_4821 => '选择左侧脚本进行编辑，或创建新脚本开始使用';

  @override
  String get createScript_4271 => '创建脚本';

  @override
  String get systemInfo_4821 => '系统信息';

  @override
  String get systemTest_4271 => '系统测试';

  @override
  String get asyncExecution_4521 => '异步执行';

  @override
  String get isolatedEnvironment_4522 => '脚本在隔离环境运行，不阻塞UI';

  @override
  String get securitySandboxTitle_4821 => '安全沙盒';

  @override
  String get securitySandboxDescription_4822 => '脚本错误不会影响主程序';

  @override
  String get crossPlatform_4821 => '跨平台';

  @override
  String get dualEngine_4821 => 'Web Worker + Isolate 双引擎';

  @override
  String get highPerformanceTitle_4821 => '高性能';

  @override
  String get highPerformanceDesc_4822 => '消息传递机制，响应迅速';

  @override
  String get createScriptPending_4821 => '创建新脚本功能待实现';

  @override
  String get newScriptSystemInfo_4821 => '新脚本系统信息';

  @override
  String get asyncScriptEngineTitle_7281 => '新异步脚本引擎 | 消息传递机制';

  @override
  String get scriptCount_4821 => '脚本数量';

  @override
  String get enableScript_4821 => '启用脚本';

  @override
  String get executionEngine_7421 => '执行引擎';

  @override
  String get webWorker_8423 => 'Web Worker (浏览器)';

  @override
  String get dartIsolate_9352 => 'Dart Isolate (桌面)';

  @override
  String get runningScriptsTitle_4821 => '运行中脚本';

  @override
  String get mapData_4821 => '地图数据';

  @override
  String get connected_4821 => '已连接';

  @override
  String get disconnected_4821 => '已断开';

  @override
  String get architectureFeatures_4821 => '架构特性';

  @override
  String get asyncIsolateMessagePassing_4821 => '异步隔离执行 + 消息传递';

  @override
  String get securityTitle_5421 => '安全性';

  @override
  String get sandboxEnvironment_5421 => '沙盒环境 + 受控API';

  @override
  String get scriptManagerDescription_4821 =>
      '新的脚本管理器采用现代化的异步架构，确保脚本执行不会阻塞用户界面，同时提供更好的安全性和性能。';

  @override
  String get systemTestFeaturePending_7281 => '系统测试功能待实现';

  @override
  String get systemInfo_7421 => '系统信息';

  @override
  String get newScriptSystemDemo_4271 => '新脚本系统演示';

  @override
  String get hideStatusMonitor_5421 => '隐藏状态监控';

  @override
  String get showStatusMonitor_5421 => '显示状态监控';

  @override
  String get unsavedChanges_7421 => '有未保存的更改';

  @override
  String lastModifiedLabel(Object lastModified) {
    return '最后修改: $lastModified';
  }

  @override
  String get switchToVersion_4821 => '切换到此版本';

  @override
  String get deleteVersionTooltip_7281 => '删除版本';

  @override
  String get createNewVersionTooltip_7421 => '创建新版本';

  @override
  String get switchingVersion_4821 => '正在切换版本...';

  @override
  String versionSwitched(Object versionId) {
    return '已切换到版本: $versionId';
  }

  @override
  String switchToVersion_7281(Object versionId) {
    return '切换到版本: $versionId';
  }

  @override
  String versionSwitchFailed_7421(Object error) {
    return '切换版本失败: $error';
  }

  @override
  String versionSwitchFailed_7285(Object e) {
    return '切换版本失败: $e';
  }

  @override
  String get createNewVersion_4271 => '创建新版本';

  @override
  String get versionNameLabel_4821 => '版本名称';

  @override
  String get versionNameHint_4822 => '输入版本名称';

  @override
  String get createButton_7421 => '创建';

  @override
  String get creatingVersion_4821 => '正在创建版本...';

  @override
  String versionCreationSuccess_7281(Object versionName) {
    return '创建版本成功: $versionName';
  }

  @override
  String versionCreatedSuccessfully(Object versionId) {
    return '创建版本成功: $versionId';
  }

  @override
  String versionCreationFailed_7421(Object error, Object versionId) {
    return '创建新版本失败 [$versionId]: $error';
  }

  @override
  String get confirmDelete_7281 => '确认删除';

  @override
  String confirmDeleteVersion(Object versionId) {
    return '确定要删除版本 \"$versionId\" 吗？此操作不可撤销。';
  }

  @override
  String get deletingVersion_4821 => '正在删除版本...';

  @override
  String versionDeletedSuccessfully(Object versionId) {
    return '删除版本成功: $versionId';
  }

  @override
  String deleteVersionFailed(Object error) {
    return '删除版本失败: $error';
  }

  @override
  String versionDeletionFailed(Object e) {
    return '删除版本失败: $e';
  }

  @override
  String get savingStatus_4821 => '正在保存...';

  @override
  String get saveSuccess_4821 => '保存成功';

  @override
  String get saveVersionSuccess_4821 => '保存当前版本成功';

  @override
  String saveFailedMessage(Object e) {
    return '保存失败: $e';
  }

  @override
  String get debugInfo_4271 => '调试信息';

  @override
  String saveFailed_7285(Object e) {
    return '保存失败: $e';
  }

  @override
  String get defaultVersionName_7281 => '默认版本';

  @override
  String get versionManagementInitialized_4821 => '版本管理系统初始化完成';

  @override
  String get responsiveVersionSystemInitialized_7281 => '响应式版本管理系统初始化完成';

  @override
  String initializationFailed_7421(Object e) {
    return '初始化失败: $e';
  }

  @override
  String get responsiveVersionManagementExample_4821 => '响应式版本管理示例';

  @override
  String get saveCurrentVersion_7421 => '保存当前版本';

  @override
  String get debugInfo_7421 => '调试信息';

  @override
  String get statusMessage_4821 => '状态: \$_statusMessage';

  @override
  String currentVersionLabel(Object currentVersionId) {
    return '当前版本: $currentVersionId';
  }

  @override
  String unsavedChangesStatus(Object status) {
    return '未保存更改: $status';
  }

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get confirmAction_7281 => '确认操作';

  @override
  String mapDeletionFailed_7421(Object e, Object mapTitle) {
    return '删除地图失败 [$mapTitle]: $e';
  }

  @override
  String mapDeletedSuccessfully_7281(Object title) {
    return '成功删除地图 \"$title\"';
  }

  @override
  String get exportingMapData_4821 => '正在导出地图数据...';

  @override
  String exportSuccessMessage(Object exportPath) {
    return '成功导出地图数据到: $exportPath';
  }

  @override
  String get exportCancelledMessage => '导出操作被取消';

  @override
  String exportMapDataFailed(Object e) {
    return '导出地图数据失败: $e';
  }

  @override
  String vfsMapExampleTitle(Object storageMode) {
    return 'VFS地图存储示例$storageMode';
  }

  @override
  String get vfsMode => ' (VFS模式)';

  @override
  String get traditionalMode => ' (传统模式)';

  @override
  String get exportButton_7281 => '导出';

  @override
  String get statusMessage_7284 => '状态: \$_statusMessage';

  @override
  String storageMode_7421(Object mode) {
    return '存储模式: $mode';
  }

  @override
  String get vfsStorage_1589 => 'VFS虚拟文件系统';

  @override
  String get sqliteStorage_2634 => '传统SQLite数据库';

  @override
  String get noMapData_7281 => '暂无地图数据';

  @override
  String versionWithNumber(Object version) {
    return '版本: $version';
  }

  @override
  String layerAndLegendGroupCount(Object layers, Object legendGroups) {
    return '图层: $layers | 图例组: $legendGroups';
  }

  @override
  String creationTimeLabel_4821(Object dateTime) {
    return '创建时间: $dateTime';
  }

  @override
  String get deleteButton_7421 => '删除';

  @override
  String viewMapWithTitle(Object title) {
    return '查看地图: $title';
  }

  @override
  String get createSampleMapTooltip_4521 => '创建示例地图';

  @override
  String get loadingMap_7421 => '正在加载地图...';

  @override
  String mapsLoadedSuccessfully(Object count) {
    return '成功加载 $count 个地图';
  }

  @override
  String mapLoadingFailed_7281(Object e) {
    return '加载地图失败: $e';
  }

  @override
  String get creatingSampleMap_4821 => '正在创建示例地图...';

  @override
  String mapCreationSuccess_7421(Object mapId) {
    return '成功创建示例地图 (ID: $mapId)';
  }

  @override
  String vfsSampleMapTitle(Object timestamp) {
    return 'VFS示例地图 $timestamp';
  }

  @override
  String createMapFailed_7421(Object e) {
    return '创建示例地图失败: $e';
  }

  @override
  String get deletingMap_7421 => '正在删除地图...';

  @override
  String get aboutPageTitle_4821 => '关于';

  @override
  String get configEditorDisplayName_4821 => '配置编辑器';

  @override
  String get externalResourcesManagement_4821 => '外部资源管理';

  @override
  String get fullscreenTest_4821 => '全屏测试';

  @override
  String get homePageTitle_4821 => '首页';

  @override
  String get legendManagement_4821 => '图例管理';

  @override
  String get mapAtlas_4821 => '地图册';

  @override
  String get markdownRendererDemo_4821 => 'Markdown 渲染器组件演示';

  @override
  String get notificationTestPageTitle_4821 => '通知测试';

  @override
  String get radialGestureDemoTitle_4721 => '径向手势菜单演示';

  @override
  String get settingsDisplayName_4821 => '设置';

  @override
  String get svgTestPageTitle_4821 => 'SVG 测试';

  @override
  String get userPreferences_4821 => '用户偏好设置';

  @override
  String get vfsFileManager_4821 => 'VFS文件管理器';

  @override
  String get webDavManagement_4821 => 'WebDAV 管理';

  @override
  String get webSocketConnectionManager_4821 => 'WebSocket 连接管理';

  @override
  String get webContextMenuDemoTitle_4721 => 'Web右键菜单演示';

  @override
  String vfsInitFailed_7281(Object e) {
    return 'VFS系统初始化失败: $e';
  }

  @override
  String get vfsInitializationSuccess_7281 => 'VFS系统初始化成功';

  @override
  String parseNoteDataFailed_7284(Object e) {
    return '解析便签数据失败: $e';
  }

  @override
  String layerDataParseFailed_7421(Object e) {
    return '解析图层数据失败: $e';
  }

  @override
  String legendDataParseFailed_7285(Object e) {
    return '解析图例组数据失败: $e';
  }

  @override
  String get defaultVersionName_4721 => '默认版本';

  @override
  String get countdownMode_4821 => '倒计时';

  @override
  String get stopwatchMode_7532 => '正计时';

  @override
  String get countdownDescription_4821 => '从设定时间倒数到零';

  @override
  String get stopwatchDescription_7532 => '从零开始正向计时';

  @override
  String get timerStopped_4821 => '已停止';

  @override
  String get timerRunning_4822 => '运行中';

  @override
  String get timerPaused_4823 => '已暂停';

  @override
  String get timerCompleted_4824 => '已完成';

  @override
  String get defaultUser_4821 => '用户';

  @override
  String get noteTag_7890 => '备注';

  @override
  String get openSourceAcknowledgement_7281 => '开源项目致谢';

  @override
  String get feedbackTitle_4271 => '问题反馈';

  @override
  String get reportBugOrFeatureSuggestion_7281 => '报告 Bug 或提出功能建议';

  @override
  String get viewFullLicenseList_7281 => '查看完整许可证列表';

  @override
  String get openSourceProjectsIntro_4821 => '本项目使用了以下优秀的开源项目和资源：';

  @override
  String get dependencyDescription_4821 =>
      '此外，本项目还依赖众多 Flutter 生态系统中的优秀开源包，点击下方按钮查看完整的依赖项列表和许可证信息。';

  @override
  String get licenseCopiedToClipboard_4821 => '许可证文本已复制到剪贴板';

  @override
  String get r6OperatorsAssetsDescription_4821 => '彩虹六号干员头像和图标资源';

  @override
  String get r6OperatorsAssetsSubtitle_7539 =>
      'marcopixel/r6operators 仓库提供的干员素材';

  @override
  String get copyText_4821 => '复制';

  @override
  String get licenseLegalese_7281 => '© 2024 R6BOX Team\n使用 GPL v3 许可证发布';

  @override
  String get demoModeTitle_7281 => '嵌入模式演示';

  @override
  String get customLayoutExample_4821 => '自定义布局示例';

  @override
  String get markdownRendererDemo_7421 => 'Markdown 渲染器演示';

  @override
  String get documentNavigation_7281 => '文档导航';

  @override
  String get historyRecord_4271 => '历史记录';

  @override
  String get bookmark_7281 => '书签';

  @override
  String get customLayoutDescription_4521 =>
      '这是一个自定义布局，\nMarkdown 渲染器被嵌入\n到右侧面板中。';

  @override
  String get supportedModesDescription_4821 => '现在支持三种不同的使用模式：';

  @override
  String get windowModeTitle_4821 => '1. 窗口模式';

  @override
  String get windowModeDescription_4821 => '在浮动窗口中显示 Markdown，适合快速预览';

  @override
  String get embeddedModeTitle_4821 => '3. 嵌入模式';

  @override
  String get embeddedModeDescription_4821 => '纯渲染组件，可嵌入任何布局';

  @override
  String get pageModeTitle_4821 => '2. 页面模式';

  @override
  String get pageModeDescription_4821 => '全屏页面显示 Markdown，适合深度阅读';

  @override
  String get webSocketDemoTitle_4271 => 'WebSocket 客户端演示';

  @override
  String get websocketManagerInitializedSuccess_4821 => 'WebSocket 客户端管理器初始化成功';

  @override
  String get connectionStatus_4821 => '连接状态';

  @override
  String activeClientDisplay(Object displayName) {
    return '活跃客户端: $displayName';
  }

  @override
  String clientIdLabel(Object clientId) {
    return '客户端ID: $clientId';
  }

  @override
  String get clientManagement_7281 => '客户端管理';

  @override
  String get connecting_5723 => '连接中';

  @override
  String get authenticating_6934 => '认证中';

  @override
  String get reconnecting_7845 => '重连中';

  @override
  String get error_8956 => '错误';

  @override
  String get disconnected_9067 => '未连接';

  @override
  String serverInfo_4827(Object host, Object port) {
    return '服务器: $host:$port';
  }

  @override
  String configValidationResult(Object result) {
    return '配置验证结果: $result';
  }

  @override
  String get valid_4821 => '有效';

  @override
  String get invalid_5739 => '无效';

  @override
  String errorMessage(Object error) {
    return '错误: $error';
  }

  @override
  String receivedMessage(Object data, Object type) {
    return '收到: $type - $data';
  }

  @override
  String get simpleRightClickMenu_7281 => '简单右键菜单';

  @override
  String get createNewProject_7281 => '新建项目';

  @override
  String get open_7281 => '打开';

  @override
  String get openFile_7282 => '打开文件';

  @override
  String get copy_4821 => '复制';

  @override
  String get copiedMessage_7532 => '已复制';

  @override
  String get pastedMessage_4821 => '已粘贴';

  @override
  String get properties_4821 => '属性';

  @override
  String get showProperties_4821 => '显示属性';

  @override
  String get rightClickHere_7281 => '右键点击这里';

  @override
  String get listItemContextMenu_4821 => '列表项右键菜单';

  @override
  String get tryRightClickMenu_4821 => '试试看右键菜单功能';

  @override
  String viewItemDetails_7421(Object item) {
    return '查看 $item 详情';
  }

  @override
  String get editLabel_5421 => '编辑';

  @override
  String editItemMessage_5421(Object item) {
    return '编辑 $item';
  }

  @override
  String get rename_7421 => '重命名';

  @override
  String moveItem_7421(Object item) {
    return '移动 $item';
  }

  @override
  String get delete_7281 => '删除';

  @override
  String get projectCopied_4821 => '已复制项目';

  @override
  String rightClickOptionsWithMode_7421(Object mode) {
    return '右键查看选项 - $mode';
  }

  @override
  String get webMode_1589 => 'Web模式';

  @override
  String get desktopMode_2634 => '桌面模式';

  @override
  String get copySuffix_7281 => '(副本)';

  @override
  String confirmDeleteItem_7421(Object item) {
    return '确定要删除\"$item\"吗？';
  }

  @override
  String projectItem(Object index) {
    return '项目 $index';
  }

  @override
  String get projectDeleted_7281 => '已删除项目';

  @override
  String get newNameLabel_4521 => '新名称';

  @override
  String get renamedSuccessfully_7281 => '已重命名';

  @override
  String get webRightClickDemo_4821 => 'Web右键菜单演示';

  @override
  String currentPlatform_4821(Object platform) {
    return '当前平台: $platform';
  }

  @override
  String get webBrowser_5732 => 'Web浏览器';

  @override
  String get desktopMobile_6943 => '桌面/移动设备';

  @override
  String get webPlatformFeatures_4821 => '在Web平台上：';

  @override
  String get browserContextMenuDisabled_4821 => '• 浏览器默认的右键菜单已被禁用';

  @override
  String get flutterCustomContextMenu_4821 => '• 使用Flutter自定义的右键菜单';

  @override
  String get consistentDesktopExperience_4821 => '• 与桌面平台保持一致的交互体验';

  @override
  String get desktopMobilePlatforms_4821 => '在桌面/移动平台上：';

  @override
  String get nativeContextMenuStyle_4821 => '• 使用系统原生的右键菜单样式';

  @override
  String get nativeInteractionExperience_4821 => '• 保持平台原生的交互体验';

  @override
  String get externalResourceManagement_7421 => '外部资源管理';

  @override
  String importPreviewWithCount(Object totalFiles) {
    return '导入预览 (共 $totalFiles 个项目)';
  }

  @override
  String metadataFormatError_7281(Object e) {
    return '元数据文件格式错误：$e';
  }

  @override
  String get validatingMetadataFile_4821 => '正在验证元数据文件...';

  @override
  String get metadataJsonNotFoundInZipRoot_7281 =>
      'ZIP文件根目录中未找到metadata.json文件';

  @override
  String get preparingFileMappingPreview_4821 => '正在准备文件映射预览...';

  @override
  String cleanupTempFilesFailed(Object cleanupError) {
    return '清理临时文件失败：$cleanupError';
  }

  @override
  String get missingMetadataFields_4821 => '元数据中未指定target_path或file_mappings';

  @override
  String get processing_5421 => '处理中...';

  @override
  String startCleaningTempFolder_4821(Object fullTempPath) {
    return '🗑️ 开始清理临时文件夹: $fullTempPath';
  }

  @override
  String tempFolderNotExist(Object fullTempPath) {
    return '🗑️ 临时文件夹不存在，无需清理: $fullTempPath';
  }

  @override
  String tempFolderCleanedSuccessfully(Object fullTempPath) {
    return '🗑️ 临时文件夹清理成功: $fullTempPath';
  }

  @override
  String tempFolderCleanupFailed(Object fullTempPath) {
    return '🗑️ 临时文件夹清理失败: $fullTempPath';
  }

  @override
  String get testResourcePackageName_4821 => '测试资源包';

  @override
  String get testResourcePackageDescription_4822 => '用于测试外部资源上传功能的示例资源包';

  @override
  String get testUser_4823 => '测试用户';

  @override
  String get testTag_4824 => '测试';

  @override
  String get exampleTag_4825 => '示例';

  @override
  String get resourcePackageTag_4826 => '资源包';

  @override
  String cleanTempFilesFailed_4821(Object e) {
    return '🗑️ 清理临时文件失败：$e';
  }

  @override
  String get confirmAndProcess_7281 => '确认并处理';

  @override
  String pathSelectionFailed_7421(Object e) {
    return '选择路径失败：$e';
  }

  @override
  String get noWebDavConfigAvailable_7281 => '没有可用的WebDAV配置，请先在WebDAV管理页面添加配置';

  @override
  String get ensureValidExportPaths_4821 => '请确保所有导出项都有有效的源路径和导出名称';

  @override
  String get addAtLeastOneExportItem_4821 => '请至少添加一个导出项';

  @override
  String get selectWebDavConfig_7281 => '选择WebDAV配置';

  @override
  String get preparingExport_7281 => '正在准备导出...';

  @override
  String get fileMappingList_4521 => '文件映射列表';

  @override
  String get webDavUploadFailed_7281 => 'WebDAV上传失败';

  @override
  String get cannotGenerateTempPath_4821 => '无法生成系统临时文件路径';

  @override
  String webDavUploadSuccess(Object remotePath) {
    return '成功上传到WebDAV：$remotePath';
  }

  @override
  String webDavUploadFailed_7421(Object e) {
    return 'WebDAV上传失败：$e';
  }

  @override
  String get processingRequired_4821 => '需要处理';

  @override
  String get expand_4821 => '展开';

  @override
  String get collapse_4821 => '折叠';

  @override
  String get saveExportFileTitle_4821 => '保存导出文件';

  @override
  String filePickerFailedWithError(Object e) {
    return '文件选择器失败，尝试下载：$e';
  }

  @override
  String downloadFailed_7425(Object e) {
    return '下载失败：$e';
  }

  @override
  String get checkAndModifyPath_4821 =>
      '请检查并修改文件的目标路径。您可以直接编辑路径或点击文件夹图标选择目标位置。';

  @override
  String get sourceFile_7281 => '源文件';

  @override
  String pathIssuesDetected_7281(Object count) {
    return '检测到 $count 个路径问题，请展开列表进行修正';
  }

  @override
  String get allPathsValid_7281 => '所有文件路径检查通过，可以直接导入';

  @override
  String get targetPath_4821 => '目标路径';

  @override
  String get operation_4821 => '操作';

  @override
  String get smartDynamicDisplayInfo_7284 => '📏 智能动态显示区域信息:';

  @override
  String basicScreenSize(Object height, Object width) {
    return '基础屏幕尺寸: $width x $height';
  }

  @override
  String get displayAreaMultiplierLabel_4821 => '显示区域倍数';

  @override
  String get affectsPerspectiveBuffer_4821 => '影响透视缓冲';

  @override
  String perspectiveBufferFactorDebug(Object factor) {
    return '   - 透视缓冲调节系数: ${factor}x';
  }

  @override
  String baseBufferMultiplierLog(Object multiplier) {
    return '   - 基础缓冲区倍数: ${multiplier}x';
  }

  @override
  String xPerspectiveFactor(Object factor) {
    return '   - X方向透视因子: $factor';
  }

  @override
  String perspectiveStrengthDebug(Object value) {
    return '   - 当前透视强度: $value (0~1)';
  }

  @override
  String dynamicBufferMultiplierInfo(Object multiplier) {
    return '   - 动态缓冲区倍数: ${multiplier}x (智能计算)';
  }

  @override
  String yPerspectiveFactor(Object factor) {
    return '   - Y方向透视因子: $factor';
  }

  @override
  String basicDisplayArea_7421(Object height, Object width) {
    return '基础显示区域: $width x $height';
  }

  @override
  String bufferedAreaSize(Object height, Object width) {
    return '   - 缓冲后区域: $width x $height';
  }

  @override
  String get performanceOptimizationInfo_7281 => '🎯 性能优化信息:';

  @override
  String centerOffsetDebug(Object dx, Object dy) {
    return '   - 中心偏移: ($dx, $dy)';
  }

  @override
  String gridSpacingInfo(Object actualSpacing, Object baseSpacing) {
    return '   - 基础网格间距: ${baseSpacing}px → 实际间距: ${actualSpacing}px';
  }

  @override
  String iconSizeDebug(Object actualSize, Object baseSize) {
    return '   - 基础图标大小: ${baseSize}px → 实际大小: ${actualSize}px';
  }

  @override
  String triangleHeightInfo(Object value) {
    return '   - 三角形高度: ${value}px (行间距)';
  }

  @override
  String windowScalingFactorDebug(Object factor) {
    return '   - 窗口随动系数: $factor (影响内容缩放)';
  }

  @override
  String get startCachingSvgFiles_7281 => '🎨 开始缓存SVG文件...';

  @override
  String bufferCalculationFormula_4821(
    Object areaMultiplier,
    Object baseMultiplier,
    Object bufferFactor,
    Object perspectiveStrength,
    Object result,
  ) {
    return '💡 缓冲计算公式: $baseMultiplier × (1 + $perspectiveStrength × $bufferFactor × $areaMultiplier) = $result';
  }

  @override
  String svgLoadFailed_4821(Object e, Object svgPath) {
    return '加载SVG失败: $svgPath - $e';
  }

  @override
  String get edit_7281 => '编辑';

  @override
  String get legendAddedSuccessfully_4821 => '添加图例成功';

  @override
  String addLegendFailed_7285(Object e) {
    return '添加图例失败: $e';
  }

  @override
  String get legendAlreadyExists_4271 => '图例已存在';

  @override
  String legendExistsConfirmation(Object legendTitle) {
    return '图例 \"$legendTitle\" 已存在，是否要覆盖现有图例？';
  }

  @override
  String get coverText_7281 => '覆盖';

  @override
  String get editLegend_4271 => '编辑图例';

  @override
  String get legendVersionHint_4821 => '输入图例版本号';

  @override
  String get legendUpdateSuccess_7284 => '图例更新成功';

  @override
  String get legendVersionHintText_4821 => '输入图例版本号';

  @override
  String updateLegendFailed(Object error) {
    return '更新图例失败: $error';
  }

  @override
  String get rootDirectory_7281 => '根目录';

  @override
  String legendLoadingFailed_7421(Object e) {
    return '加载图例失败: $e';
  }

  @override
  String get folderCreatedSuccessfully_7281 => '文件夹创建成功';

  @override
  String get folderCreationFailed_4821 => '文件夹创建失败';

  @override
  String folderCreationFailed(Object e) {
    return '创建文件夹失败: $e';
  }

  @override
  String get createFolder_4271 => '创建文件夹';

  @override
  String get folderNameLabel_4821 => '文件夹名称';

  @override
  String get folderNameHint_4821 => '文件夹名称';

  @override
  String loadFolderFailed_7285(Object e) {
    return '加载文件夹失败: $e';
  }

  @override
  String get createFolderTooltip_7281 => '创建文件夹';

  @override
  String get addLegendTooltip_7281 => '添加图例';

  @override
  String get deleteFolder_4271 => '删除文件夹';

  @override
  String confirmDeleteFolder_7281(Object folderName) {
    return '确定要删除文件夹 \"$folderName\" 吗？\n\n注意：只能删除空文件夹。';
  }

  @override
  String get folderDeletedSuccessfully_4821 => '文件夹删除成功';

  @override
  String folderDeletionFailed(Object e, Object folderPath) {
    return '删除文件夹失败 [$folderPath]: $e';
  }

  @override
  String get deleteFolderFailed_4821 => '删除失败：文件夹不为空或不存在';

  @override
  String get renameFolder_4271 => '重命名文件夹';

  @override
  String checkFolderEmptyFailed_7421(Object e, Object folderName) {
    return '检查文件夹是否为空失败: $folderName, 错误: $e';
  }

  @override
  String get folderName_4821 => '文件夹名称';

  @override
  String get renameFailed_4821 => '重命名失败';

  @override
  String get folderNameExists_4821 => '文件夹名称已存在';

  @override
  String get folderRenameSuccess_4821 => '文件夹重命名成功';

  @override
  String renameFolderFailed(Object error, Object newPath, Object oldPath) {
    return '重命名文件夹失败 [$oldPath -> $newPath]: $error';
  }

  @override
  String get mapVersion_4821 => '地图版本';

  @override
  String get enterMapVersion_4822 => '输入地图版本号';

  @override
  String clientInfoFetchFailed(Object e) {
    return '获取客户端信息失败: $e';
  }

  @override
  String get localizationFileUploadSuccess_4821 => '本地化文件上传成功';

  @override
  String get localizationVersionTooLowOrUploadCancelled_7281 =>
      '本地化文件版本过低或取消上传';

  @override
  String uploadLocalizationFailed_7421(Object error) {
    return '上传本地化文件失败: $error';
  }

  @override
  String mapSummaryError_4821(Object e, Object mapPath) {
    return '根据路径获取地图摘要失败 [$mapPath]: $e';
  }

  @override
  String get onlineUsers_7421 => '在线用户';

  @override
  String get noOnlineUsers_7421 => '暂无在线用户';

  @override
  String get activeMap_7421 => '活跃地图';

  @override
  String get currentUserSuffix_4821 => '(我)';

  @override
  String get activeMap_7281 => '活跃地图';

  @override
  String get noActiveMap_7421 => '暂无活跃地图';

  @override
  String activeMapWithCount(Object count) {
    return '活跃地图 ($count)';
  }

  @override
  String enterActiveMap(Object mapTitle) {
    return '进入活跃地图: $mapTitle';
  }

  @override
  String get meIndicator_7281 => '(我)';

  @override
  String get viewingStatus_5732 => '查看中';

  @override
  String get idleStatus_6943 => '在线';

  @override
  String get offlineStatus_7154 => '离线';

  @override
  String get unknownClient_7281 => '未知客户端';

  @override
  String mapSummaryLoadFailed(Object desanitizedTitle, Object e) {
    return '加载地图摘要失败 [$desanitizedTitle]: $e';
  }

  @override
  String get homePage_7281 => '首页';

  @override
  String get mapAlreadyExists_4271 => '地图已存在';

  @override
  String clientInfoLoaded(Object clientId, Object displayName) {
    return '客户端信息已加载: ID=$clientId, Name=$displayName';
  }

  @override
  String mapExistsConfirmation(Object mapTitle) {
    return '地图 \"$mapTitle\" 已存在，是否要覆盖现有地图？';
  }

  @override
  String get noActiveClientConfig_7281 => '未找到活跃的客户端配置';

  @override
  String get coverText_4821 => '覆盖';

  @override
  String get scriptEngineReinitialized_4821 => '新脚本引擎重新初始化完成';

  @override
  String get onlineStatusInitComplete_4821 => '在线状态管理初始化完成';

  @override
  String enteredMapEditorMode(Object title) {
    return '已进入地图编辑器协作模式: $title';
  }

  @override
  String get keyboardShortcutsInitialized_7421 => '键盘快捷键操作实例初始化完成';

  @override
  String mapInitializationFailed_7421(Object error) {
    return '初始化地图失败: $error';
  }

  @override
  String mapNotFoundWithTitle(Object mapTitle) {
    return '未找到标题为 \"$mapTitle\" 的地图';
  }

  @override
  String get mapItemAndTitleEmpty_9274 => 'mapItem 和 mapTitle 都为空';

  @override
  String mapAndResponsiveSystemInitFailed(Object e) {
    return '地图和响应式系统初始化失败: $e';
  }

  @override
  String mapDataLoaded_7421(Object title) {
    return '地图数据加载完成: $title';
  }

  @override
  String mapDataLoadFailed_7284(Object e) {
    return '加载地图数据失败: $e';
  }

  @override
  String get failedToInitializeReactiveVersionManagement_7285 =>
      '无法初始化响应式版本管理：当前地图为空';

  @override
  String initializingReactiveVersionManagement(Object title) {
    return '开始初始化响应式版本管理，地图标题: $title';
  }

  @override
  String get responsiveVersionManagerCreated_4821 => '响应式版本管理器已创建';

  @override
  String get defaultVersionName_4821 => '默认版本';

  @override
  String defaultVersionCreated_7281(Object versionId) {
    return '默认版本已创建: $versionId';
  }

  @override
  String get defaultVersionExists_7281 => '默认版本已存在';

  @override
  String get startEditingDefaultVersion_7281 => '开始编辑默认版本以确保数据同步正常工作';

  @override
  String startEditingFirstVersion_7281(Object firstVersionId) {
    return '开始编辑第一个可用版本: $firstVersionId';
  }

  @override
  String versionStatusUpdated_7281(Object count) {
    return '版本状态已更新，版本数量: $count';
  }

  @override
  String versionSystemInitialized(Object currentVersionId) {
    return '响应式版本管理系统初始化完成，当前版本: $currentVersionId';
  }

  @override
  String responsiveVersionInitFailed(Object e) {
    return '响应式版本管理初始化失败: $e';
  }

  @override
  String get noDataSkipSync_4821 => '当前响应式系统没有数据，跳过同步';

  @override
  String get noEditingVersionSkipSync_7281 => '没有正在编辑的版本，跳过数据同步到版本系统';

  @override
  String initialDataSyncComplete(
    Object layerCount,
    Object noteCount,
    Object versionId,
  ) {
    return '初始数据同步完成 [$versionId], 图层数: $layerCount, 便签数: $noteCount';
  }

  @override
  String syncDataFailed_7285(Object e) {
    return '同步当前数据到版本系统失败: $e';
  }

  @override
  String syncNoteDebug_7421(Object count, Object index, Object title) {
    return '同步便签[$index] $title: $count个绘画元素';
  }

  @override
  String versionNameMapping_7281(Object versionNames) {
    return '版本名称映射: $versionNames';
  }

  @override
  String foundStoredVersions_7281(Object count, Object ids) {
    return '找到 $count 个已存储的版本: $ids';
  }

  @override
  String get loadingStoredVersionFromVfs_4821 => '开始从VFS加载已存储的版本...';

  @override
  String versionExistsInReactiveSystem_7421(Object versionId) {
    return '版本 $versionId 已存在于响应式系统中，但需要确保数据已加载';
  }

  @override
  String versionLoadedToReactiveSystem(Object versionId, Object versionName) {
    return '已加载版本到响应式系统: $versionId ($versionName)';
  }

  @override
  String versionLoadFailed_7281(Object e, Object versionId) {
    return '加载版本 $versionId 失败: $e';
  }

  @override
  String versionLoadFailure_7285(Object e) {
    return '从VFS加载版本失败: $e';
  }

  @override
  String versionLoadedFromVfs_7281(Object length) {
    return '完成从VFS加载版本，响应式系统中共有 $length 个版本';
  }

  @override
  String startLoadingVersionDataToSession(Object versionId) {
    return '开始加载版本数据到会话: $versionId';
  }

  @override
  String versionLoadFailed_7421(Object e, Object versionId) {
    return '加载版本 $versionId 数据失败，创建空版本状态: $e';
  }

  @override
  String get mapDataLoadedEvent_4821 => '=== 响应式监听器收到 MapDataLoaded 事件 ===';

  @override
  String versionDataLoaded(
    Object layerCount,
    Object legendGroupCount,
    Object stickyNoteCount,
    Object versionId,
  ) {
    return '版本 $versionId 数据已加载到会话，图层数: $layerCount, 图例组数: $legendGroupCount, 便签数: $stickyNoteCount';
  }

  @override
  String responsiveDataLayerOrder(Object layers) {
    return '响应式数据图层order: $layers';
  }

  @override
  String currentMapUpdatedLayersOrder_7421(Object layers) {
    return '_currentMap已更新，图层order: $layers';
  }

  @override
  String get selectedLayerGroupUpdated_4821 => '选中图层组引用已更新';

  @override
  String selectedLayerUpdated_7421(Object name) {
    return '选中图层引用已更新: $name';
  }

  @override
  String legendGroupManagementStatusSynced(Object name) {
    return '图例组管理状态已同步: $name';
  }

  @override
  String get updateDisplayOrderLog_7281 =>
      '调用 _updateDisplayOrderAfterLayerChange()';

  @override
  String updateDisplayOrderLog(Object layers) {
    return '_updateDisplayOrderAfterLayerChange() 完成，_displayOrderLayers: $layers';
  }

  @override
  String uiStateSyncedWithUnsavedChanges(Object _hasUnsavedChanges) {
    return 'UI状态已同步响应式数据，未保存更改: $_hasUnsavedChanges';
  }

  @override
  String get responsiveScriptManagerAccessMapData_4821 =>
      '新的响应式脚本管理器自动通过MapDataBloc访问地图数据';

  @override
  String syncUnsavedStateToUI(Object hasUnsavedChanges) {
    return '已同步响应式系统的未保存状态到UI: $hasUnsavedChanges';
  }

  @override
  String getUserPreferenceFailed_4821(Object e) {
    return '获取用户偏好设置显示名称失败: $e';
  }

  @override
  String deleteStickyNoteElementDebug(Object elementId, Object id) {
    return '使用响应式系统删除便签绘制元素: $id/$elementId';
  }

  @override
  String get noteElementDeleted_7281 => '已删除便签元素';

  @override
  String responsiveSystemDeleteNoteFailed(Object e) {
    return '响应式系统删除便签元素失败: $e';
  }

  @override
  String deleteNoteElementFailed(Object e) {
    return '删除便签元素失败: $e';
  }

  @override
  String debugRemoveElement(Object elementId, Object layerId) {
    return '使用响应式系统删除绘制元素: $layerId/$elementId';
  }

  @override
  String get drawingElementDeleted_7281 => '已删除绘制元素';

  @override
  String responsiveSystemDeleteFailed_4821(Object e) {
    return '响应式系统删除元素失败: $e';
  }

  @override
  String deleteElementFailed(Object e) {
    return '删除元素失败: $e';
  }

  @override
  String updateStickyNoteElement(Object elementId, Object noteId) {
    return '使用响应式系统更新便签绘制元素: $noteId/$elementId';
  }

  @override
  String get noteTagUpdated_4821 => '已更新便签元素标签';

  @override
  String get layerElementLabelUpdated_4821 => '已更新图层元素标签';

  @override
  String updateLayerElementWithReactiveSystem(
    Object layerId,
    Object elementId,
  ) {
    return '使用响应式系统更新图层绘制元素: $layerId/$elementId';
  }

  @override
  String responsiveSystemUpdateFailed_5421(Object e) {
    return '响应式系统更新元素失败: $e';
  }

  @override
  String updateElementFailed(Object e) {
    return '更新元素失败: $e';
  }

  @override
  String get layer1_7281 => '图层 1';

  @override
  String addDefaultLayerWithReactiveSystem(Object name) {
    return '使用响应式系统添加默认图层: $name';
  }

  @override
  String defaultLayerAdded_7421(Object name) {
    return '默认图层已添加: \"$name\"';
  }

  @override
  String layerName_7421(Object name) {
    return '图层: $name';
  }

  @override
  String responsiveSystemAddLayerFailed(Object e) {
    return '响应式系统添加图层失败: $e';
  }

  @override
  String addLayerWithReactiveSystem(Object name) {
    return '使用响应式系统添加图层: $name';
  }

  @override
  String addLayerFailed_4821(Object error) {
    return '添加图层失败: $error';
  }

  @override
  String clientInfoFetchFailed_7421(Object e) {
    return '获取客户端信息失败: $e';
  }

  @override
  String deleteLayerWithReactiveSystem(Object name) {
    return '使用响应式系统删除图层: $name';
  }

  @override
  String layerAdded(Object name) {
    return '已添加图层 \"$name\"';
  }

  @override
  String responsiveSystemDeleteLayerFailed(Object e) {
    return '响应式系统删除图层失败: $e';
  }

  @override
  String layerDeletionFailed_7421(Object error) {
    return '删除图层失败: $error';
  }

  @override
  String get rearrangedOrder_4281 => '重新排列后的显示顺序:';

  @override
  String get priorityLayerGroupCombination_7281 => '优先显示图层和图层组的组合';

  @override
  String otherLayersDebug_7421(Object layers) {
    return '- 其他图层: $layers';
  }

  @override
  String groupLayersDebug_7421(Object layers) {
    return '- 组内图层: $layers';
  }

  @override
  String get prioritizeLayerGroupStart_7281 =>
      '=== _prioritizeLayerGroup 开始 ===';

  @override
  String priorityLayersDebug_7421(Object layers) {
    return '- 优先图层: $layers';
  }

  @override
  String priorityLayerGroupDisplay(Object groupNames) {
    return '优先显示图层组: $groupNames';
  }

  @override
  String currentLayerOrderDebug(Object layers) {
    return '当前_currentMap.layers顺序: $layers';
  }

  @override
  String displayOrderLayersDebug(Object layers) {
    return '当前_displayOrderLayers顺序: $layers';
  }

  @override
  String allLayersDebugMessage_7421(Object layers) {
    return 'allLayers从_currentMap获取: $layers';
  }

  @override
  String separatedGroupLayersOrder_7284(Object layers) {
    return '分离后的组内图层顺序: $layers';
  }

  @override
  String nonGroupLayersOrderDebug(Object layers) {
    return '分离后的非组图层顺序: $layers';
  }

  @override
  String get prioritizeLayerGroupEnd_7281 => '=== _prioritizeLayerGroup 结束 ===';

  @override
  String finalDisplayOrderLayersDebug(Object layers) {
    return '最终_displayOrderLayers顺序: $layers';
  }

  @override
  String get drawingToolDisabled_4287 => '绘制工具已禁用';

  @override
  String get layerOrderUpdated_4821 => '图层顺序已更新';

  @override
  String layerUpdateFailed_7421(Object error) {
    return '更新图层失败: $error';
  }

  @override
  String responsiveSystemReorderFailed(Object e) {
    return '响应式系统重排序图层失败: $e';
  }

  @override
  String get layerGroupOrderUpdated_4821 => '图层组内顺序已更新';

  @override
  String reorderLayerFailed(Object error) {
    return '重排序图层失败: $error';
  }

  @override
  String responsiveSystemGroupReorderFailed_4821(Object e) {
    return '响应式系统组内重排序图层失败: $e';
  }

  @override
  String batchUpdateLayerFailed(Object error) {
    return '批量更新图层失败: $error';
  }

  @override
  String layerReorderFailed_7285(Object error) {
    return '组内重排序图层失败: $error';
  }

  @override
  String addLegendGroupFailed(Object error) {
    return '添加图例组失败: $error';
  }

  @override
  String legendGroupAdded_7421(Object name) {
    return '已添加图例组 \"$name\"';
  }

  @override
  String legendGroupName(Object count) {
    return '图例组 $count';
  }

  @override
  String responsiveSystemDeleteLegendGroupFailed(Object e) {
    return '响应式系统删除图例组失败: $e';
  }

  @override
  String debugRemoveLegendGroup(Object name) {
    return '使用响应式系统删除图例组: $name';
  }

  @override
  String legendGroupDeleted(Object name) {
    return '已删除图例组 \"$name\"';
  }

  @override
  String deleteLegendGroupFailed_7421(Object error) {
    return '删除图例组失败: $error';
  }

  @override
  String mapEditorUpdateLegendGroup(Object name) {
    return '地图编辑器：更新图例组 $name';
  }

  @override
  String updatedLegendItemsCount(Object count) {
    return '更新的图例项数量: $count';
  }

  @override
  String get syncLegendGroupDrawerStatus_4821 => '同步更新图例组管理抽屉的状态';

  @override
  String updateLegendGroupWithReactiveSystem(Object name) {
    return '使用响应式系统更新图例组: $name';
  }

  @override
  String responsiveSystemUpdateFailed_7285(Object e) {
    return '响应式系统更新图例组失败: $e';
  }

  @override
  String startSavingResponsiveVersionData(Object mapTitle) {
    return '开始保存响应式版本数据 [地图: $mapTitle]';
  }

  @override
  String updateLegendGroupFailed(Object error) {
    return '更新图例组失败: $error';
  }

  @override
  String versionCount_7281(Object count) {
    return '版本数量: $count';
  }

  @override
  String saveVersion_7281(Object versionId, Object versionName) {
    return '保存版本: $versionId ($versionName)';
  }

  @override
  String versionSessionUsage_7281(Object layersCount, Object versionId) {
    return '版本 $versionId 使用会话数据，图层数: $layersCount';
  }

  @override
  String versionStatusDebug(Object hasSessionData, Object hasUnsavedChanges) {
    return '版本状态: 有会话数据=$hasSessionData, 有未保存更改=$hasUnsavedChanges';
  }

  @override
  String get hasSessionData => '有会话数据';

  @override
  String get hasUnsavedChanges => '有未保存更改';

  @override
  String versionNotFoundUsingDefault_7281(Object versionId) {
    return '版本 $versionId 不存在，使用基础数据作为初始数据';
  }

  @override
  String versionNoSessionData_7281(Object versionId) {
    return '版本 $versionId 没有会话数据，尝试从VFS加载';
  }

  @override
  String loadingVersionData_7281(
    Object layerCount,
    Object noteCount,
    Object versionId,
  ) {
    return '从VFS加载版本 $versionId 数据，图层数: $layerCount, 便签数: $noteCount';
  }

  @override
  String get allReactiveVersionsSavedToVfs_7281 => '所有响应式版本数据已成功保存到VFS存储';

  @override
  String saveVersionToVfs(Object title, Object versionId) {
    return '保存版本数据到VFS: $title/$versionId';
  }

  @override
  String loadVersionDataFailed_7421(Object error, Object versionId) {
    return '加载版本 $versionId 数据失败: $error，使用基础数据';
  }

  @override
  String get defaultVersionSaved_7281 => '默认版本已保存 (完整重建)';

  @override
  String versionDataSaved_7281(Object activeVersionId) {
    return '保存版本数据 [$activeVersionId] 完成';
  }

  @override
  String versionSaveFailed_7421(Object error, Object versionId) {
    return '保存版本数据失败 [$versionId]: $error';
  }

  @override
  String versionCreationStatus(Object currentVersionId, Object layerCount) {
    return '创建版本前状态: 当前版本=$currentVersionId, 当前地图图层数=$layerCount';
  }

  @override
  String versionSavedToMetadata(Object name, Object versionId) {
    return '版本名称已保存到元数据: $name (ID: $versionId)';
  }

  @override
  String versionCreatedMessage_7421(
    Object sessionDataStatus,
    Object versionId,
  ) {
    return '新版本已创建: $versionId, 会话数据=$sessionDataStatus';
  }

  @override
  String hasLayersMessage_5832(Object layersCount) {
    return '有(图层数: $layersCount)';
  }

  @override
  String get noData_6943 => '无';

  @override
  String versionMetadataSaveFailed_7421(Object e) {
    return '保存版本元数据失败: $e';
  }

  @override
  String versionCreated_7421(Object name) {
    return '版本 \"$name\" 已创建';
  }

  @override
  String newVersionCreated_7281(Object versionId) {
    return '新版本已创建: $versionId';
  }

  @override
  String savePanelStateFailed_7421(Object e) {
    return '在dispose中保存面板状态失败: $e';
  }

  @override
  String switchedToVersion_7281(Object versionId) {
    return '已切换到版本: $versionId';
  }

  @override
  String versionSwitchFailed(Object e) {
    return '切换版本失败: $e';
  }

  @override
  String versionCreationFailed_7285(Object e) {
    return '创建版本失败: $e';
  }

  @override
  String get cannotDeleteDefaultVersion_4821 => '无法删除默认版本';

  @override
  String get startDeletingVersionData_7281 => '开始删除版本存储数据...';

  @override
  String deleteVfsVersionDataFailed(Object e) {
    return '删除VFS版本数据失败: $e';
  }

  @override
  String vfsVersionDeletedSuccessfully(Object versionId) {
    return 'VFS版本数据删除成功: $versionId';
  }

  @override
  String saveSmartHideStateFailed_7285(Object e) {
    return '在dispose中保存智能隐藏状态失败: $e';
  }

  @override
  String versionMetadataDeletedSuccessfully(Object arg0) {
    return '删除版本元数据成功 [$arg0]';
  }

  @override
  String deleteVersionMetadataFailed(
    Object e,
    Object mapTitle,
    Object versionId,
  ) {
    return '删除版本元数据失败 [$mapTitle:$versionId]: $e';
  }

  @override
  String get versionDeletedSuccessfully_7281 => '版本已完全删除';

  @override
  String versionDeletedComplete(Object versionId) {
    return '版本删除完成: $versionId';
  }

  @override
  String deleteVersionFailed_7421(Object e) {
    return '删除版本失败: $e';
  }

  @override
  String saveScaleFactorFailed_7285(Object e) {
    return '在dispose中保存缩放因子状态失败: $e';
  }

  @override
  String exitConfirmationCheck(Object first, Object second) {
    return '退出确认检查: _hasUnsavedChanges=$first, hasUnsavedVersions=$second';
  }

  @override
  String get unsavedChanges_4271 => '未保存的更改';

  @override
  String get unsavedChangesWarning_7284 => '您有未保存的更改，确定要退出吗？';

  @override
  String get saveAndExit_4271 => '保存并退出';

  @override
  String get exitWithoutSaving_7281 => '不保存退出';

  @override
  String get mapEditorExitCleanup_4821 => '地图编辑器退出：已清理所有图例缓存';

  @override
  String legendCacheCleanupFailed_7285(Object e) {
    return '在dispose中清理图例缓存失败: $e';
  }

  @override
  String get panelStateSavedOnExit_4821 => '面板状态已在退出时保存';

  @override
  String savePanelStateFailed_7285(Object e) {
    return '保存面板状态失败: $e';
  }

  @override
  String get mapEditorExitMessage_4821 => '地图编辑器退出：已清理所有颜色滤镜';

  @override
  String colorFilterCleanupError_4821(Object e) {
    return '在dispose中清理颜色滤镜失败: $e';
  }

  @override
  String selectedLayerAndGroup_7281(Object groupNames, Object layerName) {
    return '图层: $layerName | 组: $groupNames';
  }

  @override
  String currentSelectedLayer_7421(Object name) {
    return '当前: $name';
  }

  @override
  String get resourceReleased_4821 => '在线状态管理资源已释放';

  @override
  String selectedLayerGroupMessage(Object layers) {
    return '图层组: $layers';
  }

  @override
  String get noLayerSelected_4821 => '未选择图层';

  @override
  String get mapInfo_7421 => '地图信息';

  @override
  String get exportLayer_7421 => '导出图层';

  @override
  String get disableCrosshair_42 => '关闭十字线';

  @override
  String get enableCrosshair_42 => '开启十字线';

  @override
  String get savingInProgress_42 => '保存中...';

  @override
  String get save_73 => '保存';

  @override
  String get mapInfo_7281 => '地图信息';

  @override
  String get mapName_4821 => '地图名称';

  @override
  String get editMode_4821 => '编辑模式';

  @override
  String get previewMode_4822 => '预览模式';

  @override
  String get folderPathLabel_4821 => '文件夹路径';

  @override
  String get currentVersion_7281 => '当前版本';

  @override
  String get unsavedChangesPrompt_7421 => '是否有未保存更改';

  @override
  String get editorStatus_4521 => '编辑器状态';

  @override
  String get panelStatusChanged_7281 => '面板状态已更改';

  @override
  String get viewShortcutList_7281 => '查看快捷键列表';

  @override
  String exportLayerSuccess(Object name) {
    return '导出图层: $name';
  }

  @override
  String get yes_4287 => '是';

  @override
  String get no_4287 => '否';

  @override
  String stickyNoteInspectorTitle_7421(Object title) {
    return '便签元素检视器 - $title';
  }

  @override
  String get zLevelInspector_1589 => 'Z层级检视器';

  @override
  String legendGroupSmartHideInitialized(Object _legendGroupSmartHideStates) {
    return '图例组智能隐藏状态已初始化: $_legendGroupSmartHideStates';
  }

  @override
  String get backButton_75 => '返回';

  @override
  String get noAvailableLayers_4721 => '暂无可用图层\n请先创建或显示图层';

  @override
  String get addLayer_7281 => '添加图层';

  @override
  String get addLegendGroup_7352 => '添加图例组';

  @override
  String get addStickyNote_7421 => '添加便签';

  @override
  String legendGroupZoomFactorInitialized(Object _legendGroupZoomFactors) {
    return '图例组缩放因子状态已初始化: $_legendGroupZoomFactors';
  }

  @override
  String get newScript_7281 => '新建脚本';

  @override
  String get autoCloseTooltip_4821 => '自动关闭：当点击其他工具栏时自动关闭此工具栏';

  @override
  String legendGroupSmartHideStatusUpdated(
    Object enabled,
    Object legendGroupId,
  ) {
    return '图例组 $legendGroupId 智能隐藏状态已更新: $enabled';
  }

  @override
  String get autoClose_7421 => '自动关闭';

  @override
  String updateRecentColorsFailed(Object e) {
    return '更新最近使用颜色失败: $e';
  }

  @override
  String get buildingMapCanvas_7281 => '=== 构建地图画布 ===';

  @override
  String currentMapTitle_7421(Object title) {
    return '当前地图: $title';
  }

  @override
  String legendGroupCount(Object count) {
    return '图例组数量: $count';
  }

  @override
  String legendGroupInfo(
    Object index,
    Object isVisible,
    Object length,
    Object name,
  ) {
    return '图例组 $index: $name, 可见: $isVisible, 图例项: $length';
  }

  @override
  String versionAdapterExists_7281(Object condition) {
    return '版本适配器存在: $condition';
  }

  @override
  String legendGroupZoomUpdated_7281(Object legendGroupId, Object zoomFactor) {
    return '图例组 $legendGroupId 缩放因子已更新: $zoomFactor';
  }

  @override
  String legendSessionManagerExists_7281(Object value) {
    return '图例会话管理器存在: $value';
  }

  @override
  String autoSwitchLegendGroupDrawer(Object name) {
    return '自动切换图例组抽屉到绑定的图例组: $name';
  }

  @override
  String get noLegendGroupBound_7281 => '当前选中图层没有绑定图例组';

  @override
  String get createResponsiveScript_4821 => '新建响应式脚本';

  @override
  String get responsiveScriptDescription_4521 => '响应式脚本会自动响应地图数据变化，确保实时数据一致性';

  @override
  String get scriptName_4521 => '脚本名称';

  @override
  String get descriptionLabel_4821 => '描述';

  @override
  String newNoteTitle(Object count) {
    return '新便签 $count';
  }

  @override
  String get scriptType_4521 => '脚本类型';

  @override
  String get enterScriptName_4821 => '请输入脚本名称';

  @override
  String dynamicFormulaLegendSizeCalculation(
    Object currentZoomLevel,
    Object legendSize,
    Object zoomFactor,
  ) {
    return '使用动态公式计算图例大小: zoomFactor=$zoomFactor, currentZoom=$currentZoomLevel, legendSize=$legendSize';
  }

  @override
  String scriptCreatedSuccessfully(Object name) {
    return '响应式脚本 \"$name\" 创建成功';
  }

  @override
  String fixedLegendSizeUsage(Object legendSize) {
    return '使用固定图例大小: $legendSize';
  }

  @override
  String get automation_1234 => '自动化';

  @override
  String get animation_5678 => '动画';

  @override
  String get filter_9012 => '过滤';

  @override
  String get statistics_3456 => '统计';

  @override
  String dragToAddLegendItem_7421(Object id, Object legendId) {
    return '拖拽添加图例项到地图编辑器: ID=$id, legendId=$legendId';
  }

  @override
  String updatedLegendCount(Object length) {
    return '更新后图例数量: $length';
  }

  @override
  String legendCountBeforeUpdate(Object count) {
    return '更新前图例数量: $count';
  }

  @override
  String legendAddedToGroup(Object count, Object name) {
    return '已将图例添加到 $name ($count个图例)';
  }

  @override
  String get dragEndCheckDrawer_4821 => '拖拽结束：检查是否需要重新打开图例组管理抽屉';

  @override
  String get dragStartCloseDrawer_4821 => '拖拽开始：临时关闭图例组管理抽屉';

  @override
  String get dragEndReopenLegendDrawer_7281 => '拖拽结束：重新打开图例组管理抽屉';

  @override
  String dragLegendFromCache(Object canvasPosition, Object legendPath) {
    return '从缓存拖拽添加图例: $legendPath 到位置: $canvasPosition';
  }

  @override
  String saveLegendGroupStateFailed(Object e) {
    return '保存图例组智能隐藏状态失败: $e';
  }

  @override
  String mapLegendScaleSaved(Object title) {
    return '地图 $title 的图例组缩放因子状态已保存';
  }

  @override
  String mapLegendAutoHideStatusSaved(Object title) {
    return '地图 $title 的图例组智能隐藏状态已保存';
  }

  @override
  String get responsiveSystemInitialized_7281 => '响应式系统初始化完成';

  @override
  String saveLegendScaleFactorFailed(Object e) {
    return '保存图例组缩放因子状态失败: $e';
  }

  @override
  String mapDataLoadedToReactiveSystem(Object title) {
    return '地图数据已加载到响应式系统: $title';
  }

  @override
  String layerDeleted(Object name) {
    return '已删除图层 \"$name\"';
  }

  @override
  String get loadingText_7281 => '加载中...';

  @override
  String get clickToAddText_7281 => '点击添加文本';

  @override
  String createNoteImageSelectionElement_7421(Object imageBufferData) {
    return '创建便签图片选区元素: imageData=$imageBufferData';
  }

  @override
  String processingQueueElement_7421(Object elementId, Object layerId) {
    return '处理队列元素: $elementId 添加到图层: $layerId';
  }

  @override
  String get addText_4271 => '添加文本';

  @override
  String get drawingToolManagerCallbackNotSet_4821 =>
      'DrawingToolManager: addDrawingElement回调未设置或目标图层ID为空，无法添加元素';

  @override
  String get textContent_4521 => '文本内容';

  @override
  String fontSizeLabel(Object value) {
    return '字体大小: ${value}px';
  }

  @override
  String addTextWithFontSize(Object fontSize) {
    return '添加文本 (字体大小: ${fontSize}px)';
  }

  @override
  String get addTextToNote_7421 => '添加文本到便签';

  @override
  String addTextToNoteWithFontSize(Object fontSize) {
    return '添加文本到便签 (字体大小: ${fontSize}px)';
  }

  @override
  String noteImageSelectionDebug_7421(Object value) {
    return '便签创建图片选区: 缓冲区数据=$value';
  }

  @override
  String globalServiceNotInitialized_7285(Object e) {
    return '全局协作服务未初始化，使用本地实例: $e';
  }

  @override
  String userOfflinePreviewAddedToLayer(Object targetLayerId) {
    return '用户离线，预览已直接处理并添加到图层 $targetLayerId';
  }

  @override
  String layerLockedPreviewQueued(Object targetLayerId) {
    return '图层 $targetLayerId 被锁定，预览已加入队列';
  }

  @override
  String previewImmediatelyProcessedAndAddedToLayer(Object targetLayerId) {
    return '预览已立即处理并添加到图层 $targetLayerId';
  }

  @override
  String layerLockFailedPreviewQueued(Object targetLayerId) {
    return '无法锁定图层 $targetLayerId，预览已加入队列';
  }

  @override
  String previewQueueProcessed_7421(Object id, Object zIndex) {
    return '[PreviewQueueManager] 队列中的预览已处理: $id, z值: $zIndex (基于实时图层状态)';
  }

  @override
  String previewQueueProcessed(Object itemId, Object layerId, Object zIndex) {
    return '[PreviewQueueManager] 图层 $layerId 队列中的预览已处理: $itemId, z值: $zIndex';
  }

  @override
  String forcePreviewSubmission_7421(Object id) {
    return '强制提交预览: $id';
  }

  @override
  String previewSubmitted_7285(Object itemId) {
    return '预览已提交: $itemId';
  }

  @override
  String get previewQueueCleared_7281 => '预览队列已清空';

  @override
  String get previewRemoved_7425 => '预览已移除';

  @override
  String layerPreviewQueueCleared_4821(Object layerId) {
    return '图层$layerId的预览队列已清空';
  }

  @override
  String get stickyNotePreviewProcessed_7421 => '便签预览已立即处理并添加到便签';

  @override
  String offlineStickyNotePreviewHandled_7421(Object stickyNoteId) {
    return '用户离线，便签预览已直接处理并添加到便签 $stickyNoteId';
  }

  @override
  String stickyNoteLockedPreviewQueued_7281(
    Object queueLength,
    Object stickyNoteId,
  ) {
    return '[PreviewQueueManager] 便签 $stickyNoteId 被锁定，预览已加入队列，当前队列长度: $queueLength';
  }

  @override
  String startProcessingQueue(Object stickyNoteId, Object totalItems) {
    return '开始处理便签 $stickyNoteId 队列，共 $totalItems 个项目';
  }

  @override
  String previewQueueLockFailed(Object queueLength, Object stickyNoteId) {
    return '[PreviewQueueManager] 无法锁定便签 $stickyNoteId，预览已加入队列，当前队列长度: $queueLength';
  }

  @override
  String previewQueueItemProcessed_7281(
    Object currentItem,
    Object itemId,
    Object stickyNoteId,
    Object totalItems,
  ) {
    return '[PreviewQueueManager] 便签 $stickyNoteId 队列项目 $currentItem/$totalItems 已处理: $itemId';
  }

  @override
  String get previewQueueCleared_7421 => '便签预览队列已清空';

  @override
  String previewQueueCleared(Object stickyNoteId, Object totalItems) {
    return '[PreviewQueueManager] 便签 $stickyNoteId 队列已清空，所有 $totalItems 个项目处理完成';
  }

  @override
  String stickyNotePreviewQueueCleared(Object stickyNoteId) {
    return '便签$stickyNoteId的预览队列已清空';
  }

  @override
  String get notePreviewRemoved_7421 => '便签预览已移除';

  @override
  String get clickToUploadImage_4821 => '点击上传图片';

  @override
  String get boxFitFill_4821 => '填充';

  @override
  String get boxFitContain_4822 => '包含';

  @override
  String get boxFitCover_4823 => '覆盖';

  @override
  String unsupportedKey_7425(Object key) {
    return '不支持的按键: $key';
  }

  @override
  String shortcutCheckResult(
    Object keyMatch,
    Object modifierMatch,
    Object result,
    Object shortcut,
  ) {
    return '快捷键检查: $shortcut, 主键匹配: $keyMatch, 修饰键匹配: $modifierMatch, 最终结果: $result';
  }

  @override
  String get checkUndoStatusFailed_4821 => '检查撤销状态失败';

  @override
  String checkRedoStatusFailed_4821(Object e) {
    return '检查重做状态失败: $e';
  }

  @override
  String get useReactiveSystemUndo_7281 => '使用响应式系统撤销';

  @override
  String responsiveSystemUndoFailed_7421(Object e) {
    return '响应式系统撤销失败: $e';
  }

  @override
  String get redoWithReactiveSystem_4821 => '使用响应式系统重做';

  @override
  String responsiveSystemRedoFailed_7421(Object e) {
    return '响应式系统重做失败: $e';
  }

  @override
  String get selectRegionBeforeCopy_7281 => '请先选择一个区域再复制';

  @override
  String get canvasCaptureError_4821 => '无法捕获画布区域';

  @override
  String get copyToClipboardFailed_4821 => '复制到剪贴板失败';

  @override
  String get selectionCopiedToClipboard_4821 => '选区已复制到剪贴板';

  @override
  String get noLegendGroupsAvailable_4821 => '没有可切换的图例组';

  @override
  String copyToClipboardFailed(Object e) {
    return '复制到剪贴板失败: $e';
  }

  @override
  String get noLegendGroupBoundToLayerGroup_4821 => '当前选中图层组没有绑定图例组';

  @override
  String get noLegendGroupInCurrentMap_4821 => '当前地图没有图例组';

  @override
  String get selectLayerFirst_4281 => '请先选择一个图层';

  @override
  String get noAvailableLayers_4821 => '没有可用的图层';

  @override
  String get noMapDataToSave_4821 => '没有可保存的地图数据';

  @override
  String get savingMap_7281 => '正在保存地图...';

  @override
  String get mapSavedSuccessfully_7281 => '地图保存成功';

  @override
  String mapSaveFailed_7285(Object e) {
    return '保存地图失败: $e';
  }

  @override
  String versionCreationFailed(Object error) {
    return '创建版本失败: $error';
  }

  @override
  String autoSwitchLegendGroupDrawer_7421(Object name) {
    return '自动切换图例组抽屉到绑定的图例组: $name';
  }

  @override
  String get noLegendGroupSelected_4821 => '当前选中的图层或图层组没有绑定任何图例组';

  @override
  String cachedLegendCategories(
    Object totalOtherSelected,
    Object totalOwnSelected,
    Object totalUnselected,
  ) {
    return '[CachedLegendsDisplay] 缓存图例分类完成：自己组 $totalOwnSelected，其他组 $totalOtherSelected，未选中 $totalUnselected';
  }

  @override
  String get noCachedLegend => '暂无缓存图例';

  @override
  String get selectVfsDirectoryHint_4821 => '选择VFS目录来加载图例到缓存';

  @override
  String get ownSelectedHeader_5421 => '自己组选中';

  @override
  String get otherSelectedGroup_4821 => '其他组选中';

  @override
  String get loadedButUnselected_7281 => '未选中但已加载';

  @override
  String dragLegendStart(Object legendPath) {
    return '开始拖拽图例: $legendPath';
  }

  @override
  String dragEndLegend_7281(Object legendPath, Object wasAccepted) {
    return '结束拖拽图例: $legendPath, 是否被接受: $wasAccepted';
  }

  @override
  String dragComplete_7281(Object legendPath) {
    return '拖拽完成: $legendPath';
  }

  @override
  String legendGroupIdChanged(Object newId, Object oldId) {
    return '[CachedLegendsDisplay] 图例组ID变化: $oldId -> $newId，刷新缓存显示';
  }

  @override
  String get draggingText_4821 => '拖拽中...';

  @override
  String svgThumbnailLoadFailed_7285(Object e) {
    return 'SVG图例缩略图加载失败: $e';
  }

  @override
  String get rootDirectory_4721 => '根目录';

  @override
  String updatingCachedLegendsList(Object currentLegendGroupId) {
    return '[CachedLegendsDisplay] 开始更新缓存图例列表，当前图例组ID: $currentLegendGroupId';
  }

  @override
  String get ownSelectedPaths_7425 => '自己组选中路径';

  @override
  String cachedLegendsCount_7421(Object count) {
    return '当前缓存图例数量: $count';
  }

  @override
  String get otherGroupSelectedPaths_7425 => '其他组选中路径';

  @override
  String get manageLineWidths_4821 => '管理常用线条宽度';

  @override
  String currentCount_7421(Object count) {
    return '当前数量: $count/5';
  }

  @override
  String get addedLineWidth_4821 => '已添加的线条宽度:';

  @override
  String get addNewLineWidth_4821 => '添加新的线条宽度';

  @override
  String get noCommonLineWidthAdded_4821 => '还没有添加常用线条宽度';

  @override
  String get addLineWidth_4821 => '添加线条宽度';

  @override
  String get maxLimitReached_5421 => '已达到最大数量限制 (5个)';

  @override
  String widthWithPx_7421(Object value) {
    return '宽度: ${value}px';
  }

  @override
  String get maxLineWidthLimit_4821 => '最多只能添加5个常用线条宽度';

  @override
  String get lineWidthExists_4821 => '该线条宽度已存在';

  @override
  String lineWidthAdded(Object width) {
    return '已添加线条宽度 ${width}px';
  }

  @override
  String get addButton_7421 => '添加';

  @override
  String get imageFitMethod_4821 => '图片适应方式';

  @override
  String get imageBuffer_7281 => '图片缓冲区';

  @override
  String get instructions_4521 => '使用说明';

  @override
  String get imageLoadFailed_7421 => '图片显示失败';

  @override
  String boxFitModeSetTo(Object fit) {
    return '图片适应方式已设置为: $fit';
  }

  @override
  String get reuploadText_4821 => '重新上传';

  @override
  String get clearText_4821 => '清空';

  @override
  String get supportedImageFormats_4821 => '支持 JPG、PNG、GIF 格式';

  @override
  String get uploadImageToBuffer_4521 => '点击上传图片到缓冲区';

  @override
  String get uploadImage_7421 => '上传图片';

  @override
  String get clipboardLabel_4271 => '剪贴板';

  @override
  String get invalidImageFileError_4821 => '无效的图片文件，请选择有效的图片';

  @override
  String get selectingImage_4821 => '正在选择图片...';

  @override
  String get imageSelectionCancelled_4521 => '已取消图片选择';

  @override
  String imageUploadFailed_7281(Object errorMessage) {
    return '图片上传失败: $errorMessage';
  }

  @override
  String imageUploadedToBuffer(String mimeType, Object sizeInKB) {
    String _temp0 = intl.Intl.selectLogic(mimeType, {
      'null': '',
      'other': ' · 类型: $mimeType',
    });
    return '图片已上传到缓冲区\n大小: ${sizeInKB}KB$_temp0';
  }

  @override
  String get invalidClipboardImageData_4271 => '剪贴板中的数据不是有效的图片文件';

  @override
  String get readingImageFromClipboard_4721 => '正在从剪贴板读取图片...';

  @override
  String get imageTooLargeError_4821 => '图片文件过大，请选择小于10MB的图片';

  @override
  String get noImageDataInClipboard_4821 => '剪贴板中没有图片数据';

  @override
  String clipboardImageReadFailed(Object e) {
    return '从剪贴板读取图片失败: $e';
  }

  @override
  String imageCopiedToBuffer_7421(String mimeType, Object sizeInKB) {
    String _temp0 = intl.Intl.selectLogic(mimeType, {
      'null': '',
      'other': ' · 类型: $mimeType',
    });
    return '图片已从剪贴板读取到缓冲区\n大小: ${sizeInKB}KB$_temp0';
  }

  @override
  String get toolsTitle_7281 => '工具';

  @override
  String get noCut_4821 => '无切割';

  @override
  String get topLeftTriangle_4821 => '左上三角';

  @override
  String get topRightTriangle_4821 => '右上三角';

  @override
  String get bottomRightTriangle_4821 => '右下三角';

  @override
  String get bottomLeftTriangle_4821 => '左下三角';

  @override
  String get undoAction_7421 => '撤销';

  @override
  String get redo_7281 => '重做';

  @override
  String get recentlyUsed_7421 => '最近使用';

  @override
  String get solidLine_4821 => '实线';

  @override
  String get dashedLine_5732 => '虚线';

  @override
  String get arrow_6423 => '箭头';

  @override
  String get solidRectangle_7524 => '实心矩形';

  @override
  String get hollowRectangle_8635 => '空心矩形';

  @override
  String get singleDiagonalLine_9746 => '单斜线';

  @override
  String get crossLines_0857 => '交叉线';

  @override
  String get dotGrid_1968 => '点阵';

  @override
  String get pixelPen_2079 => '像素笔';

  @override
  String get textBox_3180 => '文本框';

  @override
  String get eraser_4291 => '橡皮擦';

  @override
  String get imageSelection_5302 => '图片选区';

  @override
  String get tool_6413 => '工具';

  @override
  String get colorLabel_5421 => '颜色';

  @override
  String get customColor_7421 => '自定义颜色';

  @override
  String get clickToAddCustomColor_4821 => '点击调色盘按钮添加自定义颜色';

  @override
  String get commonLineWidth_4821 => '常用线条宽度';

  @override
  String get lineThickness_4521 => '线条粗细';

  @override
  String get patternDensity_7281 => '图案密度';

  @override
  String get radianUnit_7421 => '弧度';

  @override
  String get manageStrokeWidths_4821 => '管理常用线条宽度';

  @override
  String get diagonalCutting_4521 => '对角线切割';

  @override
  String get cancelSelection_4271 => '取消选择';

  @override
  String get advancedColorPicker_4821 => '高级颜色选择器';

  @override
  String get colorAddedToCustom_7281 => '颜色已添加到自定义';

  @override
  String stickyNoteInspectorWithCount(Object count) {
    return '便签元素检视器 ($count)';
  }

  @override
  String zLayerInspectorWithCount(Object count) {
    return 'Z层级检视器 ($count)';
  }

  @override
  String get colorAlreadyExists_7281 => '该颜色已存在';

  @override
  String addColorFailed(Object e) {
    return '添加颜色失败: $e';
  }

  @override
  String get arrowLabel_5421 => '箭头';

  @override
  String get drawArrowTooltip_8732 => '绘制箭头';

  @override
  String get rectangleLabel_4521 => '矩形';

  @override
  String get drawRectangleTooltip_4522 => '绘制矩形';

  @override
  String imageUploadFailed_7285(Object e) {
    return '图片上传失败: $e';
  }

  @override
  String get invalidClipboardImageData_4821 => '剪贴板中的数据不是有效的图片文件';

  @override
  String pasteImageFailed_4821(Object e) {
    return '从剪贴板粘贴图片失败: $e';
  }

  @override
  String get hollowRectangle_7421 => '空心矩形';

  @override
  String get drawHollowRectangle_8423 => '绘制空心矩形';

  @override
  String get diagonalAreaLabel_4821 => '斜线区域';

  @override
  String get drawDiagonalAreaTooltip_7532 => '绘制斜线区域';

  @override
  String get imageBuffer_4821 => '图片缓冲区';

  @override
  String get crossLinesLabel_4821 => '交叉线';

  @override
  String get crossLinesTooltip_7532 => '绘制交叉线';

  @override
  String get usageInstructions_4821 => '使用说明';

  @override
  String get dotGridLabel_5421 => '点阵';

  @override
  String get drawDotGridTooltip_8732 => '绘制点阵';

  @override
  String get freeDrawingLabel_4821 => '自由绘制';

  @override
  String get freeDrawingTooltip_7532 => '自由绘制';

  @override
  String get textLabel_4821 => '文本';

  @override
  String get addTextTooltip_4821 => '添加文本';

  @override
  String get selectColor_4821 => '选择颜色';

  @override
  String get eraserLabel_4821 => '橡皮擦';

  @override
  String get eraserTooltip_4822 => '擦除元素';

  @override
  String get imageAreaLabel_4281 => '图片区域';

  @override
  String get addImageAreaTooltip_4282 => '添加图片区域';

  @override
  String get recentlyUsedColors_4821 => '最近使用的颜色';

  @override
  String get selectColor_7281 => '选择颜色';

  @override
  String toolPropertiesTitle_7421(Object toolName) {
    return '$toolName 属性';
  }

  @override
  String get noConfigurableProperties_7421 => '此工具无可配置属性';

  @override
  String get unknownToolLabel_4821 => '未知工具';

  @override
  String get unknownTooltip_4821 => '未知工具';

  @override
  String curvaturePercentage(Object percentage) {
    return '弧度: $percentage%';
  }

  @override
  String get cuttingType_4821 => '切割类型';

  @override
  String get topLeftCut_4822 => '左上切割';

  @override
  String get topRightCut_4823 => '右上切割';

  @override
  String get bottomLeftCut_4824 => '左下切割';

  @override
  String get bottomRightCut_4825 => '右下切割';

  @override
  String strokeWidthLabel(Object width) {
    return '线宽:${width}px';
  }

  @override
  String densityValue_7281(Object value) {
    return '密度: ${value}x';
  }

  @override
  String get imageLoadFailed_4721 => '图片显示失败';

  @override
  String get reuploadText_7281 => '重新上传';

  @override
  String get uploadImageToBuffer_5421 => '点击上传图片到缓冲区';

  @override
  String get lineToolLabel_4521 => '直线';

  @override
  String get drawLineTooltip_4522 => '绘制直线';

  @override
  String get dashedLine_4821 => '虚线';

  @override
  String get drawDashedLine_7532 => '绘制虚线';

  @override
  String get toolLabel_4821 => '工具';

  @override
  String get parameters_4821 => '参数';

  @override
  String get selectedLayerLabel_4821 => '选中图层';

  @override
  String get drawingLayer_4821 => '绘制图层';

  @override
  String get defaultLayerSuffix_7532 => '(默认)';

  @override
  String get selectedGroup_4821 => '选中组';

  @override
  String selectedLayersInfo_4821(Object count, Object names) {
    return '$count层: $names';
  }

  @override
  String get layersLabel_7281 => '图层';

  @override
  String get stickyNoteLabel_4281 => '便签';

  @override
  String get layerGroup_4821 => '图层组';

  @override
  String colorWithHex_7421(Object colorHex) {
    return '颜色:$colorHex';
  }

  @override
  String densityValue_7421(Object value) {
    return '密度:$value';
  }

  @override
  String radianValue(Object value) {
    return '弧度:$value';
  }

  @override
  String cuttingTriangleName_7421(Object name) {
    return '切割:$name';
  }

  @override
  String get none_4821 => '无';

  @override
  String get topLeft_5723 => '左上';

  @override
  String get topRight_6934 => '右上';

  @override
  String get bottomLeft_7145 => '左下';

  @override
  String get bottomRight_8256 => '右下';

  @override
  String get unknown_9367 => '未知';

  @override
  String get dashedLine_4822 => '虚线';

  @override
  String get arrow_4823 => '箭头';

  @override
  String get solidRectangle_4824 => '实心矩形';

  @override
  String get hollowRectangle_4825 => '空心矩形';

  @override
  String get diagonalArea_4826 => '斜线区域';

  @override
  String get crossLineArea_4827 => '交叉线区域';

  @override
  String get dotGridArea_4828 => '点阵区域';

  @override
  String get eraser_4829 => '橡皮擦';

  @override
  String get freeDrawing_4830 => '自由绘制';

  @override
  String get text_4831 => '文本';

  @override
  String get imageSelection_4832 => '图片选区';

  @override
  String get unknownTool_4833 => '未知工具';

  @override
  String legendGroupName_7421(Object name) {
    return '图例组: $name';
  }

  @override
  String get selectLayersForLegendGroup_4821 => '选择要绑定到此图例组的图层';

  @override
  String boundLayersTitle(Object count) {
    return '已绑定的图层 ($count)';
  }

  @override
  String availableLayersCount(Object count) {
    return '可用的图层 ($count)';
  }

  @override
  String elementCount(Object count) {
    return '元素: $count';
  }

  @override
  String get noAvailableLayers_7281 => '暂无可用的图层';

  @override
  String layerGroupInfo(Object groupIndex, Object layerCount) {
    return '图层组 $groupIndex ($layerCount 个图层)';
  }

  @override
  String get groupSuffix_7281 => '(组)';

  @override
  String opacityPercentage(Object percentage) {
    return '透明度: $percentage%';
  }

  @override
  String get exportLayerAsPng_7281 => '导出图层为PNG';

  @override
  String get addAllLayers_4821 => '添加全部图层';

  @override
  String previewGenerationFailed_7421(Object e) {
    return '预览生成失败: $e';
  }

  @override
  String get selectableLayers_7281 => '可选择的图层';

  @override
  String get addDividerLine_4821 => '添加分割线';

  @override
  String get addBackground_7281 => '添加背景';

  @override
  String get exportList_7281 => '导出列表';

  @override
  String get addLayerHint_7281 => '点击左侧加号\n添加图层';

  @override
  String get exportPreview_4821 => '导出预览';

  @override
  String get noExportItems_7281 => '暂无导出项目';

  @override
  String get addLayerOrItemFromLeft_4821 => '从左侧添加图层或项目';

  @override
  String imageCount(Object count) {
    return '$count 张图片';
  }

  @override
  String get generatingPreviewImage_7281 => '正在生成预览图片...';

  @override
  String get exportingImage_7421 => '正在导出图片...';

  @override
  String exportSuccessMessage_7421(Object count) {
    return '成功导出 $count 张图片';
  }

  @override
  String get exportFailedRetry_4821 => '导出失败，请重试';

  @override
  String get noValidImageToExport_4821 => '没有有效的图片可导出';

  @override
  String exportFailed_7285(Object e) {
    return '导出失败: $e';
  }

  @override
  String exportFailed_7284(Object e) {
    return '导出失败: $e';
  }

  @override
  String get noValidImageToExport_7281 => '没有有效的图片可导出';

  @override
  String fetchImageFailed_7285(Object e) {
    return '获取图片失败: $e';
  }

  @override
  String get exportImage_7421 => '导出图片';

  @override
  String get exportPdf_7281 => '导出PDF';

  @override
  String imageFetchFailed(Object e) {
    return '获取图片失败: $e';
  }

  @override
  String exportImageTitle_7421(Object index) {
    return '导出图片 $index';
  }

  @override
  String get imageGenerationFailed_4821 => '图片生成失败';

  @override
  String imageDimensions(Object height, Object width) {
    return '尺寸: $width × $height';
  }

  @override
  String get invalidImage => '无效图片';

  @override
  String get background_7281 => '背景';

  @override
  String get dividerText_4821 => '分割线';

  @override
  String layerId(Object id) {
    return '图层 ID: $id';
  }

  @override
  String layerOrderText(Object order) {
    return '顺序: $order';
  }

  @override
  String get backgroundElement_4821 => '背景元素';

  @override
  String legendGroupItemCount(Object count) {
    return '图例组: $count 项';
  }

  @override
  String get background_5421 => '背景';

  @override
  String get untitledNote_4721 => '无标题便签';

  @override
  String get selectLegendGroupToBind_7281 => '选择要绑定到此图层的图例组';

  @override
  String boundLegendGroupsTitle(Object count) {
    return '已绑定的图例组 ($count)';
  }

  @override
  String availableLegendGroups(Object count) {
    return '可用的图例组 ($count)';
  }

  @override
  String get noLegendAvailable_4251 => '暂无图例';

  @override
  String legendCount(Object count) {
    return '$count 个图例';
  }

  @override
  String get manageLegendGroup_7421 => '管理图例组';

  @override
  String get colorFilter_4821 => '色彩滤镜';

  @override
  String get changeImage_4821 => '更换图片';

  @override
  String get uploadImage_5739 => '上传图片';

  @override
  String get backgroundImageSetting_4821 => '背景图片设置';

  @override
  String get removeImage_7421 => '移除图片';

  @override
  String get backgroundDialogClosed_7281 => '背景图片设置对话框已关闭，没有应用更改。';

  @override
  String layerBackgroundUpdated_7281(Object name) {
    return '图层 \"$name\" 的背景图片设置已更新';
  }

  @override
  String get colorFilterSettings_7421 => '色彩滤镜设置';

  @override
  String layerFilterSetMessage(Object filterName, Object layerName) {
    return '图层 \"$layerName\" 的色彩滤镜已设置为：$filterName';
  }

  @override
  String get deleteLayer_4271 => '删除图层';

  @override
  String confirmDeleteLayer_7421(Object name) {
    return '确定要删除图层 \"$name\" 吗？此操作不可撤销。';
  }

  @override
  String get noFilter_1234 => '无滤镜';

  @override
  String get grayscale_5678 => '灰度';

  @override
  String get sepia_9012 => '棕褐色';

  @override
  String get invert_3456 => '反色';

  @override
  String get brightness_7890 => '亮度';

  @override
  String get contrast_1235 => '对比度';

  @override
  String get saturation_6789 => '饱和度';

  @override
  String get hue_0123 => '色相';

  @override
  String get opacityLabel_7281 => '不透明度:';

  @override
  String get groupReordering_7281 => '=== 组重排序 ===';

  @override
  String groupIndexDebug(Object newIndex, Object oldIndex) {
    return '组内oldIndex: $oldIndex, newIndex: $newIndex';
  }

  @override
  String groupLayersDebug_4821(Object layers) {
    return '组内图层: $layers';
  }

  @override
  String groupSize(Object length) {
    return '组大小: $length';
  }

  @override
  String get skipSameIndex_7281 => '索引相同，跳过';

  @override
  String get indexOutOfRange_7281 => 'oldIndex 超出范围，跳过';

  @override
  String adjustNewIndexTo_7421(Object newIndex) {
    return '调整 newIndex 到: $newIndex';
  }

  @override
  String adjustNewIndexTo(Object newIndex) {
    return '调整 newIndex 到: $newIndex';
  }

  @override
  String get skipSameIndexAdjustment_7281 => '调整后索引相同，跳过';

  @override
  String get emptyLayerSkipped_7281 => '图层为空，跳过';

  @override
  String movingLayerDebug_7281(Object isMovingLastElement, Object name) {
    return '移动的图层: $name, 是否为组内最后元素: $isMovingLastElement';
  }

  @override
  String adjustedNewIndex_7421(Object newIndex) {
    return '调整后的 newIndex: $newIndex';
  }

  @override
  String targetPositionAdjustedToGroupEnd(Object adjustedNewIndex) {
    return '目标位置调整为组内最后位置: $adjustedNewIndex';
  }

  @override
  String normalPositionAdjustment(Object adjustedNewIndex) {
    return '正常位置调整: $adjustedNewIndex';
  }

  @override
  String groupGlobalStartPosition(Object groupStartIndex) {
    return '组在全局的起始位置: $groupStartIndex';
  }

  @override
  String targetPositionInGroup_7281(Object adjustedNewIndex) {
    return '目标位置在组内: $adjustedNewIndex';
  }

  @override
  String calculatedNewGlobalIndex(Object newGlobalIndex) {
    return '计算出的新全局索引: $newGlobalIndex';
  }

  @override
  String debugCompleteGroupCheck(Object wasCompleteGroup) {
    return '原组是否为完整连接组: $wasCompleteGroup';
  }

  @override
  String closeLastElementLink(Object name) {
    return '关闭组内最后元素的链接: $name';
  }

  @override
  String enableLayerLinkingToMaintainGroupIntegrity(Object name) {
    return '开启图层链接以保持组完整性: $name';
  }

  @override
  String detectionResultShouldEnableLink_7421(Object shouldEnableLink) {
    return '检测结果 - 应该开启链接: $shouldEnableLink';
  }

  @override
  String enableMobileLayerLink_7421(Object name) {
    return '开启移动图层的链接: $name';
  }

  @override
  String closeNewGroupLastElementLink(Object name) {
    return '关闭新的组内最后元素的链接: $name';
  }

  @override
  String closeLayerLinkToLastPosition(Object name) {
    return '关闭移动到最后位置的图层链接: $name';
  }

  @override
  String get layerIndexOutOfRange_4821 => '找不到图层的全局索引或索引超出范围';

  @override
  String globalIndexDebug_7281(Object newGlobalIndex, Object oldGlobalIndex) {
    return '全局索引: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex';
  }

  @override
  String get groupReorderingLog_7281 => '=== 执行组内重排序（同时处理链接状态和顺序）===';

  @override
  String layersReorderedLog(Object count, Object newIndex, Object oldIndex) {
    return '调用 onLayersInGroupReordered($oldIndex, $newIndex, $count 个图层更新)';
  }

  @override
  String get groupReorderingComplete_7281 => '=== 组内重排序完成 ===';

  @override
  String get skipSameIndex_7421 => '索引相同，跳过';

  @override
  String debugIndexChange(Object newIndex, Object oldIndex) {
    return '组oldIndex: $oldIndex, newIndex: $newIndex';
  }

  @override
  String get groupIndexOutOfRange_7281 => '组索引超出范围';

  @override
  String get sourceGroupEmpty_7281 => '源组为空';

  @override
  String mobileGroupSize(Object length) {
    return '移动组大小: $length';
  }

  @override
  String mobileGroupLayerDebug(Object layers) {
    return '移动组图层: $layers';
  }

  @override
  String get mobileGroupTitle_7281 => '=== 移动组 ===';

  @override
  String groupGlobalIndexDebug(Object newGlobalIndex, Object oldGlobalIndex) {
    return '组全局索引: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex';
  }

  @override
  String movedLayersName_4821(Object layers) {
    return '移动后图层名称: $layers';
  }

  @override
  String get useLegacyReorderMethod_4821 => '使用传统重排序方式';

  @override
  String get batchUpdateWarning_7281 => '警告：没有批量更新接口，无法正确移动组';

  @override
  String get bindLegendGroup_5421 => '点击绑定图例组';

  @override
  String get legendGroupUnavailable_5421 => '图例组不可用';

  @override
  String tagCount_7421(Object count) {
    return '$count 个标签';
  }

  @override
  String get addTag_1589 => '添加标签';

  @override
  String get layerCleared_4821 => '已清空图层标签';

  @override
  String manageLayerTagsTitle(Object name) {
    return '管理图层标签 - $name';
  }

  @override
  String get maxTagsLimitComment => '限制最多10个标签';

  @override
  String updatedLayerLabels_7281(Object labels) {
    return '已更新图层标签：$labels';
  }

  @override
  String get imageUploadSuccess_4821 => '图片上传成功';

  @override
  String get layerNameHint_7281 => '输入图层名称';

  @override
  String get backgroundLayer_1234 => '背景图层';

  @override
  String get foregroundLayer_1234 => '前景图层';

  @override
  String get annotationLayer_1234 => '标注图层';

  @override
  String get referenceLayer_1234 => '参考图层';

  @override
  String get baseLayer_1234 => '基础图层';

  @override
  String get decorationLayer_1234 => '装饰图层';

  @override
  String get imageRemoved_4821 => '图片已移除';

  @override
  String get hideOtherLayers_4271 => '隐藏其他图层';

  @override
  String imageUploadFailed_7421(Object e) {
    return '上传图片失败: $e';
  }

  @override
  String get showAllLayers_7281 => '显示所有图层';

  @override
  String hideOtherLayersMessage(Object name) {
    return '已隐藏其他图层，只显示 \"$name\"';
  }

  @override
  String get allLayersShown_7281 => '已显示所有图层';

  @override
  String get noLayersAvailable_4271 => '暂无图层';

  @override
  String get noLayersAvailable_7281 => '暂无图层';

  @override
  String layerGroupReorderLog(Object newIndex, Object oldIndex) {
    return '图层组重排序：oldIndex=$oldIndex, newIndex=$newIndex';
  }

  @override
  String get selectedText_7421 => '已选中';

  @override
  String selectedLayerGroup_7281(Object group) {
    return '选择图层组: $group';
  }

  @override
  String get selectedWithMultiple_4827 => '已选中 (同时选择)';

  @override
  String get layerGroupSelectionCancelled_4821 => '已取消图层组选择';

  @override
  String selectedLayerGroup(Object count) {
    return '已选中图层组 ($count 个图层)';
  }

  @override
  String selectedLayerGroupWithCount_4821(Object count) {
    return '已选中图层组 ($count 个图层)，可同时操作图层和图层组';
  }

  @override
  String get showAllLayersInGroup_7281 => '已显示组内所有图层';

  @override
  String get hideAllLayersInGroup_7282 => '已隐藏组内所有图层';

  @override
  String groupReorderTriggered(Object newIndex, Object oldIndex) {
    return '组内重排序触发：oldIndex=$oldIndex, newIndex=$newIndex';
  }

  @override
  String get unnamedLegendGroup_4821 => '未命名图例组';

  @override
  String svgThumbnailLoadFailed_4821(Object e) {
    return 'SVG图例缩略图加载失败: $e';
  }

  @override
  String legendDataLoadFailed(Object e, Object legendPath) {
    return '加载图例数据失败: $legendPath, 错误: $e';
  }

  @override
  String updateLegendDataFailed_7284(Object e) {
    return '更新图例数据失败: $e';
  }

  @override
  String get legendGroupTooltip_7281 => '左键：打开图例组管理\n右键：选择图例组';

  @override
  String get legendBlockedMessage_4821 => '图例被遮挡';

  @override
  String get remainingLegendBlocked_4821 => '剩余图例被遮挡';

  @override
  String layerGroupTitle(Object groupNumber, Object layerCount) {
    return '图层组 $groupNumber ($layerCount层)';
  }

  @override
  String get noLegendAvailable_4821 => '暂无图例';

  @override
  String get noBoundLegend_4821 => '无绑定图例';

  @override
  String get noAvailableLegend_4821 => '无可用图例';

  @override
  String legendListTitle(Object count) {
    return '图例列表 ($count)';
  }

  @override
  String get addLegend_4521 => '添加图例';

  @override
  String get loading_5421 => '加载中...';

  @override
  String positionCoordinates_7421(Object dx, Object dy) {
    return '位置: ($dx, $dy)';
  }

  @override
  String get deleteText_4821 => '删除';

  @override
  String get hide_4821 => '隐藏';

  @override
  String get show_4822 => '显示';

  @override
  String get sizeLabel_4821 => '大小';

  @override
  String get rotationLabel_4821 => '旋转';

  @override
  String get linkSettings_4821 => '链接设置';

  @override
  String get label_4821 => '标签';

  @override
  String get legendLinkOptional_4821 => '图例链接 (可选)';

  @override
  String get inputLinkOrSelectFile_4821 => '输入网络链接、选择VFS文件或绑定脚本';

  @override
  String legendLoadingPath_7421(Object actualPath) {
    return '加载图例: 绝对路径=$actualPath';
  }

  @override
  String legendLoadingInfo(Object actualPath, Object folderPath, Object title) {
    return '加载图例: title=$title, folderPath=$folderPath, 相对路径=$actualPath';
  }

  @override
  String legendLoadFailed_7281(Object e, Object legendPath) {
    return '载入图例失败: $legendPath, 错误: $e';
  }

  @override
  String get editLegendGroupName_4271 => '编辑图例组名称';

  @override
  String get legendGroupName_4821 => '图例组名称';

  @override
  String get addLegend_4271 => '添加图例';

  @override
  String get selectLegendFileTooltip_4821 => '选择图例文件';

  @override
  String get selectLegendFileError_4821 => '请选择.legend文件';

  @override
  String get selectVfsFileTooltip_4821 => '选择VFS文件';

  @override
  String get legendItemLabel_4521 => '图例项标签';

  @override
  String get management_7281 => '管理';

  @override
  String get xCoordinateLabel_4521 => 'X坐标';

  @override
  String get rotationAngle_4521 => '旋转角度';

  @override
  String get sizeLabel_4521 => '大小';

  @override
  String get yCoordinateLabel_4821 => 'Y坐标';

  @override
  String get addButton_4821 => '添加';

  @override
  String get deleteLegend_7421 => '删除图例';

  @override
  String get confirmDeleteLegend_4821 => '确定要删除此图例吗？此操作不可撤销。';

  @override
  String get noLayersBoundWarning_4821 => '当前图例组未绑定任何图层';

  @override
  String allLayersHiddenLegendAutoHidden(Object totalLayersCount) {
    return '已启用：绑定的 $totalLayersCount 个图层均已隐藏，图例组已自动隐藏';
  }

  @override
  String autoControlLegendVisibility(Object totalLayersCount) {
    return '启用后，根据绑定图层的可见性自动控制图例组显示/隐藏（共 $totalLayersCount 个图层）';
  }

  @override
  String fileSelectionFailed(Object e) {
    return '文件选择失败: $e';
  }

  @override
  String layerVisibilityStatus(
    Object totalLayersCount,
    Object visibleLayersCount,
  ) {
    return '已启用：绑定的 $totalLayersCount 个图层中有 $visibleLayersCount 个可见，图例组已自动显示';
  }

  @override
  String unsupportedUrlFormat(Object url) {
    return '不支持的链接格式: $url';
  }

  @override
  String openLinkFailed_7285(Object e) {
    return '打开链接失败: $e';
  }

  @override
  String get legendGroupCleared_4281 => '已清空图例组标签';

  @override
  String legendGroupUpdated(Object count) {
    return '图例组标签已更新 ($count个标签)';
  }

  @override
  String manageLegendGroupTagsTitle(Object name) {
    return '管理图例组标签 - $name';
  }

  @override
  String get noTagsAvailable_7421 => '暂无标签';

  @override
  String get manageLegendTagsTitle_4821 => '管理图例项标签';

  @override
  String get building_4821 => '建筑';

  @override
  String get room_4822 => '房间';

  @override
  String get entrance_4823 => '入口';

  @override
  String get device_4824 => '装置';

  @override
  String get shelter_4825 => '掩体';

  @override
  String get path_4826 => '路径';

  @override
  String get marker_4827 => '标记';

  @override
  String get tactic_4828 => '战术';

  @override
  String get important_4829 => '重要';

  @override
  String get destructible_4830 => '可破坏';

  @override
  String get trap_4831 => '陷阱';

  @override
  String get surveillance_4832 => '监控';

  @override
  String get legendItemsCleared_4281 => '已清空图例项标签';

  @override
  String legendLabelsUpdated(Object count) {
    return '图例项标签已更新 ($count个标签)';
  }

  @override
  String get entrance_4821 => '入口';

  @override
  String get stairs_4822 => '楼梯';

  @override
  String get elevator_4823 => '电梯';

  @override
  String get window_4824 => '窗户';

  @override
  String get door_4825 => '门';

  @override
  String get wall_4826 => '墙';

  @override
  String get cover_4827 => '掩体';

  @override
  String get device_4828 => '装置';

  @override
  String get camera_4829 => '摄像头';

  @override
  String get trap_4830 => '陷阱';

  @override
  String get destructible_4831 => '可破坏';

  @override
  String get important_4832 => '重要';

  @override
  String get selectScriptToBind_4271 => '选择要绑定的脚本';

  @override
  String get noAvailableScripts_7281 => '暂无可用的启用脚本';

  @override
  String editScriptParamsFailed_7421(Object e) {
    return '编辑脚本参数失败: $e';
  }

  @override
  String scriptNoParamsRequired(Object name) {
    return '脚本 $name 无需参数';
  }

  @override
  String scriptParamsUpdated_7421(Object name) {
    return '已更新脚本参数: $name';
  }

  @override
  String editScriptParamsFailed(Object e) {
    return '编辑脚本参数失败: $e';
  }

  @override
  String get idChanged_4821 => 'ID变化';

  @override
  String legendItemCountChanged(Object newCount, Object oldCount) {
    return '图例项数量变化: $oldCount -> $newCount';
  }

  @override
  String newLegendGroupItemCount(Object count) {
    return '新图例组有 $count 个图例项';
  }

  @override
  String legendGroupDrawerUpdate(Object reason) {
    return '图例组管理抽屉更新: $reason';
  }

  @override
  String get updateTimeChanged_4821 => '更新时间变化';

  @override
  String get legendGroupNotVisibleError_4821 => '无法选择图例：图例组当前不可见，请先显示图例组';

  @override
  String mapIdChanged(Object oldMapId, Object newMapId) {
    return '地图ID变更: $oldMapId -> $newMapId';
  }

  @override
  String get cannotSelectLegend_4821 => '无法选择图例：请先选择一个绑定了此图例组的图层';

  @override
  String get bindLayer_7281 => '绑定图层';

  @override
  String get restrictedChoice_7281 => '选择受限';

  @override
  String get editNameTooltip_7281 => '编辑名称';

  @override
  String get manageLegendGroupLegends_4821 => '管理图例组中的图例';

  @override
  String get settingsOption_7421 => '设置选项';

  @override
  String get vfsLegendDirectory_4821 => 'VFS图例目录';

  @override
  String get vfsLegendDirectory_7421 => 'VFS图例目录';

  @override
  String get cacheLegend_4521 => '缓存图例';

  @override
  String get cacheLegend_7421 => '缓存图例';

  @override
  String get delete_5421 => '删除';

  @override
  String get editLegendGroup_4271 => '编辑图例组';

  @override
  String get deleteLegendGroup_4271 => '删除图例组';

  @override
  String confirmDeleteLegendGroup_7281(Object name) {
    return '确定要删除图例组 \"$name\" 吗？此操作不可撤销。';
  }

  @override
  String legendItemCount(Object count) {
    return '图例项数量: $count';
  }

  @override
  String get noLegendGroup_4521 => '暂无图例组';

  @override
  String get layerBinding_4271 => '图层绑定';

  @override
  String scaleLevelErrorWithDefault(Object defaultValue, Object e) {
    return '获取缩放等级失败: $e，返回默认值$defaultValue';
  }

  @override
  String get releaseToAddLegend_4821 => '释放以添加图例到此位置';

  @override
  String coordinateConversion(Object clampedPosition, Object localPosition) {
    return '坐标转换: 本地($localPosition) -> 画布($clampedPosition)';
  }

  @override
  String transformInfo(
    Object scaleX,
    Object scaleY,
    Object translateX,
    Object translateY,
  ) {
    return '变换信息: 缩放($scaleX, $scaleY), 平移($translateX, $translateY)';
  }

  @override
  String coordinateConversionFailed_7421(Object e) {
    return '坐标转换失败: $e，使用原始坐标';
  }

  @override
  String buildingLegendGroupTitle(Object name) {
    return '构建图例组: $name';
  }

  @override
  String get legendGroupInvisible_7281 => '图例组不可见，返回空Widget';

  @override
  String get legendGroupEmpty_7281 => '图例组没有图例项';

  @override
  String legendItemInfo(
    Object dx,
    Object dy,
    Object id,
    Object index,
    Object path,
  ) {
    return '图例项 $index: $id, 路径: $path, 位置: ($dx, $dy)';
  }

  @override
  String legendPathDebug(Object legendPath) {
    return '图例路径: $legendPath';
  }

  @override
  String get buildLegendSticker_7421 => '构建图例贴纸';

  @override
  String legendPosition(Object dx, Object dy) {
    return '图例位置: ($dx, $dy)';
  }

  @override
  String debugLegendSessionManagerExists(Object isExists) {
    return '图例会话管理器是否存在: $isExists';
  }

  @override
  String legendVisibility(Object isVisible) {
    return '图例可见性: $isVisible';
  }

  @override
  String get buildLegendSessionManager_4821 => '使用图例会话管理器构建';

  @override
  String get fallbackToAsyncLoading_7281 => '回退到异步加载方式';

  @override
  String futureBuilderStatus(Object connectionState) {
    return 'FutureBuilder 状态: $connectionState';
  }

  @override
  String futureBuilderData(Object data) {
    return 'FutureBuilder 数据: $data';
  }

  @override
  String get unknownLegend_4821 => '未知图例';

  @override
  String futureBuilderError(Object error) {
    return 'FutureBuilder 错误: $error';
  }

  @override
  String get legendSessionManagerStatus_7281 => '图例会话管理器状态:';

  @override
  String loadingStateMessage_5421(Object loadingState) {
    return '  - 加载状态: $loadingState';
  }

  @override
  String legendDataStatus_4821(Object status) {
    return '图例数据: $status';
  }

  @override
  String get loaded_4821 => '已加载';

  @override
  String get notLoaded_4821 => '未加载';

  @override
  String get useLoadedLegendData_7281 => '  - 使用已加载的图例数据';

  @override
  String legendLoadingStatus(Object isLoading) {
    return '  - 图例未加载，是否正在加载: $isLoading';
  }

  @override
  String get unknownLegend_7632 => '未知图例';

  @override
  String legendId_4821(Object id) {
    return '图例ID: $id';
  }

  @override
  String get buildLegendStickerWidget_7421 => '*** 构建图例贴纸Widget ***';

  @override
  String legendVisibilityStatus(Object isVisible) {
    return '图例是否可见: $isVisible';
  }

  @override
  String loadingStatusCheck(Object isLoading) {
    return '是否正在加载: $isLoading';
  }

  @override
  String legendHasImageData(Object hasImageData) {
    return '图例数据有图片: $hasImageData';
  }

  @override
  String get legendInvisibleWidget_4821 => '图例不可见，返回空Widget';

  @override
  String canvasPositionDebug(Object dx, Object dy) {
    return '画布位置: ($dx, $dy)';
  }

  @override
  String get legendNoImageData_4821 => '图例没有图片数据且不在加载中，返回空Widget';

  @override
  String imageSizeAndOffset_7281(Object dx, Object dy, Object imageSize) {
    return '图片大小: $imageSize, 中心偏移: ($dx, $dy)';
  }

  @override
  String legendLoadFailed_7421(Object e, Object legendFile) {
    return '加载图例失败: $legendFile, 错误: $e';
  }

  @override
  String get legendTitle_4821 => '图例';

  @override
  String scriptNotFoundError(Object scriptId) {
    return '未找到绑定的脚本: $scriptId';
  }

  @override
  String get scriptManagerNotInitializedError_42 => '脚本管理器未初始化，无法执行脚本';

  @override
  String unableToOpenUrl(Object url) {
    return '无法打开链接: $url';
  }

  @override
  String legendOperationDisabled(Object name) {
    return '无法操作图例：图例组\"$name\"当前不可见';
  }

  @override
  String cannotOperateLegend(Object name) {
    return '无法操作图例：请先选择一个绑定了图例组\"$name\"的图层';
  }

  @override
  String get editNote_4271 => '编辑便签';

  @override
  String urlOpenFailed_7285(Object e) {
    return '打开链接失败: $e';
  }

  @override
  String get contentLabel_4521 => '内容';

  @override
  String get untitledNote_7281 => '无标题便签';

  @override
  String get titleLabel_4821 => '标题文字';

  @override
  String skipInvisibleLayer(Object name) {
    return '跳过不可见图层: $name';
  }

  @override
  String skippingInvisibleLegendGroup(Object name) {
    return '跳过不可见图例组: $name';
  }

  @override
  String exportLayerFailed_7421(Object e) {
    return '导出图层失败: $e';
  }

  @override
  String boundLayersLog_7284(Object boundLayerNames) {
    return '绑定的图层: $boundLayerNames';
  }

  @override
  String isSelectedCheck(Object isLegendSelected) {
    return '是否选中: $isLegendSelected';
  }

  @override
  String legendRenderOrderDebug_7421(Object legendRenderOrder) {
    return '计算得到的 legendRenderOrder: $legendRenderOrder';
  }

  @override
  String addLegendGroupElement(
    Object isLegendSelected,
    Object legendRenderOrder,
  ) {
    return '添加图例组元素 - renderOrder=$legendRenderOrder, selected=$isLegendSelected';
  }

  @override
  String skippingInvisibleNote(Object title) {
    return '跳过不可见便签: $title';
  }

  @override
  String noteProcessing(
    Object isVisible,
    Object noteIndex,
    Object title,
    Object zIndex,
  ) {
    return '处理便签: $title(zIndex=$zIndex), 索引=$noteIndex, 可见=$isVisible';
  }

  @override
  String newImageElementsDetected_7281(Object count) {
    return '检测到 $count 个新的图片元素，开始预加载';
  }

  @override
  String debugAddNoteElement(
    Object isSelected,
    Object renderOrder,
    Object zIndex,
  ) {
    return '添加便签元素 - renderOrder=$renderOrder (原zIndex=$zIndex), selected=$isSelected';
  }

  @override
  String get clearedImageCache_7281 => '已清理所有图片缓存';

  @override
  String cleanedOrphanedCacheItems(Object count, Object items) {
    return '已清理 $count 个孤立的图片缓存项: $items';
  }

  @override
  String get exportBoundaryNotFound_7281 => '导出边界未找到';

  @override
  String fetchUserPreferenceFailed(Object e) {
    return '获取用户偏好失败: $e';
  }

  @override
  String get nullContextThemeInfo_4821 => 'context为null，无法获取主题信息';

  @override
  String setThemeFilterForLayer(Object id) {
    return '为图层 $id 设置主题适配滤镜';
  }

  @override
  String exportGroupFailed_7285(Object e) {
    return '导出组失败: $e';
  }

  @override
  String dragLegendAccepted_5421(Object legendPath) {
    return '接收到拖拽的图例(onAccept): $legendPath';
  }

  @override
  String dragReleasePosition_7421(Object globalPosition, Object localPosition) {
    return '拖拽释放位置 - 全局: $globalPosition, 本地: $localPosition';
  }

  @override
  String convertedCanvasPosition_7281(Object canvasPosition) {
    return '转换后的画布坐标: $canvasPosition';
  }

  @override
  String get renderBoxWarning_4721 => '警告：无法获取RenderBox，使用默认位置处理拖拽';

  @override
  String get layoutType_7281 => '布局类型: ';

  @override
  String get paperSize_4821 => '纸张大小: ';

  @override
  String get pageOrientation_7281 => '页面方向: ';

  @override
  String get marginLabel_4821 => '页边距: ';

  @override
  String get imageSpacing_7281 => '图片间距: ';

  @override
  String totalImageCount(Object count) {
    return '总图片数量: $count';
  }

  @override
  String layoutTypeName(Object layoutName) {
    return '布局: $layoutName';
  }

  @override
  String paperSizeAndOrientation(Object orientation, Object paperSize) {
    return '纸张: $paperSize ($orientation)';
  }

  @override
  String get webPlatformExportPdf_4728 => 'Web平台将使用打印功能导出PDF';

  @override
  String get printLabel_4271 => '打印';

  @override
  String get printPdf_1234 => '打印PDF';

  @override
  String get exportPdf_5678 => '导出PDF';

  @override
  String get pdfPreview_4521 => 'PDF预览';

  @override
  String get generatePreview_7421 => '生成预览';

  @override
  String get generatingPreview_7421 => '正在生成预览...';

  @override
  String imageTitleWithIndex(Object index) {
    return '图片 $index';
  }

  @override
  String get clickToGeneratePreview_4821 => '点击\"生成预览\"查看PDF效果';

  @override
  String get clickToEditTitleAndContent_7281 => '点击编辑标题和内容';

  @override
  String editImageTitle(Object index) {
    return '编辑图片 $index';
  }

  @override
  String get imageDescriptionHint_4522 => '请输入图片描述内容（可选）';

  @override
  String get titleLabel_4521 => '标题';

  @override
  String get imageTitleHint_4522 => '请输入图片标题（可选）';

  @override
  String get exportAsPdf_7281 => '导出为PDF';

  @override
  String get enterFileName_4821 => '请输入文件名';

  @override
  String get preparingToPrint_7281 => '正在准备打印...';

  @override
  String get pdfPrintDialogOpened_4821 => 'PDF打印对话框已打开';

  @override
  String get pdfPrintFailed_4821 => 'PDF打印失败，请重试';

  @override
  String pdfPrintFailed_7281(Object e) {
    return 'PDF打印失败: $e';
  }

  @override
  String pdfGenerationFailed_7281(Object e) {
    return 'PDF文档生成失败: $e';
  }

  @override
  String get generatingPdf_7421 => '正在生成PDF...';

  @override
  String pdfExportFailed_7281(Object e) {
    return 'PDF导出失败: $e';
  }

  @override
  String get pdfExportSuccess_4821 => 'PDF导出成功';

  @override
  String get fileNameHint_4521 => '请输入文件名';

  @override
  String imageListTitle(Object count) {
    return '图片列表 ($count张)';
  }

  @override
  String get noLayerGroups_4521 => '暂无图层组';

  @override
  String get emptyNote_4251 => '空便签';

  @override
  String get noRecentColors_4821 => '暂无最近颜色';

  @override
  String get drawingTools_4821 => '绘图工具';

  @override
  String get recentColors_7281 => '最近颜色';

  @override
  String get layerGroups_4821 => '图层组';

  @override
  String get layersLabel_4821 => '图层';

  @override
  String get stickyNoteLabel_4821 => '便签';

  @override
  String get scriptEngine_4521 => '脚本引擎';

  @override
  String get totalCountLabel_4821 => '总数';

  @override
  String get runningStatus_5421 => '运行中';

  @override
  String get refreshStatus_4821 => '刷新状态';

  @override
  String get automation_7281 => '自动化';

  @override
  String get viewExecutionLogs_4821 => '查看执行日志';

  @override
  String get animation_7281 => '动画';

  @override
  String get filterLabel_4281 => '过滤';

  @override
  String get statistics_4821 => '统计';

  @override
  String get createScript_4821 => '创建脚本';

  @override
  String noScriptsAvailable_7421(Object type) {
    return '暂无$type脚本';
  }

  @override
  String get executing_7421 => '执行中...';

  @override
  String get stopExecution_7421 => '停止执行';

  @override
  String executionSuccessWithTime(Object time) {
    return '执行成功 (${time}ms)';
  }

  @override
  String get executionFailed_7281 => '执行失败';

  @override
  String returnValue_4821(Object result) {
    return '返回值: $result';
  }

  @override
  String get executionSuccess_5421 => '执行成功';

  @override
  String get executionFailed_5421 => '执行失败';

  @override
  String get executeScript_4821 => '执行脚本';

  @override
  String get editButton_7281 => '编辑';

  @override
  String get runButton_7421 => '运行';

  @override
  String get copyLabel_4821 => '复制';

  @override
  String get deleteScript_4271 => '删除脚本';

  @override
  String get deleteButton_7281 => '删除';

  @override
  String confirmDeleteScript_7421(Object name) {
    return '确定要删除脚本 \"$name\" 吗？';
  }

  @override
  String get scriptExecutionLog_4821 => '脚本执行日志';

  @override
  String totalLogsCount_7421(Object count) {
    return '共 $count 条';
  }

  @override
  String get noExecutionLogs_7421 => '暂无执行日志';

  @override
  String get scriptExecutionLogs_4521 => '执行脚本时的日志会显示在这里';

  @override
  String get clearLogs_4271 => '清空日志';

  @override
  String get refreshLabel_7421 => '刷新';

  @override
  String get deleteVersion_4271 => '删除版本';

  @override
  String confirmDeleteVersion_7281(Object versionName) {
    return '确定要删除版本 \"$versionName\" 吗？\n此操作无法撤销。';
  }

  @override
  String responsiveVersionTabDebug(
    Object currentVersion,
    Object hasUnsavedVersions,
    Object versionCount,
  ) {
    return '响应式版本标签栏构建: 版本数量=$versionCount, 当前版本=$currentVersion, 未保存版本=$hasUnsavedVersions';
  }

  @override
  String get noVersionAvailable_7281 => '暂无版本';

  @override
  String get createNewVersion_4821 => '创建新版本';

  @override
  String scriptExecutionFailed_7281(Object error) {
    return '脚本执行失败: $error';
  }

  @override
  String get unsavedChanges_4821 => '未保存的更改';

  @override
  String get unsavedChangesWarning_4821 => '您有未保存的更改，确定要关闭吗？';

  @override
  String get discardChanges_7421 => '放弃更改';

  @override
  String get saveAndClose_7281 => '保存并关闭';

  @override
  String get unsavedText_7421 => '未保存';

  @override
  String get closeEditor_7421 => '关闭编辑器';

  @override
  String get switchToLightTheme_7421 => '切换到亮色主题';

  @override
  String get switchToDarkTheme_8532 => '切换到暗色主题';

  @override
  String get saveScript_4821 => '保存脚本';

  @override
  String get scrollToTop_4821 => '跳转到顶部';

  @override
  String get scrollToBottom_4821 => '跳转到底部';

  @override
  String get runText_4821 => '运行';

  @override
  String get inProgress_7421 => '执行中';

  @override
  String get scriptSaved_4821 => '脚本已保存';

  @override
  String runningScriptsCount(Object count) {
    return '运行中的脚本 ($count)';
  }

  @override
  String get idleStatus_7421 => '空闲状态';

  @override
  String scriptCount(Object count) {
    return '$count 个脚本';
  }

  @override
  String get scriptEngineStatusMonitoring_7281 => '脚本引擎状态监控';

  @override
  String get executionEngine_4821 => '执行引擎';

  @override
  String get totalScriptsLabel_4821 => '总脚本';

  @override
  String get systemMetrics_4521 => '系统指标';

  @override
  String get errorLabel_4821 => '错误';

  @override
  String get executionEngine_4521 => '执行引擎';

  @override
  String get runningStatus_4821 => '运行中';

  @override
  String get noRunningScripts_7421 => '当前没有运行中的脚本';

  @override
  String get stopScript_7421 => '停止脚本';

  @override
  String get recentExecutionRecords_4821 => '最近执行记录';

  @override
  String get noExecutionRecords_4521 => '暂无执行记录';

  @override
  String hoursAgo_7281(Object hours) {
    return '$hours小时前';
  }

  @override
  String get daysAgo_7283 => '天前';

  @override
  String get versionManagement_4821 => '版本管理';

  @override
  String get previousVersion_4822 => '上一个版本';

  @override
  String get nextVersion_4823 => '下一个版本';

  @override
  String get createNewVersion_4824 => '创建新版本';

  @override
  String get quickSelectLayerGroup => '快速选择 (图层组)';

  @override
  String get selectLayerGroup1 => '选择图层组 1';

  @override
  String get selectLayerGroup2 => '选择图层组 2';

  @override
  String get selectLayerGroup3 => '选择图层组 3';

  @override
  String get selectLayerGroup4 => '选择图层组 4';

  @override
  String get selectLayerGroup5 => '选择图层组 5';

  @override
  String get selectLayerGroup6 => '选择图层组 6';

  @override
  String get selectLayerGroup7 => '选择图层组 7';

  @override
  String get selectLayerGroup8 => '选择图层组 8';

  @override
  String get selectLayerGroup9 => '选择图层组 9';

  @override
  String get selectLayerGroup10 => '选择图层组 10';

  @override
  String get notSet_7281 => '未设置';

  @override
  String get shortcutList_4821 => '快捷键列表';

  @override
  String get quickSelectLayerCategory_4821 => '快速选择 (图层)';

  @override
  String get selectLayer1_4822 => '选择图层 1';

  @override
  String get selectLayer2_4823 => '选择图层 2';

  @override
  String get selectLayer3_4824 => '选择图层 3';

  @override
  String get selectLayer4_4825 => '选择图层 4';

  @override
  String get selectLayer5_4826 => '选择图层 5';

  @override
  String get selectLayer6_4827 => '选择图层 6';

  @override
  String get selectLayer7_4828 => '选择图层 7';

  @override
  String get selectLayer8_4829 => '选择图层 8';

  @override
  String get selectLayer9_4830 => '选择图层 9';

  @override
  String get selectLayer10_4831 => '选择图层 10';

  @override
  String get selectLayer11_4832 => '选择图层 11';

  @override
  String get selectLayer12_4833 => '选择图层 12';

  @override
  String get basicOperations_4821 => '基本操作';

  @override
  String get undo_4822 => '撤销';

  @override
  String get redo_4823 => '重做';

  @override
  String get save_4824 => '保存';

  @override
  String get clearSelection_4825 => '清除选择';

  @override
  String get uiControl_4821 => '界面控制';

  @override
  String get toggleSidebar_4822 => '切换侧边栏';

  @override
  String get openZInspector_4823 => '打开Z层级检视器';

  @override
  String get toggleLegendGroupDrawer_4824 => '切换图例组抽屉';

  @override
  String get legendOperations_4821 => '图例操作';

  @override
  String get previousLegendGroup_4822 => '上一个图例组';

  @override
  String get nextLegendGroup_4823 => '下一个图例组';

  @override
  String get openLegendDrawer_4824 => '打开图例组绑定抽屉';

  @override
  String get hideOtherLegendGroups_4825 => '隐藏其他图例组';

  @override
  String get showCurrentLegendGroup_4826 => '显示当前图例组';

  @override
  String get layerOperations_4821 => '图层操作';

  @override
  String get previousLayer_4822 => '上一个图层';

  @override
  String get nextLayer_4823 => '下一个图层';

  @override
  String get previousLayerGroup_4824 => '上一个图层组';

  @override
  String get nextLayerGroup_4825 => '下一个图层组';

  @override
  String get hideOtherLayers_4826 => '隐藏其他图层';

  @override
  String get hideOtherLayerGroups_4827 => '隐藏其他图层组';

  @override
  String get showCurrentLayer_4828 => '显示当前图层';

  @override
  String get showCurrentLayerGroup_4829 => '显示当前图层组';

  @override
  String get showShortcutsList_7281 => '显示快捷键列表';

  @override
  String noteImagePreloadFailed_7421(Object elementId, Object error) {
    return '便签图片预加载失败: element.id=$elementId, 错误=$error';
  }

  @override
  String noteRendererElementCount(Object count) {
    return '便签绘制器: 元素数量=$count';
  }

  @override
  String elementDebugInfo_7428(Object i, Object imageData, Object typeName) {
    return '元素[$i]: 类型=$typeName, imageData=$imageData';
  }

  @override
  String noteBackgroundLoadFailed(Object error) {
    return '便签背景图片加载失败 (直接数据): $error';
  }

  @override
  String noteBackgroundImageHashRef(Object backgroundImageHash) {
    return '便签背景图片只有VFS哈希引用: $backgroundImageHash';
  }

  @override
  String get drawingAreaHint_4821 => '可在此区域绘制';

  @override
  String get noteBackgroundImageHint_4821 => '提示: 便签背景图片应该在加载时已恢复为直接数据';

  @override
  String get backgroundImage_7421 => '背景图片';

  @override
  String noteDrawingStats(Object elementCount, Object imageCacheCount) {
    return '便签绘制: 元素=$elementCount, 图片缓存=$imageCacheCount';
  }

  @override
  String noteQueueDebugPrint(Object noteId, Object queueLength) {
    return '便签队列渲染: 便签ID=$noteId, 队列项目=$queueLength';
  }

  @override
  String editNoteDebug(Object id) {
    return '编辑便签: $id';
  }

  @override
  String noteImagePreloadComplete(Object height, Object id, Object width) {
    return '便签图片预加载完成: element.id=$id, 图片尺寸=${width}x$height';
  }

  @override
  String get addNote_7421 => '添加便签';

  @override
  String get deleteNoteTooltip_7281 => '删除便签';

  @override
  String get noteTitleHint_4821 => '便签标题';

  @override
  String noteElementInspectorWithCount_7421(Object count) {
    return '便签元素检视器 ($count个元素)';
  }

  @override
  String get noteElementInspectorEmpty_1589 => '便签元素检视器 (无元素)';

  @override
  String get untitledNote_4821 => '无标题便签';

  @override
  String get changeBackgroundImage_5421 => '更换背景图片';

  @override
  String get uploadBackgroundImage_5421 => '上传背景图片';

  @override
  String get backgroundImageSetting_4271 => '背景图片设置';

  @override
  String get removeBackgroundImage_4271 => '移除背景图片';

  @override
  String get backgroundImageUploaded_4821 => '背景图片已上传';

  @override
  String noteBackgroundImageUploaded(Object length) {
    return '便签背景图片已上传，将在地图保存时存储到资产系统 ($length bytes)';
  }

  @override
  String imageUploadFailed(Object e) {
    return '上传图片失败: $e';
  }

  @override
  String get imageFitMethod_7281 => '图片适应方式';

  @override
  String get boxFitContain_7281 => '包含';

  @override
  String get boxFitCover_7285 => '覆盖';

  @override
  String get fitWidthOption_4821 => '适合宽度';

  @override
  String get fitHeight_4821 => '适合高度';

  @override
  String backgroundImageOpacityLabel(Object value) {
    return '背景图片透明度: $value%';
  }

  @override
  String get backgroundImageRemoved_4821 => '背景图片已移除';

  @override
  String get selectNoteColor_7281 => '选择便签颜色';

  @override
  String confirmDeleteNote(Object title) {
    return '确定要删除便签 \"$title\" 吗？此操作不可撤销。';
  }

  @override
  String get copyNote_7281 => '复制便签';

  @override
  String get emptyNotesMessage_7421 => '暂无便签\n点击上方按钮添加新便签';

  @override
  String get expandNote_5421 => '展开便签';

  @override
  String get collapseNote_5421 => '折叠便签';

  @override
  String get moveToTop_7281 => '移到顶层';

  @override
  String get copyFeatureComingSoon_7281 => '复制功能将在下个版本中实现';

  @override
  String get management_4821 => '管理';

  @override
  String get noteMovedToTop1234 => '便签已移到顶层';

  @override
  String get label_5421 => '标签';

  @override
  String noteTagsUpdated(Object count) {
    return '便签标签已更新 ($count个标签)';
  }

  @override
  String get notesTagsCleared_7281 => '已清空便签标签';

  @override
  String manageNoteTagsTitle(Object title) {
    return '管理便签标签 - $title';
  }

  @override
  String get noTagsAvailable_7281 => '暂无标签';

  @override
  String get important_1234 => '重要';

  @override
  String get todo_5678 => '待办';

  @override
  String get completed_9012 => '已完成';

  @override
  String get temporary_3456 => '临时';

  @override
  String get reminder_7890 => '提醒';

  @override
  String get idea_2345 => '想法';

  @override
  String get plan_6789 => '计划';

  @override
  String get problem_0123 => '问题';

  @override
  String get solution_4567 => '解决方案';

  @override
  String get note_8901 => '备注';

  @override
  String get analysis_2346 => '分析';

  @override
  String get summary_7892 => '总结';

  @override
  String get loadingVfsDirectory_7421 => '正在加载VFS目录结构...';

  @override
  String get failedToLoadVfsDirectory_7281 => '无法加载VFS目录';

  @override
  String selectedDirectoriesCount(Object count) {
    return '已选中: $count 个目录';
  }

  @override
  String get stepSelectionModeHint_4821 => '步进型选择模式：只选择当前目录，不会递归选择子目录';

  @override
  String get refreshDirectoryTree_7281 => '刷新目录树';

  @override
  String stepperSelection_4821(Object path) {
    return '步进型选择: 选中目录 $path';
  }

  @override
  String stepperCancelLog(Object path) {
    return '步进型取消: 取消选中目录 $path';
  }

  @override
  String startLoadingLegendsToCache(Object directoryPath) {
    return '开始从目录加载图例到缓存: $directoryPath';
  }

  @override
  String foundLegendFilesInDirectory(Object count, Object directoryPath) {
    return '在目录 $directoryPath 中找到 $count 个图例文件';
  }

  @override
  String cachedLegendPath_7421(Object legendPath) {
    return '已缓存图例: $legendPath';
  }

  @override
  String loadLegendFailed(Object directoryPath, Object e) {
    return '从目录加载图例失败: $directoryPath, 错误: $e';
  }

  @override
  String get directorySelectedByOthers_4821 => '此目录已被其他图例组选择';

  @override
  String directorySelectedByGroup(Object groupName) {
    return '此目录已被图例组 \"$groupName\" 选择';
  }

  @override
  String directoryUsedByGroups(Object groupNames) {
    return '此目录已被以下图例组选择：$groupNames';
  }

  @override
  String selectedPathsCount_7421(Object otherCount, Object selectedCount) {
    return '当前组选中路径: $selectedCount 个，其他组选中: $otherCount 个';
  }

  @override
  String syncTreeStatusLegendGroup(Object legendGroupId) {
    return '同步树状态（步进型）- 当前图例组: $legendGroupId';
  }

  @override
  String zIndexLabel(Object zIndex) {
    return 'Z层级: $zIndex';
  }

  @override
  String pointsCount(Object count) {
    return '点数: $count';
  }

  @override
  String get deleteElementTooltip_7281 => '删除元素';

  @override
  String get manageTags_4821 => '管理标签';

  @override
  String get zLevel_4821 => 'Z层级';

  @override
  String get textContent_4821 => '文本内容';

  @override
  String get fontSize_4821 => '字体大小';

  @override
  String get line_4821 => '直线';

  @override
  String get singleDiagonalLine_4826 => '单斜线';

  @override
  String get crossLines_4827 => '交叉线';

  @override
  String get dotGrid_4828 => '点阵';

  @override
  String get pixelPen_4829 => '像素笔';

  @override
  String get text_4830 => '文本';

  @override
  String get eraser_4831 => '橡皮擦';

  @override
  String get imageSelectionArea_4832 => '图片选区';

  @override
  String get strokeWidth_4821 => '描边宽度';

  @override
  String get rotationAngle_4721 => '旋转角度';

  @override
  String get densityLabel_4821 => '密度';

  @override
  String get curvatureLabel_7281 => '弧度';

  @override
  String get triangleDivision_4821 => '三角分割';

  @override
  String get stickyNoteNoElements_4821 => '便签没有绘制元素';

  @override
  String get layerNoElements_4822 => '图层没有绘制元素';

  @override
  String manageTagsTitle_7421(Object type) {
    return '管理 $type 标签';
  }

  @override
  String get markedTag_5678 => '标记';

  @override
  String get temporaryTag_9012 => '临时';

  @override
  String get completedTag_3456 => '完成';

  @override
  String confirmDeleteElement_4821(Object type) {
    return '确定要删除这个$type元素吗？';
  }

  @override
  String zIndexLabel_1567(Object zIndex) {
    return 'Z层级: $zIndex';
  }

  @override
  String contentLabel_7392(Object text) {
    return '内容: $text';
  }

  @override
  String get operationCanBeUndone_8245 => '此操作可以通过撤销功能恢复。';

  @override
  String get editZIndexTitle_7281 => '编辑Z层级';

  @override
  String get zLevelLabel_4521 => 'Z层级';

  @override
  String get inputNumberHint_4522 => '输入数字';

  @override
  String get editTextContent_4821 => '编辑文本内容';

  @override
  String get textContentLabel_4821 => '文本内容';

  @override
  String elementListWithCount(Object count) {
    return '元素列表 ($count)';
  }

  @override
  String get editFontSize_4821 => '编辑字体大小';

  @override
  String get fontSizeLabel_4821 => '字体大小';

  @override
  String get inputNumberHint_5732 => '输入数字';

  @override
  String get editStrokeWidth_4271 => '编辑描边宽度';

  @override
  String currentValueWithUnit(Object value) {
    return '当前值: ${value}x';
  }

  @override
  String get editRotationAngle_4271 => '编辑旋转角度';

  @override
  String get editRadial_7421 => '编辑弧度';

  @override
  String currentValuePercentage(Object value) {
    return '当前值: $value%';
  }

  @override
  String get editDensity_4271 => '编辑密度';

  @override
  String get selectTriangulation_4271 => '选择三角分割';

  @override
  String get websocketConnectionManagement_4821 => 'WebSocket 连接管理';

  @override
  String get websocketClientConfig_4821 => '管理 WebSocket 客户端连接配置';

  @override
  String get webDavConfigTitle_7281 => '配置和管理 WebDAV 云存储连接';

  @override
  String get about_5421 => '关于';

  @override
  String get aboutR6box_7281 => '关于 R6BOX';

  @override
  String get softwareInfoLicenseAcknowledgements_4821 => '软件信息、许可证和开源项目致谢';

  @override
  String get personalSettingsManagement_4821 => '管理主题、地图编辑器、界面布局等个人设置';

  @override
  String get importExportBrowseData_4821 => '导入、导出和浏览应用数据';

  @override
  String get webDavManagement_4271 => 'WebDAV 管理';

  @override
  String resetFailedWithError(Object error) {
    return '重置失败：$error';
  }

  @override
  String get resetAllSettings_4821 => '重置所有设置';

  @override
  String loadUserPreferencesFailed_7421(Object error) {
    return '加载用户偏好设置失败: $error';
  }

  @override
  String exportFailed_7421(Object error) {
    return '导出失败：$error';
  }

  @override
  String get extendedSettingsStorage_4821 => '扩展设置存储';

  @override
  String get mapPreferencesDescription_4821 =>
      '用于存储临时的地图相关偏好设置，如图例组智能隐藏状态等。这些设置不会影响地图数据本身。';

  @override
  String storageStats_7281(Object count, Object size) {
    return '存储大小: $size KB | 键值对数量: $count';
  }

  @override
  String get editJson_7281 => '编辑JSON';

  @override
  String get saveButton_7281 => '保存';

  @override
  String get noExtensionSettingsData_7421 => '当前没有扩展设置数据';

  @override
  String get jsonData_4821 => 'JSON数据';

  @override
  String get extensionStorageDisabled_4821 => '扩展设置存储已禁用';

  @override
  String get clearExtensionSettingsTitle_4821 => '清空扩展设置';

  @override
  String get clearExtensionSettingsWarning_4821 => '确定要清空所有扩展设置吗？此操作不可撤销。';

  @override
  String get extensionSettingsCleared_4821 => '扩展设置已清空';

  @override
  String get extensionSettingsSaved_4821 => '扩展设置已保存';

  @override
  String saveFailedError_7281(Object error) {
    return '保存失败: $error';
  }

  @override
  String get displayLocaleSetting_4821 => '显示区域设置';

  @override
  String displayAreaMultiplierText(Object value) {
    return '显示区域倍数: ${value}x';
  }

  @override
  String windowScalingFactorLabel(Object value) {
    return '窗口大小随动系数: $value';
  }

  @override
  String get performanceSettings_7281 => '性能设置';

  @override
  String baseGridSpacing_4827(Object value) {
    return '基础网格间距: ${value}px';
  }

  @override
  String baseIconSizeText(Object size) {
    return '基础图标大小: ${size}px';
  }

  @override
  String cameraSpeedLabel(Object speed) {
    return '摄像机移动速度: ${speed}px/s';
  }

  @override
  String get enableThemeColorFilter_7281 => '启用主题颜色滤镜';

  @override
  String get visualEffectsSettings_4821 => '视觉效果设置';

  @override
  String get homePageSettings_4821 => '主页设置';

  @override
  String get adaptiveIconTheme_7421 => '让图标颜色适应当前主题';

  @override
  String baseBufferMultiplierText(Object value) {
    return '基础缓冲区倍数: ${value}x';
  }

  @override
  String perspectiveBufferFactorLabel(Object factor) {
    return '透视缓冲调节系数: ${factor}x';
  }

  @override
  String iconEnlargementFactorLabel(Object factor) {
    return '图标放大系数: ${factor}x';
  }

  @override
  String svgDistributionRecordCount(Object recentSvgHistorySize) {
    return 'SVG分布记录数量: $recentSvgHistorySize';
  }

  @override
  String get titleSetting_1234 => '标题设置';

  @override
  String get titleHint_4821 => '输入主页标题文字';

  @override
  String titleFontSizeMultiplierText(Object value) {
    return '标题字体大小倍数: $value%';
  }

  @override
  String get showTooltip_4271 => '显示工具提示';

  @override
  String get hoverHelpText_4821 => '鼠标悬停时显示帮助信息';

  @override
  String get verticalLayoutNavBar_4821 => '将导航栏显示在屏幕右侧（垂直布局）';

  @override
  String get rightVerticalNavigation_4271 => '右侧垂直导航';

  @override
  String get windowControlMode_4821 => '窗口控件模式';

  @override
  String get windowControlDisplayMode_4821 => '选择窗口控制按钮的显示方式';

  @override
  String get separate_7281 => '分离';

  @override
  String get mergeText_7421 => '合并';

  @override
  String get mergeExpand_4281 => '合并展开';

  @override
  String get enableAnimation_7281 => '启用动画';

  @override
  String get interfaceSwitchAnimation_7281 => '界面切换和过渡动画';

  @override
  String get animationDuration_4271 => '动画持续时间';

  @override
  String get windowSettings_4821 => '窗口设置';

  @override
  String get autoSaveWindowSize_4271 => '自动保存窗口大小';

  @override
  String get autoResizeWindowHint_4821 => '自动记录窗口大小变化并在下次启动时恢复';

  @override
  String get layoutSettings_4821 => '界面布局设置';

  @override
  String get panelCollapseStatus_4821 => '面板折叠状态';

  @override
  String get collapsedState_5421 => '折叠';

  @override
  String get expandedState_5421 => '展开';

  @override
  String get savePanelStateChange_4821 => '保存面板状态变更';

  @override
  String get autoCloseWhenLoseFocus_7281 => '自动关闭';

  @override
  String get keepOpenWhenLoseFocus_7281 => '保持开启';

  @override
  String get panelAutoClose_4821 => '面板自动关闭';

  @override
  String get sidebarWidth_4271 => '侧边栏宽度';

  @override
  String get autoSavePanelStateOnExit_4821 => '退出地图编辑器时自动保存面板折叠/展开状态';

  @override
  String get compactMode_7281 => '紧凑模式';

  @override
  String get reduceSpacingForSmallScreen_7281 => '减少界面元素间距，适合小屏幕';

  @override
  String get defaultLegendSize_4821 => '默认图例大小';

  @override
  String get legendSize_4821 => '图例大小';

  @override
  String get enterSubMenuImmediately_4721 => '立即进入子菜单';

  @override
  String enterSubMenuAfterDelay_4721(Object delay) {
    return '鼠标停止移动${delay}ms后进入子菜单';
  }

  @override
  String get dynamicSize_4821 => '动态大小';

  @override
  String legendSizeValue_4821(Object value) {
    return '$value';
  }

  @override
  String get shortcutSettings_4821 => '快捷键设置';

  @override
  String get dynamicFormulaText_7281 => '使用动态公式：1/(缩放*系数)';

  @override
  String fixedSizeText_7281(Object size) {
    return '固定大小：$size';
  }

  @override
  String get shortcutManagement_4821 => '快捷键管理';

  @override
  String get viewEditShortcutSettings_4821 => '点击查看和编辑所有快捷键设置';

  @override
  String get notSet_4821 => '未设置';

  @override
  String get shortcutEditHint_7281 => '点击编辑按钮可以修改对应功能的快捷键';

  @override
  String get restoreDefaults_7421 => '恢复默认';

  @override
  String get editShortcutTooltip_4821 => '编辑快捷键';

  @override
  String get restoreDefaultShortcuts_4821 => '恢复默认快捷键';

  @override
  String get resetShortcutsConfirmation_4821 =>
      '确定要将所有快捷键恢复到默认设置吗？此操作将覆盖您的自定义快捷键设置。';

  @override
  String get shortcutsResetToDefault_4821 => '已恢复所有快捷键到默认设置';

  @override
  String get confirm_4821 => '确定';

  @override
  String get editShortcuts_7421 => '编辑快捷键';

  @override
  String setShortcutForAction(Object action) {
    return '为 $action 设置快捷键';
  }

  @override
  String get currentShortcutKey_4821 => '当前快捷键:';

  @override
  String get notSet_7421 => '未设置';

  @override
  String get addNewShortcut_7421 => '添加新快捷键:';

  @override
  String get shortcutInstruction_4821 => '点击下方区域，然后按下您想要添加的快捷键组合';

  @override
  String get pressShortcutFirst_4821 => '请先按下快捷键组合';

  @override
  String duplicateShortcutWarning(Object shortcut) {
    return '快捷键重复: $shortcut 已在当前列表中';
  }

  @override
  String get addShortcut_7421 => '添加快捷键';

  @override
  String shortcutConflict_4827(Object conflictName, Object shortcut) {
    return '快捷键冲突: $shortcut 已被 \"$conflictName\" 使用';
  }

  @override
  String duplicateShortcutsWarning_7421(Object duplicates) {
    return '列表中存在重复快捷键: $duplicates';
  }

  @override
  String shortcutConflictMessage(Object conflictName, Object shortcut) {
    return '快捷键冲突: $shortcut 已被 \"$conflictName\" 使用';
  }

  @override
  String get undoHistoryCount_4821 => '撤销历史记录数量';

  @override
  String get mapEditorSettings_7421 => '地图编辑器设置';

  @override
  String get backgroundPattern_4271 => '背景图案';

  @override
  String undoStepsLabel(Object count) {
    return '$count 步';
  }

  @override
  String get blankPattern_4821 => '空白';

  @override
  String get gridPattern_4821 => '网格';

  @override
  String get checkerboardPattern_4821 => '棋盘格';

  @override
  String get zoomSensitivity_4271 => '缩放敏感度';

  @override
  String get canvasMargin_4821 => '画布边距';

  @override
  String canvasBoundaryMarginDescription(Object margin) {
    return '控制画布内容与容器边缘的距离：${margin}px';
  }

  @override
  String get rouletteMenuSettings_4821 => '轮盘菜单设置';

  @override
  String get triggerButton_7421 => '触发按键';

  @override
  String get menuRadius_4271 => '菜单半径';

  @override
  String get middleButton_7281 => '中键';

  @override
  String get rightClick_4271 => '右键';

  @override
  String get centerRadius_4821 => '中心区域半径';

  @override
  String get objectOpacity_4271 => '对象不透明度';

  @override
  String get backgroundOpacity_4271 => '背景不透明度';

  @override
  String get backButton_7421 => '返回';

  @override
  String get submenuDelay_4821 => '子菜单延迟';

  @override
  String get enterImmediately_4821 => '立即进入';

  @override
  String delayWithMs(Object delay) {
    return '${delay}ms';
  }

  @override
  String get useSystemColorTheme_4821 => '使用系统颜色主题';

  @override
  String get increaseTextContrast_4821 => '提高文本和背景的对比度';

  @override
  String get highContrastMode_4271 => '高对比度';

  @override
  String get canvasThemeAdaptation_7281 => '画布主题适配';

  @override
  String get darkThemeCanvasAdjustment_4821 => '在暗色主题下调整画布背景和绘制元素的可见性';

  @override
  String get primaryColor_7285 => '主色调';

  @override
  String ttsTestStartedPlaying(Object languageName) {
    return 'TTS 测试已开始播放 ($languageName)';
  }

  @override
  String ttsTestFailed(Object error) {
    return 'TTS 测试失败: $error';
  }

  @override
  String get resetTtsSettings_4271 => '重置TTS设置';

  @override
  String get confirmResetTtsSettings_4821 => '确定要重置TTS设置为默认值吗？';

  @override
  String get ttsSettingsReset_4821 => 'TTS设置已重置';

  @override
  String get resetButton_7421 => '重置';

  @override
  String get addCustomTag_4271 => '添加自定义标签';

  @override
  String get labelName_4821 => '标签名称';

  @override
  String get hintLabelName_7532 => '输入标签名称';

  @override
  String get addButton_7284 => '添加';

  @override
  String get languageSetting_4821 => '语言';

  @override
  String get defaultLanguage_7421 => '默认';

  @override
  String get defaultOption_7281 => '默认';

  @override
  String get unknownVoice_4821 => '未知语音';

  @override
  String get defaultVoice_4821 => '默认';

  @override
  String get customVoice_5732 => '自定义语音';

  @override
  String get voiceTitle_4271 => '语音';

  @override
  String get defaultText_1234 => '默认';

  @override
  String get addCustomColor_4271 => '添加自定义颜色';

  @override
  String get clearButton_7421 => '清空';

  @override
  String get commonLineWidth_4521 => '常用线条宽度';

  @override
  String get toolbarLayout_4521 => '工具栏布局';

  @override
  String get showAdvancedTools_4271 => '显示高级工具';

  @override
  String get showProToolsInToolbar_4271 => '在工具栏中显示专业级工具';

  @override
  String get toolSettings_4821 => '工具设置';

  @override
  String get dragHandleSizeHint_4821 => '拖动控制柄大小';

  @override
  String get handleSize_4821 => '控制柄大小';

  @override
  String get adjustDrawingElementHandleSize_7281 => '调整绘制元素控制柄的大小';

  @override
  String get resetToolSettings_4271 => '重置工具设置';

  @override
  String currentSize_7421(Object size) {
    return '当前: ${size}px';
  }

  @override
  String tagCount(Object count) {
    return '$count 个标签';
  }

  @override
  String get noCustomTags_7281 => '暂无自定义标签';

  @override
  String get manageTags_4271 => '管理标签';

  @override
  String get addLabel_4271 => '添加标签';

  @override
  String get enableSpeechSynthesis_4271 => '启用语音合成';

  @override
  String get ttsSettingsTitle_4821 => 'TTS 语音合成设置';

  @override
  String get voiceSpeed_4251 => '语音速度';

  @override
  String get enableVoiceReadingFeature_4821 => '开启后将支持语音朗读功能';

  @override
  String get adjustVoiceSpeed_4271 => '调整语音播放速度';

  @override
  String get slow_7284 => '慢';

  @override
  String get fast_4821 => '快';

  @override
  String currentSpeechRate(Object percentage) {
    return '当前: $percentage%';
  }

  @override
  String get adjustVoiceVolume_4251 => '调整语音播放音量';

  @override
  String get volumeTitle_4821 => '音量';

  @override
  String currentVolume(Object percentage) {
    return '当前: $percentage%';
  }

  @override
  String get toneTitle_4821 => '音调';

  @override
  String get adjustVoicePitch_4271 => '调整语音音调高低';

  @override
  String get low_7284 => '低';

  @override
  String get high_7281 => '高';

  @override
  String currentPitch(Object value) {
    return '当前: $value';
  }

  @override
  String get testVoice_7281 => '测试语音';

  @override
  String get clearRecentColors_4271 => '清空最近颜色';

  @override
  String get addRecentColorsTitle_7421 => '添加最近使用颜色';

  @override
  String get confirmClearRecentColors_4821 => '确定要清空所有最近使用的颜色吗？';

  @override
  String currentCount(Object count) {
    return '当前数量: $count/5';
  }

  @override
  String get resetToolSettingsConfirmation_4821 => '确定要将工具设置重置为默认值吗？此操作不可撤销。';

  @override
  String get toolSettingsReset_4821 => '工具设置已重置';

  @override
  String get resetButton_5421 => '重置';

  @override
  String get clearCustomColors_4271 => '清空自定义颜色';

  @override
  String get addCustomColor_7421 => '添加自定义颜色';

  @override
  String get confirmClearCustomColors_7421 => '确定要清空所有自定义颜色吗？';

  @override
  String get addColor_7421 => '添加颜色';

  @override
  String get clearCustomTags_4271 => '清空自定义标签';

  @override
  String get confirmClearAllTags_7281 => '确定要清空所有自定义标签吗？';

  @override
  String nameUpdatedTo_7421(Object newName) {
    return '显示名称已更新为 \"$newName\"';
  }

  @override
  String updateFailedWithError(Object error) {
    return '更新失败: $error';
  }

  @override
  String get enterValidUrl_4821 => '请输入有效的URL';

  @override
  String get inputAvatarUrl_7281 => '输入头像URL';

  @override
  String get invalidImageUrlError_4821 => '请输入图片URL（支持 jpg, png, gif 等格式）';

  @override
  String get imageUrlLabel_4821 => '图片URL';

  @override
  String get supportedImageFormats_5732 => '支持 jpg, png, gif 等格式的图片';

  @override
  String lastLoginTime(Object time) {
    return '最后登录: $time';
  }

  @override
  String creationTimeText_7421(Object date) {
    return '创建时间: $date';
  }

  @override
  String get configurationManagement_7421 => '配置管理';

  @override
  String get saveAsNewConfig_7281 => '将当前设置保存为新配置';

  @override
  String get saveCurrentConfig_4271 => '保存当前配置';

  @override
  String loadConfigFailed_4821(Object configError) {
    return '加载配置失败: $configError';
  }

  @override
  String get noSavedConfigs_7281 => '暂无保存的配置';

  @override
  String savedConfigsCount(Object count) {
    return '已保存的配置 ($count)';
  }

  @override
  String get importConfig_7421 => '导入配置';

  @override
  String get importConfigFromJson_4821 => '从JSON数据导入配置';

  @override
  String get accountSettings_7421 => '账户设置';

  @override
  String get displayName_1234 => '显示名称';

  @override
  String get avatarTitle_4821 => '头像';

  @override
  String get language_4821 => '语言';

  @override
  String get simplifiedChinese_4821 => '简体中文';

  @override
  String localImageSize_7421(Object size) {
    return '本地图片 ($size KB)';
  }

  @override
  String get changeAvatar_7421 => '更改头像';

  @override
  String get useNetworkImageUrl_4821 => '使用网络图片URL';

  @override
  String get uploadLocalImage_4271 => '上传本地图片';

  @override
  String get removeAvatar_4271 => '移除头像';

  @override
  String get confirmRemoveAvatar_7421 => '确定要移除当前头像吗？';

  @override
  String get avatarUploaded_7421 => '头像已上传';

  @override
  String get avatarRemoved_4281 => '头像已移除';

  @override
  String removeFailedMessage_7421(Object error) {
    return '移除失败: $error';
  }

  @override
  String get configurationName_4821 => '配置名称';

  @override
  String get enterConfigurationName_5732 => '请输入配置名称';

  @override
  String get configurationDescription_4521 => '配置描述';

  @override
  String get enterConfigurationDescriptionHint_4522 => '请输入配置描述（可选）';

  @override
  String get inputConfigName_4821 => '请输入配置名称';

  @override
  String get configurationSavedSuccessfully_4821 => '配置保存成功';

  @override
  String saveConfigFailed(Object error) {
    return '保存配置失败: $error';
  }

  @override
  String get loadingConfiguration_7281 => '加载配置';

  @override
  String get exportConfig_7281 => '导出配置';

  @override
  String get loadingConfiguration_7421 => '加载配置';

  @override
  String get deleteConfiguration_7281 => '删除配置';

  @override
  String confirmLoadConfig_7421(Object name) {
    return '确定要加载配置 \"$name\" 吗？\n\n这将覆盖当前的所有设置（用户信息除外）。';
  }

  @override
  String get configurationLoadedSuccessfully_4821 => '配置加载成功';

  @override
  String loadConfigFailed_7421(Object error) {
    return '加载配置失败: $error';
  }

  @override
  String get deleteConfiguration_4271 => '删除配置';

  @override
  String confirmDeleteConfig(Object displayName) {
    return '确定要删除配置 \"$displayName\" 吗？';
  }

  @override
  String get configurationDeletedSuccessfully_7281 => '配置删除成功';

  @override
  String deleteConfigFailed_7421(Object error) {
    return '删除配置失败: $error';
  }

  @override
  String get configurationCopiedToClipboard_4821 => '配置已复制到剪贴板';

  @override
  String exportConfigFailed_7421(Object error) {
    return '导出配置失败: $error';
  }

  @override
  String get importConfig_4271 => '导入配置';

  @override
  String get pasteJsonConfig_7281 => '请粘贴配置JSON数据：';

  @override
  String get jsonDataLabel_4521 => 'JSON数据';

  @override
  String get jsonDataHint_4522 => '粘贴配置JSON数据...';

  @override
  String get userManagement_4521 => '用户管理';

  @override
  String get inputJsonData_4821 => '请输入JSON数据';

  @override
  String get import_4521 => '导入';

  @override
  String get configurationImportSuccess_7281 => '配置导入成功';

  @override
  String importConfigFailed_7421(Object error) {
    return '导入配置失败: $error';
  }

  @override
  String get simplifiedChinese_7281 => '简体中文';

  @override
  String get selectLanguage_4821 => '选择语言';

  @override
  String languageUpdated(Object name) {
    return '语言已更新为 $name';
  }

  @override
  String get editUserInfo_4821 => '编辑用户信息';

  @override
  String get displayName_4521 => '显示名称';

  @override
  String get avatarUrlOptional_4821 => '头像URL（可选）';

  @override
  String get userInfoUpdated_7421 => '用户信息已更新';

  @override
  String get createNewProfile_4271 => '创建新配置文件';

  @override
  String get profileNameLabel_4821 => '配置文件名称';

  @override
  String configFileCreated(Object name) {
    return '配置文件\"$name\"已创建';
  }

  @override
  String get displayNameCannotBeEmpty_4821 => '显示名称不能为空';

  @override
  String get displayNameMinLength_4821 => '显示名称至少需要2个字符';

  @override
  String get changeDisplayName_4821 => '修改显示名称';

  @override
  String get displayNameLabel_4821 => '显示名称';

  @override
  String get displayNameHint_7532 => '请输入您的显示名称';

  @override
  String get displayNameTooLong_42 => '显示名称不能超过50个字符';

  @override
  String get disabledTrayNavigation_4821 => '此页面已禁用 TrayNavigation';

  @override
  String get fullScreenTestPage_7421 => '全屏测试页面';

  @override
  String get displayLocation_7421 => '显示位置';

  @override
  String get otherSettings_7421 => '其他设置';

  @override
  String get oneSecond_7281 => '1秒';

  @override
  String get displayDuration_7284 => '显示时长: ';

  @override
  String get twoSeconds_4271 => '2秒';

  @override
  String get secondsCount_4821 => '6秒';

  @override
  String get tenSeconds_4821 => '10秒';

  @override
  String get doNotAutoClose_7281 => '不自动关闭';

  @override
  String get showCloseButton_4271 => '显示关闭按钮: ';

  @override
  String get testMessage_4721 => '这是一条测试消息';

  @override
  String get showMultipleNotifications_4271 => '显示多条通知';

  @override
  String get showNotification_1234 => '显示通知';

  @override
  String get clearCurrentLocation_4821 => '清除当前位置';

  @override
  String get clearAllNotifications_7281 => '清除所有通知';

  @override
  String get quickTest_7421 => '快速测试';

  @override
  String get success_4821 => '成功';

  @override
  String errorMessage_4821(Object error) {
    return '错误: $error';
  }

  @override
  String get successMessage_4821 => '成功消息';

  @override
  String get error_4821 => '错误';

  @override
  String get warning_7281 => '警告';

  @override
  String get warningMessage_7284 => '警告消息';

  @override
  String get infoMessage_7284 => '信息消息';

  @override
  String get information_7281 => '信息';

  @override
  String get persistentNotificationDemo_7281 => '🔥 常驻通知演示 (SnackBar 替换)';

  @override
  String get snackBarDemoDescription_7281 => '演示如何替换原版 SnackBar 的常驻显示功能';

  @override
  String get showPersistentNotification_7281 => '显示常驻通知';

  @override
  String get notificationSystemTest_4271 => '通知系统测试';

  @override
  String get progressNotification_4271 => '进度通知';

  @override
  String get snackBarDemo_4271 => 'SnackBar兼容演示';

  @override
  String get imageSelectionDemo_4271 => '图片选择演示';

  @override
  String get demoUpdateNoticeWithoutAnimation_4821 => '🔄 演示更新通知（无重新动画）';

  @override
  String get error_5732 => '错误';

  @override
  String get warning_6643 => '警告';

  @override
  String get info_7554 => '信息';

  @override
  String get messageContent_7281 => '消息内容';

  @override
  String get inputMessageContent_7281 => '请输入消息内容';

  @override
  String notificationClicked_7281(Object message) {
    return '通知被点击: $message';
  }

  @override
  String get topLeft_1234 => '左上';

  @override
  String get topCenter_5678 => '上中';

  @override
  String get topRight_9012 => '右上';

  @override
  String get centerLeft_3456 => '左中';

  @override
  String get center_7890 => '中心';

  @override
  String get centerRight_1235 => '右中';

  @override
  String get bottomLeft_6789 => '左下';

  @override
  String get bottomCenter_0123 => '下中';

  @override
  String get bottomRight_4567 => '右下';

  @override
  String notificationClosed(Object message) {
    return '通知被关闭: $message';
  }

  @override
  String messageWithIndexAndType_7421(Object index, Object type) {
    return '第$index条消息 - $type';
  }

  @override
  String get residentNotificationClosed_7281 => '常驻通知被关闭';

  @override
  String get notificationClicked_4821 => '常驻通知被点击';

  @override
  String get inputMessageHint_4521 => '输入要显示的消息内容';

  @override
  String downloadingFileProgress_4821(Object percent) {
    return '正在下载文件... $percent%';
  }

  @override
  String downloadingFileProgress_7281(Object progress) {
    return '正在下载文件... $progress%';
  }

  @override
  String get notificationWillBeUpdated_7281 => '🔄 这个通知将会被更新（不重新播放动画）';

  @override
  String get fileDownloadComplete_4821 => '文件下载完成！';

  @override
  String get notificationUpdated_7281 => '✨ 消息已更新！注意没有重新播放动画';

  @override
  String get updateCompleteMessage_4821 => '🎉 更新完成！这就是updateNotification的威力';

  @override
  String get featureEnhancement_4821 => '🎉 功能更强大：支持9个位置、堆叠管理、精美动画！';

  @override
  String get selectingImage_7421 => '📸 正在选择图片...';

  @override
  String get imageSelectionComplete_4821 => '✅ 图片选择完成！';

  @override
  String get messageType_7281 => '消息类型';

  @override
  String fileNotFound_7421(Object fileName) {
    return '文件不存在: $fileName';
  }

  @override
  String get r6OperatorSvgTest_4271 => 'R6 干员 SVG 测试';

  @override
  String get reloadTooltip_7281 => '重新加载';

  @override
  String get loadingSvgFiles_5421 => '正在加载 SVG 文件...';

  @override
  String foundSvgFilesCount_5421(Object count) {
    return '找到 $count 个 SVG 文件';
  }

  @override
  String get svgFileNotFound_4821 => '未找到 SVG 文件';

  @override
  String get loadFailed_7281 => '加载失败';

  @override
  String get svgLoadFailed_7421 => '无法加载 SVG 文件';

  @override
  String fileNameLabel_7281(Object fileName) {
    return '文件: $fileName';
  }

  @override
  String svgLoadError(Object e) {
    return '加载 SVG 文件时出错: $e';
  }

  @override
  String cannotViewPermissionError_4821(Object error) {
    return '无法查看权限: $error';
  }

  @override
  String get selectFileToViewMetadata_4821 => '选择文件以查看元数据';

  @override
  String get totalCount_7421 => '总数量';

  @override
  String get fileTypeStatistics_4521 => '文件类型统计';

  @override
  String get folderType_4822 => '文件夹';

  @override
  String get fileType_4823 => '文件';

  @override
  String get fileSizeLabel_4821 => '大小';

  @override
  String get databaseLabel_7421 => '数据库';

  @override
  String get totalFilesCount_7284 => '文件总数';

  @override
  String get selectDatabaseAndCollection_7281 => '请选择数据库和集合';

  @override
  String get singleFileSelectionModeWarning_4827 => '单选模式下只能选择一个文件';

  @override
  String fileLoadFailed_7284(Object e) {
    return '加载文件失败: $e';
  }

  @override
  String get userFile_4521 => '用户文件';

  @override
  String fileUploadSuccess_7421(Object fullRemotePath, Object localFilePath) {
    return '文件上传成功: $localFilePath -> $fullRemotePath';
  }

  @override
  String fileUploadFailed_7285(Object e) {
    return '上传文件失败: $e';
  }

  @override
  String downloadFailed_7284(Object error) {
    return '下载失败: $error';
  }

  @override
  String downloadFilesAndFolders(
    Object downloadPath,
    Object fileCount,
    Object folderCount,
  ) {
    return '已下载 $fileCount 个文件和 $folderCount 个文件夹到 $downloadPath';
  }

  @override
  String filesDownloaded_7421(Object downloadPath, Object fileCount) {
    return '已下载 $fileCount 个文件到 $downloadPath';
  }

  @override
  String foldersDownloaded_7281(Object downloadPath, Object folderCount) {
    return '已下载 $folderCount 个文件夹到 $downloadPath';
  }

  @override
  String get saveZipFileTitle_4721 => '保存压缩文件';

  @override
  String get rootDirectory_5832 => '根目录';

  @override
  String compressionDownloadFailed_4821(Object e) {
    return '压缩下载失败: $e';
  }

  @override
  String downloadedFilesInDirectories(Object directoryCount) {
    return '已下载 $directoryCount 个目录中的文件';
  }

  @override
  String webDownloadFailed_4821(Object error) {
    return 'Web平台下载失败: $error';
  }

  @override
  String get notZipFileError_4821 => '所选文件不是ZIP文件';

  @override
  String get zipReadError_7281 => '无法读取ZIP文件内容';

  @override
  String itemsCutCount(Object count) {
    return '已剪切 $count 个项目';
  }

  @override
  String get copy_7421 => '副本';

  @override
  String get confirmDeleteTitle_4821 => '确认删除';

  @override
  String confirmDeleteMessage_4821(Object count) {
    return '确定要删除选中的 $count 个项目吗？此操作不可撤销。';
  }

  @override
  String renameFailed_7284(Object e) {
    return '重命名失败: $e';
  }

  @override
  String get permissionUpdated_7281 => '权限已更新';

  @override
  String get newFolderTitle_4821 => '新建文件夹';

  @override
  String createFolderFailed_7285(Object e) {
    return '创建文件夹失败: $e';
  }

  @override
  String get selectDatabaseFirst_4281 => '请先选择数据库';

  @override
  String get share_7281 => '分享';

  @override
  String get openInWindow_4281 => '在窗口中打开';

  @override
  String get openInWindowTooltip_4271 => '在窗口中打开';

  @override
  String get openInWindowHint_7281 => '在窗口中打开功能需要导入窗口组件';

  @override
  String get shareFeatureInDevelopment_7281 => '分享功能开发中...';

  @override
  String get fileInfo_4821 => '文件信息';

  @override
  String get fileUnavailable_4287 => '文件信息不可用';

  @override
  String get pathLabel_5421 => '路径';

  @override
  String get directory_4821 => '目录';

  @override
  String get file_4821 => '文件';

  @override
  String get fullScreenModeInDevelopment_7281 => '全屏模式开发中...';

  @override
  String get disableAutoPlay_5421 => '关闭自动播放';

  @override
  String get enableAutoPlay_5421 => '开启自动播放';

  @override
  String videoInfoLoadFailed(Object e) {
    return '加载视频信息失败: $e';
  }

  @override
  String get disableLoopPlayback_7281 => '关闭循环播放';

  @override
  String get enableLoopPlayback_7282 => '开启循环播放';

  @override
  String get unmute_5421 => '取消静音';

  @override
  String get mute_5422 => '静音';

  @override
  String get videoInfo_4821 => '视频信息';

  @override
  String get openInWindow_7281 => '在窗口中打开';

  @override
  String get loadingVideo_7281 => '正在加载视频...';

  @override
  String get videoLoadFailed_7281 => '视频加载失败';

  @override
  String get retry_4281 => '重试';

  @override
  String openVideoInWindow(Object vfsPath) {
    return '在窗口中打开视频: $vfsPath';
  }

  @override
  String get pathLabel_7421 => '路径';

  @override
  String get fileName_5421 => '文件名';

  @override
  String get videoFile_5732 => '视频文件';

  @override
  String copyVideoLink_5421(Object vfsPath) {
    return '复制视频链接: $vfsPath';
  }

  @override
  String vfsFileInfoError(Object e) {
    return '获取VFS文件信息失败: $e';
  }

  @override
  String get webDavManagement_7421 => 'WebDAV 管理';

  @override
  String get webDavConfig_7281 => 'WebDAV 配置';

  @override
  String get verifiedAccount_7281 => '认证账户';

  @override
  String get addConfiguration_7421 => '添加配置';

  @override
  String get noWebDAVConfig_7281 => '暂无 WebDAV 配置';

  @override
  String totalConfigsCount(Object count) {
    return '共 $count 个配置';
  }

  @override
  String get clickToAddConfig => '点击\"添加配置\"开始使用';

  @override
  String get addAccount_7421 => '添加账户';

  @override
  String totalAccountsCount(Object count) {
    return '共 $count 个账户';
  }

  @override
  String get noAuthenticatedAccount_7421 => '暂无认证账户';

  @override
  String get clickToAddAccount_7281 => '点击\"添加账户\"开始使用';

  @override
  String get unknownAccount_4821 => '未知账户';

  @override
  String get unknown_4822 => '未知';

  @override
  String get serverLabel_4821 => '服务器';

  @override
  String get verifiedAccountTitle_4821 => '认证账户';

  @override
  String get storagePath_7281 => '存储路径';

  @override
  String get testingInProgress_4821 => '测试中...';

  @override
  String get testConnection_4821 => '测试连接';

  @override
  String get editLabel_4271 => '编辑';

  @override
  String get enable_7532 => '启用';

  @override
  String get configurationsCount_7421 => '个配置';

  @override
  String get usernameLabel_5421 => '用户名';

  @override
  String accountInUseMessage_4821(Object configCount) {
    return '此账户正在被 $configCount 个配置使用，无法删除';
  }

  @override
  String get connectionSuccess_4821 => '连接成功';

  @override
  String get connectionFailed_4821 => '连接失败';

  @override
  String serverInfoLabel_7281(Object serverInfo) {
    return '服务器: $serverInfo';
  }

  @override
  String testFailedMessage(Object e) {
    return '测试失败: $e';
  }

  @override
  String operationFailedWithError(Object error) {
    return '操作失败: $error';
  }

  @override
  String get configDisabled_4821 => '配置已禁用';

  @override
  String get configEnabled_4822 => '配置已启用';

  @override
  String get configurationDeleted_4821 => '配置已删除';

  @override
  String confirmDeleteAccount_7421(Object accountDisplayName) {
    return '确定要删除认证账户\"$accountDisplayName\"吗？此操作无法撤销。';
  }

  @override
  String get accountDeletedSuccess_4821 => '认证账户已删除';

  @override
  String get editWebDavConfig => '编辑 WebDAV 配置';

  @override
  String get addWebDavConfig => '添加 WebDAV 配置';

  @override
  String get inputDisplayName_4821 => '请输入显示名称';

  @override
  String get displayName_4821 => '显示名称';

  @override
  String get exampleMyCloud_4822 => '例如：我的云盘';

  @override
  String get serverUrlLabel_4821 => '服务器 URL';

  @override
  String get serverUrlHint_4821 => 'https://example.com/webdav';

  @override
  String dataLoadFailed(Object e) {
    return '加载数据失败: $e';
  }

  @override
  String connectionStateChanged_7281(Object state) {
    return '连接状态变更: $state';
  }

  @override
  String errorLog_7421(Object error) {
    return '错误: $error';
  }

  @override
  String delayUpdateLog(Object delay) {
    return '延迟更新: ${delay}ms';
  }

  @override
  String userStatusBroadcast_7421(
    Object activityStatus,
    Object onlineStatus,
    Object spaceId,
    Object userId,
  ) {
    return '用户状态广播: 用户=$userId, 在线状态=$onlineStatus, 活动状态=$activityStatus, 空间=$spaceId';
  }

  @override
  String configListUpdated(Object count) {
    return '配置列表已更新，共 $count 个配置';
  }

  @override
  String activeConfigChange(Object clientId, Object displayName) {
    return '活跃配置变更: $displayName ($clientId)';
  }

  @override
  String activeConfigLog(Object displayName) {
    return '当前活跃配置: $displayName';
  }

  @override
  String configListLoaded(Object count) {
    return '配置列表已加载，共 $count 个配置';
  }

  @override
  String get activeConfigCleared_7281 => '活跃配置已清除';

  @override
  String currentConnectionState_7421(Object state) {
    return '当前连接状态: $state';
  }

  @override
  String loadConfigFailed(Object e) {
    return '加载配置失败: $e';
  }

  @override
  String get createNewClientConfig_7281 => '创建新的客户端配置';

  @override
  String get connecting_5732 => '连接中';

  @override
  String get authenticating_6943 => '认证中';

  @override
  String get connected_7154 => '已连接';

  @override
  String get reconnecting_8265 => '重连中';

  @override
  String get error_9376 => '错误';

  @override
  String get displayNameHint_4821 => '输入客户端显示名称';

  @override
  String get webApiKeyLabel_4821 => 'Web API Key';

  @override
  String get webApiKeyHint_7532 => '输入 Web API Key';

  @override
  String get enterDisplayName_4821 => '请输入显示名称';

  @override
  String get enterWebApiKey_4821 => '请输入 Web API Key';

  @override
  String get startCreatingClientConfigWithWebApiKey_4821 =>
      '开始使用 Web API Key 创建客户端配置...';

  @override
  String webApiKeyClientConfigFailed(Object e) {
    return '使用 Web API Key 创建客户端配置失败: $e';
  }

  @override
  String clientConfigCreatedSuccessfully(Object clientId, Object displayName) {
    return '客户端配置创建成功: $displayName ($clientId)';
  }

  @override
  String setActiveConfig(Object clientId, Object displayName) {
    return '设置活跃配置: $displayName ($clientId)';
  }

  @override
  String get activeConfigSetSuccess_4821 => '活跃配置设置成功';

  @override
  String setActiveConfigFailed(Object e) {
    return '设置活跃配置失败: $e';
  }

  @override
  String get cancelActiveConfig_7421 => '取消当前活跃配置...';

  @override
  String get activeConfigCancelled_7281 => '活跃配置已取消';

  @override
  String connectingToTarget(Object clientId, Object displayName) {
    return '开始连接到: $displayName ($clientId)';
  }

  @override
  String connectionFailed_7281(Object error) {
    return '连接失败: $error';
  }

  @override
  String connectionError_5421(Object e) {
    return '连接错误: $e';
  }

  @override
  String get disconnectCurrentConnection_7281 => '断开当前连接...';

  @override
  String get connectionDisconnected_4821 => '连接已断开';

  @override
  String disconnectFailed_7285(Object e) {
    return '断开连接失败: $e';
  }

  @override
  String deleteConfigLog_7421(Object clientId, Object displayName) {
    return '删除配置: $displayName ($clientId)';
  }

  @override
  String deleteConfigFailed_7284(Object e) {
    return '删除配置失败: $e';
  }

  @override
  String get configurationDeletedSuccessfully_7421 => '配置删除成功';

  @override
  String get logCleared_7281 => '日志已清空';

  @override
  String get connectionConfig_7281 => '连接配置';

  @override
  String get newButton_4821 => '新建';

  @override
  String get setAsActive_7281 => '设为活跃';

  @override
  String get createFirstConnectionHint_4821 => '点击\"新建\"按钮创建第一个连接配置';

  @override
  String get cancelActive_7281 => '取消活跃';

  @override
  String get connect_4821 => '连接';

  @override
  String get noConnectionConfig_4521 => '暂无连接配置';

  @override
  String get disconnect_7421 => '断开';

  @override
  String currentConfigDisplay(Object displayName) {
    return '当前配置: $displayName';
  }

  @override
  String serverInfo(Object host, Object port) {
    return '服务器:$host:$port';
  }

  @override
  String latencyWithValue(Object value) {
    return '延迟: ${value}ms';
  }

  @override
  String get activityLog_7281 => '活动日志';

  @override
  String get webSocketManagerInitialized_7281 => 'WebSocket 连接管理器初始化成功';

  @override
  String initializationFailed_7281(Object e) {
    return '初始化失败: $e';
  }

  @override
  String get noLogsAvailable_7421 => '暂无日志';

  @override
  String initializationFailed_7285(Object e) {
    return '初始化失败: $e';
  }

  @override
  String cancelActiveConfigFailed_7285(Object e) {
    return '取消活跃配置失败: $e';
  }

  @override
  String get englishLanguage_4821 => 'English';

  @override
  String get chineseLanguage_5732 => '中文';

  @override
  String themeUpdateFailed(Object error) {
    return '更新主题设置失败: $error';
  }

  @override
  String mapEditorUpdateFailed(Object error) {
    return '更新地图编辑器设置失败: $error';
  }

  @override
  String updateLayoutFailed(Object error) {
    return '更新界面布局设置失败: $error';
  }

  @override
  String windowSizeUpdateFailed(Object e) {
    return '更新窗口大小失败: $e';
  }

  @override
  String toolSettingsUpdateFailed(Object error) {
    return '更新工具设置失败: $error';
  }

  @override
  String updateUserInfoFailed_7421(Object error) {
    return '更新用户信息失败: $error';
  }

  @override
  String addRecentColorFailed(Object error) {
    return '添加最近使用颜色失败: $error';
  }

  @override
  String addLineWidthFailed(Object error) {
    return '添加常用线条宽度失败: $error';
  }

  @override
  String customColorAddedSuccessfully(Object count) {
    return '自定义颜色添加成功，当前自定义颜色数量: $count';
  }

  @override
  String addingCustomColor_7281(Object color) {
    return '开始添加自定义颜色: $color';
  }

  @override
  String addCustomColorFailed(Object error) {
    return '添加自定义颜色失败: $error';
  }

  @override
  String addCustomColorFailed_7285(Object e) {
    return '添加自定义颜色失败: $e';
  }

  @override
  String removeCustomColorFailed_7421(Object error) {
    return '移除自定义颜色失败: $error';
  }

  @override
  String updateCustomTagFailed(Object error) {
    return '更新自定义标签失败: $error';
  }

  @override
  String removeCustomTagFailed_7421(Object error) {
    return '移除自定义标签失败: $error';
  }

  @override
  String panelUpdateFailed_7285(Object error) {
    return '更新面板状态失败: $error';
  }

  @override
  String addRecentTagFailed(Object error) {
    return '添加最近使用标签失败: $error';
  }

  @override
  String userCreationFailed_7421(Object error) {
    return '创建用户失败: $error';
  }

  @override
  String switchUserFailed_7421(Object error) {
    return '切换用户失败: $error';
  }

  @override
  String deleteUserFailed_7421(Object error) {
    return '删除用户失败: $error';
  }

  @override
  String exportSettingsFailed_7421(Object error) {
    return '导出设置失败: $error';
  }

  @override
  String updateShortcutFailed_7421(Object error) {
    return '更新地图编辑器快捷键失败: $error';
  }

  @override
  String importSettingsFailed_7421(Object e) {
    return '导入设置失败: $e';
  }

  @override
  String resetSettingsFailed_7421(Object error) {
    return '重置设置失败: $error';
  }

  @override
  String updateExtensionSettingsFailed(Object error) {
    return '更新扩展设置失败: $error';
  }

  @override
  String updateHomeSettingsFailed(Object error) {
    return '更新主页设置失败: $error';
  }

  @override
  String parseExtensionSettingsFailed(Object error) {
    return '解析扩展设置JSON失败: $error';
  }

  @override
  String forceSaveFailed_4829(Object e) {
    return '强制保存待处理更改失败: $e';
  }

  @override
  String get noPreferencesToSave_7281 => '当前没有可保存的偏好设置';

  @override
  String fetchConfigListFailed_7285(Object error) {
    return '获取配置列表失败: $error';
  }

  @override
  String configSavedSuccessfully(Object configId, Object name) {
    return '配置保存成功: $name ($configId)';
  }

  @override
  String get configNotFoundOrLoadFailed_4821 => '配置不存在或加载失败';

  @override
  String saveConfigFailed_7281(Object error) {
    return '保存配置失败: $error';
  }

  @override
  String configLoadedSuccessfully(Object configId) {
    return '配置加载并应用成功: $configId';
  }

  @override
  String configDeletedSuccessfully(Object configId) {
    return '配置删除成功: $configId';
  }

  @override
  String deleteConfigFailed_7281(Object e) {
    return '删除配置失败: $e';
  }

  @override
  String preferencesInitialized(Object displayName) {
    return '用户偏好设置初始化完成: $displayName';
  }

  @override
  String configCheckFailed_7425(Object e) {
    return '检查配置存在性失败: $e';
  }

  @override
  String get extensionManagerInitialized_7281 => '扩展设置管理器已初始化';

  @override
  String fetchConfigFailed_7281(Object e) {
    return '获取配置信息失败: $e';
  }

  @override
  String initUserPrefsFailed(Object error) {
    return '初始化用户偏好设置失败: $error';
  }

  @override
  String get noUpdatablePreferences_4821 => '没有可更新的偏好设置';

  @override
  String configUpdateSuccess(Object configId, Object name) {
    return '配置更新成功: $name ($configId)';
  }

  @override
  String userPrefsInitFailed_4829(Object e) {
    return '初始化用户偏好设置失败: $e';
  }

  @override
  String updateConfigFailed_7421(Object error) {
    return '更新配置失败: $error';
  }

  @override
  String get configNotFound_4821 => '配置不存在';

  @override
  String get fetchConfigFailed_4821 => '获取配置信息失败';

  @override
  String importConfigFailed_7281(Object error) {
    return '导入配置失败: $error';
  }

  @override
  String configImportSuccess(Object importedConfigId, Object name) {
    return '配置导入成功: $name ($importedConfigId)';
  }

  @override
  String get importedSuffix_4821 => '(导入)';

  @override
  String get importedFromJson_4822 => '(从JSON导入)';

  @override
  String get audioPlayerInitialized_7281 => '🎵 AudioPlayerService: 音频播放器初始化完成';

  @override
  String get audioPlayerInitFailed_4821 => '初始化失败';

  @override
  String audioPlayerInitFailed_7284(Object e) {
    return '音频播放器初始化失败: $e';
  }

  @override
  String get audioPlayerTimeout_4821 => '🎵 AudioPlayerService: 暂停操作超时，但继续处理';

  @override
  String audioPlayerTempQueuePlaying_7421(Object title) {
    return '🎵 AudioPlayerService: 临时队列开始播放 - $title';
  }

  @override
  String temporaryQueuePlaybackFailed_4829(Object e) {
    return '临时队列播放失败: $e';
  }

  @override
  String get noAudioSourceSpecified_7281 => '没有指定音频源';

  @override
  String audioPlayerStartPlaying_7421(Object audioSource) {
    return '开始播放 - $audioSource';
  }

  @override
  String get audioPlayerTimeout_7421 => '🎵 AudioPlayerService: 播放操作超时，但继续处理';

  @override
  String get audioPlayerPaused_7281 => '🎵 AudioPlayerService: 已暂停';

  @override
  String pauseFailed_7285(Object e) {
    return '暂停失败: $e';
  }

  @override
  String get audioPlayerStopped_7281 => '🎵 AudioPlayerService: 已停止';

  @override
  String stopFailedError(Object e) {
    return '停止失败: $e';
  }

  @override
  String get audioPlayerFallback_4821 => '🎵 AudioPlayerService: 跳转操作超时，使用备选方案';

  @override
  String seekToPosition(Object seconds) {
    return '跳转到 $seconds秒';
  }

  @override
  String audioPlayerStopFailure_4821(Object e) {
    return '停止失败 - $e';
  }

  @override
  String jumpFailed_4821(Object e) {
    return '跳转失败: $e';
  }

  @override
  String volumeSetTo(Object percentage) {
    return '音量设置为 $percentage%';
  }

  @override
  String volumeSettingFailed_7285(Object e) {
    return '设置音量失败: $e';
  }

  @override
  String playbackRateSetTo(Object _playbackRate) {
    return '播放速度设置为 ${_playbackRate}x';
  }

  @override
  String get setVolumeFailed_7281 => '设置音量失败';

  @override
  String setPlaybackSpeedFailed_7285(Object e) {
    return '设置播放速度失败: $e';
  }

  @override
  String audioBalanceSet_7421(Object balance) {
    return '音频平衡设置为 $balance';
  }

  @override
  String audioBalanceError_4821(Object e) {
    return '设置音频平衡失败: $e';
  }

  @override
  String get setPlaybackSpeedFailed_7281 => '设置播放速度失败';

  @override
  String get mutedStatusOn => '已静音';

  @override
  String get mutedStatusOff => '取消静音';

  @override
  String toggleMuteFailed_7284(Object error) {
    return '切换静音失败: $error';
  }

  @override
  String get addedToQueue_7421 => '添加到播放队列';

  @override
  String get batchAddToQueue_7421 => '批量添加到播放队列';

  @override
  String get songsSuffix_8153 => '首';

  @override
  String insertToPlayQueue_7425(Object index) {
    return '插入到播放队列[$index]';
  }

  @override
  String get removedFromQueue_7421 => '从播放队列移除';

  @override
  String get audioPlayerClearQueue_4821 => '🎵 AudioPlayerService: 清空播放队列';

  @override
  String get audioPlayerQueueUpdated_7281 => '🎵 AudioPlayerService: 播放队列已更新';

  @override
  String get playlistIndexOutOfRange_7281 => '播放队列索引超出范围';

  @override
  String get playQueueEmpty_4821 => '播放队列为空';

  @override
  String get audioPlayerReachedEnd_7281 => '🎵 AudioPlayerService: 已到播放队列末尾';

  @override
  String get playQueueEmpty_7281 => '播放队列为空';

  @override
  String get audioPlayerReachedStart_7281 => '🎵 AudioPlayerService: 已到播放队列开头';

  @override
  String playbackModeSetTo(Object playbackMode) {
    return '播放模式设置为 $playbackMode';
  }

  @override
  String audioSourceLoading_4821(Object source) {
    return '开始加载音频源 - $source';
  }

  @override
  String backgroundPlayStatus(Object status) {
    return '🎵 AudioPlayerService: 后台播放 $status';
  }

  @override
  String get enabled_4821 => '已启用';

  @override
  String get disabled_4821 => '已禁用';

  @override
  String get audioPlayerUsingNetworkUrl_4821 =>
      '🎵 AudioPlayerService: 使用网络URL播放';

  @override
  String get audioPlayerServiceGenerateUrl_4821 =>
      '🎵 AudioPlayerService: 从VFS生成播放URL';

  @override
  String generatedPlayUrl(Object playableUrl) {
    return '生成的播放URL - $playableUrl';
  }

  @override
  String get audioSourceLoaded_7281 => '🎵 AudioPlayerService: 音频源加载完成';

  @override
  String get failedToGetAudioFile_7281 => '无法从VFS获取音频文件';

  @override
  String get seekFailed_4821 => '跳转失败';

  @override
  String cleanupCompleted(Object elapsedMilliseconds) {
    return '应用清理操作完成，总耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String cleanupErrorWithDuration(Object e, Object elapsedMilliseconds) {
    return '清理操作过程中发生错误: $e，已耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String get closingDbConnection_7281 => '正在关闭数据库连接...';

  @override
  String closeUserPrefDbFailed(Object e) {
    return '关闭用户偏好数据库失败: $e';
  }

  @override
  String vfsDatabaseCloseFailure(Object e) {
    return '关闭VFS存储数据库失败: $e';
  }

  @override
  String mapLocalizationDbCloseFailed(Object e) {
    return '关闭地图本地化数据库失败: $e';
  }

  @override
  String mapDatabaseCloseFailed(Object e) {
    return '关闭地图数据库失败: $e';
  }

  @override
  String closeLegendDatabaseFailed(Object e) {
    return '关闭图例数据库失败: $e';
  }

  @override
  String userPreferenceCloseFailed(Object e) {
    return '关闭用户偏好服务失败: $e';
  }

  @override
  String get stoppingScriptExecutor_7421 => '正在停止脚本执行器...';

  @override
  String databaseCloseError_4821(Object e) {
    return '关闭数据库连接时发生错误: $e';
  }

  @override
  String get databaseConnectionClosed_7281 => '数据库连接关闭完成';

  @override
  String scriptExecutorFailure_4829(Object e) {
    return '停止脚本执行器失败: $e';
  }

  @override
  String get scriptExecutorStopped_7281 => '脚本执行器停止完成';

  @override
  String scriptExecutorError_7425(Object e) {
    return '停止脚本执行器时发生错误: $e';
  }

  @override
  String audioServiceStopFailed(Object e) {
    return '停止音频播放服务失败: $e';
  }

  @override
  String get stoppingAudioService_7421 => '正在停止音频服务...';

  @override
  String ttsServiceFailed(Object e) {
    return '停止TTS服务失败: $e';
  }

  @override
  String audioServiceError_4829(Object e) {
    return '停止音频服务时发生错误: $e';
  }

  @override
  String get audioServiceStopped_7281 => '音频服务停止完成';

  @override
  String get clearingCache_7421 => '正在清理缓存...';

  @override
  String clearLegendCacheFailed(Object e) {
    return '清理图例缓存失败: $e';
  }

  @override
  String cacheCleanError_7284(Object e) {
    return '清理缓存时发生错误: $e';
  }

  @override
  String get cacheCleared_7281 => '缓存清理完成';

  @override
  String deleteTempFile(Object path) {
    return '删除临时文件: $path';
  }

  @override
  String get cleaningTempFiles_7421 => '正在清理临时文件...';

  @override
  String deleteTempFileFailed_7421(Object error, Object path) {
    return '删除临时文件失败: $path, 错误: $error';
  }

  @override
  String get tempFileCleaned_7281 => '临时文件清理完成';

  @override
  String tempFileCleanupError_4821(Object e) {
    return '清理临时文件时发生错误: $e';
  }

  @override
  String get skipDuplicateExecution_4821 => '清理操作已在进行中，跳过重复执行';

  @override
  String deleteExpiredLogFile(Object path) {
    return '删除过期日志文件: $path';
  }

  @override
  String get cleaningExpiredLogs_7281 => '正在清理过期日志文件...';

  @override
  String logDeletionFailed_7421(Object error, Object path) {
    return '删除日志文件失败: $path, 错误: $error';
  }

  @override
  String get logCleanupComplete_7281 => '日志文件清理完成';

  @override
  String logCleanupError_5421(Object e) {
    return '清理日志文件时发生错误: $e';
  }

  @override
  String get closingVfsSystem_7281 => '正在关闭VFS系统...';

  @override
  String vfsProviderCloseFailed(Object e) {
    return '关闭VFS服务提供者失败: $e';
  }

  @override
  String get vfsShutdownComplete_7281 => 'VFS系统关闭完成';

  @override
  String vfsErrorClosing_5421(Object e) {
    return '关闭VFS系统时发生错误: $e';
  }

  @override
  String get startCleanupOperation_7281 => '开始执行应用清理操作...';

  @override
  String deleteTempFile_7421(Object path) {
    return '删除临时文件: $path';
  }

  @override
  String deleteEmptyDirectory_7281(Object path) {
    return '删除空目录: $path';
  }

  @override
  String cleanupFailedMessage(Object error, Object path) {
    return '清理文件/目录失败: $path, 错误: $error';
  }

  @override
  String cleanDirectoryFailed(Object directoryPath, Object error) {
    return '清理目录失败: $directoryPath, 错误: $error';
  }

  @override
  String dbConnectionCloseTime(Object elapsedMilliseconds) {
    return '数据库连接关闭耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String scriptExecutionTime(Object elapsedMilliseconds) {
    return '脚本执行器停止耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String audioServiceStopTime(Object elapsedMilliseconds) {
    return '音频服务停止耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String cacheCleanupTime(Object elapsedMilliseconds) {
    return '缓存清理耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String tempFileCleanupTime(Object elapsedMilliseconds) {
    return '临时文件清理耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String logCleanupTime(Object elapsedMilliseconds) {
    return '日志文件清理耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String vfsShutdownTime(Object elapsedMilliseconds) {
    return 'VFS系统关闭耗时: ${elapsedMilliseconds}ms';
  }

  @override
  String mapAreaCopiedToClipboard(Object height, Object width) {
    return 'Web: 地图选中区域已成功复制到剪贴板: ${width}x$height';
  }

  @override
  String tempFileDeletionWarning(Object e) {
    return '警告：无法删除临时文件: $e';
  }

  @override
  String get clipboardUnavailable_7281 => '系统剪贴板不可用，尝试平台特定实现';

  @override
  String clipboardCopyImageFailed(Object e) {
    return '使用 super_clipboard 复制图像失败: $e';
  }

  @override
  String get imageCopiedToClipboard_4821 => 'macOS: 图像已成功复制到剪贴板';

  @override
  String nativeImageCopyFailed_4821(Object e) {
    return '原生平台复制图像失败: $e';
  }

  @override
  String windowsPowerShellCopyFailed(Object resultStderr) {
    return 'Windows PowerShell 复制失败: $resultStderr';
  }

  @override
  String tempFileDeletionWarning_4821(Object e) {
    return '警告：无法删除临时文件: $e';
  }

  @override
  String macOsCopyFailed_7421(Object error) {
    return 'macOS osascript 复制失败: $error';
  }

  @override
  String get imageCopiedToClipboardLinux_4821 => 'Linux: 图像已成功复制到剪贴板';

  @override
  String linuxXclipCopyFailed(Object resultStderr) {
    return 'Linux xclip 复制失败: $resultStderr';
  }

  @override
  String platformCopyFailed_7285(Object e) {
    return '平台特定复制实现失败: $e';
  }

  @override
  String mapSelectionSavedWithSize(
    Object height,
    Object platformHint,
    Object width,
  ) {
    return '地图选中区域已保存 (${width}x$height) - 图像剪贴板功能在$platformHint不可用';
  }

  @override
  String fallbackToTextModeCopy(Object height, Object platform, Object width) {
    return '已回退到文本模式复制: ${width}x$height ($platform)';
  }

  @override
  String get web_1234 => 'Web';

  @override
  String get native_5678 => 'Native';

  @override
  String get invalidImageData_7281 => '无效的图像数据';

  @override
  String textModeCopyFailed_4821(Object e) {
    return '文本模式复制也失败了: $e';
  }

  @override
  String clipboardPngReadSuccess(String isSynthesized, Object length) {
    String _temp0 = intl.Intl.selectLogic(isSynthesized, {
      'true': ' (合成)',
      'other': '',
    });
    return 'super_clipboard: 从剪贴板成功读取PNG图片，大小: $length 字节$_temp0';
  }

  @override
  String jpegImageReadSuccess(Object length) {
    return 'super_clipboard: 从剪贴板成功读取JPEG图片，大小: $length 字节';
  }

  @override
  String clipboardGifReadSuccess(Object length) {
    return 'super_clipboard: 从剪贴板成功读取GIF图片，大小: $length 字节';
  }

  @override
  String superClipboardReadError_7425(Object e) {
    return 'super_clipboard 读取失败: $e，回退到平台特定实现';
  }

  @override
  String get clipboardUnavailable_7421 => '系统剪贴板不可用，使用平台特定实现';

  @override
  String get clipboardNoSupportedImageFormat_4821 =>
      'super_clipboard: 剪贴板中没有支持的图片格式';

  @override
  String get webClipboardNotSupported_7281 => 'Web 平台不支持平台特定的剪贴板读取实现';

  @override
  String windowsClipboardImageReadSuccess(Object bytesLength) {
    return 'Windows: 从剪贴板成功读取图片，大小: $bytesLength 字节';
  }

  @override
  String get powershellReadError_4821 => 'Windows PowerShell 读取失败或剪贴板中没有图片';

  @override
  String tempFileDeletionWarning_7284(Object e) {
    return '警告：无法删除临时文件: $e';
  }

  @override
  String get clipboardImageReadSuccess_7285 => '从剪贴板成功读取图片';

  @override
  String sizeInBytes_7285(Object bytes) {
    return '大小: $bytes 字节';
  }

  @override
  String get macOsScriptReadFailed_7281 => 'macOS osascript 读取失败或剪贴板中没有图片';

  @override
  String clipboardImageReadSuccess_7425(Object bytesLength) {
    return '从剪贴板成功读取图片，大小: $bytesLength 字节';
  }

  @override
  String get linuxXclipReadFailed_7281 => 'Linux xclip 读取失败或剪贴板中没有图片';

  @override
  String get clipboardReadError_4821 => '平台特定的剪贴板读取不支持或失败';

  @override
  String clipboardReadFailed_7285(Object e) {
    return '平台特定剪贴板读取实现失败: $e';
  }

  @override
  String copyMapSelectionFailed_4829(Object e) {
    return '复制地图选中区域失败: $e';
  }

  @override
  String get clipboardUnavailableWeb_9274 => 'Web: 系统剪贴板不可用，使用事件监听器方式';

  @override
  String webImageCopyFailed(Object e) {
    return 'Web 平台复制图像失败: $e';
  }

  @override
  String fetchLocalizationFailed(Object e) {
    return '获取本地化数据失败: $e';
  }

  @override
  String get exportDatabaseDialogTitle_4721 => '导出R6Box数据库 (Web平台专用)';

  @override
  String databaseExportFailed_4829(Object e) {
    return '合并数据库导出失败: $e';
  }

  @override
  String exportFileNotExist_7285(Object filePath) {
    return '导出文件不存在: $filePath';
  }

  @override
  String get invalidExportFileFormat_4821 => '导出文件格式不正确，缺少必要字段';

  @override
  String get invalidMapDataFormat_7281 => '地图数据格式不正确';

  @override
  String get invalidLegendDataFormat_7281 => '图例数据格式不正确';

  @override
  String exportFileValidationPassed(Object filePath) {
    return '导出文件验证通过: $filePath';
  }

  @override
  String exportValidationFailed_4821(Object e) {
    return '验证导出文件失败: $e';
  }

  @override
  String fetchMapListFailed_7285(Object e) {
    return '获取地图列表失败: $e';
  }

  @override
  String exportFileInfoFailed(Object e) {
    return '获取导出文件信息失败: $e';
  }

  @override
  String databaseStatsError_4821(Object e) {
    return '获取数据库统计信息失败: $e';
  }

  @override
  String fetchLegendListFailed_4821(Object e) {
    return '获取图例列表失败: $e';
  }

  @override
  String startBatchLoadingDirectoryToCache(Object directoryPath) {
    return '开始批量加载目录到缓存: $directoryPath';
  }

  @override
  String batchLoadComplete_7281(Object count, Object directoryPath) {
    return '批量加载完成: $directoryPath, 共 $count 个图例';
  }

  @override
  String batchLoadDirectoryFailed(Object directoryPath, Object e) {
    return '批量加载目录失败: $directoryPath, 错误: $e';
  }

  @override
  String legendCacheCleaned_7281(Object count, Object folderPath) {
    return '图例缓存: 清理了目录 \"$folderPath\" 下的 $count 个缓存项';
  }

  @override
  String steppedCacheCleanStart(Object folderPath) {
    return '步进型缓存清理开始: 目标目录=\"$folderPath\"';
  }

  @override
  String currentCacheKeys(Object keys) {
    return '当前缓存键: $keys';
  }

  @override
  String rootDirectoryCheck(
    Object containsSlash,
    Object path,
    Object shouldRemove,
  ) {
    return '根目录检查: 路径=\"$path\", 包含/=$containsSlash, 应移除=$shouldRemove';
  }

  @override
  String subdirectoryCheck(
    Object containsSlash,
    Object path,
    Object relativePath,
    Object shouldRemove,
  ) {
    return '子目录检查: 路径=\"$path\", 相对路径=\"$relativePath\", 包含/=$containsSlash, 应移除=$shouldRemove';
  }

  @override
  String pathMismatch_7284(Object folderPath, Object path) {
    return '路径不匹配: 路径=\"$path\", 不以\"$folderPath/\"开头';
  }

  @override
  String markRemovedWithPath(Object path) {
    return '标记移除: 路径=\"$path\"';
  }

  @override
  String legendCacheCleaned(Object count, Object folderPath) {
    return '图例缓存 (步进型): 清理了目录 \"$folderPath\" 下的 $count 个缓存项（不包括子目录）';
  }

  @override
  String cleanedPaths_7285(Object keysToRemove) {
    return '被清理的路径: $keysToRemove';
  }

  @override
  String legendCacheNoItemsToClean(Object folderPath) {
    return '图例缓存 (步进型): 目录 \"$folderPath\" 下没有需要清理的缓存项';
  }

  @override
  String legendAddedToCache(Object legendPath) {
    return '图例已添加到缓存: $legendPath';
  }

  @override
  String excludedListSkipped_7285(Object path) {
    return '排除列表跳过: 路径=\"$path\"';
  }

  @override
  String exportLegendFailed_7285(Object e) {
    return '导出图例数据库失败: $e';
  }

  @override
  String get exportLegendDatabaseTitle_4821 => '导出图例数据库';

  @override
  String importLegendDbFailed(Object e) {
    return '导入图例数据库失败: $e';
  }

  @override
  String get metadataTableCreated_7281 => '元数据表创建完成';

  @override
  String get creatingMetadataTable_7281 => '元数据表不存在，正在创建...';

  @override
  String legendSessionManagerInitialized(Object count) {
    return '图例会话管理器: 初始化完成，预加载图例数量: $count';
  }

  @override
  String legendSessionManagerLoaded(Object legendPath) {
    return '图例会话管理器: 成功加载 $legendPath';
  }

  @override
  String legendPathConversion_7281(Object actualPath, Object legendPath) {
    return '图例会话管理器: 路径转换 $legendPath -> $actualPath';
  }

  @override
  String legendSessionManagerLoadFailed(Object legendPath) {
    return '图例会话管理器: 加载失败 $legendPath';
  }

  @override
  String legendSessionManagerError(Object e, Object legendPath) {
    return '图例会话管理器: 加载异常 $legendPath, 错误: $e';
  }

  @override
  String legendSessionManagerRemoveLegend_7281(Object legendPath) {
    return '图例会话管理器: 移除图例 $legendPath';
  }

  @override
  String legendSessionManagerBatchPreloadComplete(Object count) {
    return '图例会话管理器: 批量预加载完成，数量: $count';
  }

  @override
  String legendSessionManagerRetryCount(Object count) {
    return '图例会话管理器: 重试失败的图例，数量: $count';
  }

  @override
  String get sessionManagerClearData_7281 => '图例会话管理器: 清除会话数据';

  @override
  String legendSessionManagerPathConversion(
    Object actualPath,
    Object legendPath,
  ) {
    return '图例会话管理器: 路径转换 $legendPath -> $actualPath';
  }

  @override
  String legendSessionManagerLoadFailed_7421(Object e, Object legendPath) {
    return '图例会话管理器: 加载单个图例失败 $legendPath, 错误: $e';
  }

  @override
  String get vfsVersionNotImplemented_7281 => 'VFS版本管理暂未实现';

  @override
  String importLegendDatabaseFailed(Object e) {
    return '导入图例数据库失败: $e';
  }

  @override
  String get exportLegendDatabase_4821 => '导出图例数据库';

  @override
  String get legendTitleEmpty_7281 => '图例标题为空';

  @override
  String invalidLegendCenterPoint(Object title) {
    return '图例 \"$title\" 中心点坐标无效';
  }

  @override
  String invalidLegendVersion_7421(Object title) {
    return '图例 \"$title\" 版本号无效';
  }

  @override
  String legendReloadFailed_7421(Object title) {
    return '图例 \"$title\" 无法重新加载';
  }

  @override
  String legendLoadError_7285(Object error, Object title) {
    return '图例 \"$title\" 加载错误: $error';
  }

  @override
  String get vfsServiceNoNeedToClose_7281 => 'VFS服务不需要显式关闭';

  @override
  String legendMetadataReadFailed_7421(Object e) {
    return '读取图例元数据失败: $e';
  }

  @override
  String invalidAbsolutePathFormat(Object absolutePath) {
    return '无效的绝对路径格式: $absolutePath';
  }

  @override
  String insufficientPathSegments(Object absolutePath) {
    return '路径段不足: $absolutePath';
  }

  @override
  String legendFromAbsolutePath(Object absolutePath, Object title) {
    return '从绝对路径获取图例: \"$title\", 路径: $absolutePath';
  }

  @override
  String legendDirectoryNotExist_7284(Object absolutePath) {
    return '图例目录不存在: $absolutePath';
  }

  @override
  String get originalJsonMissing_4821 => '原始标题JSON文件不存在，尝试sanitized标题';

  @override
  String findJsonFileWithPath(Object jsonPath) {
    return '查找JSON文件: $jsonPath (使用原始标题)';
  }

  @override
  String jsonFileSearch_7281(
    Object jsonPath,
    Object sanitizedTitle,
    Object title,
  ) {
    return '查找JSON文件: $jsonPath (原标题: \"$title\" -> 清理后: \"$sanitizedTitle\")';
  }

  @override
  String jsonFileNotExist_4821(Object jsonPath) {
    return 'JSON文件不存在: $jsonPath';
  }

  @override
  String fetchLegendListPath_7421(Object basePath) {
    return '获取图例列表，路径: $basePath';
  }

  @override
  String failedToGetLegendFromPath_7281(Object absolutePath, Object e) {
    return '从绝对路径获取图例失败: $absolutePath, 错误: $e';
  }

  @override
  String vfsEntryCount(Object count) {
    return 'VFS返回的条目数量: $count';
  }

  @override
  String folderNameConversion(Object desanitized, Object name) {
    return '文件夹名称转换: \"$name\" -> \"$desanitized\"';
  }

  @override
  String foundLegendFolders(Object folders) {
    return '找到的.legend文件夹: $folders';
  }

  @override
  String finalLegendTitleList(Object titles) {
    return '最终图例标题列表: $titles';
  }

  @override
  String folderLegendError_7421(Object e, Object folderPath) {
    return '获取文件夹中的图例失败: $folderPath, 错误: $e';
  }

  @override
  String getSubfolderFailed_7281(Object e, Object parentPath) {
    return '获取子文件夹失败: $parentPath, 错误: $e';
  }

  @override
  String fetchLegendListFailed_7285(Object e) {
    return '获取图例列表失败: $e';
  }

  @override
  String folderNotEmptyCannotDelete(Object folderPath) {
    return '文件夹不为空，无法删除: $folderPath';
  }

  @override
  String clearLegendFailed_7285(Object e) {
    return '清空图例失败: $e';
  }

  @override
  String sourceFolderNotExist_7285(Object oldPath) {
    return '源文件夹不存在: $oldPath';
  }

  @override
  String deleteFolderFailed(Object e, Object folderPath) {
    return '删除文件夹失败: $folderPath, 错误: $e';
  }

  @override
  String targetFolderExists_7281(Object newPath) {
    return '目标文件夹已存在: $newPath';
  }

  @override
  String renameFolderFailed_7281(Object e, Object newPath, Object oldPath) {
    return '重命名文件夹失败: $oldPath -> $newPath, 错误: $e';
  }

  @override
  String vfsDirectoryTreeLoaded(Object count) {
    return 'VFS目录树: 加载完成，根节点包含 $count 个子目录';
  }

  @override
  String vfsDirectoryLoadFailed_7421(Object e) {
    return 'VFS目录树: 加载失败 $e';
  }

  @override
  String get rootDirectoryName_4721 => '根目录';

  @override
  String get exampleLibrary_7421 => '图例库';

  @override
  String vfsDirectoryTreeStartBuilding(Object count) {
    return 'VFS目录树: 开始构建，输入文件夹数量: $count';
  }

  @override
  String vfsDirectoryTreeProcessingPath(
    Object folderPath,
    Object pathSegments,
  ) {
    return 'VFS目录树: 处理路径 \"$folderPath\"，分段: $pathSegments';
  }

  @override
  String vfsDirectoryTreeCreateNode(
    Object currentPath,
    Object parentName,
    Object parentPath,
    Object segment,
  ) {
    return 'VFS目录树: 创建节点 \"$segment\" (路径: $currentPath)，添加到父节点 \"$parentName\" (路径: $parentPath)';
  }

  @override
  String vfsTreeWarningParentNotFound(Object parentPath) {
    return 'VFS目录树: 警告 - 找不到父节点: $parentPath';
  }

  @override
  String vfsNodeExists_7281(Object currentPath) {
    return 'VFS目录树: 节点已存在: $currentPath';
  }

  @override
  String vfsDirectoryTreeBuilt_7281(Object count) {
    return 'VFS目录树: 构建完成，根节点包含 $count 个子节点';
  }

  @override
  String mapIdDebug(Object id) {
    return '地图ID: $id';
  }

  @override
  String get mapDatabaseServiceUpdateMapStart_7281 =>
      'MapDatabaseService.updateMap 开始执行';

  @override
  String get mapTitle_7421 => '地图标题';

  @override
  String get databaseConnected_7281 => '数据库连接成功';

  @override
  String dataSerializationComplete(Object fields) {
    return '数据序列化完成，字段: $fields';
  }

  @override
  String layerSerializationSuccess(Object length) {
    return '图层数据序列化成功，长度: $length';
  }

  @override
  String layerSerializationFailed_4829(Object e) {
    return '图层数据序列化失败: $e';
  }

  @override
  String legendGroupSerializationSuccess(Object length) {
    return '图例组数据序列化成功，长度: $length';
  }

  @override
  String legendGroupSerializationFailed_4821(Object e) {
    return '图例组数据序列化失败: $e';
  }

  @override
  String databaseUpdateComplete(Object updateResult) {
    return '数据库更新完成，影响行数: $updateResult';
  }

  @override
  String legendGroupSerializationFailed_7285(Object e) {
    return '图例组数据序列化失败: $e';
  }

  @override
  String mapRecordNotFoundWithId(Object id) {
    return '没有找到要更新的地图记录，ID: $id';
  }

  @override
  String layerSerializationFailed_7284(Object e) {
    return '图层数据序列化失败: $e';
  }

  @override
  String get mapDatabaseServiceError_4821 => 'MapDatabaseService.updateMap 错误:';

  @override
  String stackTraceMessage_7421(Object stackTrace) {
    return '堆栈: $stackTrace';
  }

  @override
  String databaseExportSuccess(
    Object dbVersion,
    Object mapCount,
    Object outputFile,
  ) {
    return '数据库导出成功: $outputFile (版本: $dbVersion, 地图数量: $mapCount)';
  }

  @override
  String get saveMapDatabaseTitle_4821 => '保存地图数据库';

  @override
  String exportDatabaseFailed_7421(Object e) {
    return '导出数据库失败: $e';
  }

  @override
  String mapUpdateMessage(Object newVersion, Object oldVersion, Object title) {
    return '更新地图: $title (版本 $oldVersion -> $newVersion)';
  }

  @override
  String addNewMapWithVersion(Object title, Object version) {
    return '添加新地图: $title (版本 $version)';
  }

  @override
  String skipMapMessage(
    Object existingVersion,
    Object importedVersion,
    Object title,
  ) {
    return '跳过地图: $title (当前版本 $existingVersion >= 导入版本 $importedVersion)';
  }

  @override
  String databaseImportFailed_7421(Object e) {
    return '导入数据库失败: $e';
  }

  @override
  String localizationVersionNotHigher(Object currentVersion, Object version) {
    return '本地化文件版本 $version 不高于当前版本 $currentVersion，跳过导入';
  }

  @override
  String exportLocalDbFailed(Object e) {
    return '导出本地化数据库失败: $e';
  }

  @override
  String importLocalizationFailed_7285(Object e) {
    return '导入本地化文件失败: $e';
  }

  @override
  String get exportMapLocalizationFileTitle_4821 => '导出地图本地化文件';

  @override
  String noteDebugInfo(Object arg0, Object arg1, Object arg2) {
    return '便签[$arg0] $arg1: $arg2个绘画元素';
  }

  @override
  String legendGroupInfo_7421(
    Object groupName,
    Object index,
    Object itemCount,
  ) {
    return '图例组[$index] $groupName: $itemCount个图例项';
  }

  @override
  String syncMapDataToVersion(
    Object layersCount,
    Object legendsCount,
    Object stickiesCount,
    Object versionId,
  ) {
    return '同步地图数据到版本 [$versionId], 图层数: $layersCount, 便签数: $stickiesCount, 图例组数: $legendsCount';
  }

  @override
  String versionManagerStatusChanged_7281(Object summary) {
    return '版本管理器状态变化: $summary';
  }

  @override
  String chartSessionInitFailed_7421(Object e) {
    return '图例会话初始化失败: $e';
  }

  @override
  String legendSessionInitialized(Object count) {
    return '图例会话初始化完成，图例数量: $count';
  }

  @override
  String versionNotFoundError(Object versionId) {
    return '版本不存在: $versionId';
  }

  @override
  String startSwitchingVersion_7281(Object versionId) {
    return '开始切换版本: $versionId';
  }

  @override
  String switchAndLoadVersionData(
    Object layersCount,
    Object notesCount,
    Object versionId,
  ) {
    return '切换并加载版本数据 [$versionId] 到响应式系统，图层数: $layersCount, 便签数: $notesCount';
  }

  @override
  String loadingNoteWithElements(Object count, Object i, Object title) {
    return '加载便签[$i] $title: $count个绘画元素';
  }

  @override
  String loadVersionDataToReactiveSystem(Object versionId) {
    return '从VFS加载版本数据 [$versionId] 到响应式系统';
  }

  @override
  String startEditingVersion(Object mapTitle, Object versionId) {
    return '开始编辑版本 [$mapTitle/$versionId]';
  }

  @override
  String versionSwitchCompleteResetFlag(Object versionId) {
    return '版本切换完成，重置更新标志 [$versionId]';
  }

  @override
  String versionCreationStart(Object sourceVersionId, Object versionId) {
    return '开始创建新版本: $versionId, 源版本: $sourceVersionId';
  }

  @override
  String fetchDataResult_7281(Object result, Object sourceVersionId) {
    return '从源版本 [$sourceVersionId] 获取数据: $result';
  }

  @override
  String successWithLayerCount_4592(Object count) {
    return '成功(图层数: $count)';
  }

  @override
  String get failure_8364 => '失败';

  @override
  String initialDataSetupSuccess(Object versionId) {
    return '为新版本 [$versionId] 设置初始数据成功';
  }

  @override
  String debugLayerCount(Object count) {
    return '从当前BLoC状态获取数据: 图层数: $count';
  }

  @override
  String versionWarning_7284(Object versionId) {
    return '警告: 新版本 [$versionId] 没有初始数据';
  }

  @override
  String versionCreatedAndSwitched_7281(Object versionId) {
    return '新版本创建并切换完成: $versionId';
  }

  @override
  String get noEditingVersionToSave_4821 => '没有正在编辑的版本，无需保存';

  @override
  String versionNoSessionDataToSave(Object activeVersionId) {
    return '版本 [$activeVersionId] 没有会话数据，无法保存';
  }

  @override
  String versionSaveFailed_7281(Object error, Object versionId) {
    return '保存版本数据失败 [$versionId]: $error';
  }

  @override
  String versionSaveFailed_4821(Object activeVersionId, Object e) {
    return '保存版本数据失败 [$activeVersionId]: $e';
  }

  @override
  String allVersionsSaved_7281(Object mapTitle) {
    return '标记所有版本已保存 [$mapTitle]';
  }

  @override
  String get cannotDeleteDefaultVersion_7281 => '无法删除默认版本';

  @override
  String versionDeletedLog(Object versionId) {
    return '删除版本完成 [$versionId]';
  }

  @override
  String get incompleteVersionData_7281 => '版本数据不完整';

  @override
  String versionStatusNotFound(Object versionId) {
    return '版本状态不存在: $versionId';
  }

  @override
  String versionDataTitleEmpty_7281(Object versionId) {
    return '版本数据标题为空: $versionId';
  }

  @override
  String versionSessionDataMissing_7281(Object versionId) {
    return '版本会话数据不存在: $versionId';
  }

  @override
  String responsiveVersionManagerBatchUpdate(Object count) {
    return '响应式版本管理器: 批量更新图层，数量: $count';
  }

  @override
  String responsiveVersionManagerUpdateLayer(Object name) {
    return '响应式版本管理器: 更新图层 $name';
  }

  @override
  String responsiveVersionManagerAddLayer(Object name) {
    return '响应式版本管理器: 添加图层 $name';
  }

  @override
  String responsiveVersionManagerDeleteLayer(Object layerId) {
    return '响应式版本管理器: 删除图层 $layerId';
  }

  @override
  String responsiveVersionManagerSetVisibility(
    Object groupId,
    Object isVisible,
  ) {
    return '响应式版本管理器: 设置图例组可见性 $groupId = $isVisible';
  }

  @override
  String responsiveVersionManagerSetOpacity(Object layerId, Object opacity) {
    return '响应式版本管理器: 设置图层透明度 $layerId = $opacity';
  }

  @override
  String get legendSessionInitialized_4821 => '已为现有地图数据初始化图例会话';

  @override
  String responsiveVersionManagerReorder(
    Object length,
    Object newIndex,
    Object oldIndex,
  ) {
    return '响应式版本管理器: 组内重排序图层 $oldIndex -> $newIndex，更新图层数量: $length';
  }

  @override
  String responsiveVersionManagerAddNote(Object title) {
    return '响应式版本管理器: 添加便签 $title';
  }

  @override
  String responsiveLayerManagerReorder(Object newIndex, Object oldIndex) {
    return '响应式版本管理器: 重新排序图层 $oldIndex -> $newIndex';
  }

  @override
  String responsiveVersionManagerUpdateNote(Object title) {
    return '响应式版本管理器: 更新便签 $title';
  }

  @override
  String responsiveNoteManagerDeleteNote_7421(Object noteId) {
    return '响应式版本管理器: 删除便签 $noteId';
  }

  @override
  String responsiveNoteManager_7281(Object count) {
    return '响应式版本管理器: 拖拽重新排序便签，数量: $count';
  }

  @override
  String reorderNoteLog(Object newIndex, Object oldIndex) {
    return '响应式版本管理器: 重新排序便签 $oldIndex -> $newIndex';
  }

  @override
  String responsiveVersionManagerAddLegendGroup_7421(Object name) {
    return '响应式版本管理器: 添加图例组 $name';
  }

  @override
  String responsiveVersionManagerUpdateLegendGroup(Object name) {
    return '响应式版本管理器: 更新图例组 $name';
  }

  @override
  String responsiveVersionManagerDeleteLegendGroup(Object legendGroupId) {
    return '响应式版本管理器: 删除图例组 $legendGroupId';
  }

  @override
  String get noEditingVersionSkipSync_4821 => '没有正在编辑的版本，跳过数据同步';

  @override
  String get responsiveVersionManagerAdapterReleased_7421 => '响应式版本管理适配器已释放资源';

  @override
  String initVersionSession(Object arg0, Object arg1, Object arg2) {
    return '初始化版本会话 [$arg0/$arg1]: $arg2';
  }

  @override
  String versionExists_7285(Object versionId) {
    return '版本已存在: $versionId';
  }

  @override
  String copyPathSelectionStatus(Object sourceVersionId, Object versionId) {
    return '从版本 $sourceVersionId 复制路径选择状态到 $versionId';
  }

  @override
  String copyDataFromVersion_4821(Object dataStatus, Object sourceVersionId) {
    return '从版本 $sourceVersionId 复制数据: $dataStatus';
  }

  @override
  String dataWithLayers_5729(Object layersCount) {
    return '有数据(图层数: $layersCount)';
  }

  @override
  String get noData_6391 => '无数据';

  @override
  String createVersionSession_4821(
    Object mapTitle,
    Object versionId,
    Object versionName,
  ) {
    return '创建新版本会话 [$mapTitle/$versionId]: $versionName';
  }

  @override
  String copiedFrom_5729(Object sourceVersionId) {
    return ' (从 $sourceVersionId 复制)';
  }

  @override
  String get cannotDeleteDefaultVersion_4271 => '无法删除默认版本';

  @override
  String versionNotExistNeedDelete(Object versionId) {
    return '版本不存在，无需删除: $versionId';
  }

  @override
  String deleteVersionSession(Object mapTitle, Object versionId) {
    return '删除版本会话 [$mapTitle/$versionId]';
  }

  @override
  String versionNotFoundError_4821(Object versionId) {
    return '版本不存在: $versionId';
  }

  @override
  String versionSwitchLog_7421(
    Object mapTitle,
    Object previousVersionId,
    Object versionId,
  ) {
    return '切换版本 [$mapTitle]: $previousVersionId -> $versionId';
  }

  @override
  String get versionWarning_4821 => '警告: 两个版本都没有路径选择数据';

  @override
  String compareVersionPathDiff_4827(Object fromVersionId, Object toVersionId) {
    return '开始比较版本路径差异: $fromVersionId -> $toVersionId';
  }

  @override
  String get pathDiffAnalysisComplete_7281 => '路径差异分析完成:';

  @override
  String addedPathsCount(Object count) {
    return '新增路径: $count 个';
  }

  @override
  String removedPathsCount_7421(Object count) {
    return '  移除路径: $count 个';
  }

  @override
  String loadingPathToCache(Object legendGroupId, Object path) {
    return '加载路径到缓存: $legendGroupId -> $path';
  }

  @override
  String cacheCleanPath(Object legendGroupId, Object path) {
    return '从缓存清理路径: $legendGroupId -> $path';
  }

  @override
  String pathStillInUse(Object path) {
    return '路径仍被其他图例组使用，跳过清理: $path';
  }

  @override
  String loadingPathToCache_7281(Object path) {
    return '正在加载路径到缓存: $path';
  }

  @override
  String legendFilesFound_7281(Object count, Object path) {
    return '在路径 $path 中找到 $count 个图例文件';
  }

  @override
  String loadedToCache_7281(Object legendPath) {
    return '已加载到缓存: $legendPath';
  }

  @override
  String pathLoadedComplete_728(Object path) {
    return '路径加载完成: $path';
  }

  @override
  String loadPathToCacheFailed(Object e, Object path) {
    return '加载路径到缓存失败: $path, 错误: $e';
  }

  @override
  String cacheCleanedPath_7281(Object path) {
    return '已从缓存清理路径: $path';
  }

  @override
  String versionNotFoundError_7284(Object versionId) {
    return '版本不存在: $versionId';
  }

  @override
  String versionSwitchStart(Object previousVersionId, Object versionId) {
    return '开始智能版本切换: $previousVersionId -> $versionId';
  }

  @override
  String compareVersionPathDiff(Object previousVersionId, Object versionId) {
    return '比较版本路径差异: $previousVersionId vs $versionId';
  }

  @override
  String cacheCleanFailed(Object e, Object path) {
    return '从缓存清理路径失败: $path, 错误: $e';
  }

  @override
  String sourceVersionPathSelection_7281(Object versionId) {
    return '源版本 $versionId 路径选择:';
  }

  @override
  String legendGroup_7421(Object key, Object value) {
    return '图例组 $key: $value';
  }

  @override
  String versionPathSelection_7281(Object versionId) {
    return '目标版本 $versionId 路径选择:';
  }

  @override
  String versionSwitchPath_4821(Object legendGroupId, Object path) {
    return '版本切换-加载路径: [$legendGroupId] $path';
  }

  @override
  String versionSwitchCleanPath(Object legendGroupId, Object path) {
    return '版本切换-清理路径: [$legendGroupId] $path';
  }

  @override
  String noNeedComparePathDiff(Object previousVersionId, Object versionId) {
    return '无需比较路径差异: previousVersionId=$previousVersionId, versionId=$versionId';
  }

  @override
  String versionSwitchComplete(Object previousVersionId, Object versionId) {
    return '智能版本切换完成: $previousVersionId -> $versionId';
  }

  @override
  String stopEditingVersion(Object arg0, Object arg1) {
    return '停止编辑版本 [$arg0/$arg1]';
  }

  @override
  String versionNotFoundCannotUpdate(Object versionId) {
    return '版本不存在，无法更新数据: $versionId';
  }

  @override
  String versionOrSessionNotFound_7421(Object versionId) {
    return '版本或会话数据不存在，无法更新图层: $versionId';
  }

  @override
  String updateVersionSessionData_4821(
    Object isModified,
    Object layerCount,
    Object mapTitle,
    Object versionId,
  ) {
    return '更新版本会话数据 [$mapTitle/$versionId], 标记为$isModified, 图层数: $layerCount';
  }

  @override
  String get modified_5732 => '已修改';

  @override
  String get notModified_6843 => '未修改';

  @override
  String versionOrSessionNotFound(Object versionId) {
    return '版本或会话数据不存在，无法更新图例组: $versionId';
  }

  @override
  String versionSavedLog(Object arg0, Object arg1) {
    return '标记版本已保存 [$arg0/$arg1]';
  }

  @override
  String updateVersionName(Object arg0, Object arg1, Object arg2) {
    return '更新版本名称 [$arg0/$arg1]: $arg2';
  }

  @override
  String updateVersionMetadata_7421(Object mapTitle, Object versionId) {
    return '更新版本元数据 [$mapTitle/$versionId]';
  }

  @override
  String sourceVersionNotFound_4821(Object sourceVersionId) {
    return '源版本不存在: $sourceVersionId';
  }

  @override
  String targetVersionExists_4821(Object newVersionId) {
    return '目标版本已存在: $newVersionId';
  }

  @override
  String get copySuffix_4821 => '(副本)';

  @override
  String copyVersionSession(
    Object mapTitle,
    Object newVersionId,
    Object sourceVersionId,
  ) {
    return '复制版本会话 [$mapTitle]: $sourceVersionId -> $newVersionId';
  }

  @override
  String clearSessionState_7421(Object arg0) {
    return '清理所有版本会话状态 [$arg0]';
  }

  @override
  String cleanVersionSessionData(Object mapTitle, Object versionId) {
    return '清理版本会话数据 [$mapTitle/$versionId]';
  }

  @override
  String editingVersion_7421(Object versionId) {
    return '编辑中: $versionId';
  }

  @override
  String mapSessionSummary_1589(
    Object currentVersionId,
    Object mapTitle,
    Object totalVersions,
    Object unsavedCount,
  ) {
    return '地图: $mapTitle, 版本: $totalVersions, 未保存: $unsavedCount, 当前: $currentVersionId';
  }

  @override
  String invalidVersionIdWarning(Object activeEditingVersionId) {
    return '警告：正在编辑的版本ID无效: $activeEditingVersionId';
  }

  @override
  String versionSessionCacheMissing_7421(Object key) {
    return '警告：版本 $key 的会话数据缓存丢失';
  }

  @override
  String resetVersionLegendSelection(Object legendGroupId, Object versionId) {
    return '重置版本 $versionId 图例组 $legendGroupId 的选择';
  }

  @override
  String steppedCleanupSkip_4827(Object folderPath) {
    return '步进型清理: 路径 $folderPath 仍被使用，跳过清理';
  }

  @override
  String versionLegendGroupStatusPath(
    Object legendGroupId,
    Object path,
    Object status,
    Object versionId,
  ) {
    return '版本 $versionId 图例组 $legendGroupId $status 路径: $path';
  }

  @override
  String get selected_3632 => '选中';

  @override
  String get unselected_3633 => '取消选中';

  @override
  String steppedCleanupLog(Object folderPath) {
    return '步进型清理: 清理路径 $folderPath 的缓存';
  }

  @override
  String get debugAsyncFunction_7425 => '处理异步外部函数';

  @override
  String asyncFunctionCompleteDebug(Object functionName, Object runtimeType) {
    return '异步函数 $functionName 完成，结果类型: $runtimeType';
  }

  @override
  String serializedResultDebug_7281(Object serializedResult) {
    return '序列化后的结果: $serializedResult';
  }

  @override
  String asyncFunctionError_4821(Object error, Object functionName) {
    return '异步函数 $functionName 出错: $error';
  }

  @override
  String syncExternalFunctionDebug_7421(
    Object functionName,
    Object runtimeType,
  ) {
    return '处理同步外部函数: $functionName，结果类型: $runtimeType';
  }

  @override
  String externalFunctionError_4821(Object error, Object functionName) {
    return '外部函数 $functionName 执行出错: $error';
  }

  @override
  String get serializedResultDebug_7425 => '序列化后的结果';

  @override
  String unsupportedProperty_7285(Object property) {
    return '不支持的属性: $property';
  }

  @override
  String stoppedScriptTtsPlayback_7421(Object _scriptId) {
    return '已停止脚本 $_scriptId 的所有TTS播放';
  }

  @override
  String scriptTtsFailed_4821(Object e) {
    return '停止脚本TTS失败: $e';
  }

  @override
  String scriptTtsFailure_4829(Object e) {
    return '停止脚本TTS失败: $e';
  }

  @override
  String ttsLanguageListObtained(Object count) {
    return '获取TTS语言列表: $count 种语言';
  }

  @override
  String fetchTtsLanguagesFailed_4821(Object e) {
    return '获取TTS语言列表失败: $e';
  }

  @override
  String ttsVoiceListCount(Object count) {
    return '获取TTS语音列表: $count 种语音';
  }

  @override
  String ttsListFetchFailed(Object e) {
    return '获取TTS语音列表失败: $e';
  }

  @override
  String ttsListFetchFailed_7285(Object e) {
    return '获取TTS语音列表失败: $e';
  }

  @override
  String checkLanguageAvailability_7421(Object isAvailable, Object language) {
    return '检查语言 $language 可用性: $isAvailable';
  }

  @override
  String ttsLanguageListError_4821(Object e) {
    return '获取TTS语言列表失败: $e';
  }

  @override
  String languageCheckFailed_7285(Object e) {
    return '检查语言可用性失败: $e';
  }

  @override
  String failedToGetVoiceSpeedRange(Object e) {
    return '获取语音速度范围失败: $e';
  }

  @override
  String ttsSpeedRangeLog(Object range) {
    return '获取TTS语音速度范围: $range';
  }

  @override
  String readingJsonFile_7421(Object path) {
    return '读取JSON文件: $path';
  }

  @override
  String writeTextFileLog_7421(Object length, Object path) {
    return '写入文本文件: $path, 内容长度: $length';
  }

  @override
  String get ttsInitializationSuccess_7281 => 'TTS 服务初始化成功';

  @override
  String ttsInitializationFailed(Object e) {
    return 'TTS服务初始化失败: $e';
  }

  @override
  String get tagFilterFailedJsonError_4821 => '标签筛选失败：JSON解析错误';

  @override
  String voiceSynthesisLog_7285(Object text) {
    return '处理语音合成: text=\"$text\"';
  }

  @override
  String get voiceSynthesisEmptyText_7281 => '语音合成: 文本为空，跳过';

  @override
  String updateLayerElementProperty_7421(
    Object elementId,
    Object layerId,
    Object property,
  ) {
    return '更新图层 $layerId 中元素 $elementId 的属性 $property';
  }

  @override
  String updateNoteElementProperty(
    Object elementId,
    Object noteId,
    Object property,
  ) {
    return '更新便签 $noteId 中元素 $elementId 的属性 $property';
  }

  @override
  String elementNotFound_4821(Object elementId) {
    return '未找到元素 $elementId';
  }

  @override
  String get moveElementFailedJsonError_4821 => '移动元素失败：JSON解析错误';

  @override
  String moveLayerElementOffset(
    Object deltaX,
    Object deltaY,
    Object elementId,
    Object layerId,
  ) {
    return '移动图层 $layerId 中元素 $elementId 偏移 ($deltaX, $deltaY)';
  }

  @override
  String moveNoteElementOffset_4821(
    Object deltaX,
    Object deltaY,
    Object elementId,
    Object noteId,
  ) {
    return '移动便签 $noteId 中元素 $elementId 偏移 ($deltaX, $deltaY)';
  }

  @override
  String createTextElementLog(Object text, Object x, Object y) {
    return '创建文本元素: \"$text\" 在位置 ($x, $y)';
  }

  @override
  String updateElementTextLog(Object elementId, Object newText) {
    return '更新元素 $elementId 的文本内容为: \"$newText\"';
  }

  @override
  String updateElementSizeLog(Object elementId, Object newSize) {
    return '更新元素 $elementId 的文本大小为: $newSize';
  }

  @override
  String failedToParseLegendUpdateJson(Object e) {
    return '解析图例组更新参数JSON失败: $e';
  }

  @override
  String legendGroupNotFound(Object groupId) {
    return '未找到图例组 $groupId';
  }

  @override
  String updateLegendGroupLog(Object groupId) {
    return '更新图例组 $groupId';
  }

  @override
  String setLegendGroupOpacityLog_7421(Object groupId, Object opacity) {
    return '设置图例组 $groupId 透明度为: $opacity';
  }

  @override
  String failedToParseLegendUpdateParamsJson(Object error) {
    return '解析图例项更新参数JSON失败: $error';
  }

  @override
  String speechSynthesisFailed_7285(Object e) {
    return '语音合成失败: $e';
  }

  @override
  String setLegendGroupVisibility(Object groupId, Object isVisible) {
    return '设置图例组 $groupId 可见性为: $isVisible';
  }

  @override
  String voiceSynthesisFailed_7281(Object e) {
    return '语音合成失败: $e';
  }

  @override
  String updateLegendItem_7425(Object itemId) {
    return '更新图例项 $itemId';
  }

  @override
  String legendItemNotFound_7285(Object itemId) {
    return '未找到图例项 $itemId';
  }

  @override
  String backupOnEventCalled(Object message) {
    return '备用onEvent被调用: $message';
  }

  @override
  String customMessageTypeLog_7421(Object executionId, Object type) {
    return '处理自定义消息类型: $type, 任务ID: $executionId';
  }

  @override
  String mapDataUpdatedWithTaskId_7421(Object executionId) {
    return '地图数据更新，任务ID: $executionId';
  }

  @override
  String stopSignalReceived_7421(Object executionId) {
    return '收到停止信号，任务ID: $executionId';
  }

  @override
  String scriptExecutionRequestLog(Object executionId) {
    return '执行脚本请求，任务ID: $executionId';
  }

  @override
  String unknownMessageTypeWithId(Object executionId, Object type) {
    return '未知消息类型: $type, 任务ID: $executionId';
  }

  @override
  String unknownMessageType(Object type) {
    return '未知消息类型: $type';
  }

  @override
  String customMessageError_4821(Object e) {
    return '自定义消息处理错误: $e';
  }

  @override
  String errorStackTrace_4821(Object stackTrace) {
    return '错误堆栈: $stackTrace';
  }

  @override
  String sendCustomMessageWithTaskId(Object executionId, Object type) {
    return '发送自定义消息: $type 任务ID: $executionId';
  }

  @override
  String sendCustomMessageError_4821(Object e) {
    return '发送自定义消息错误: $e';
  }

  @override
  String sendErrorMessageFailed_4827(Object e2) {
    return '发送错误消息也失败: $e2';
  }

  @override
  String get autoTypeAliasRegistrationComplete_7421 => '自动类型别名注册完成';

  @override
  String syncInternalFunctionsLog(Object internalFunctionNames) {
    return '同步内部函数: $internalFunctionNames';
  }

  @override
  String fallbackFailed_7285(Object e2) {
    return '回退方案也失败: $e2';
  }

  @override
  String asyncInternalFunctionLog_7428(Object asyncInternalFunctionNames) {
    return '异步内部函数: $asyncInternalFunctionNames';
  }

  @override
  String externalFunctionBindingRequired(Object uniqueExternalFunctions) {
    return '需要绑定的外部函数: $uniqueExternalFunctions';
  }

  @override
  String sendStartSignal(Object executionId) {
    return '发送开始信号，任务ID: $executionId';
  }

  @override
  String scriptExecutionSuccess_7421(Object executionId, Object executionTime) {
    return '脚本执行成功，用时 ${executionTime}ms，任务ID: $executionId';
  }

  @override
  String receivedStringMessage_7421(Object data) {
    return '收到字符串消息，尝试JSON解析: $data';
  }

  @override
  String nonStringMessageReceived_7285(Object runtimeType) {
    return '收到非字符串消息: $runtimeType';
  }

  @override
  String cannotAccessEventData_4821(Object e) {
    return '无法访问event.data: $e';
  }

  @override
  String jsonParseSuccess(Object runtimeType) {
    return 'JSON解析成功，数据类型: $runtimeType';
  }

  @override
  String jsonParseFailedWithData(Object data, Object error) {
    return 'JSON解析失败: $error, 原始数据: $data';
  }

  @override
  String typeMapping(Object fullTypeName, Object logicalName) {
    return '类型映射: $logicalName -> $fullTypeName';
  }

  @override
  String jsonParseFailed(Object e) {
    return 'JSON解析失败: $e';
  }

  @override
  String failedToExtractCoreType_7421(Object fullTypeName) {
    return '提取核心类型失败: $fullTypeName';
  }

  @override
  String registerGenericTypeName(Object fullTypeName, Object logicalName) {
    return '注册泛型类型名: $fullTypeName -> $logicalName';
  }

  @override
  String registerCoreObfuscationName(Object coreTypeName, Object logicalName) {
    return '注册核心混淆名: $coreTypeName -> $logicalName';
  }

  @override
  String processingDataTypeLog(Object runtimeType) {
    return '处理数据类型: $runtimeType';
  }

  @override
  String registrationFailed_4827(
    Object coreTypeName,
    Object e,
    Object fullTypeName,
    Object logicalName,
  ) {
    return '注册类型失败: $fullTypeName/$coreTypeName -> $logicalName, 错误: $e';
  }

  @override
  String taskProcessingLog(Object executionId, Object messageType) {
    return '处理任务ID: $executionId, 消息类型: $messageType';
  }

  @override
  String asyncMessageError_7284(Object error) {
    return '异步消息处理错误: $error';
  }

  @override
  String asyncMessageError_7285(Object e) {
    return '异步消息处理错误: $e';
  }

  @override
  String jsonParseError(Object content, Object type) {
    return 'JSON解析后仍非Map类型: $type, 内容: $content';
  }

  @override
  String messageFormatError(Object runtimeType) {
    return '消息格式错误: 期望Map类型，实际: $runtimeType';
  }

  @override
  String errorStackTrace_5421(Object stackTrace) {
    return '错误堆栈: $stackTrace';
  }

  @override
  String originalMessageError(Object e) {
    return '原始消息处理错误: $e';
  }

  @override
  String rawMessageError_4821(Object error) {
    return '原始消息处理错误: $error';
  }

  @override
  String timerCompleted_7281(Object timerId) {
    return '计时器已完成: $timerId';
  }

  @override
  String get timerManagerCleaned_7281 => '计时器管理器已清理';

  @override
  String timerStarted_7281(Object timerId) {
    return '计时器已启动: $timerId';
  }

  @override
  String get timerStopped_7285 => '计时器已停止';

  @override
  String get allTimersStopped_7281 => '所有计时器已停止';

  @override
  String timerPaused_7285(Object timerId) {
    return '计时器已暂停: $timerId';
  }

  @override
  String get ttsPlaybackCancelled_7421 => 'TTS播放取消';

  @override
  String ttsRequestFailed_7421(Object e) {
    return '处理TTS请求失败: $e';
  }

  @override
  String get ttsDisabledSkipPlayRequest_4821 => 'TTS已禁用，跳过播放请求';

  @override
  String availableLanguages_7421(Object availableLanguages) {
    return '可用语言: $availableLanguages';
  }

  @override
  String ttsPlaybackStart(Object sourceId, Object text) {
    return 'TTS开始播放文本: $text (来源: $sourceId)';
  }

  @override
  String get unknownSource_3632 => '未知';

  @override
  String availableVoicesMessage(Object availableVoices) {
    return '可用语音: $availableVoices';
  }

  @override
  String ttsLoadFailed_7285(Object e) {
    return '加载TTS选项失败: $e';
  }

  @override
  String get ttsNotInitialized_7281 => 'TTS未初始化，无法播放';

  @override
  String get ttsEmptySkipPlay_4821 => 'TTS文本为空，跳过播放';

  @override
  String get ttsStoppedQueueCleared_4821 => 'TTS已停止，队列已清空';

  @override
  String ttsRequestQueued(Object length, Object source, Object text) {
    return 'TTS请求已加入队列: \"$text\" (来源: $source, 队列长度: $length)';
  }

  @override
  String get unknown => '未知';

  @override
  String stoppedTtsRequests(Object count, Object sourceId) {
    return '已停止来源为 $sourceId 的 $count 个TTS请求';
  }

  @override
  String languageCheckFailed_4821(Object e) {
    return '检查语言可用性失败: $e';
  }

  @override
  String get ttsInitializationComplete_7281 => 'TTS服务初始化完成';

  @override
  String get ttsStartPlaying_7281 => 'TTS开始播放';

  @override
  String get ttsPlaybackComplete_7281 => 'TTS播放完成';

  @override
  String ttsError_7285(Object msg) {
    return 'TTS错误: $msg';
  }

  @override
  String fetchConfigFailed_7284(Object e) {
    return '获取配置信息失败: $e';
  }

  @override
  String get userPreferencesInitComplete_4821 => '用户偏好设置配置管理系统初始化完成';

  @override
  String configInitFailed_7285(Object e) {
    return '初始化配置管理系统失败: $e';
  }

  @override
  String get configDirCreatedOrExists_7281 => '配置目录已创建或已存在';

  @override
  String configDirCreationError_4821(Object e) {
    return '配置目录创建: $e';
  }

  @override
  String get databaseUpgradeMessage_7281 => '数据库升级：添加 home_page_data 字段';

  @override
  String get databaseUpgradeLayoutData_7281 =>
      '数据库升级：为 layout_data 添加 windowControlsMode 字段';

  @override
  String userPreferenceDbUpgrade_7421(Object newVersion, Object oldVersion) {
    return '用户偏好设置数据库从版本 $oldVersion 升级到 $newVersion';
  }

  @override
  String userPreferencesSavedToDatabase(Object displayName) {
    return '用户偏好设置已保存到数据库: $displayName';
  }

  @override
  String userConfigDeleted(Object userId) {
    return '用户配置已删除: $userId';
  }

  @override
  String get allUserPreferencesCleared_4821 => '所有用户偏好设置数据已清除';

  @override
  String migratedWindowControlsMode(Object userId) {
    return '已为用户 $userId 迁移 enableMergedWindowControls 到 windowControlsMode';
  }

  @override
  String userFieldAdded(Object userId) {
    return '已为用户 $userId 添加 windowControlsMode 字段';
  }

  @override
  String parseUserLayoutFailed(Object e, Object userId) {
    return '解析用户 $userId 的 layout_data 失败: $e';
  }

  @override
  String layoutDataMigrationError(Object e) {
    return '迁移 layout_data 时发生错误: $e';
  }

  @override
  String get userPreferencesTableCreated_7281 => '用户偏好设置数据库表创建完成';

  @override
  String migrateUserConfig(Object displayName) {
    return '迁移用户配置: $displayName';
  }

  @override
  String migrateLegacyPreferences(Object displayName) {
    return '迁移传统用户偏好设置: $displayName';
  }

  @override
  String migrationFailed_7285(Object e) {
    return '迁移传统用户偏好设置失败: $e';
  }

  @override
  String setCurrentUser_7421(Object currentUserId) {
    return '设置当前用户: $currentUserId';
  }

  @override
  String userPreferencesMigrationComplete(Object migratedUsersCount) {
    return '用户偏好设置迁移完成，迁移了 $migratedUsersCount 个用户';
  }

  @override
  String dataMigrationFailed_7281(Object e) {
    return '数据迁移失败: $e';
  }

  @override
  String get oldDataCleanedUp_7281 => '旧数据清理完成';

  @override
  String get migrationStatusReset_7281 => '迁移状态已重置';

  @override
  String resetMigrationFailed_4821(Object e) {
    return '重置迁移状态失败: $e';
  }

  @override
  String migrationStatsFailed_5421(Object e) {
    return '获取迁移统计信息失败: $e';
  }

  @override
  String get detectOldDataMigration_7281 => '检测到需要迁移的旧数据';

  @override
  String get dataMigrationSkipped_7281 => '数据已经迁移过，跳过迁移';

  @override
  String migrationCheckFailed_4821(Object e) {
    return '检查迁移状态失败: $e';
  }

  @override
  String userPreferencesSaved_7281(Object displayName) {
    return '用户偏好设置已保存: $displayName';
  }

  @override
  String get useGetAllUsersAsyncMethod => '请使用 getAllUsersAsync() 方法';

  @override
  String saveUserPreferenceFailed(Object e) {
    return '保存用户偏好设置失败: $e';
  }

  @override
  String commonStrokeWidthAdded(Object strokeWidth) {
    return '常用线条宽度已添加: ${strokeWidth}px';
  }

  @override
  String customColorAdded_7281(Object color) {
    return '自定义颜色已添加: $color';
  }

  @override
  String get userPreferencesMigration_7281 => '执行用户偏好设置数据迁移...';

  @override
  String loadUserPreferencesFailed(Object e) {
    return '加载当前用户偏好设置失败: $e';
  }

  @override
  String get dataMigrationComplete_7281 => '数据迁移完成';

  @override
  String get userPreferencesInitialized_7281 => '用户偏好设置服务初始化完成';

  @override
  String userPreferenceInitFailed_7421(Object e) {
    return '用户偏好设置服务初始化失败: $e';
  }

  @override
  String get fileOpenFailed_5421 => '打开文件失败';

  @override
  String get unsupportedFileType_4271 => '不支持的文件类型';

  @override
  String fileTypeWithExtension(Object extension) {
    return '文件类型: .$extension';
  }

  @override
  String get supportedImageFormats_7281 =>
      '• 图片: png, jpg, jpeg, gif, bmp, webp, svg';

  @override
  String get supportedFileTypes_4821 => '当前支持的文件类型:';

  @override
  String get videoFormats_7281 => '• 视频: mp4, avi, mov, wmv';

  @override
  String get supportedTextFormats_7281 => '• 文本: txt, log, csv, json';

  @override
  String get exportingVfsMapDatabase_7281 => '开始导出VFS地图数据库...';

  @override
  String vfsDatabaseExportSuccess(Object dbVersion, Object mapCount) {
    return 'VFS地图数据库导出成功 (版本: $dbVersion, 地图数量: $mapCount)';
  }

  @override
  String get vfsMapDbImportNotImplemented_7281 => 'VFS地图数据库导入功能暂未实现';

  @override
  String vfsMapExportFailed(Object e) {
    return 'VFS地图数据库导出失败: $e';
  }

  @override
  String vfsMapDbImportFailed(Object e) {
    return 'VFS地图数据库导入失败: $e';
  }

  @override
  String idMappingInitFailed_7425(Object e) {
    return '初始化ID映射失败: $e';
  }

  @override
  String get vfsCleanupComplete_7281 => 'VFS数据清理完成';

  @override
  String vfsCleanupFailed_7281(Object e) {
    return 'VFS数据清理失败: $e';
  }

  @override
  String get migrationDisabledNote_7281 => '迁移功能已禁用，直接使用VFS存储';

  @override
  String startMigrationMap_7421(Object title) {
    return '开始迁移地图: $title';
  }

  @override
  String mapMigrationComplete(Object mapId, Object title) {
    return '地图迁移完成: $title -> $mapId';
  }

  @override
  String mapMigrationFailed(Object error, Object title) {
    return '地图迁移失败: $title - $error';
  }

  @override
  String skipFailedMigrationMap(Object title) {
    return '跳过迁移失败的地图: $title';
  }

  @override
  String migrationValidationFailed(Object originalCount, Object vfsCount) {
    return '迁移验证失败: 地图数量不匹配 (原始: $originalCount, VFS: $vfsCount)';
  }

  @override
  String mapNotFoundError(Object mapTitle) {
    return '找不到地图: $mapTitle';
  }

  @override
  String get migrationValidationSuccess_7281 => '迁移验证成功: 所有地图数据完整';

  @override
  String migrationError_7425(Object e) {
    return '迁移验证出错: $e';
  }

  @override
  String legendGroupLoadFailed(Object e, Object mapTitle, Object version) {
    return '加载图例组失败[$mapTitle:$version]: $e';
  }

  @override
  String deleteLegendGroupFailed(
    Object error,
    Object groupId,
    Object mapTitle,
    Object version,
  ) {
    return '删除图例组失败[$mapTitle/$groupId:$version]: $error';
  }

  @override
  String saveLegendGroupFailed(
    Object error,
    Object groupId,
    Object mapTitle,
    Object version,
  ) {
    return '保存图例组失败[$mapTitle/$groupId:$version]: $error';
  }

  @override
  String startLoadingLegendGroup(
    Object folderPath,
    Object groupId,
    Object mapTitle,
    Object version,
  ) {
    return '开始加载图例组项: mapTitle=$mapTitle, groupId=$groupId, version=$version, folderPath=$folderPath';
  }

  @override
  String legendItemsPath_7285(Object itemsPath) {
    return '图例项路径: $itemsPath';
  }

  @override
  String foundFilesCount_7421(Object count, Object fileList) {
    return '找到 $count 个文件: $fileList';
  }

  @override
  String loadingLegendItem(Object itemId) {
    return '正在加载图例项: $itemId';
  }

  @override
  String legendItemLoadFailed(
    Object e,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return '加载图例项失败[$mapTitle/$groupId/$itemId:$version]: $e';
  }

  @override
  String legendItemLoadFailed_7421(
    Object groupId,
    Object itemError,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return '加载图例项失败[$mapTitle/$groupId/$itemId:$version]: $itemError';
  }

  @override
  String legendItemLoaded(Object itemId, Object legendId, Object legendPath) {
    return '成功加载图例项: $itemId, legendPath=$legendPath, legendId=$legendId';
  }

  @override
  String skippingNonJsonFile(Object fileName) {
    return '跳过非JSON文件: $fileName';
  }

  @override
  String legendGroupItemsLoaded(Object count) {
    return '图例组项加载完成: 共 $count 个项目';
  }

  @override
  String startLoadingLegendItems_7421(
    Object folderPath,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return '开始加载图例项: mapTitle=$mapTitle, groupId=$groupId, itemId=$itemId, version=$version, folderPath=$folderPath';
  }

  @override
  String legendItemFilePath(Object itemPath) {
    return '图例项文件路径: $itemPath';
  }

  @override
  String legendItemJsonSize(Object length) {
    return '图例项JSON数据大小: $length bytes';
  }

  @override
  String legendItemNotFound(Object itemPath) {
    return '图例项文件不存在: $itemPath';
  }

  @override
  String legendItemJsonContent(Object itemJson) {
    return '图例项JSON内容: $itemJson';
  }

  @override
  String legendItemParsedSuccessfully(
    Object id,
    Object legendId,
    Object legendPath,
  ) {
    return '成功解析图例项: id=$id, legendPath=$legendPath, legendId=$legendId';
  }

  @override
  String legendItemDeletionFailed_4827(
    Object e,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return '删除图例项失败[$mapTitle/$groupId/$itemId:$version]: $e';
  }

  @override
  String legendItemSaveFailed(
    Object error,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return '保存图例项失败[$mapTitle/$groupId/$itemId:$version]: $error';
  }

  @override
  String warningFailedToLoadStickyNoteBackground_7285(
    Object backgroundImageHash,
  ) {
    return '警告：无法从资产系统加载便签背景图片，哈希: $backgroundImageHash';
  }

  @override
  String noteDrawingElementLoaded(Object imageHash, Object length) {
    return '便签绘画元素图像已从资产系统加载，哈希: $imageHash ($length bytes)';
  }

  @override
  String stickyNoteBackgroundLoaded(Object backgroundImageHash, Object length) {
    return '便签背景图片已从资产系统加载，哈希: $backgroundImageHash ($length bytes)';
  }

  @override
  String parseNoteDataFailed(Object error, Object filePath) {
    return '解析便签数据失败 [$filePath]: $error';
  }

  @override
  String loadNoteDataFailed(Object e, Object mapTitle, Object version) {
    return '加载便签数据失败 [$mapTitle:$version]: $e';
  }

  @override
  String stickyNoteBackgroundSaved(Object hash, Object length) {
    return '便签背景图片已保存到资产系统，哈希: $hash ($length bytes)';
  }

  @override
  String noteDrawingElementSaved(Object hash, Object length) {
    return '便签绘画元素图像已保存到资产系统，哈希: $hash ($length bytes)';
  }

  @override
  String warningCannotLoadStickerImage(Object imageHash) {
    return '警告：无法从资产系统加载便签绘画元素图像，哈希: $imageHash';
  }

  @override
  String saveStickyNoteError(
    Object error,
    Object id,
    Object mapTitle,
    Object version,
  ) {
    return '保存便签数据失败 [$mapTitle/$id:$version]: $error';
  }

  @override
  String stickyNoteSaved(Object id, Object mapTitle, Object version) {
    return '便签数据已保存 [$mapTitle/$id:$version]';
  }

  @override
  String stickyNoteDeleted(
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  ) {
    return '便签数据已删除 [$mapTitle/$stickyNoteId:$version]';
  }

  @override
  String deleteStickyNoteError_7425(
    Object e,
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  ) {
    return '删除便签数据失败 [$mapTitle/$stickyNoteId:$version]: $e';
  }

  @override
  String warningCannotLoadStickyNoteBackground(Object backgroundImageHash) {
    return '警告：无法从资产系统加载便签背景图片，哈希: $backgroundImageHash';
  }

  @override
  String warningFailedToLoadNoteDrawingElement(Object imageHash) {
    return '警告：无法从资产系统加载便签绘画元素图像，哈希: $imageHash';
  }

  @override
  String versionExists_7284(Object version) {
    return '版本已存在: $version';
  }

  @override
  String loadStickyNoteError_4827(
    Object e,
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  ) {
    return '加载便签数据失败 [$mapTitle/$stickyNoteId:$version]: $e';
  }

  @override
  String mapVersionFetchFailed(Object e, Object mapTitle) {
    return '获取地图版本失败 [$mapTitle]: $e';
  }

  @override
  String createEmptyVersionDirectory(Object version) {
    return '创建空版本目录: $version';
  }

  @override
  String mapVersionCreationFailed_7421(
    Object e,
    Object mapTitle,
    Object version,
  ) {
    return '创建地图版本失败 [$mapTitle:$version]: $e';
  }

  @override
  String copyDataFromVersion(Object sourceVersion, Object version) {
    return '从版本 $sourceVersion 复制数据到版本 $version';
  }

  @override
  String copyVersionDataFailed(
    Object e,
    Object mapTitle,
    Object sourceVersion,
    Object targetVersion,
  ) {
    return '复制版本数据失败 [$mapTitle:$sourceVersion->$targetVersion]: $e';
  }

  @override
  String mapVersionDeletionFailed_7421(
    Object e,
    Object mapTitle,
    Object version,
  ) {
    return '删除地图版本失败 [$mapTitle:$version]: $e';
  }

  @override
  String versionMetadataReadFailed(Object e) {
    return '读取版本元数据失败，将创建新文件: $e';
  }

  @override
  String versionMetadataSaveFailed(
    Object e,
    Object mapTitle,
    Object versionId,
  ) {
    return '保存版本元数据失败 [$mapTitle:$versionId]: $e';
  }

  @override
  String versionMetadataSaved_7281(
    Object mapTitle,
    Object versionId,
    Object versionName,
  ) {
    return '保存版本元数据成功 [$mapTitle:$versionId -> $versionName]';
  }

  @override
  String versionFetchFailed(Object e, Object mapTitle, Object versionId) {
    return '获取版本名称失败 [$mapTitle:$versionId]: $e';
  }

  @override
  String fetchVersionNamesFailed(Object e, Object mapTitle) {
    return '获取所有版本名称失败 [$mapTitle]: $e';
  }

  @override
  String fetchMapFailed_7285(Object e) {
    return '获取所有地图失败: $e';
  }

  @override
  String mapLocalizationFailed_7421(Object e, Object mapTitle) {
    return '保存地图本地化失败[$mapTitle]: $e';
  }

  @override
  String assetDeletionFailed_7425(Object e, Object hash, Object mapTitle) {
    return '删除资产失败 [$mapTitle/$hash]: $e';
  }

  @override
  String assetFetchFailed(Object arg0, Object arg1, Object arg2) {
    return '获取资产失败 [$arg0/$arg1]: $arg2';
  }

  @override
  String directoryCopyComplete(Object sourcePath, Object targetPath) {
    return '目录复制完成: $sourcePath -> $targetPath';
  }

  @override
  String sourceDirectoryNotExist_7285(Object sourcePath) {
    return '源目录不存在: $sourcePath';
  }

  @override
  String copyDirectoryFailed(
    Object error,
    Object sourcePath,
    Object targetPath,
  ) {
    return '复制目录失败 [$sourcePath -> $targetPath]: $error';
  }

  @override
  String fetchFolderListFailed_4821(Object e) {
    return '获取文件夹列表失败: $e';
  }

  @override
  String folderCreationFailed_7421(Object e, Object folderPath) {
    return '创建文件夹失败 [$folderPath]: $e';
  }

  @override
  String folderRenameSuccess_4827(Object newPath, Object oldPath) {
    return '文件夹重命名成功: $oldPath -> $newPath';
  }

  @override
  String targetFolderExists(Object newPath) {
    return '目标文件夹已存在: $newPath';
  }

  @override
  String saveImageAssetToMap(Object filename, Object length, Object mapTitle) {
    return '保存新图像资产到地图 [$mapTitle]: $filename ($length bytes)';
  }

  @override
  String imageAssetExistsOnMap_7421(Object filename, Object mapTitle) {
    return '图像资产已在地图 [$mapTitle] 中存在，跳过保存: $filename';
  }

  @override
  String mapMoveFailed(Object arg0, Object arg1) {
    return '移动地图失败 [$arg0]: $arg1';
  }

  @override
  String saveAssetFailed_7281(Object e) {
    return '保存资产失败: $e';
  }

  @override
  String mapNotFoundError_7285(Object oldTitle) {
    return '找不到地图: $oldTitle';
  }

  @override
  String duplicateMapTitle(Object newTitle) {
    return '地图标题 \"$newTitle\" 已存在';
  }

  @override
  String mapRenameSuccess_7285(Object newTitle, Object oldTitle) {
    return '地图重命名成功: $oldTitle -> $newTitle';
  }

  @override
  String renameMapFailed(Object error, Object newTitle, Object oldTitle) {
    return '重命名地图失败 [$oldTitle -> $newTitle]: $error';
  }

  @override
  String mapCoverUpdatedSuccessfully(Object mapTitle) {
    return '地图封面更新成功: $mapTitle';
  }

  @override
  String mapCoverLoadFailed_7285(Object e) {
    return '加载地图封面失败: $e';
  }

  @override
  String fetchMapSummariesFailed_7285(Object e) {
    return '获取所有地图摘要失败: $e';
  }

  @override
  String mapIdLookupFailed_7421(Object id) {
    return '无法通过ID查找地图，VFS系统使用基于标题的存储: $id';
  }

  @override
  String mapFetchFailed_7284(Object e) {
    return '获取地图数量失败: $e';
  }

  @override
  String mapLoadFailed(Object e, Object title) {
    return '加载地图失败 [$title]: $e';
  }

  @override
  String mapSaveFailed(Object error, Object title) {
    return '保存地图失败 [$title]: $error';
  }

  @override
  String mapLoadFailedById(Object e, Object id) {
    return '通过ID加载地图失败 [$id]: $e';
  }

  @override
  String recursivelyDeletedOldDataDir(Object dataPath) {
    return '已递归删除旧的data目录及其所有内容: $dataPath';
  }

  @override
  String deleteOldDataError(Object e, Object mapTitle) {
    return '删除旧数据目录时出错 [$mapTitle]: $e';
  }

  @override
  String recursivelyDeletedOldAssets(Object assetsPath) {
    return '已递归删除旧的assets目录及其所有内容: $assetsPath';
  }

  @override
  String layerListLoadFailed(Object e, Object mapTitle, Object version) {
    return '加载图层列表失败 [$mapTitle:$version]: $e';
  }

  @override
  String layerBackgroundLoaded(Object hash, Object length) {
    return '图层背景图已从资产系统加载，哈希: $hash ($length bytes)';
  }

  @override
  String warningLayerBackgroundLoadFailed(Object hash) {
    return '警告：无法从资产系统加载图层背景图，哈希: $hash';
  }

  @override
  String layerLoadingFailed_4821(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return '加载图层失败 [$mapTitle/$layerId:$version]: $e';
  }

  @override
  String layerSaveFailed_7421(
    Object error,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return '保存图层失败 [$mapTitle/$layerId:$version]: $error';
  }

  @override
  String layerImageSavedToAssets(Object hash, Object length) {
    return '图层背景图已保存到资产系统，哈希: $hash ($length bytes)';
  }

  @override
  String imageDataLoadedFromAssets(Object bytes, Object imageHash) {
    return '已从资产系统加载图像数据，哈希: $imageHash ($bytes bytes)';
  }

  @override
  String failedToLoadDrawingElement(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return '加载绘制元素失败 [$mapTitle/$layerId:$version]: $e';
  }

  @override
  String layerDeletionFailed(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return '删除图层失败 [$mapTitle/$layerId:$version]: $e';
  }

  @override
  String imageLoadWarning(Object imageHash) {
    return '警告：无法从资产系统加载图像，哈希: $imageHash';
  }

  @override
  String imageSavedToMapAssets(Object hash, Object length) {
    return '图像已保存到地图资产系统，哈希: $hash ($length bytes)';
  }

  @override
  String failedToLoadElement_4821(
    Object e,
    Object elementId,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return '加载绘制元素失败 [$mapTitle/$layerId/$elementId:$version]: $e';
  }

  @override
  String saveDrawingElementError_7281(Object error, Object location) {
    return '保存绘制元素失败 [$location]: $error';
  }

  @override
  String deleteElementError_4821(
    Object elementId,
    Object error,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return '删除绘制元素失败 [$mapTitle/$layerId/$elementId:$version]: $error';
  }

  @override
  String validationError_7285(Object error) {
    return '验证过程出错: $error';
  }

  @override
  String get metadataFileMissing_7285 => '元数据文件不存在: meta.json';

  @override
  String missingRequiredField_4827(Object field) {
    return '元数据缺少必需字段: $field';
  }

  @override
  String metadataFileFormatError_7285(Object e) {
    return '元数据文件格式错误: $e';
  }

  @override
  String mapNotFound_7425(Object mapId) {
    return '地图不存在: $mapId';
  }

  @override
  String get backupRestoreUnimplemented_7281 => '恢复备份功能待实现';

  @override
  String mapBackupCreated(Object backupPath, Object length, Object mapId) {
    return '地图备份创建完成: $mapId -> $backupPath ($length bytes)';
  }

  @override
  String mapBackupFailed_7285(Object e) {
    return '创建地图备份失败: $e';
  }

  @override
  String mapRestoreFailed_7285(Object e) {
    return '从备份恢复地图失败: $e';
  }

  @override
  String mapPackageExportComplete(Object exportPath, Object mapId) {
    return '地图包导出完成: $mapId -> $exportPath';
  }

  @override
  String exportMapFailed_7285(Object e) {
    return '导出地图包失败: $e';
  }

  @override
  String get vfsRootInitialized_7281 => 'VFS根文件系统初始化完成';

  @override
  String collectionStatsError(Object collection, Object dbName, Object e) {
    return '获取集合统计失败: $dbName/$collection - $e';
  }

  @override
  String get vfsInitialized_7281 => 'VFS系统已初始化，跳过重复初始化';

  @override
  String get initializingVfsSystem_7281 => '开始初始化应用VFS系统...';

  @override
  String get vfsInitializationComplete_7281 => '应用VFS系统初始化完成';

  @override
  String vfsInitializationFailed_7421(Object e) {
    return '应用VFS系统初始化失败: $e';
  }

  @override
  String get vfsInitializedSkipDb_4821 => 'VFS系统已通过全局初始化完成，跳过默认数据库初始化';

  @override
  String get vfsInitializationStart_7281 => '开始初始化VFS根文件系统...';

  @override
  String get vfsRootExists_7281 => 'VFS根文件系统已存在，跳过初始化';

  @override
  String vfsRootInitFailed(Object e) {
    return 'VFS根文件系统初始化失败: $e';
  }

  @override
  String get initializingAppDatabase_7281 => '开始初始化应用数据库...';

  @override
  String get vfsInitializationSkipped_7281 => 'VFS权限系统已初始化，跳过重复初始化';

  @override
  String get vfsPlatformIOCreatingTempFile_4821 => '🔗 VfsPlatformIO: 开始创建临时文件';

  @override
  String get tempFileCreated_7285 => '成功创建临时文件';

  @override
  String get tempFileExists_4821 => '🔗 VfsPlatformIO: 临时文件已存在，直接返回路径';

  @override
  String get createTempDir_7425 => '创建应用临时目录';

  @override
  String get createWebDavTempDir_4721 => '创建WebDAV导入临时目录';

  @override
  String get webDavTempFilesCleaned => '🔗 VfsPlatformIO: 已清理WebDAV导入临时文件';

  @override
  String get vfsPlatformIOCleanedTempFiles_7281 => '🔗 VfsPlatformIO: 已清理临时文件';

  @override
  String get cleanWebDavTempFilesFailed_4721 => '清理WebDAV导入临时文件失败';

  @override
  String get tempFileCleanupFailed_7421 => '清理临时文件失败';

  @override
  String get webPlatformUnsupportedDirectoryCreation_4821 => 'Web平台不支持创建目录';

  @override
  String get webPlatformNotSupported_7281 => 'Web平台不支持创建文件';

  @override
  String get webPlatformNoNeedCleanTempFiles_4821 =>
      '🔗 VfsPlatformWeb: Web平台不需要清理临时文件';

  @override
  String get webPlatformNotSupportTempFile_4821 =>
      'Web平台不支持生成临时文件，请使用Data URI或Blob URL';

  @override
  String get webTempDirUnsupported_7281 => 'Web平台不支持获取临时目录';

  @override
  String generateFileUrl(Object vfsPath) {
    return '生成文件URL - $vfsPath';
  }

  @override
  String generateFileUrlFailed_4821(Object e) {
    return '生成文件URL失败 - $e';
  }

  @override
  String fileSizeExceededWebLimit(Object fileSize) {
    return '文件过大（${fileSize}MB，超过4MB限制），无法在Web平台生成URL';
  }

  @override
  String get generateDataUri_7425 => '生成Data URI';

  @override
  String get length_8921 => '长度';

  @override
  String largeFileWarning(Object fileSize) {
    return '🔗 VfsServiceProvider: 警告 - 文件较大（${fileSize}MB），可能影响性能';
  }

  @override
  String fileNotExist_4721(Object vfsPath) {
    return '文件不存在 - $vfsPath';
  }

  @override
  String get tempFileGenerationFailed_4821 => '生成临时文件失败';

  @override
  String webDavStorageCreated(Object storagePath) {
    return 'WebDAV存储目录已创建: $storagePath';
  }

  @override
  String get authFailedMessage_4821 => '认证失败，请检查用户名和密码';

  @override
  String get invalidServerPath_4821 => '服务器地址不正确或路径不存在';

  @override
  String get connectionTimeoutError_4821 => '连接超时，请检查网络和服务器地址';

  @override
  String fileDownloadSuccess(Object fullRemotePath, Object localFilePath) {
    return '文件下载成功: $fullRemotePath -> $localFilePath';
  }

  @override
  String fileDownloadFailed_7281(Object e) {
    return '文件下载失败: $e';
  }

  @override
  String directoryListSuccess(Object fullRemotePath, Object length) {
    return '目录列表获取成功: $fullRemotePath ($length 个项目)';
  }

  @override
  String fetchDirectoryFailed_7285(Object e) {
    return '获取目录列表失败: $e';
  }

  @override
  String deleteSuccessLog_7421(Object fullRemotePath) {
    return '删除成功: $fullRemotePath';
  }

  @override
  String get webDavClientInitialized_7281 => 'WebDAV客户端服务初始化完成';

  @override
  String directoryCreationFailed_7285(Object e) {
    return '目录创建失败: $e';
  }

  @override
  String deleteFailed_7425(Object e) {
    return '删除失败: $e';
  }

  @override
  String directoryCreatedSuccessfully(Object fullRemotePath) {
    return '目录创建成功: $fullRemotePath';
  }

  @override
  String pinyinConversionFailed_4821(Object e) {
    return '拼音转换失败: $e';
  }

  @override
  String pathExists_4821(Object fullRemotePath) {
    return '路径存在: $fullRemotePath';
  }

  @override
  String pathCheckFailed(Object e, Object remotePath) {
    return '路径检查失败: $remotePath - $e';
  }

  @override
  String webDavPasswordNotFound(Object authAccountId) {
    return 'WebDAV密码未找到: $authAccountId';
  }

  @override
  String webDavAuthAccountNotFound(Object authAccountId) {
    return 'WebDAV认证账户未找到: $authAccountId';
  }

  @override
  String webDavConfigNotFound(Object configId) {
    return 'WebDAV配置未找到: $configId';
  }

  @override
  String webDavClientCreationFailed(Object e) {
    return '创建WebDAV客户端失败: $e';
  }

  @override
  String get configurationNotFound_7281 => '配置未找到';

  @override
  String get webDavClientCreationError_4821 => '无法创建WebDAV客户端，请检查配置';

  @override
  String webDavAccountCreated(Object authAccountId) {
    return 'WebDAV认证账户已创建: $authAccountId';
  }

  @override
  String webDavAccountUpdated(Object authAccountId) {
    return 'WebDAV认证账户已更新: $authAccountId';
  }

  @override
  String cannotDeleteAuthAccountWithConfigs(Object count) {
    return '无法删除认证账户，仍有 $count 个配置在使用此账户';
  }

  @override
  String webDavAuthAccountDeleted(Object authAccountId) {
    return 'WebDAV认证账户已删除: $authAccountId';
  }

  @override
  String get webDavInitialized_7281 => 'WebDAV数据库服务初始化完成';

  @override
  String webDavConfigCreated(Object configId) {
    return 'WebDAV配置已创建: $configId';
  }

  @override
  String webDavConfigUpdated(Object configId) {
    return 'WebDAV配置已更新: $configId';
  }

  @override
  String webDavConfigDeleted(Object configId) {
    return 'WebDAV配置已删除: $configId';
  }

  @override
  String webDavPasswordRemoved(Object authAccountId) {
    return 'WebDAV密码已从 SharedPreferences 删除 (macOS): $authAccountId';
  }

  @override
  String webDavPasswordDeleted(Object authAccountId) {
    return 'WebDAV密码已删除: $authAccountId';
  }

  @override
  String checkWebDavPasswordExistenceFailed_4821(Object e) {
    return '检查WebDAV密码存在性失败: $e';
  }

  @override
  String webDavPasswordDeletionFailed(Object e) {
    return '删除WebDAV密码失败: $e';
  }

  @override
  String failedToGetWebDavAccountIds(Object e) {
    return '获取所有WebDAV认证账户ID失败: $e';
  }

  @override
  String get webDavPasswordsClearedMacOs =>
      '所有WebDAV密码已从 SharedPreferences 清理 (macOS)';

  @override
  String get allWebDavPasswordsCleared_7281 => '所有WebDAV密码已清理';

  @override
  String clearWebDavPasswordsFailed(Object e) {
    return '清理所有WebDAV密码失败: $e';
  }

  @override
  String webDavStatsError_4821(Object e) {
    return '获取WebDAV存储统计信息失败: $e';
  }

  @override
  String webDavAuthFailed_7285(Object e) {
    return 'WebDAV认证凭据验证失败: $e';
  }

  @override
  String get webDavAuthFailed_7281 => 'WebDAV认证凭据验证失败：密码未找到';

  @override
  String webDavPasswordStored(Object authAccountId) {
    return 'WebDAV密码已安全存储: $authAccountId';
  }

  @override
  String webDavPasswordStored_7421(Object authAccountId) {
    return 'WebDAV密码已存储到 SharedPreferences (macOS): $authAccountId';
  }

  @override
  String get webDavInitializationComplete_7281 => 'WebDAV安全存储服务初始化完成';

  @override
  String webDavPasswordSaveFailed(Object e) {
    return '存储WebDAV密码失败: $e';
  }

  @override
  String webDavPasswordRetrievedMacos(Object authAccountId) {
    return 'WebDAV密码从 SharedPreferences 获取成功 (macOS): $authAccountId';
  }

  @override
  String webDavPasswordSuccess_7285(Object authAccountId) {
    return 'WebDAV密码获取成功: $authAccountId';
  }

  @override
  String webDavPasswordError(Object e) {
    return '获取WebDAV密码失败: $e';
  }

  @override
  String get sampleDataCreated_7421 => 'WebDatabaseImporter: 示例数据创建完成';

  @override
  String get webDatabaseImporterWebOnly_7281 =>
      'WebDatabaseImporter: 只能在Web平台使用';

  @override
  String get webDatabaseImportComplete_4821 => 'WebDatabaseImporter: 数据导入完成';

  @override
  String mapImportSuccess(Object title) {
    return '成功导入地图: $title';
  }

  @override
  String get legendImportSuccess_7421 => '成功导入图例';

  @override
  String get importLegendFailed_7281 => '导入图例失败';

  @override
  String get createSampleData_7421 => 'WebDatabaseImporter: 创建示例数据';

  @override
  String get sampleMapTitle_7281 => '示例地图';

  @override
  String get createSampleDataFailed_7281 => '创建示例数据失败';

  @override
  String get sampleDataCleaned_7421 => '示例数据清理完成';

  @override
  String sampleDataCleanupFailed_7421(Object e) {
    return '示例数据清理失败: $e';
  }

  @override
  String get sampleDataInitialized_7281 => '示例数据初始化完成';

  @override
  String get skipExampleDataInitialization_7281 => '已有地图数据，跳过示例数据初始化';

  @override
  String sampleDataInitFailed_7421(Object e) {
    return '示例数据初始化失败: $e';
  }

  @override
  String get sampleLayerName_4821 => '示例图层';

  @override
  String mapInsertFailed_7285(Object e) {
    return '直接插入示例地图失败: $e';
  }

  @override
  String windowStateOnExit(Object height, Object maximized, Object width) {
    return '退出时读取窗口状态: ${width}x$height, 最大化: $maximized';
  }

  @override
  String resetWindowSizeFailed_4829(Object e) {
    return '重置窗口大小失败: $e';
  }

  @override
  String get windowSizeResetToDefault_4821 => '窗口大小已重置为默认值';

  @override
  String get autoSaveWindowSizeDisabled_7281 => '自动保存窗口大小已禁用，跳过保存';

  @override
  String get saveMaximizeStatusEnabled_4821 => '保存最大化状态：已开启记住最大化状态设置';

  @override
  String get saveWindowSizeNotMaximized_4821 => '保存窗口大小：当前非最大化状态';

  @override
  String get windowStateSavedSuccessfully_7281 => '退出时窗口状态保存成功';

  @override
  String get skipSaveMaximizedStateNotEnabled_4821 => '跳过保存：最大化状态但未开启记住最大化状态设置';

  @override
  String windowStateSaveError(Object e) {
    return '退出时保存窗口状态异常: $e';
  }

  @override
  String get windowStateSaveFailed_7281 => '退出时窗口状态保存失败';

  @override
  String windowSizeApplied(
    Object isMaximized,
    Object windowHeight,
    Object windowWidth,
  ) {
    return '窗口大小已应用: ${windowWidth}x$windowHeight, 位置由系统决定, 最大化: $isMaximized';
  }

  @override
  String windowSizeError_7425(Object e) {
    return '应用窗口大小失败: $e';
  }

  @override
  String windowSizeSaved(Object height, Object maximized, Object width) {
    return '窗口大小已保存: ${width}x$height, 最大化: $maximized (位置由系统决定)';
  }

  @override
  String get windowSizeSaveFailed_7281 => '窗口大小保存失败';

  @override
  String get cancelOperation_4821 => '取消操作';

  @override
  String get pauseOperationTooltip_7281 => '暂停操作';

  @override
  String get retryTooltip_7281 => '重试操作';

  @override
  String workStatusStart_7285(Object description) {
    return '工作状态开始: $description';
  }

  @override
  String get forceTerminateAllWorkStatus_4821 => '强制结束所有工作状态';

  @override
  String get workStatusEnded_7281 => '工作状态结束';

  @override
  String mapLegendZoomFactorLog_4821(
    Object legendGroupId,
    Object mapId,
    Object zoomFactor,
  ) {
    return '扩展设置: 地图 $mapId 的图例组 $legendGroupId 缩放因子已设置为 $zoomFactor';
  }

  @override
  String extensionSettingsClearedMapLegendZoom_7421(Object mapId) {
    return '扩展设置: 已清除地图 $mapId 的所有图例组缩放因子设置';
  }

  @override
  String mapLayerPresetSet(Object layerId, Object mapId, Object presets) {
    return '扩展设置: 地图 $mapId 的图层 $layerId 透明度预设已设置: $presets';
  }

  @override
  String toolbarPositionSet(Object toolbarId, Object x, Object y) {
    return '扩展设置: 工具栏 $toolbarId 位置已设置为 ($x, $y)';
  }

  @override
  String clearedSettingsWithPrefix(Object prefix) {
    return '扩展设置: 已清除前缀为 $prefix 的所有设置';
  }

  @override
  String mapZoomLevelRecord(Object mapId, Object zoomLevel) {
    return '扩展设置: 地图 $mapId 添加缩放级别记录 $zoomLevel';
  }

  @override
  String mapLegendAutoHideStatus(
    Object isHidden,
    Object legendGroupId,
    Object mapId,
  ) {
    return '扩展设置: 地图 $mapId 的图例组 $legendGroupId 智能隐藏状态已设置为 $isHidden';
  }

  @override
  String debugClearMapLegendSettings(Object mapId) {
    return '扩展设置: 已清除地图 $mapId 的所有图例组智能隐藏设置';
  }

  @override
  String legendGroupZoomFactorSaved(
    Object legendGroupId,
    Object mapId,
    Object zoomFactor,
  ) {
    return '图例组缩放因子已保存: $mapId/$legendGroupId = $zoomFactor';
  }

  @override
  String clearedMapLegendGroups_7421(Object mapId) {
    return '已清除地图 $mapId 的所有图例组缩放因子设置';
  }

  @override
  String get invalidImportDataFormat_7281 => '无效的导入数据格式';

  @override
  String importedMapLegendSettings(Object length, Object mapId) {
    return '已导入地图 $mapId 的图例组智能隐藏设置: $length 项';
  }

  @override
  String legendGroupSmartHideStatus_7421(
    Object isEnabled,
    Object legendGroupId,
  ) {
    return '图例组 $legendGroupId 智能隐藏状态: $isEnabled';
  }

  @override
  String legendGroupHiddenStatusSaved(
    Object enabled,
    Object legendGroupId,
    Object mapId,
  ) {
    return '图例组智能隐藏状态已保存: $mapId/$legendGroupId = $enabled';
  }

  @override
  String smartHideStatusSaved(Object enabled) {
    return '智能隐藏状态已保存: $enabled';
  }

  @override
  String zoomLevelRecorded(Object zoomLevel) {
    return '缩放级别已记录: $zoomLevel';
  }

  @override
  String toolbarPositionSaved(Object toolbarId, Object x, Object y) {
    return '工具栏 $toolbarId 位置已保存: ($x, $y)';
  }

  @override
  String get extensionManagerNotInitialized_7281 => '扩展设置管理器未初始化';

  @override
  String clearedMapLegendSettings(Object mapId) {
    return '已清除地图 $mapId 的所有图例组智能隐藏设置';
  }

  @override
  String get invalidImportDataFormat_4271 => '无效的导入数据格式';

  @override
  String exportImageFailed_7421(Object e) {
    return '导出图片失败: $e';
  }

  @override
  String get selectExportDirectory_4821 => '选择导出目录';

  @override
  String desktopExportFailed(Object e) {
    return '桌面平台导出图片失败: $e';
  }

  @override
  String get saveImageTitle_4821 => '保存图片';

  @override
  String desktopExportImageFailed_7285(Object e) {
    return '桌面平台导出单张图片失败: $e';
  }

  @override
  String webExportImageFailed(Object e) {
    return 'Web平台导出图片失败: $e';
  }

  @override
  String webExportSingleImageFailed(Object e) {
    return 'Web平台导出单张图片失败: $e';
  }

  @override
  String get transparentLayer_7285 => '透明图层';

  @override
  String failedToGetImageSize(Object e) {
    return '获取图片尺寸失败: $e';
  }

  @override
  String get failedToReadImageData_7284 => '无法读取图片数据';

  @override
  String get unsupportedImageFormatError_4821 =>
      '不支持的图片格式，请选择 JPG、PNG、GIF 或 WebP 格式的图片';

  @override
  String imageDecodeFailed_4821(Object error) {
    return '解码图片失败: $error';
  }

  @override
  String pdfPreviewFailed_7285(Object e) {
    return 'PDF预览生成失败: $e';
  }

  @override
  String googleFontLoadFailed(Object e) {
    return '无法加载Google中文字体，使用默认字体: $e';
  }

  @override
  String get pdfPrintDialogOpened_7281 => 'PDF打印对话框已打开';

  @override
  String get webPdfDialogOpened_7281 => 'Web平台PDF打印对话框已打开';

  @override
  String get savePdfDialogTitle_4821 => '保存PDF文件';

  @override
  String pdfPrintFailed_7285(Object e) {
    return 'PDF打印失败: $e';
  }

  @override
  String pdfSavedToPath_7281(Object path) {
    return 'PDF已保存到: $path';
  }

  @override
  String get userCanceledSaveOperation_9274 => '用户取消了保存操作';

  @override
  String pdfSaveFailed_7421(Object e) {
    return '保存PDF失败: $e';
  }

  @override
  String get portraitOrientation_1234 => '竖向';

  @override
  String get landscapeOrientation_5678 => '横向';

  @override
  String get onePerPage_4821 => '一页一张';

  @override
  String get twoPerPage_4822 => '一页两张';

  @override
  String get fourPerPage_4823 => '一页四张';

  @override
  String get sixPerPage_4824 => '一页六张';

  @override
  String get ninePerPage_4825 => '一页九张';

  @override
  String throttleErrorImmediate(Object e, Object key) {
    return '节流立即执行出错 [$key]: $e';
  }

  @override
  String throttleManagerReleased(Object count) {
    return 'ThrottleManager已释放，清理了$count个定时器';
  }

  @override
  String throttleError_7425(Object arg0, Object arg1) {
    return '节流执行出错 [$arg0]: $arg1';
  }

  @override
  String get webDownloadHelperWebOnly_7281 => 'WebDownloadHelper只能在Web平台使用';

  @override
  String get webDownloadUtilsWebOnly_7281 => 'WebDownloadUtils只能在Web平台使用';

  @override
  String webFileDownloadFailed_7285(Object e) {
    return 'Web文件下载失败: $e';
  }

  @override
  String batchDownloadFailed(Object error, Object fileName) {
    return '批量下载文件 \"$fileName\" 失败: $error';
  }

  @override
  String startTimerName_7281(Object name) {
    return '开始 $name';
  }

  @override
  String pauseTimerName(Object name) {
    return '暂停 $name';
  }

  @override
  String resetTimerName(Object name) {
    return '重置 $name';
  }

  @override
  String get createNewTimer_4821 => '创建新计时器';

  @override
  String stopTimerName(Object name) {
    return '停止 $name';
  }

  @override
  String get manageTimers_4821 => '管理计时器';

  @override
  String get createTimer_4271 => '创建计时器';

  @override
  String get createTimerTooltip_7421 => '创建计时器';

  @override
  String get timeSettings_7284 => '时间设置';

  @override
  String get timerNameLabel_4821 => '计时器名称';

  @override
  String get timerNameHint_4821 => '请输入计时器名称';

  @override
  String get timerTypeLabel_7281 => '计时器类型';

  @override
  String get hoursLabel_4821 => '小时';

  @override
  String get minutesLabel_7281 => '分钟';

  @override
  String get secondsLabel_4821 => '秒';

  @override
  String get enterTimerName_4821 => '请输入计时器名称';

  @override
  String get createButton_7281 => '创建';

  @override
  String get timerManagement_4271 => '计时器管理';

  @override
  String get setValidTimeError_4821 => '请设置有效的时间';

  @override
  String get noTimerAvailable_7281 => '暂无计时器';

  @override
  String get createNewTimer_4271 => '创建新计时器';

  @override
  String get confirmDeleteTimer_7421 => '确定要删除这个计时器吗？';

  @override
  String get pressKeyCombination_4821 => '请按下按键组合...';

  @override
  String get clickToStartRecording_4821 => '点击开始录制按键';
}
