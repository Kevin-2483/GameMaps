import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/collaboration_state/collaboration_state_bloc.dart';
import '../blocs/collaboration_state/collaboration_state_event.dart';
import '../blocs/collaboration_state/collaboration_state_state.dart';
import '../models/collaboration_state.dart';
import 'collaboration_conflict_widget.dart';
import 'user_cursor_widget.dart';

/// 协作状态覆盖层
/// 显示其他用户的指针、选择状态和冲突信息
class CollaborationOverlay extends StatelessWidget {
  /// 子组件（通常是地图或画布）
  final Widget child;

  /// 是否显示用户指针
  final bool showUserCursors;

  /// 是否显示用户选择
  final bool showUserSelections;

  /// 是否显示冲突信息
  final bool showConflicts;

  /// 指针样式配置
  final UserCursorStyle? cursorStyle;

  /// 选择样式配置
  final UserSelectionStyle? selectionStyle;

  /// 冲突样式配置
  final ConflictStyle? conflictStyle;

  /// 坐标转换函数（将逻辑坐标转换为屏幕坐标）
  final Offset Function(Offset logicalPosition)? coordinateTransform;

  /// 元素位置获取函数（根据元素ID获取其在屏幕上的位置和大小）
  final Rect? Function(String elementId)? getElementBounds;

  const CollaborationOverlay({
    super.key,
    required this.child,
    this.showUserCursors = true,
    this.showUserSelections = true,
    this.showConflicts = true,
    this.cursorStyle,
    this.selectionStyle,
    this.conflictStyle,
    this.coordinateTransform,
    this.getElementBounds,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollaborationStateBloc, CollaborationStateBlocState>(
      builder: (context, state) {
        if (state is! CollaborationStateLoaded) {
          return child;
        }

        return Stack(
          children: [
            // 主要内容
            child,

            // 用户选择覆盖层
            if (showUserSelections) _buildUserSelectionsOverlay(context, state),

            // 用户指针覆盖层
            if (showUserCursors) _buildUserCursorsOverlay(context, state),

            // 冲突信息覆盖层
            if (showConflicts) _buildConflictsOverlay(context, state),
          ],
        );
      },
    );
  }

  /// 构建用户选择覆盖层
  Widget _buildUserSelectionsOverlay(
    BuildContext context,
    CollaborationStateLoaded state,
  ) {
    final otherUsersSelections = state.getOtherUsersSelections();

    if (otherUsersSelections.isEmpty || getElementBounds == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: UserSelectionsPainter(
            selections: otherUsersSelections,
            getElementBounds: getElementBounds!,
            style: selectionStyle ?? const UserSelectionStyle(),
          ),
        ),
      ),
    );
  }

  /// 构建用户指针覆盖层
  Widget _buildUserCursorsOverlay(
    BuildContext context,
    CollaborationStateLoaded state,
  ) {
    final otherUsersCursors = state.getOtherUsersCursors();

    if (otherUsersCursors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: otherUsersCursors.map((cursor) {
            final screenPosition =
                coordinateTransform?.call(cursor.position) ?? cursor.position;

            return Positioned(
              left: screenPosition.dx,
              top: screenPosition.dy,
              child: UserCursorWidget(
                cursor: cursor,
                style: cursorStyle ?? const UserCursorStyle(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建冲突信息覆盖层
  Widget _buildConflictsOverlay(
    BuildContext context,
    CollaborationStateLoaded state,
  ) {
    final unresolvedConflicts = state.getUnresolvedConflicts();

    if (unresolvedConflicts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: unresolvedConflicts.map((conflict) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CollaborationConflictWidget(
              conflict: conflict,
              style: conflictStyle ?? const ConflictStyle(),
              onResolve: () {
                context.read<CollaborationStateBloc>().add(
                  ResolveConflict(conflictId: conflict.id),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 用户选择绘制器
class UserSelectionsPainter extends CustomPainter {
  final List<UserSelectionState> selections;
  final Rect? Function(String elementId) getElementBounds;
  final UserSelectionStyle style;

  UserSelectionsPainter({
    required this.selections,
    required this.getElementBounds,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final selection in selections) {
      _paintUserSelection(canvas, selection);
    }
  }

  void _paintUserSelection(Canvas canvas, UserSelectionState selection) {
    final paint = Paint()
      ..color = selection.userColor.withValues(alpha: style.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.strokeWidth;

    for (final elementId in selection.selectedElementIds) {
      final bounds = getElementBounds(elementId);
      if (bounds != null) {
        // 绘制选择边框
        final rect = RRect.fromRectAndRadius(
          bounds.inflate(style.padding),
          Radius.circular(style.borderRadius),
        );
        canvas.drawRRect(rect, paint);

        // 绘制用户标签
        if (style.showUserLabel) {
          _paintUserLabel(canvas, bounds, selection);
        }
      }
    }
  }

  void _paintUserLabel(
    Canvas canvas,
    Rect bounds,
    UserSelectionState selection,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: selection.userDisplayName,
        style: TextStyle(
          color: style.labelTextColor,
          fontSize: style.labelFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final labelRect = Rect.fromLTWH(
      bounds.left,
      bounds.top - textPainter.height - 4,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    // 绘制标签背景
    final labelPaint = Paint()
      ..color = selection.userColor.withValues(alpha: 0.9);

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      labelPaint,
    );

    // 绘制标签文字
    textPainter.paint(canvas, Offset(labelRect.left + 4, labelRect.top + 2));
  }

  @override
  bool shouldRepaint(UserSelectionsPainter oldDelegate) {
    return selections != oldDelegate.selections || style != oldDelegate.style;
  }
}

/// 用户选择样式配置
class UserSelectionStyle {
  final double strokeWidth;
  final double opacity;
  final double padding;
  final double borderRadius;
  final bool showUserLabel;
  final Color labelTextColor;
  final double labelFontSize;

  const UserSelectionStyle({
    this.strokeWidth = 2.0,
    this.opacity = 0.7,
    this.padding = 2.0,
    this.borderRadius = 4.0,
    this.showUserLabel = true,
    this.labelTextColor = Colors.white,
    this.labelFontSize = 12.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSelectionStyle &&
        other.strokeWidth == strokeWidth &&
        other.opacity == opacity &&
        other.padding == padding &&
        other.borderRadius == borderRadius &&
        other.showUserLabel == showUserLabel &&
        other.labelTextColor == labelTextColor &&
        other.labelFontSize == labelFontSize;
  }

  @override
  int get hashCode {
    return Object.hash(
      strokeWidth,
      opacity,
      padding,
      borderRadius,
      showUserLabel,
      labelTextColor,
      labelFontSize,
    );
  }
}

/// 用户指针样式配置
class UserCursorStyle {
  final double size;
  final double opacity;
  final bool showUserLabel;
  final Color labelTextColor;
  final double labelFontSize;
  final Duration animationDuration;

  const UserCursorStyle({
    this.size = 20.0,
    this.opacity = 0.9,
    this.showUserLabel = true,
    this.labelTextColor = Colors.white,
    this.labelFontSize = 12.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserCursorStyle &&
        other.size == size &&
        other.opacity == opacity &&
        other.showUserLabel == showUserLabel &&
        other.labelTextColor == labelTextColor &&
        other.labelFontSize == labelFontSize &&
        other.animationDuration == animationDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      size,
      opacity,
      showUserLabel,
      labelTextColor,
      labelFontSize,
      animationDuration,
    );
  }
}

/// 冲突样式配置
class ConflictStyle {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double fontSize;

  const ConflictStyle({
    this.backgroundColor = const Color(0xFFFF5722),
    this.textColor = Colors.white,
    this.borderColor = const Color(0xFFD32F2F),
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(12.0),
    this.fontSize = 14.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConflictStyle &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other.borderColor == borderColor &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode {
    return Object.hash(
      backgroundColor,
      textColor,
      borderColor,
      borderRadius,
      padding,
      fontSize,
    );
  }
}
