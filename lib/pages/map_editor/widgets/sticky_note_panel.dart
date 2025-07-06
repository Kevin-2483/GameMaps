import 'package:flutter/material.dart';
import '../../../models/sticky_note.dart';
import '../../../utils/image_utils.dart';
import '../../../components/color_picker_dialog.dart';
import '../../../components/common/tags_manager.dart';
import 'dart:typed_data';
import 'dart:async';

class StickyNotePanel extends StatefulWidget {
  final List<StickyNote> stickyNotes;
  final StickyNote? selectedStickyNote;
  final bool isPreviewMode;
  final Function(StickyNote?) onStickyNoteSelected;
  final Function(StickyNote) onStickyNoteUpdated;
  final Function(StickyNote) onStickyNoteDeleted;
  final VoidCallback onStickyNoteAdded;
  final Function(int oldIndex, int newIndex) onStickyNotesReordered;
  final Function(String)? onError;
  final Function(String)? onSuccess;
  final Function(String noteId, double opacity)? onOpacityPreview; // 实时透明度预览回调
  final VoidCallback? onZIndexInspectorRequested; // Z层级检视器显示回调

  const StickyNotePanel({
    super.key,
    required this.stickyNotes,
    this.selectedStickyNote,
    required this.isPreviewMode,
    required this.onStickyNoteSelected,
    required this.onStickyNoteUpdated,
    required this.onStickyNoteDeleted,
    required this.onStickyNoteAdded,
    required this.onStickyNotesReordered,
    this.onError,
    this.onSuccess,
    this.onOpacityPreview,
    this.onZIndexInspectorRequested,
  });

  @override
  State<StickyNotePanel> createState() => _StickyNotePanelState();
}

class _StickyNotePanelState extends State<StickyNotePanel> {
  // 用于存储临时的透明度值，避免频繁更新数据
  final Map<String, double> _tempOpacityValues = {};
  final Map<String, Timer?> _opacityTimers = {};

  @override
  void dispose() {
    // 清理所有定时器
    for (final timer in _opacityTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stickyNotes.isEmpty) {
      return Column(
        children: [
          // 添加便签按钮
          if (!widget.isPreviewMode) _buildAddButton(),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(
              child: Text(
                '暂无便签\n点击上方按钮添加新便签',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // 添加便签按钮
        if (!widget.isPreviewMode) _buildAddButton(),
        const SizedBox(height: 8),
        // 便签列表
        Expanded(
          child: widget.isPreviewMode
              ? ListView.builder(
                  itemCount: widget.stickyNotes.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final note = widget.stickyNotes[index];
                    return _buildStickyNoteItem(context, note, index);
                  },
                )
              : ReorderableListView.builder(
                  itemCount: widget.stickyNotes.length,
                  onReorder: (int oldIndex, int newIndex) {
                    widget.onStickyNotesReordered(oldIndex, newIndex);
                  },
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final note = widget.stickyNotes[index];
                    return _buildStickyNoteItem(context, note, index);
                  },
                ),
        ),
      ],
    );
  }

  /// 构建添加按钮
  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        onPressed: widget.onStickyNoteAdded,
        icon: const Icon(Icons.add),
        label: const Text('添加便签'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// 构建便签项
  Widget _buildStickyNoteItem(
    BuildContext context,
    StickyNote note,
    int index,
  ) {
    final isSelected = widget.selectedStickyNote?.id == note.id;
    return Container(
      key: ValueKey(note.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha((0.2 * 255).toInt())
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
            : Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: GestureDetector(
        onSecondaryTapDown: widget.isPreviewMode
            ? null
            : (details) {
                _showStickyNoteContextMenu(
                  context,
                  note,
                  details.globalPosition,
                );
              },
        child: InkWell(
          onTap: () => _handleStickyNoteSelection(note),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一排：选择状态指示器 + 可见性按钮 + 便签标题 + 拖动手柄 + 操作按钮
                Row(
                  children: [
                    // 添加选择状态指示器
                    if (isSelected)
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    if (isSelected) const SizedBox(width: 8),

                    // 可见性按钮
                    IconButton(
                      icon: Icon(
                        note.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                        color: note.isVisible
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: widget.isPreviewMode
                          ? null
                          : () {
                              final updatedNote = note.copyWith(
                                isVisible: !note.isVisible,
                                updatedAt: DateTime.now(),
                              );
                              widget.onStickyNoteUpdated(updatedNote);
                            },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: '',
                    ),
                    const SizedBox(width: 8),

                    // 便签标题
                    Expanded(child: _buildStickyNoteTitleEditor(note)),

                    // 拖动手柄
                    if (!widget.isPreviewMode)
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle, size: 16),
                      ),

                    // 操作按钮
                    if (!widget.isPreviewMode) ...[
                      const SizedBox(width: 8),
                      // 背景图片管理按钮
                      GestureDetector(
                        onTap: () => _showImageMenu(context, note),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.image, size: 16),
                        ),
                      ), // 颜色设置按钮
                      GestureDetector(
                        onTap: () => _showColorPicker(context, note),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.palette,
                            size: 16,
                            color: note.backgroundColor,
                          ),
                        ),
                      ), // Z层级检视器按钮 (只在便签被选中时显示)
                      if (widget.selectedStickyNote?.id == note.id &&
                          widget.onZIndexInspectorRequested != null)
                        Tooltip(
                          message: note.elements.isNotEmpty
                              ? '便签元素检视器 (${note.elements.length}个元素)'
                              : '便签元素检视器 (无元素)',
                          child: GestureDetector(
                            onTap: widget.onZIndexInspectorRequested,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.layers,
                                size: 16,
                                color: note.elements.isNotEmpty
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                          ),
                        ),

                      // 删除按钮
                      if (widget.stickyNotes.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () => _showDeleteDialog(context, note),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          tooltip: '',
                        ),
                    ],
                  ],
                ),

                // 第二排：透明度滑块
                const SizedBox(height: 8),
                _buildOpacitySlider(note), // 第三排：便签预览（如果有内容）
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: note.backgroundColor.withAlpha(
                        (0.3 * 255).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      note.content,
                      style: TextStyle(fontSize: 12, color: note.textColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // 第四排：标签管理
                const SizedBox(height: 8),
                _buildStickyNoteTagsSection(note),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建便签标题编辑器
  Widget _buildStickyNoteTitleEditor(StickyNote note) {
    final TextEditingController controller = TextEditingController(
      text: note.title,
    );

    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: TextField(
        controller: controller,
        enabled: !widget.isPreviewMode,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: '便签标题',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
        ),
        onSubmitted: (value) {
          if (value.trim() != note.title) {
            final updatedNote = note.copyWith(
              title: value.trim().isEmpty ? '无标题便签' : value.trim(),
              updatedAt: DateTime.now(),
            );
            widget.onStickyNoteUpdated(updatedNote);
          }
        },
      ),
    );
  }

  /// 构建透明度滑块
  Widget _buildOpacitySlider(StickyNote note) {
    // 获取当前显示的透明度值（临时值或实际值）
    final currentOpacity = _tempOpacityValues[note.id] ?? note.opacity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 透明度滑块
          Row(
            children: [
              const Text('不透明度:', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Flexible(
                child: Slider(
                  value: currentOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: widget.isPreviewMode
                      ? null
                      : (opacity) => _handleOpacityChange(note, opacity),
                  onChangeEnd: widget.isPreviewMode
                      ? null
                      : (opacity) => _handleOpacityChangeEnd(note, opacity),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '${(currentOpacity * 100).round()}%',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 处理便签选择
  void _handleStickyNoteSelection(StickyNote note) {
    // 检查当前点击的便签是否已经被选中
    if (widget.selectedStickyNote?.id == note.id) {
      // 如果已经选中，取消选择
      widget.onStickyNoteSelected(null);
    } else {
      // 如果未选中，则选择该便签
      widget.onStickyNoteSelected(note);
    }
  }

  /// 处理透明度变化（拖动时）
  void _handleOpacityChange(StickyNote note, double opacity) {
    setState(() {
      _tempOpacityValues[note.id] = opacity;
    });

    // 立即通知画布进行预览
    widget.onOpacityPreview?.call(note.id, opacity);
  }

  /// 处理透明度变化结束（松开滑块时）
  void _handleOpacityChangeEnd(StickyNote note, double opacity) {
    // 取消之前的定时器
    _opacityTimers[note.id]?.cancel();

    // 设置新的定时器，延迟保存
    _opacityTimers[note.id] = Timer(const Duration(milliseconds: 300), () {
      final finalOpacity = _tempOpacityValues[note.id] ?? opacity;

      // 更新实际数据
      final updatedNote = note.copyWith(
        opacity: finalOpacity,
        updatedAt: DateTime.now(),
      );
      widget.onStickyNoteUpdated(updatedNote);

      // 清除临时值
      setState(() {
        _tempOpacityValues.remove(note.id);
      });
    });
  }

  /// 显示图片菜单
  void _showImageMenu(BuildContext context, StickyNote note) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  note.backgroundImageData != null ? Icons.edit : Icons.upload,
                  size: 20,
                ),
                title: Text(
                  note.backgroundImageData != null ? '更换背景图片' : '上传背景图片',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageUpload(note);
                },
              ),
              if (note.backgroundImageData != null) ...[
                ListTile(
                  leading: const Icon(Icons.settings, size: 20),
                  title: const Text('背景图片设置'),
                  onTap: () {
                    Navigator.pop(context);
                    _showBackgroundImageSettings(context, note);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, size: 20),
                  title: const Text('移除背景图片'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeBackgroundImage(note);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 处理图片上传
  Future<void> _handleImageUpload(StickyNote note) async {
    try {
      final Uint8List? imageData = await ImageUtils.pickAndEncodeImage();
      if (imageData != null) {
        // 直接保存图像数据到便签，不立即保存到资产系统
        // 资产保存将在地图保存时由VFS服务处理
        final updatedNote = note.copyWith(
          backgroundImageData: imageData,
          clearBackgroundImageHash: true, // 清除旧的哈希引用，新数据在保存时会生成哈希
          updatedAt: DateTime.now(),
        );

        widget.onStickyNoteUpdated(updatedNote);
        widget.onSuccess?.call('背景图片已上传');

        debugPrint('便签背景图片已上传，将在地图保存时存储到资产系统 (${imageData.length} bytes)');
      }
    } catch (e) {
      widget.onError?.call('上传图片失败: $e');
    }
  }

  /// 显示背景图片设置
  void _showBackgroundImageSettings(BuildContext context, StickyNote note) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('背景图片设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片适应方式
            DropdownButtonFormField<BoxFit>(
              value: note.backgroundImageFit,
              decoration: const InputDecoration(labelText: '图片适应方式'),
              items: const [
                DropdownMenuItem(value: BoxFit.cover, child: Text('覆盖')),
                DropdownMenuItem(value: BoxFit.contain, child: Text('包含')),
                DropdownMenuItem(value: BoxFit.fill, child: Text('填充')),
                DropdownMenuItem(value: BoxFit.fitWidth, child: Text('适合宽度')),
                DropdownMenuItem(value: BoxFit.fitHeight, child: Text('适合高度')),
              ],
              onChanged: (BoxFit? value) {
                if (value != null) {
                  final updatedNote = note.copyWith(
                    backgroundImageFit: value,
                    updatedAt: DateTime.now(),
                  );
                  widget.onStickyNoteUpdated(updatedNote);
                }
              },
            ),
            const SizedBox(height: 16),

            // 背景图片透明度
            Text('背景图片透明度: ${(note.backgroundImageOpacity * 100).round()}%'),
            Slider(
              value: note.backgroundImageOpacity,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (double value) {
                final updatedNote = note.copyWith(
                  backgroundImageOpacity: value,
                  updatedAt: DateTime.now(),
                );
                widget.onStickyNoteUpdated(updatedNote);
              },
            ),
          ],
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

  /// 移除背景图片
  void _removeBackgroundImage(StickyNote note) {
    final updatedNote = note.copyWith(
      clearBackgroundImageData: true,
      clearBackgroundImageHash: true,
      updatedAt: DateTime.now(),
    );
    widget.onStickyNoteUpdated(updatedNote);
    widget.onSuccess?.call('背景图片已移除');
  }

  /// 显示颜色选择器
  void _showColorPicker(BuildContext context, StickyNote note) {
    showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: note.backgroundColor,
        title: '选择便签颜色',
      ),
    ).then((Color? selectedColor) {
      if (selectedColor != null) {
        // 根据背景色自动调整标题栏和文字颜色
        final titleBarColor = _adjustColorBrightness(selectedColor, -0.2);
        final textColor = _getContrastColor(selectedColor);

        final updatedNote = note.copyWith(
          backgroundColor: selectedColor,
          titleBarColor: titleBarColor,
          textColor: textColor,
          updatedAt: DateTime.now(),
        );
        widget.onStickyNoteUpdated(updatedNote);
      }
    });
  }

  /// 调整颜色亮度
  Color _adjustColorBrightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// 获取对比色（用于文字）
  Color _getContrastColor(Color backgroundColor) {
    // 计算亮度
    final luminance = backgroundColor.computeLuminance();
    // 如果背景较亮，使用深色文字；如果背景较暗，使用浅色文字
    return luminance > 0.5 ? const Color(0xFF424242) : const Color(0xFFFAFAFA);
  }

  /// 显示删除确认对话框
  void _showDeleteDialog(BuildContext context, StickyNote note) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除便签'),
        content: Text('确定要删除便签 "${note.title}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onStickyNoteDeleted(note);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示便签右键菜单
  void _showStickyNoteContextMenu(
    BuildContext context,
    StickyNote note,
    Offset position,
  ) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'duplicate',
          child: Row(
            children: const [
              Icon(Icons.copy, size: 16),
              SizedBox(width: 8),
              Text('复制便签'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'collapse',
          child: Row(
            children: [
              Icon(
                note.isCollapsed ? Icons.expand_more : Icons.expand_less,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(note.isCollapsed ? '展开便签' : '折叠便签'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'move_to_top',
          child: Row(
            children: const [
              Icon(Icons.vertical_align_top, size: 16),
              SizedBox(width: 8),
              Text('移到顶层'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleContextMenuAction(value, note);
      }
    });
  }

  /// 处理右键菜单操作
  void _handleContextMenuAction(String action, StickyNote note) {
    switch (action) {
      case 'duplicate':
        _duplicateStickyNote(note);
        break;
      case 'collapse':
        _toggleCollapse(note);
        break;
      case 'move_to_top':
        _moveToTop(note);
        break;
    }
  }

  /// 复制便签
  void _duplicateStickyNote(StickyNote note) {
    // TODO: 当前接口设计限制，复制功能需要在上层组件中实现
    // 这里先显示提示信息，实际复制逻辑需要在MapItem级别处理
    widget.onSuccess?.call('复制功能将在下个版本中实现');
  }

  /// 切换折叠状态
  void _toggleCollapse(StickyNote note) {
    final updatedNote = note.copyWith(
      isCollapsed: !note.isCollapsed,
      updatedAt: DateTime.now(),
    );
    widget.onStickyNoteUpdated(updatedNote);
  }

  /// 移动到顶层
  void _moveToTop(StickyNote note) {
    // 找到当前最大的 zIndex
    final maxZIndex = widget.stickyNotes
        .map((n) => n.zIndex)
        .fold(0, (prev, current) => prev > current ? prev : current);

    final updatedNote = note.copyWith(
      zIndex: maxZIndex + 1,
      updatedAt: DateTime.now(),
    );
    widget.onStickyNoteUpdated(updatedNote);
    widget.onSuccess?.call('便签已移到顶层');
  }

  /// 构建便签标签管理区域
  Widget _buildStickyNoteTagsSection(StickyNote note) {
    final tags = note.tags ?? [];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '标签',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (!widget.isPreviewMode)
                GestureDetector(
                  onTap: () => _showStickyNoteTagsManagerDialog(note),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '管理',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _buildStickyNoteTagsDisplay(tags),
        ],
      ),
    );
  }

  /// 显示便签标签管理对话框
  void _showStickyNoteTagsManagerDialog(StickyNote note) async {
    final currentTags = note.tags ?? [];

    final result = await TagsManagerUtils.showTagsDialog(
      context,
      initialTags: currentTags,
      title: '管理便签标签 - ${note.title}',
      maxTags: 10, // 限制最多10个标签
      suggestedTags: _getStickyNoteSuggestedTags(),
      tagValidator: TagsManagerUtils.defaultTagValidator,
      enableCustomTagsManagement: true,
    );

    if (result != null) {
      final updatedNote = note.copyWith(
        tags: result.isNotEmpty ? result : null,
        updatedAt: DateTime.now(),
      );
      widget.onStickyNoteUpdated(updatedNote);

      if (result.isEmpty) {
        widget.onSuccess?.call('已清空便签标签');
      } else {
        widget.onSuccess?.call('便签标签已更新 (${result.length}个标签)');
      }
    }
  }

  /// 构建便签标签显示
  Widget _buildStickyNoteTagsDisplay(List<String> tags) {
    if (tags.isEmpty) {
      return Text(
        '暂无标签',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// 获取便签建议标签
  List<String> _getStickyNoteSuggestedTags() {
    return [
      '重要',
      '待办',
      '已完成',
      '临时',
      '提醒',
      '想法',
      '计划',
      '问题',
      '解决方案',
      '备注',
      '分析',
      '总结',
    ];
  }
}
