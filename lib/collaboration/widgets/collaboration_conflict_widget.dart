import 'package:flutter/material.dart';
import '../models/collaboration_state.dart';
import 'collaboration_overlay.dart';

/// 协作冲突组件
/// 显示协作冲突信息和解决选项
class CollaborationConflictWidget extends StatefulWidget {
  final CollaborationConflict conflict;
  final ConflictStyle style;
  final VoidCallback? onResolve;
  final VoidCallback? onDismiss;
  final bool showActions;
  final Duration autoHideDuration;

  const CollaborationConflictWidget({
    super.key,
    required this.conflict,
    required this.style,
    this.onResolve,
    this.onDismiss,
    this.showActions = true,
    this.autoHideDuration = const Duration(seconds: 10),
  });

  @override
  State<CollaborationConflictWidget> createState() => _CollaborationConflictWidgetState();
}

class _CollaborationConflictWidgetState extends State<CollaborationConflictWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 自动隐藏定时器
    if (widget.autoHideDuration.inMilliseconds > 0) {
      Future.delayed(widget.autoHideDuration, () {
        if (mounted && _isVisible) {
          _hideConflict();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hideConflict() {
    if (!_isVisible) return;
    
    setState(() {
      _isVisible = false;
    });
    
    _animationController.forward().then((_) {
      widget.onDismiss?.call();
    });
  }

  void _resolveConflict() {
    widget.onResolve?.call();
    _hideConflict();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(300 * _slideAnimation.value, 0),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildConflictCard(),
          ),
        );
      },
    );
  }

  Widget _buildConflictCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: BorderRadius.circular(widget.style.borderRadius),
        border: Border.all(
          color: widget.style.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 冲突标题
          _buildConflictHeader(),
          
          // 冲突内容
          Padding(
            padding: widget.style.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConflictDescription(),
                
                if (widget.showActions) ...[
                  const SizedBox(height: 12),
                  _buildConflictActions(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.style.borderColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.style.borderRadius),
          topRight: Radius.circular(widget.style.borderRadius),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getConflictIcon(),
            color: widget.style.textColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getConflictTitle(),
              style: TextStyle(
                color: widget.style.textColor,
                fontSize: widget.style.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: widget.style.textColor,
              size: 16,
            ),
            onPressed: _hideConflict,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.conflict.description,
          style: TextStyle(
            color: widget.style.textColor,
            fontSize: widget.style.fontSize - 1,
          ),
        ),
        
        if (widget.conflict.involvedUserIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInvolvedUsers(),
        ],
        
        const SizedBox(height: 4),
        Text(
          '发生时间: ${_formatTimestamp(widget.conflict.timestamp)}',
          style: TextStyle(
            color: widget.style.textColor.withValues(alpha: 0.7),
            fontSize: widget.style.fontSize - 2,
          ),
        ),
      ],
    );
  }

  Widget _buildInvolvedUsers() {
    return Wrap(
      spacing: 4,
      children: widget.conflict.involvedUserIds.map((userId) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: widget.style.textColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            userId,
            style: TextStyle(
              color: widget.style.textColor,
              fontSize: widget.style.fontSize - 3,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConflictActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _hideConflict,
          style: TextButton.styleFrom(
            foregroundColor: widget.style.textColor.withValues(alpha: 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: const Text('忽略'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _resolveConflict,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.style.textColor,
            foregroundColor: widget.style.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 0,
          ),
          child: const Text('解决'),
        ),
      ],
    );
  }

  IconData _getConflictIcon() {
    switch (widget.conflict.type) {
      case ConflictType.elementLockConflict:
        return Icons.lock;
      case ConflictType.simultaneousEdit:
        return Icons.edit;
      case ConflictType.versionMismatch:
        return Icons.sync_problem;
      case ConflictType.permissionDenied:
        return Icons.security;
      case ConflictType.networkError:
        return Icons.wifi_off;
      case ConflictType.other:
        return Icons.warning;
      case ConflictType.editConflict:
        return Icons.edit;
      case ConflictType.lockConflict:
        return Icons.lock_outline;
      case ConflictType.deleteConflict:
        return Icons.delete_outline;
      case ConflictType.permissionConflict:
        return Icons.security;
    }
  }

  String _getConflictTitle() {
    switch (widget.conflict.type) {
      case ConflictType.elementLockConflict:
        return '元素锁定冲突';
      case ConflictType.simultaneousEdit:
        return '同时编辑冲突';
      case ConflictType.versionMismatch:
        return '版本不匹配';
      case ConflictType.permissionDenied:
        return '权限被拒绝';
      case ConflictType.networkError:
        return '网络错误';
      case ConflictType.other:
        return '协作冲突';
      case ConflictType.editConflict:
        return '编辑冲突';
      case ConflictType.lockConflict:
        return '锁定冲突';
      case ConflictType.deleteConflict:
        return '删除冲突';
      case ConflictType.permissionConflict:
        return '权限冲突';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// 冲突列表组件
/// 显示所有未解决的冲突
class ConflictListWidget extends StatelessWidget {
  final List<CollaborationConflict> conflicts;
  final ConflictStyle? style;
  final Function(String conflictId)? onResolveConflict;
  final Function(String conflictId)? onDismissConflict;
  final bool showResolvedConflicts;

  const ConflictListWidget({
    super.key,
    required this.conflicts,
    this.style,
    this.onResolveConflict,
    this.onDismissConflict,
    this.showResolvedConflicts = false,
  });

  @override
  Widget build(BuildContext context) {
    final filteredConflicts = showResolvedConflicts
        ? conflicts
        : conflicts.where((c) => !c.isResolved).toList();
    
    if (filteredConflicts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        child: Column(
          children: filteredConflicts.map((conflict) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CollaborationConflictWidget(
                conflict: conflict,
                style: style ?? const ConflictStyle(),
                onResolve: () => onResolveConflict?.call(conflict.id),
                onDismiss: () => onDismissConflict?.call(conflict.id),
                autoHideDuration: Duration.zero, // 不自动隐藏
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 冲突统计组件
/// 显示冲突数量和类型统计
class ConflictStatsWidget extends StatelessWidget {
  final List<CollaborationConflict> conflicts;
  final VoidCallback? onTap;

  const ConflictStatsWidget({
    super.key,
    required this.conflicts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unresolvedConflicts = conflicts.where((c) => !c.isResolved).toList();
    
    if (unresolvedConflicts.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red.shade700,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${unresolvedConflicts.length}个冲突',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}