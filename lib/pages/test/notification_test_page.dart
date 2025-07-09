import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/notification/notification_service.dart';
import '../../services/notification/notification_models.dart';

/// 通知系统测试页面
class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  NotificationPosition _selectedPosition = NotificationPosition.bottomCenter;
  NotificationType _selectedType = NotificationType.success;
  Duration _selectedDuration = const Duration(seconds: 4);
  bool _showCloseButton = true;
  final TextEditingController _messageController = TextEditingController(
    text: '这是一条测试消息',
  );

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知系统测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 消息内容输入
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '消息内容',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '输入要显示的消息内容',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 消息类型选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '消息类型',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: NotificationType.values.map((type) {
                        return ChoiceChip(
                          label: Text(_getTypeLabel(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 位置选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '显示位置',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPositionGrid(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 其他设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '其他设置',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 显示时长
                    Row(
                      children: [
                        const Text('显示时长: '),
                        Expanded(
                          child: DropdownButton<Duration>(
                            value: _selectedDuration,
                            onChanged: (duration) {
                              if (duration != null) {
                                setState(() {
                                  _selectedDuration = duration;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: Duration(seconds: 1),
                                child: Text('1秒'),
                              ),
                              DropdownMenuItem(
                                value: Duration(seconds: 2),
                                child: Text('2秒'),
                              ),
                              DropdownMenuItem(
                                value: Duration(seconds: 4),
                                child: Text('4秒'),
                              ),
                              DropdownMenuItem(
                                value: Duration(seconds: 6),
                                child: Text('6秒'),
                              ),
                              DropdownMenuItem(
                                value: Duration(seconds: 10),
                                child: Text('10秒'),
                              ),
                              DropdownMenuItem(
                                value: Duration.zero,
                                child: Text('不自动关闭'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 显示关闭按钮
                    Row(
                      children: [
                        const Text('显示关闭按钮: '),
                        Switch(
                          value: _showCloseButton,
                          onChanged: (value) {
                            setState(() {
                              _showCloseButton = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showTestNotification,
                    child: const Text('显示通知'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showMultipleNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('显示多条通知'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => NotificationService.instance
                        .hideAllAtPosition(_selectedPosition),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('清除当前位置'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => NotificationService.instance.hideAll(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('清除所有通知'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 快速测试按钮
            const Text(
              '快速测试',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _showQuickTest('成功消息', NotificationType.success),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('成功'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showQuickTest('错误消息', NotificationType.error),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('错误'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showQuickTest('警告消息', NotificationType.warning),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('警告'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showQuickTest('信息消息', NotificationType.info),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('信息'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 常驻通知演示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔥 常驻通知演示 (SnackBar 替换)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '演示如何替换原版 SnackBar 的常驻显示功能',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // 常驻通知按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showPersistentNotification,
                            icon: const Icon(Icons.access_time),
                            label: const Text('显示常驻通知'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showProgressNotification,
                            icon: const Icon(Icons.download),
                            label: const Text('进度通知'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // SnackBar 兼容演示
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showSnackBarCompatDemo,
                            icon: const Icon(Icons.compare_arrows),
                            label: const Text('SnackBar兼容演示'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showImagePickerDemo,
                            icon: const Icon(Icons.image),
                            label: const Text('图片选择演示'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 更新通知演示
                    ElevatedButton.icon(
                      onPressed: _showUpdateNotificationDemo,
                      icon: const Icon(Icons.update),
                      label: const Text('🔄 演示更新通知（无重新动画）'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建位置选择网格
  Widget _buildPositionGrid() {
    final positions = [
      [
        NotificationPosition.topLeft,
        NotificationPosition.topCenter,
        NotificationPosition.topRight,
      ],
      [
        NotificationPosition.centerLeft,
        NotificationPosition.center,
        NotificationPosition.centerRight,
      ],
      [
        NotificationPosition.bottomLeft,
        NotificationPosition.bottomCenter,
        NotificationPosition.bottomRight,
      ],
    ];

    return Column(
      children: positions.map((row) {
        return Row(
          children: row.map((position) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ChoiceChip(
                  label: Text(
                    _getPositionLabel(position),
                    style: const TextStyle(fontSize: 10),
                  ),
                  selected: _selectedPosition == position,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPosition = position;
                      });
                    }
                  },
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  /// 获取类型标签
  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return '成功';
      case NotificationType.error:
        return '错误';
      case NotificationType.warning:
        return '警告';
      case NotificationType.info:
        return '信息';
    }
  }

  /// 获取位置标签
  String _getPositionLabel(NotificationPosition position) {
    switch (position) {
      case NotificationPosition.topLeft:
        return '左上';
      case NotificationPosition.topCenter:
        return '上中';
      case NotificationPosition.topRight:
        return '右上';
      case NotificationPosition.centerLeft:
        return '左中';
      case NotificationPosition.center:
        return '中心';
      case NotificationPosition.centerRight:
        return '右中';
      case NotificationPosition.bottomLeft:
        return '左下';
      case NotificationPosition.bottomCenter:
        return '下中';
      case NotificationPosition.bottomRight:
        return '右下';
    }
  }

  /// 显示测试通知
  void _showTestNotification() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      // 使用新的通知系统替换 SnackBar
      context.showErrorSnackBar('请输入消息内容');
      return;
    }

    NotificationService.instance.show(
      message: message,
      type: _selectedType,
      position: _selectedPosition,
      duration: _selectedDuration == Duration.zero ? null : _selectedDuration,
      showCloseButton: _showCloseButton,
      onTap: () {
        debugPrint('通知被点击: $message');
      },
      onClose: () {
        debugPrint('通知被关闭: $message');
      },
    );
  }

  /// 显示多条通知
  void _showMultipleNotifications() {
    final types = [
      NotificationType.success,
      NotificationType.error,
      NotificationType.warning,
      NotificationType.info,
    ];

    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        NotificationService.instance.show(
          message: '第${i + 1}条消息 - ${_getTypeLabel(types[i])}',
          type: types[i],
          position: _selectedPosition,
          duration: const Duration(seconds: 6),
          showCloseButton: true,
        );
      });
    }
  }

  /// 快速测试
  void _showQuickTest(String message, NotificationType type) {
    NotificationService.instance.show(
      message: message,
      type: type,
      position: NotificationPosition.bottomCenter,
      duration: const Duration(seconds: 3),
      showCloseButton: true,
    );
  }

  /// 显示常驻通知
  void _showPersistentNotification() {
    NotificationService.instance.show(
      message: '这是一个常驻通知，不会自动消失',
      type: NotificationType.info,
      position: NotificationPosition.bottomCenter,
      isPersistent: true, // 🔑 使用新的isPersistent参数
      borderEffect: NotificationBorderEffect.glow, // 🔑 使用发光边框效果
      showCloseButton: true,
      onTap: () {
        debugPrint('常驻通知被点击');
      },
      onClose: () {
        debugPrint('常驻通知被关闭');
      },
    );
  }

  /// 显示进度通知（使用updateNotification避免重新播放动画）
  void _showProgressNotification() {
    // 生成唯一ID用于更新通知
    final notificationId = 'progress_${DateTime.now().millisecondsSinceEpoch}';

    // 显示初始进度通知
    NotificationService.instance.show(
      id: notificationId,
      message: '正在下载文件... 0%',
      type: NotificationType.info,
      position: NotificationPosition.bottomCenter,
      isPersistent: true, // 🔑 常驻显示直到完成
      borderEffect: NotificationBorderEffect.loading, // 🔑 使用loading旋转边框
      showCloseButton: false, // 下载期间不允许关闭
    );

    // 模拟进度更新
    int progress = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      progress += 10;
      if (progress <= 100) {
        // 🔑 使用updateNotification更新现有通知（不重新播放动画）
        NotificationService.instance.updateNotification(
          notificationId: notificationId,
          message: '正在下载文件... $progress%',
          isPersistent: progress < 100, // 🔑 完成前常驻，完成后自动消失
          borderEffect: progress == 100
              ? NotificationBorderEffect.glow
              : NotificationBorderEffect.loading,
          duration: progress >= 100 ? const Duration(seconds: 2) : null,
          showCloseButton: progress >= 100,
        );

        if (progress >= 100) {
          timer.cancel();
          // 下载完成，最后一次更新为成功状态
          Future.delayed(const Duration(milliseconds: 100), () {
            NotificationService.instance.updateNotification(
              notificationId: notificationId,
              message: '文件下载完成！',
              type: NotificationType.success,
              borderEffect: NotificationBorderEffect.glow, // 🔑 使用发光边框效果
              duration: const Duration(seconds: 3),
              showCloseButton: true,
              isPersistent: false,
            );
          });
        }
      }
    });
  }

  /// 演示updateNotification功能
  void _showUpdateNotificationDemo() {
    final notificationId =
        'update_demo_${DateTime.now().millisecondsSinceEpoch}';

    // 显示初始通知
    NotificationService.instance.show(
      id: notificationId,
      message: '🔄 这个通知将会被更新（不重新播放动画）',
      type: NotificationType.info,
      position: NotificationPosition.topCenter,
      isPersistent: true,
      borderEffect: NotificationBorderEffect.loading,
      showCloseButton: false,
    );

    // 2秒后更新消息内容
    Future.delayed(const Duration(seconds: 2), () {
      NotificationService.instance.updateNotification(
        notificationId: notificationId,
        message: '✨ 消息已更新！注意没有重新播放动画',
        type: NotificationType.warning,
        borderEffect: NotificationBorderEffect.glow,
      );
    });

    // 4秒后再次更新为成功状态
    Future.delayed(const Duration(seconds: 4), () {
      NotificationService.instance.updateNotification(
        notificationId: notificationId,
        message: '🎉 更新完成！这就是updateNotification的威力',
        type: NotificationType.success,
        borderEffect: NotificationBorderEffect.glow,
        duration: const Duration(seconds: 3),
        showCloseButton: true,
        isPersistent: false,
      );
    });
  }

  /// SnackBar 兼容性演示
  void _showSnackBarCompatDemo() {
    // 原版 SnackBar 写法（注释掉）
    /*
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('这是原版 SnackBar'),
          duration: Duration(seconds: 4),
        ),
      );
    }
    */

    // 使用我们的通知系统替换
    if (mounted) {
      NotificationService.instance.show(
        message: '✅ 这是替换后的通知系统（完全兼容 SnackBar）',
        type: NotificationType.success,
        position: NotificationPosition.bottomCenter,
        duration: const Duration(seconds: 4),
        showCloseButton: true,
        onTap: () {
          // 显示对比信息
          NotificationService.instance.show(
            message: '🎉 功能更强大：支持9个位置、堆叠管理、精美动画！',
            type: NotificationType.info,
            position: NotificationPosition.topCenter,
            duration: const Duration(seconds: 3),
            showCloseButton: true,
          );
        },
      );
    }
  }

  /// 图片选择演示（模拟用户提供的场景）
  void _showImagePickerDemo() {
    // 原版 SnackBar 代码（注释掉）
    /*
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('正在选择图片...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }
    */

    // 使用我们的通知系统替换
    if (mounted) {
      NotificationService.instance.show(
        message: '📸 正在选择图片...',
        type: NotificationType.info,
        position: NotificationPosition.bottomCenter,
        isPersistent: true, // 🔑 使用新的isPersistent参数
        borderEffect: NotificationBorderEffect.loading, // 🔑 使用loading旋转边框
        showCloseButton: true,
      );

      // 模拟图片选择完成
      Future.delayed(const Duration(seconds: 3), () {
        NotificationService.instance.hideAllAtPosition(
          NotificationPosition.bottomCenter,
        );
        NotificationService.instance.show(
          message: '✅ 图片选择完成！',
          type: NotificationType.success,
          position: NotificationPosition.bottomCenter,
          borderEffect: NotificationBorderEffect.glow, // 🔑 使用发光边框效果
          duration: const Duration(seconds: 2),
          showCloseButton: true,
        );
      });
    }
  }
}
