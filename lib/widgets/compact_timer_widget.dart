import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/map_data_bloc.dart';
import '../data/map_data_event.dart';
import '../data/map_data_state.dart';
import '../models/timer_data.dart';

/// 紧凑的标题栏计时器组件
class CompactTimerWidget extends StatefulWidget {
  final MapDataBloc mapDataBloc;

  const CompactTimerWidget({super.key, required this.mapDataBloc});

  @override
  State<CompactTimerWidget> createState() => _CompactTimerWidgetState();
}

class _CompactTimerWidgetState extends State<CompactTimerWidget> {
  TimerData? _currentTimer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapDataBloc, MapDataState>(
      bloc: widget.mapDataBloc,
      builder: (context, state) {
        if (state is! MapDataLoaded) {
          return const SizedBox.shrink();
        }

        // 如果没有计时器，显示添加按钮
        if (state.timers.isEmpty) {
          return IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => _showCreateTimerDialog(context),
            tooltip: '创建计时器',
          );
        }

        // 如果有计时器但没有选中的，选择第一个运行中的或第一个
        if (_currentTimer == null ||
            !state.timers.any((t) => t.id == _currentTimer!.id)) {
          _currentTimer = state.runningTimers.isNotEmpty
              ? state.runningTimers.first
              : state.timers.first;
        }

        final timer = state.getTimerById(_currentTimer!.id);
        if (timer == null) {
          _currentTimer = state.timers.first;
          return _buildTimerDisplay(state.timers.first, state);
        }

        return _buildTimerDisplay(timer, state);
      },
    );
  }

  Widget _buildTimerDisplay(TimerData timer, MapDataLoaded state) {
    return GestureDetector(
      onTap: () => _showTimerMenu(context, timer, state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getTimerColor(timer).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getTimerColor(timer).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getTimerIcon(timer), size: 16, color: _getTimerColor(timer)),
            const SizedBox(width: 4),
            Text(
              _formatDuration(timer.currentTime),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTimerColor(timer),
              ),
            ),
            if (state.timers.length > 1) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: _getTimerColor(timer),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTimerMenu(BuildContext context, TimerData timer, MapDataLoaded state) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final ThemeData theme = Theme.of(context);
    
    // 计算菜单位置，防止超出屏幕
    const double menuWidth = 280;
    const double menuMaxHeight = 400;
    const double padding = 16;
    
    double left = offset.dx;
    double top = offset.dy + size.height + 8;
    
    // 检查右边界
    if (left + menuWidth > mediaQuery.size.width - padding) {
      left = mediaQuery.size.width - menuWidth - padding;
    }
    
    // 检查左边界
    if (left < padding) {
      left = padding;
    }
    
    // 检查下边界，如果超出则显示在上方
    if (top + menuMaxHeight > mediaQuery.size.height - padding) {
      top = offset.dy - menuMaxHeight - 8;
      // 如果上方也不够，则调整到屏幕内
      if (top < padding) {
        top = padding;
      }
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          // 透明背景，点击关闭菜单
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          // 菜单内容
          Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.surface,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 200,
                  maxWidth: menuWidth,
                  maxHeight: menuMaxHeight,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: BlocBuilder<MapDataBloc, MapDataState>(
                  bloc: widget.mapDataBloc,
                  builder: (context, currentState) {
                    if (currentState is! MapDataLoaded) {
                      return const SizedBox.shrink();
                    }
                    
                    final currentTimer = currentState.getTimerById(timer.id) ?? timer;
                    
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        // 计时器控制选项
                        if (currentTimer.state.canStart)
                          _buildMenuItem(
                            icon: Icons.play_arrow,
                            color: Colors.green,
                            text: '开始 ${currentTimer.name}',
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.mapDataBloc.add(StartTimer(timerId: currentTimer.id));
                            },
                          ),
                        if (currentTimer.state.canPause)
                          _buildMenuItem(
                            icon: Icons.pause,
                            color: Colors.orange,
                            text: '暂停 ${currentTimer.name}',
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.mapDataBloc.add(PauseTimer(timerId: currentTimer.id));
                            },
                          ),
                        if (currentTimer.state.canStop)
                          _buildMenuItem(
                            icon: Icons.stop,
                            color: Colors.red,
                            text: '停止 ${currentTimer.name}',
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.mapDataBloc.add(StopTimer(timerId: currentTimer.id));
                            },
                          ),
                        if (currentTimer.state.canReset)
                          _buildMenuItem(
                            icon: Icons.refresh,
                            color: Colors.blue,
                            text: '重置 ${currentTimer.name}',
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.mapDataBloc.add(ResetTimer(timerId: currentTimer.id));
                            },
                          ),

                        // 分隔线
                         if (currentTimer.state.canStart ||
                             currentTimer.state.canPause ||
                             currentTimer.state.canStop ||
                             currentTimer.state.canReset)
                           Divider(
                             height: 1,
                             color: theme.colorScheme.outline.withValues(alpha: 0.2),
                           ),

                        // 切换计时器选项
                        if (currentState.timers.length > 1)
                          ...currentState.timers.map(
                            (t) {
                              final latestTimer = currentState.getTimerById(t.id) ?? t;
                              return _buildMenuItem(
                                icon: _getTimerIcon(latestTimer),
                                color: _getTimerColor(latestTimer),
                                text: '${latestTimer.name} (${_formatDuration(latestTimer.currentTime)})',
                                trailing: t.id == currentTimer.id
                                    ? const Icon(Icons.check, size: 16, color: Colors.green)
                                    : null,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (t.id != currentTimer.id) {
                                    setState(() {
                                      _currentTimer = latestTimer;
                                    });
                                  }
                                },
                              );
                            },
                          ),

                        if (currentState.timers.length > 1) Divider(
                           height: 1,
                           color: theme.colorScheme.outline.withValues(alpha: 0.2),
                         ),

                        // 管理选项
                        _buildMenuItem(
                          icon: Icons.add,
                          color: Colors.blue,
                          text: '创建新计时器',
                          onTap: () {
                            Navigator.of(context).pop();
                            _showCreateTimerDialog(context);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.settings,
                          color: Colors.grey,
                          text: '管理计时器',
                          onTap: () {
                            Navigator.of(context).pop();
                            _showTimerManagementDialog(context, currentState);
                          },
                        ),
                         ],
                       ),
                     );
                   },
                 ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String text,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }



  void _showCreateTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateTimerDialog(mapDataBloc: widget.mapDataBloc),
    );
  }

  void _showTimerManagementDialog(BuildContext context, MapDataLoaded state) {
    showDialog(
      context: context,
      builder: (context) => TimerManagementDialog(
        timers: state.timers,
        mapDataBloc: widget.mapDataBloc,
      ),
    );
  }

  IconData _getTimerIcon(TimerData timer) {
    switch (timer.state) {
      case TimerState.running:
        return timer.mode == TimerMode.countdown
            ? Icons.timer
            : Icons.timer_outlined;
      case TimerState.paused:
        return Icons.pause_circle_outline;
      case TimerState.completed:
        return Icons.check_circle_outline;
      case TimerState.stopped:
        return timer.mode == TimerMode.countdown
            ? Icons.timer_off
            : Icons.timer_outlined;
    }
  }

  Color _getTimerColor(TimerData timer) {
    switch (timer.state) {
      case TimerState.running:
        return Colors.green;
      case TimerState.paused:
        return Colors.orange;
      case TimerState.completed:
        return Colors.red;
      case TimerState.stopped:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    }
  }
}

/// 创建计时器对话框
class CreateTimerDialog extends StatefulWidget {
  final MapDataBloc mapDataBloc;

  const CreateTimerDialog({super.key, required this.mapDataBloc});

  @override
  State<CreateTimerDialog> createState() => _CreateTimerDialogState();
}

class _CreateTimerDialogState extends State<CreateTimerDialog> {
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '5');
  final _secondsController = TextEditingController(text: '0');
  TimerMode _mode = TimerMode.countdown;

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建计时器'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '计时器名称',
                hintText: '请输入计时器名称',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TimerMode>(
              value: _mode,
              decoration: const InputDecoration(labelText: '计时器类型'),
              items: TimerMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _mode = value;
                  });
                }
              },
            ),
            // 只有倒计时模式才显示时间设置
            if (_mode == TimerMode.countdown) ...[
              const SizedBox(height: 16),
              const Text('时间设置'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hoursController,
                      decoration: const InputDecoration(labelText: '小时'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _minutesController,
                      decoration: const InputDecoration(labelText: '分钟'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _secondsController,
                      decoration: const InputDecoration(labelText: '秒'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(onPressed: _createTimer, child: const Text('创建')),
      ],
    );
  }

  void _createTimer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入计时器名称')));
      return;
    }

    Duration duration = Duration.zero;

    // 只有倒计时模式才需要验证和设置时长
    if (_mode == TimerMode.countdown) {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;

      duration = Duration(hours: hours, minutes: minutes, seconds: seconds);

      if (duration.inMilliseconds <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请设置有效的时间')));
        return;
      }
    }

    final timer = TimerData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      mode: _mode,
      state: TimerState.stopped,
      currentTime: _mode == TimerMode.countdown ? duration : Duration.zero,
      targetTime: _mode == TimerMode.countdown ? duration : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.mapDataBloc.add(CreateTimer(timer: timer));
    Navigator.of(context).pop();
  }
}

/// 计时器管理对话框
class TimerManagementDialog extends StatelessWidget {
  final List<TimerData> timers;
  final MapDataBloc mapDataBloc;

  const TimerManagementDialog({
    super.key,
    required this.timers,
    required this.mapDataBloc,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('计时器管理'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: timers.isEmpty
            ? const Center(child: Text('暂无计时器'))
            : ListView.builder(
                itemCount: timers.length,
                itemBuilder: (context, index) {
                  final timer = timers[index];
                  return ListTile(
                    leading: Icon(
                      _getTimerIcon(timer),
                      color: _getTimerColor(timer),
                    ),
                    title: Text(timer.name),
                    subtitle: Text(
                      '${timer.mode.displayName} - ${_formatDuration(timer.currentTime)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTimer(context, timer.id),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => CreateTimerDialog(mapDataBloc: mapDataBloc),
            );
          },
          child: const Text('创建新计时器'),
        ),
      ],
    );
  }

  void _deleteTimer(BuildContext context, String timerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个计时器吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              mapDataBloc.add(DeleteTimer(timerId: timerId));
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 关闭管理对话框
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  IconData _getTimerIcon(TimerData timer) {
    switch (timer.state) {
      case TimerState.running:
        return timer.mode == TimerMode.countdown
            ? Icons.timer
            : Icons.timer_outlined;
      case TimerState.paused:
        return Icons.pause_circle_outline;
      case TimerState.completed:
        return Icons.check_circle_outline;
      case TimerState.stopped:
        return timer.mode == TimerMode.countdown
            ? Icons.timer_off
            : Icons.timer_outlined;
    }
  }

  Color _getTimerColor(TimerData timer) {
    switch (timer.state) {
      case TimerState.running:
        return Colors.green;
      case TimerState.paused:
        return Colors.orange;
      case TimerState.completed:
        return Colors.red;
      case TimerState.stopped:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    }
  }
}