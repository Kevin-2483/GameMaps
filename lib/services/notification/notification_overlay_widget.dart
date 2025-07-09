import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'notification_models.dart';

/// 通知弹窗组件
class NotificationOverlayWidget extends StatefulWidget {
  final NotificationMessage? notification;
  final List<NotificationMessage>? notifications;
  final NotificationConfig config;
  final NotificationTheme theme;
  final VoidCallback? onClose;
  final Function(String)? onCloseById;
  final int stackIndex;
  final ValueNotifier<int>? totalInStackNotifier;
  final ValueNotifier<List<String>>? queueStateNotifier;
  final ValueNotifier<int>? notificationUpdateNotifier;
  final NotificationMessage? Function()? getUpdatedNotification;

  // 单个通知构造函数（原有）
  const NotificationOverlayWidget({
    super.key,
    required this.notification,
    required this.config,
    required this.theme,
    required this.onClose,
  }) : notifications = null,
       onCloseById = null,
       stackIndex = 0,
       totalInStackNotifier = null,
       queueStateNotifier = null,
       notificationUpdateNotifier = null,
       getUpdatedNotification = null;

  // 独立单个通知构造函数（新增）
  const NotificationOverlayWidget.single({
    super.key,
    required this.notification,
    required this.config,
    required this.theme,
    required this.stackIndex,
    required this.totalInStackNotifier,
    required this.queueStateNotifier,
    this.notificationUpdateNotifier,
    this.getUpdatedNotification,
    required this.onClose,
  }) : notifications = null,
       onCloseById = null;

  // 堆叠通知构造函数
  const NotificationOverlayWidget.stack({
    super.key,
    required this.notifications,
    required this.config,
    required this.theme,
    required this.onCloseById,
  }) : notification = null,
       onClose = null,
       stackIndex = 0,
       totalInStackNotifier = null,
       queueStateNotifier = null,
       notificationUpdateNotifier = null,
       getUpdatedNotification = null;

  // 新的命名构造函数用于兼容
  const NotificationOverlayWidget.notifications({
    super.key,
    required this.notifications,
    required this.config,
    required this.theme,
    required Function(String) onClose,
  }) : notification = null,
       onClose = null,
       onCloseById = onClose,
       stackIndex = 0,
       totalInStackNotifier = null,
       queueStateNotifier = null,
       notificationUpdateNotifier = null,
       getUpdatedNotification = null;

  @override
  State<NotificationOverlayWidget> createState() =>
      _NotificationOverlayWidgetState();
}

class _NotificationOverlayWidgetState extends State<NotificationOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _loadingController; // 🔑 新增：loading动画控制器
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  double _continuousLoadingRotation = 0.0;
  @override
  void initState() {
    super.initState();

    // 滑入动画控制器
    _slideController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    // 进度条动画控制器 - 使用最新通知的持续时间
    final latestNotification = _getLatestNotification();
    _progressController = AnimationController(
      duration: latestNotification?.duration ?? widget.config.defaultDuration,
      vsync: this,
    );

    // 🔑 loading动画控制器 - 持续旋转
    _loadingController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..addStatusListener((status) {
            // 当一个动画周期完成时
            if (status == AnimationStatus.completed) {
              // 将一整圈 (2π) 累加到我们的连续旋转值上
              _continuousLoadingRotation += 2 * math.pi;
              // 从头开始下一个周期的动画
              _loadingController.forward(from: 0.0);
            }
          });

    // 设置滑入动画
    _slideAnimation =
        Tween<Offset>(begin: _getSlideBeginOffset(), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: widget.config.animationCurve,
          ),
        );

    // 设置进度动画
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // 启动动画
    _slideController.forward();
    if (latestNotification?.duration != null &&
        latestNotification!.duration! > Duration.zero &&
        !(latestNotification.isPersistent)) {
      _progressController.forward();
    }

    // 🔑 如果有loading边框效果，启动旋转动画
    if (latestNotification?.borderEffect == NotificationBorderEffect.loading) {
      _loadingController.forward();
    }
  }

  /// 获取最新的通知
  NotificationMessage? _getLatestNotification() {
    if (widget.notification != null) {
      return widget.notification;
    }
    if (widget.notifications != null && widget.notifications!.isNotEmpty) {
      return widget.notifications!.last;
    }
    return null;
  }

  @override
  void didUpdateWidget(NotificationOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldNotification =
        oldWidget.notification ??
        (oldWidget.notifications?.isNotEmpty == true
            ? oldWidget.notifications!.last
            : null);
    final newNotification = _getLatestNotification();

    // 如果通知内容发生变化，更新相关状态但不重新播放动画
    if (oldNotification != null && newNotification != null) {
      // 检查边框效果是否变化
      if (oldNotification.borderEffect != newNotification.borderEffect) {
        if (newNotification.borderEffect == NotificationBorderEffect.loading) {
          // 开始loading动画
          if (!_loadingController.isAnimating) {
            // 🔑 重置旋转值并使用 forward()
            _continuousLoadingRotation = 0.0;
            _loadingController.forward(from: 0.0);
          }
        } else {
          // 停止loading动画
          _loadingController.stop();
        }
      }

      // print('🔍 Update check: oldPersistent=$oldIsPersistent, newPersistent=$newIsPersistent, durationChanged=$durationChanged, becameNonPersistent=$becameNonPersistent');

      // if (durationChanged || becameNonPersistent) {
      //   print('🔄 Updating progress controller...');
      //   _progressController.stop();
      //   _progressController.duration =
      //       newNotification.duration ?? widget.config.defaultDuration;

      //   // 如果通知变为非常驻且有有效的持续时间，启动进度动画
      //   if (!newIsPersistent &&
      //       newNotification.duration != null &&
      //       newNotification.duration! > Duration.zero) {
      //     print('🔄 Before reset: controller.value=${_progressController.value}, status=${_progressController.status}');
      //     _progressController.reset();
      //     print('🔄 After reset: controller.value=${_progressController.value}, status=${_progressController.status}');
      //     _progressController.forward();
      //     print('🔄 After forward: controller.value=${_progressController.value}, status=${_progressController.status}');
      //     print('🔄 Progress animation started: duration=${newNotification.duration}, isPersistent=$newIsPersistent');
      //   } else {
      //     print('🔄 Not starting animation: newPersistent=$newIsPersistent, duration=${newNotification.duration}');
      //   }
      // } else {
      //   print('🔄 No update needed');
      // }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    _loadingController.dispose(); // 🔑 释放loading动画控制器
    super.dispose();
  }

  /// 获取滑入动画的起始偏移
  Offset _getSlideBeginOffset() {
    final latestNotification = _getLatestNotification();
    final position =
        latestNotification?.position ?? widget.config.defaultPosition;
    switch (position) {
      case NotificationPosition.topLeft:
      case NotificationPosition.topCenter:
      case NotificationPosition.topRight:
        return const Offset(0, -1);
      case NotificationPosition.bottomLeft:
      case NotificationPosition.bottomCenter:
      case NotificationPosition.bottomRight:
        return const Offset(0, 1);
      case NotificationPosition.centerLeft:
        return const Offset(-1, 0);
      case NotificationPosition.centerRight:
        return const Offset(1, 0);
      case NotificationPosition.center:
        return const Offset(0, -0.5);
    }
  }

  /// 获取位置对齐方式
  Alignment _getAlignment() {
    final latestNotification = _getLatestNotification();
    final position =
        latestNotification?.position ?? widget.config.defaultPosition;
    switch (position) {
      case NotificationPosition.topLeft:
        return Alignment.topLeft;
      case NotificationPosition.topCenter:
        return Alignment.topCenter;
      case NotificationPosition.topRight:
        return Alignment.topRight;
      case NotificationPosition.centerLeft:
        return Alignment.centerLeft;
      case NotificationPosition.center:
        return Alignment.center;
      case NotificationPosition.centerRight:
        return Alignment.centerRight;
      case NotificationPosition.bottomLeft:
        return Alignment.bottomLeft;
      case NotificationPosition.bottomCenter:
        return Alignment.bottomCenter;
      case NotificationPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  /// 处理关闭
  void _handleClose([String? messageId]) async {
    // 滑出动画
    await _slideController.reverse();

    if (messageId != null && widget.onCloseById != null) {
      widget.onCloseById!(messageId);
    } else if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Align(
          alignment: _getAlignment(),
          child: Padding(
            padding: widget.config.margin,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: _buildNotificationContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建通知内容
  Widget _buildNotificationContent() {
    if (widget.notification != null) {
      // 单个通知模式
      // 如果有队列状态通知器，使用它来动态计算位置
      if (widget.queueStateNotifier != null) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: widget.queueStateNotifier!,
          builder: (context, queueState, child) {
            // 在队列中找到当前通知的实际位置
            final actualIndex = queueState.indexOf(widget.notification!.id);
            if (actualIndex == -1) {
              // 通知不在队列中，可能正在被移除
              return const SizedBox.shrink();
            }

            // 计算缩放比例和偏移
            // 最上层(actualIndex=0)始终保持原始位置和大小
            final scale = actualIndex == 0
                ? 1.0
                : math.pow(widget.config.stackScale, actualIndex).toDouble();
            double horizontalOffset = 0.0;
            double verticalOffset = 0.0;

            if (actualIndex > 0) {
              final offsetDistance = actualIndex * widget.config.stackOffset;
              final position = widget.notification!.position;

              // 判断对齐的轴和方向
              final bool isTop =
                  position == NotificationPosition.topLeft ||
                  position == NotificationPosition.topCenter ||
                  position == NotificationPosition.topRight;
              final bool isBottom =
                  position == NotificationPosition.bottomLeft ||
                  position == NotificationPosition.bottomCenter ||
                  position == NotificationPosition.bottomRight;
              final bool isCenterVertical =
                  position == NotificationPosition.centerLeft ||
                  position == NotificationPosition.center ||
                  position == NotificationPosition.centerRight;

              final bool isLeft =
                  position == NotificationPosition.topLeft ||
                  position == NotificationPosition.centerLeft ||
                  position == NotificationPosition.bottomLeft;
              final bool isRight =
                  position == NotificationPosition.topRight ||
                  position == NotificationPosition.centerRight ||
                  position == NotificationPosition.bottomRight;
              final bool isCenterHorizontal =
                  position == NotificationPosition.topCenter ||
                  position == NotificationPosition.center ||
                  position == NotificationPosition.bottomCenter;

              final widthDifference =
                  widget.config.notificationWidth * (1.0 - scale);
              final heightDifference =
                  widget.config.notificationHeight * (1.0 - scale);

              // 根据方向计算垂直偏移
              if (isTop) {
                verticalOffset = -offsetDistance;
              } else if (isBottom) {
                verticalOffset =
                    offsetDistance + heightDifference; // 底部对齐需要额外加上高度差
              } else if (isCenterVertical) {
                verticalOffset = heightDifference / 2.0; // 垂直居中
                if (position == NotificationPosition.center) {
                  // 特殊处理 Center，使其向下偏移
                  verticalOffset += offsetDistance;
                }
              }

              // 根据方向计算水平偏移
              if (isLeft) {
                horizontalOffset = -offsetDistance;
              } else if (isRight) {
                horizontalOffset =
                    offsetDistance + widthDifference; // 右侧对齐需要额外加上宽度差
              } else if (isCenterHorizontal) {
                horizontalOffset = widthDifference / 2.0; // 水平居中
              }
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..translate(horizontalOffset, verticalOffset)
                ..scale(scale),
              child: _buildSingleNotification(
                widget.notification!,
                actualIndex,
              ),
            );
          },
        );
      }

      // 回退到原有逻辑
      return Transform.translate(
        offset: Offset(0, widget.stackIndex * widget.config.stackOffset),
        child: widget.totalInStackNotifier != null
            ? ValueListenableBuilder<int>(
                valueListenable: widget.totalInStackNotifier!,
                builder: (context, totalInStack, child) {
                  return Transform.scale(
                    scale: totalInStack > 1
                        ? math
                              .pow(
                                widget.config.stackScale,
                                totalInStack - 1 - widget.stackIndex,
                              )
                              .toDouble()
                        : 1.0,
                    child: _buildSingleNotification(
                      widget.notification!,
                      widget.stackIndex,
                    ),
                  );
                },
              )
            : _buildSingleNotification(widget.notification!, widget.stackIndex),
      );
    } else {
      // 堆叠通知模式（保持原有逻辑）
      return _buildNotificationStack();
    }
  }

  /// 构建通知堆叠
  Widget _buildNotificationStack() {
    final notifications = widget.notifications ?? [widget.notification!];

    if (notifications.length == 1) {
      return _buildSingleNotification(notifications.first, 0);
    }

    // 构建堆叠的通知
    return Stack(
      children: notifications.asMap().entries.map((entry) {
        final index = entry.key;
        final notification = entry.value;
        final isTop = index == notifications.length - 1;

        return Transform.translate(
          offset: Offset(0, index * widget.config.stackOffset),
          child: Transform.scale(
            scale: isTop
                ? 1.0
                : math
                      .pow(
                        widget.config.stackScale,
                        notifications.length - 1 - index,
                      )
                      .toDouble(),
            child: _buildSingleNotification(notification, index),
          ),
        );
      }).toList(),
    );
  }

  /// 构建单个通知
  Widget _buildSingleNotification(
    NotificationMessage notification,
    int stackIndex,
  ) {
    // 如果有更新通知器，使用它来监听内容变化
    if (widget.notificationUpdateNotifier != null &&
        widget.getUpdatedNotification != null) {
      return ValueListenableBuilder<int>(
        valueListenable: widget.notificationUpdateNotifier!,
        builder: (context, version, child) {
          // 获取最新的通知数据
          final updatedNotification =
              widget.getUpdatedNotification!() ?? notification;

          // 检查是否需要启动进度动画
          final shouldStartProgress =
              !(updatedNotification.isPersistent) &&
              updatedNotification.duration != null &&
              updatedNotification.duration! > Duration.zero;

          // print('🔄 ValueListenableBuilder: version=$version, shouldStart=$shouldStartProgress, duration=${updatedNotification.duration}, isPersistent=${updatedNotification.isPersistent}');

          if (shouldStartProgress &&
              _progressController.status != AnimationStatus.forward) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // print('🔄 Starting progress animation from ValueListenableBuilder');
              _progressController.duration = updatedNotification.duration!;
              _progressController.reset();
              _progressController.forward();
            });
          }

          return _buildNotificationWidget(updatedNotification, stackIndex);
        },
      );
    }

    // 回退到原有逻辑
    return _buildNotificationWidget(notification, stackIndex);
  }

  /// 构建通知组件
  Widget _buildNotificationWidget(
    NotificationMessage notification,
    int stackIndex,
  ) {
    return Builder(
      builder: (context) {
        final backgroundColor = widget.theme.getColorForType(
          notification.type,
          context,
        );
        final icon = widget.theme.getIconForType(notification.type);
        final iconColor = widget.theme.getIconColorForType(notification.type);

        return GestureDetector(
          onTap: notification.onTap,
          child: Stack(
            children: [
              // 主要通知容器
              Container(
                width: widget.config.notificationWidth,
                height: widget.config.notificationHeight,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(
                    widget.config.borderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: widget.config.elevation,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 左侧图标
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      // 消息文本
                      Expanded(
                        child: Text(
                          notification.message,
                          style: widget.theme.textStyle.copyWith(
                            color: widget.theme.getTextColorForTheme(context),
                            height: 1.3,
                          ),
                          maxLines: widget.config.maxLines,
                          overflow: widget.config.textOverflow,
                        ),
                      ),
                      // 关闭按钮
                      // if (notification.showCloseButton ?? false)
                      //   GestureDetector(
                      //     onTap: () => _handleClose(notification.id),
                      //     child: Container(
                      //       width: 24,
                      //       height: 24,
                      //       alignment: Alignment.center,
                      //       child: Icon(
                      //         Icons.close,
                      //         color: iconColor,
                      //         size: 16,
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
              // 🔑 边框效果
              _buildBorderEffect(notification, iconColor),
            ],
          ),
        );
      },
    );
  }

  /// 🔑 构建边框效果
  Widget _buildBorderEffect(NotificationMessage notification, Color iconColor) {
    switch (notification.borderEffect) {
      case NotificationBorderEffect.none:
        // 原有的进度条边框（仅在有duration时显示）
        final shouldShowProgress =
            notification.duration != null &&
            notification.duration! > Duration.zero &&
            !(notification.isPersistent);

        // print('🔍 Progress check: duration=${notification.duration}, isPersistent=${notification.isPersistent}, shouldShow=$shouldShowProgress, animValue=${_progressAnimation.value}');

        if (shouldShowProgress) {
          return Positioned.fill(
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                // print('🎯 Progress animation value: ${_progressAnimation.value}');
                return CustomPaint(
                  painter: _CircularProgressBorderPainter(
                    progress: _progressAnimation.value,
                    color: iconColor,
                    borderRadius: widget.config.borderRadius,
                    strokeWidth: 3.0,
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();

      case NotificationBorderEffect.glow:
        // 发光边框效果
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.config.borderRadius),
              border: Border.all(color: iconColor.withOpacity(0.8), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
          ),
        );

      case NotificationBorderEffect.loading:
        // 旋转loading边框效果
        return Positioned.fill(
          child: AnimatedBuilder(
            // 🔑 直接监听 controller，而不是 animation 对象
            animation: _loadingController,
            builder: (context, child) {
              // 🔑 计算总的、连续的旋转值
              final double totalRotation =
                  _continuousLoadingRotation +
                  (_loadingController.value * 2 * math.pi);

              return CustomPaint(
                painter: _LoadingBorderPainter(
                  // 🔑 传递连续的旋转值
                  rotation: totalRotation,
                  color: iconColor,
                  borderRadius: widget.config.borderRadius,
                  strokeWidth: 3.0,
                ),
              );
            },
          ),
        );
    }
  }
}

/// 旋转loading边框绘制器
class _LoadingBorderPainter extends CustomPainter {
  final double rotation;
  final Color color;
  final double borderRadius;
  final double strokeWidth;

  _LoadingBorderPainter({
    required this.rotation,
    required this.color,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 背景边框（淡色）
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, backgroundPaint);

    // 环形加载条边框
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;

    // ------------------- 🔑 核心逻辑修正 -------------------

    // 1. 确定头部的行进距离 (headPosition)
    // 让头部严格跟随 `rotation` 匀速前进，确保其速度恒定。
    final headPosition = (rotation / (2 * math.pi)) * totalLength;

    // 2. 计算加载条的动态长度 (progressLength)
    // 这部分沿用您原来的正确逻辑，使用cos函数使其周期性变化。
    const baseLengthRatio = 0.2; // 基础长度比例
    const lengthVariation = 0.6; // 长度变化幅度
    const speedFactor = 0.3; // 长度变化的频率

    final cosValue = math.cos(rotation * speedFactor);
    // 将cos值从[-1, 1]映射到[0, 1]
    final dynamicLengthRatio =
        baseLengthRatio + lengthVariation * (cosValue + 1) / 2;
    final progressLength = totalLength * dynamicLengthRatio;

    // 3. 反向计算出尾部的行进距离 (tailPosition)
    // 这是最关键的一步：尾部位置 = 头部位置 - 动态长度
    final tailPosition = headPosition - progressLength;

    // 4. 将行进距离转换为路径上的实际绘制点 (0 到 totalLength 之间)
    // 使用 remainder (取余) 操作来处理循环动画，并确保结果为正数。
    var actualStart = tailPosition.remainder(totalLength);
    if (actualStart < 0) {
      actualStart += totalLength;
    }

    var actualEnd = headPosition.remainder(totalLength);
    if (actualEnd < 0) {
      actualEnd += totalLength;
    }

    // 5. 绘制路径，并处理跨越路径起点的“环绕”情况
    if (actualStart < actualEnd) {
      // 普通情况：起点在终点后面，一次性绘制。
      final progressPath = pathMetrics.extractPath(actualStart, actualEnd);
      canvas.drawPath(progressPath, progressPaint);
    } else {
      // 环绕情况：【代码已修正】
      // 先创建一条空路径
      final combinedPath = Path();
      // 将两段路径依次添加进去，合并成一条
      combinedPath.addPath(
        pathMetrics.extractPath(actualStart, totalLength),
        Offset.zero,
      );
      combinedPath.addPath(pathMetrics.extractPath(0, actualEnd), Offset.zero);

      // 最后只绘制一次合并后的完整路径
      canvas.drawPath(combinedPath, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoadingBorderPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 环形进度条边框绘制器
class _CircularProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderRadius;
  final double strokeWidth;

  _CircularProgressBorderPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 计算路径总长度（近似）
    final perimeter =
        2 * (rect.width + rect.height) + 2 * math.pi * borderRadius;
    final progressLength = perimeter * (1.0 - progress);

    // 背景边框（淡色）
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, backgroundPaint);

    // 进度边框
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 创建路径
    final path = Path();
    path.addRRect(rrect);

    // 使用PathMetrics来绘制部分路径
    final pathMetrics = path.computeMetrics().first;
    final progressPath = pathMetrics.extractPath(0, progressLength);

    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
