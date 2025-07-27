import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../collaboration.dart';

/// 协作功能集成示例
/// 展示如何在地图页面中集成协作状态管理
class CollaborationIntegrationExample extends StatefulWidget {
  const CollaborationIntegrationExample({super.key});

  @override
  State<CollaborationIntegrationExample> createState() =>
      _CollaborationIntegrationExampleState();
}

class _CollaborationIntegrationExampleState
    extends State<CollaborationIntegrationExample> {
  late CollaborationStateBloc _collaborationBloc;
  late CollaborationSyncService _syncService;

  // 模拟地图元素位置
  final Map<String, Rect> _elementBounds = {
    'element_1': const Rect.fromLTWH(100, 100, 150, 80),
    'element_2': const Rect.fromLTWH(300, 200, 120, 60),
    'element_3': const Rect.fromLTWH(200, 350, 180, 100),
  };

  String? _selectedElementId;
  Offset _currentCursorPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeCollaboration();
  }

  @override
  void dispose() {
    _collaborationBloc.close();
    _syncService.dispose();
    super.dispose();
  }

  Future<void> _initializeCollaboration() async {
    // 初始化同步服务
    _syncService = CollaborationSyncService.instance;

    await _syncService.initialize(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      displayName: '演示用户',
      userColor: Colors.blue,
      onSendToRemote: _handleSendToRemote,
      onUserJoined: _handleUserJoined,
      onUserLeft: _handleUserLeft,
    );

    // 初始化协作状态Bloc
    _collaborationBloc = CollaborationStateBloc(
      stateManager: _syncService.stateManager,
    );

    // 初始化协作状态
    _collaborationBloc.add(
      InitializeCollaborationState(
        userId: _syncService.stateManager.currentUserId!,
        displayName: _syncService.stateManager.currentUserDisplayName!,
        userColor: _syncService.stateManager.currentUserColor!,
      ),
    );

    // 启用同步
    _syncService.enableSync();
  }

  void _handleSendToRemote(Map<String, dynamic> data) {
    // 在实际应用中，这里会通过WebSocket或其他方式发送到远程服务器
    debugPrint('[CollaborationExample] 发送数据到远程: ${data['type']}');

    // 模拟接收远程数据（用于演示）
    Future.delayed(const Duration(milliseconds: 100), () {
      _simulateRemoteData(data);
    });
  }

  void _handleUserJoined(String userId, String displayName) {
    debugPrint('[CollaborationExample] 用户加入: $displayName ($userId)');
  }

  void _handleUserLeft(String userId) {
    debugPrint('[CollaborationExample] 用户离开: $userId');
  }

  void _simulateRemoteData(Map<String, dynamic> originalData) {
    // 模拟其他用户的操作
    final remoteUserId = 'remote_user_${DateTime.now().millisecondsSinceEpoch}';

    final remoteData = {
      'type': 'user_selection',
      'payload': {
        'userId': remoteUserId,
        'userDisplayName': '远程用户',
        'userColor': Colors.red.toARGB32(),
        'selectedElementIds': ['element_2'],
        'selectionType': 'single',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };

    _syncService.handleRemoteData(remoteData);
  }

  void _onElementTap(String elementId) {
    setState(() {
      _selectedElementId = elementId;
    });

    // 尝试锁定元素
    _collaborationBloc.add(
      TryLockElement(
        elementId: elementId,
        elementType: 'map_element',
        isHardLock: false,
        timeoutSeconds: 30,
      ),
    );

    // 更新用户选择
    _collaborationBloc.add(
      UpdateUserSelection(
        selectedElementIds: [elementId],
        selectionType: 'single',
      ),
    );
  }

  void _onCursorMove(Offset position) {
    setState(() {
      _currentCursorPosition = position;
    });

    // 更新用户指针位置
    _collaborationBloc.add(
      UpdateUserCursor(position: position, isVisible: true),
    );
  }

  Rect? _getElementBounds(String elementId) {
    return _elementBounds[elementId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('协作功能集成示例'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<CollaborationStateBloc, CollaborationStateBlocState>(
            bloc: _collaborationBloc,
            builder: (context, state) {
              if (state is CollaborationStateLoaded) {
                return ConflictStatsWidget(
                  conflicts: state.conflicts,
                  onTap: () => _showConflictDialog(context, state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocProvider.value(
        value: _collaborationBloc,
        child: MouseRegion(
          onHover: (event) => _onCursorMove(event.localPosition),
          child: CollaborationOverlay(
            showUserCursors: true,
            showUserSelections: true,
            showConflicts: true,
            getElementBounds: _getElementBounds,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade100,
              child: Stack(
                children: [
                  // 模拟地图元素
                  ..._elementBounds.entries.map((entry) {
                    return _buildMapElement(entry.key, entry.value);
                  }),

                  // 当前用户指针
                  Positioned(
                    left: _currentCursorPosition.dx,
                    top: _currentCursorPosition.dy,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),

                  // 用户列表
                  Positioned(top: 16, left: 16, child: _buildUsersList()),

                  // 操作面板
                  Positioned(bottom: 16, left: 16, child: _buildActionPanel()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapElement(String elementId, Rect bounds) {
    return Positioned(
      left: bounds.left,
      top: bounds.top,
      child: GestureDetector(
        onTap: () => _onElementTap(elementId),
        child: BlocBuilder<CollaborationStateBloc, CollaborationStateBlocState>(
          bloc: _collaborationBloc,
          builder: (context, state) {
            bool isSelected = _selectedElementId == elementId;
            bool isLocked = false;
            bool isLockedByOther = false;

            if (state is CollaborationStateLoaded) {
              isLocked = state.isElementLocked(elementId);
              isLockedByOther = state.isElementLockedByOtherUser(elementId);
            }

            return Container(
              width: bounds.width,
              height: bounds.height,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.shade200
                    : isLockedByOther
                    ? Colors.red.shade100
                    : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? Colors.blue
                      : isLocked
                      ? Colors.orange
                      : Colors.grey,
                  width: isSelected || isLocked ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      elementId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isLocked)
                      Icon(
                        Icons.lock,
                        color: isLockedByOther ? Colors.red : Colors.orange,
                        size: 16,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return BlocBuilder<CollaborationStateBloc, CollaborationStateBlocState>(
      bloc: _collaborationBloc,
      builder: (context, state) {
        if (state is! CollaborationStateLoaded) {
          return const SizedBox.shrink();
        }

        final cursors = state.getOtherUsersCursors();

        return UserCursorsList(cursors: cursors);
      },
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '操作面板',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () {
              _collaborationBloc.add(const ClearUserSelection());
              setState(() {
                _selectedElementId = null;
              });
            },
            child: const Text('清除选择'),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () {
              _collaborationBloc.add(const HideUserCursor());
            },
            child: const Text('隐藏指针'),
          ),

          const SizedBox(height: 8),

          BlocBuilder<CollaborationStateBloc, CollaborationStateBlocState>(
            bloc: _collaborationBloc,
            builder: (context, state) {
              if (state is CollaborationStateLoaded &&
                  _selectedElementId != null) {
                final lockState = state.getElementLockState(
                  _selectedElementId!,
                );
                if (lockState != null &&
                    lockState.userId == state.currentUserId) {
                  return ElevatedButton(
                    onPressed: () {
                      _collaborationBloc.add(
                        UnlockElement(elementId: _selectedElementId!),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('解锁元素'),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _showConflictDialog(
    BuildContext context,
    CollaborationStateLoaded state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('协作冲突'),
        content: SizedBox(
          width: 400,
          child: ConflictListWidget(
            conflicts: state.conflicts,
            onResolveConflict: (conflictId) {
              _collaborationBloc.add(ResolveConflict(conflictId: conflictId));
              Navigator.of(context).pop();
            },
            onDismissConflict: (conflictId) {
              _collaborationBloc.add(ResolveConflict(conflictId: conflictId));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
