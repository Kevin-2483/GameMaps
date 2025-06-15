import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/user_preferences_provider.dart';

/// 标签管理组件
/// 可以被其他组件调用来为元素分配和管理tags
class TagsManager extends StatefulWidget {
  /// 当前标签列表
  final List<String> tags;

  /// 标签更新回调
  final Function(List<String>) onTagsChanged;

  /// 是否只读模式
  final bool readOnly;

  /// 最大标签数量，null表示无限制
  final int? maxTags;

  /// 建议的标签列表（预设标签）
  final List<String> suggestedTags;

  /// 是否显示建议标签
  final bool showSuggestions;

  /// 标签验证函数，返回null表示有效，返回字符串表示错误信息
  final String? Function(String tag)? tagValidator;

  /// 组件标题
  final String? title;

  /// 提示文本
  final String? hintText;

  /// 是否启用个人偏好设置整合
  final bool enablePreferencesIntegration;

  /// 是否自动保存自定义标签到偏好设置
  final bool autoSaveCustomTags;

  const TagsManager({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.readOnly = false,
    this.maxTags,
    this.suggestedTags = const [],
    this.showSuggestions = true,
    this.tagValidator,
    this.title,
    this.hintText,
    this.enablePreferencesIntegration = false,
    this.autoSaveCustomTags = false,
  });

  @override
  State<TagsManager> createState() => _TagsManagerState();
}

class _TagsManagerState extends State<TagsManager> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _inputText = '';
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestedTags = [];

  @override
  void initState() {
    super.initState();
    _updateAllSuggestedTags();
    _updateSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.enablePreferencesIntegration) {
      _updateAllSuggestedTags();
      _updateSuggestions();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 更新建议标签列表
  void _updateSuggestions() {
    if (!widget.showSuggestions || _inputText.isEmpty) {
      _filteredSuggestions = _allSuggestedTags
          .where((tag) => !widget.tags.contains(tag))
          .toList();
      return;
    }

    _filteredSuggestions = _allSuggestedTags
        .where(
          (tag) =>
              !widget.tags.contains(tag) &&
              tag.toLowerCase().contains(_inputText.toLowerCase()),
        )
        .toList();
  }

  /// 更新所有建议标签（包括偏好设置中的自定义标签）
  void _updateAllSuggestedTags() {
    _allSuggestedTags = List<String>.from(widget.suggestedTags);

    if (widget.enablePreferencesIntegration) {
      try {
        final provider = Provider.of<UserPreferencesProvider>(
          context,
          listen: false,
        );
        if (provider.isInitialized) {
          final customTags = provider.tools.customTags;
          final recentTags = provider.tools.recentTags;

          // 合并最近使用的标签和自定义标签，避免重复
          final combinedTags = <String>[];

          // 首先添加最近使用的标签
          for (final tag in recentTags) {
            if (!combinedTags.contains(tag)) {
              combinedTags.add(tag);
            }
          }

          // 然后添加自定义标签
          for (final tag in customTags) {
            if (!combinedTags.contains(tag)) {
              combinedTags.add(tag);
            }
          }

          // 最后添加传入的建议标签
          for (final tag in widget.suggestedTags) {
            if (!combinedTags.contains(tag)) {
              combinedTags.add(tag);
            }
          }

          _allSuggestedTags = combinedTags;
        }
      } catch (e) {
        // 如果获取偏好设置失败，使用默认的建议标签
        debugPrint('获取自定义标签失败: $e');
      }
    }
  }

  /// 添加标签
  void _addTag(String tag) async {
    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return;

    // 验证标签
    if (widget.tagValidator != null) {
      final error = widget.tagValidator!(trimmedTag);
      if (error != null) {
        _showError(error);
        return;
      }
    }

    // 检查是否已存在
    if (widget.tags.contains(trimmedTag)) {
      _showError('标签已存在');
      return;
    }

    // 检查最大数量限制
    if (widget.maxTags != null && widget.tags.length >= widget.maxTags!) {
      _showError('最多只能添加${widget.maxTags}个标签');
      return;
    }

    // 添加标签
    final newTags = List<String>.from(widget.tags)..add(trimmedTag);
    widget.onTagsChanged(newTags);

    // 如果启用偏好设置整合，保存标签到偏好设置
    if (widget.enablePreferencesIntegration) {
      try {
        final provider = Provider.of<UserPreferencesProvider>(
          context,
          listen: false,
        );
        if (provider.isInitialized) {
          // 添加到最近使用的标签
          await provider.addRecentTag(trimmedTag);

          // 如果是新的自定义标签且启用了自动保存，添加到自定义标签
          if (widget.autoSaveCustomTags &&
              !provider.tools.customTags.contains(trimmedTag) &&
              !TagsManagerUtils.getDefaultSuggestedTags().contains(
                trimmedTag,
              )) {
            await provider.addCustomTag(trimmedTag);
          }

          // 更新建议标签列表
          _updateAllSuggestedTags();
        }
      } catch (e) {
        debugPrint('保存标签到偏好设置失败: $e');
      }
    }

    // 清空输入框
    _textController.clear();
    _inputText = '';
    _updateSuggestions();
    setState(() {});
  }

  /// 移除标签
  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onTagsChanged(newTags);
    _updateSuggestions();
    setState(() {});
  }

  /// 显示错误信息
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 构建标签芯片
  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag, style: const TextStyle(fontSize: 12)),
      onDeleted: widget.readOnly ? null : () => _removeTag(tag),
      deleteIcon: const Icon(Icons.close, size: 16),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// 构建建议标签
  Widget _buildSuggestionChip(String tag) {
    return ActionChip(
      label: Text(
        tag,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: () => _addTag(tag),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],

        // 当前标签列表
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.tags.map(_buildTagChip).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // 输入框
        if (!widget.readOnly) ...[
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText ?? '输入标签名称',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addTag(_textController.text),
                tooltip: '添加标签',
              ),
            ),
            onChanged: (value) {
              _inputText = value;
              _updateSuggestions();
              setState(() {});
            },
            onSubmitted: _addTag,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),
        ],

        // 建议标签
        if (widget.showSuggestions &&
            _filteredSuggestions.isNotEmpty &&
            !widget.readOnly) ...[
          Text(
            '建议标签：',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _filteredSuggestions
                .take(10)
                .map(_buildSuggestionChip)
                .toList(),
          ),
        ],

        // 标签统计信息
        if (widget.tags.isNotEmpty || widget.maxTags != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.maxTags != null
                ? '${widget.tags.length} / ${widget.maxTags} 个标签'
                : '${widget.tags.length} 个标签',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }
}

/// 标签管理对话框
/// 提供一个独立的对话框来管理标签，包含自定义标签管理功能
class TagsManagerDialog extends StatefulWidget {
  /// 初始标签列表
  final List<String> initialTags;

  /// 对话框标题
  final String title;

  /// 其他配置参数
  final int? maxTags;
  final List<String> suggestedTags;
  final String? Function(String tag)? tagValidator;

  /// 是否启用自定义标签管理
  final bool enableCustomTagsManagement;

  const TagsManagerDialog({
    super.key,
    required this.initialTags,
    this.title = '管理标签',
    this.maxTags,
    this.suggestedTags = const [],
    this.tagValidator,
    this.enableCustomTagsManagement = true,
  });

  @override
  State<TagsManagerDialog> createState() => _TagsManagerDialogState();
}

class _TagsManagerDialogState extends State<TagsManagerDialog> {
  late List<String> _currentTags;
  late List<String> _customTags;
  final TextEditingController _customTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTags = List<String>.from(widget.initialTags);
    _customTags = [];
    _loadCustomTags();
  }

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }

  /// 加载自定义标签
  void _loadCustomTags() {
    if (!widget.enableCustomTagsManagement) return;

    try {
      final provider = Provider.of<UserPreferencesProvider>(
        context,
        listen: false,
      );
      if (provider.isInitialized) {
        setState(() {
          _customTags = List<String>.from(provider.tools.customTags);
        });
      }
    } catch (e) {
      debugPrint('加载自定义标签失败: $e');
    }
  }

  /// 添加自定义标签
  void _addCustomTag(String tag) async {
    if (!widget.enableCustomTagsManagement) return;

    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty || _customTags.contains(trimmedTag)) return;

    try {
      final provider = Provider.of<UserPreferencesProvider>(
        context,
        listen: false,
      );
      if (provider.isInitialized) {
        await provider.addCustomTag(trimmedTag);
        setState(() {
          _customTags = List<String>.from(provider.tools.customTags);
        });
        _customTagController.clear();
      }
    } catch (e) {
      debugPrint('添加自定义标签失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加自定义标签失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// 显示自定义标签管理界面
  void _showCustomTagsManager() async {
    if (!widget.enableCustomTagsManagement) return;

    await showDialog(
      context: context,
      builder: (context) =>
          _CustomTagsManagerDialog(customTags: _customTags, recentTags: []),
    );

    // 刷新自定义标签列表
    _loadCustomTags();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：自定义标签区域
            if (widget.enableCustomTagsManagement) ...[
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '自定义标签',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _showCustomTagsManager,
                          icon: const Icon(Icons.settings, size: 18),
                          tooltip: '管理自定义标签',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 自定义标签列表
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // 快速添加自定义标签
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _customTagController,
                                    decoration: const InputDecoration(
                                      hintText: '添加自定义标签',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      isDense: true,
                                    ),
                                    onSubmitted: _addCustomTag,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () =>
                                      _addCustomTag(_customTagController.text),
                                  icon: const Icon(Icons.add, size: 18),
                                  tooltip: '添加',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 自定义标签芯片（可点击添加）
                            Expanded(
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: _customTags
                                      .map(
                                        (tag) => ActionChip(
                                          label: Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          onPressed: () {
                                            // 添加到当前标签列表
                                            if (!_currentTags.contains(tag)) {
                                              setState(() {
                                                _currentTags.add(tag);
                                              });
                                            }
                                          },
                                          avatar: Icon(
                                            _currentTags.contains(tag)
                                                ? Icons.check
                                                : Icons.add,
                                            size: 14,
                                            color: _currentTags.contains(tag)
                                                ? Colors.green
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          backgroundColor:
                                              _currentTags.contains(tag)
                                              ? Colors.green.withOpacity(0.1)
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
            // 右侧：标签管理区域
            Expanded(
              flex: widget.enableCustomTagsManagement ? 2 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '标签管理',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TagsManager(
                      tags: _currentTags,
                      onTagsChanged: (tags) {
                        setState(() {
                          _currentTags = tags;
                        });
                      },
                      maxTags: widget.maxTags,
                      suggestedTags: [..._customTags, ...widget.suggestedTags],
                      tagValidator: widget.tagValidator,
                      hintText: '添加新标签',
                      enablePreferencesIntegration:
                          widget.enableCustomTagsManagement,
                      autoSaveCustomTags: widget.enableCustomTagsManagement,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_currentTags),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

/// 标签管理工具类
class TagsManagerUtils {
  /// 显示标签管理对话框
  static Future<List<String>?> showTagsDialog(
    BuildContext context, {
    required List<String> initialTags,
    String title = '管理标签',
    int? maxTags,
    List<String> suggestedTags = const [],
    String? Function(String tag)? tagValidator,
    bool enableCustomTagsManagement = true,
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => TagsManagerDialog(
        initialTags: initialTags,
        title: title,
        maxTags: maxTags,
        suggestedTags: suggestedTags,
        tagValidator: tagValidator,
        enableCustomTagsManagement: enableCustomTagsManagement,
      ),
    );
  }

  /// 默认标签验证器
  static String? defaultTagValidator(String tag) {
    if (tag.trim().isEmpty) {
      return '标签不能为空';
    }
    if (tag.length > 20) {
      return '标签长度不能超过20个字符';
    }
    if (tag.contains(' ')) {
      return '标签不能包含空格';
    }
    if (RegExp(r'[<>"/\\|?*]').hasMatch(tag)) {
      return '标签包含非法字符';
    }
    return null;
  }

  /// 获取预设的建议标签
  static List<String> getDefaultSuggestedTags() {
    return [
      '重要',
      '紧急',
      '完成',
      '临时',
      '备注',
      '标记',
      '高优先级',
      '低优先级',
      '计划',
      '想法',
      '参考',
    ];
  }

  /// 获取包含用户自定义标签的建议标签列表
  static List<String> getSuggestedTagsWithCustomTags(
    UserPreferencesProvider? provider,
  ) {
    final defaultTags = getDefaultSuggestedTags();

    if (provider?.isInitialized != true) {
      return defaultTags;
    }

    final customTags = provider!.tools.customTags;
    final recentTags = provider.tools.recentTags;

    // 合并标签列表，避免重复
    final allTags = <String>[];

    // 首先添加最近使用的标签
    for (final tag in recentTags) {
      if (!allTags.contains(tag)) {
        allTags.add(tag);
      }
    }

    // 然后添加自定义标签
    for (final tag in customTags) {
      if (!allTags.contains(tag)) {
        allTags.add(tag);
      }
    }

    // 最后添加默认标签
    for (final tag in defaultTags) {
      if (!allTags.contains(tag)) {
        allTags.add(tag);
      }
    }

    return allTags;
  }

  /// 显示自定义标签管理对话框
  ///
  /// @deprecated 此方法已弃用，请使用 showTagsDialog 并设置 enableCustomTagsManagement: true
  @deprecated
  static Future<void> showCustomTagsManagerDialog(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    return showDialog(
      context: context,
      builder: (context) => _CustomTagsManagerDialog(
        customTags: provider.tools.customTags,
        recentTags: provider.tools.recentTags,
      ),
    );
  }
}

/// 自定义标签管理对话框
/// 提供一个独立的对话框来管理标签
class _CustomTagsManagerDialog extends StatefulWidget {
  final List<String> customTags;
  final List<String> recentTags;

  const _CustomTagsManagerDialog({
    required this.customTags,
    required this.recentTags,
  });

  @override
  State<_CustomTagsManagerDialog> createState() =>
      _CustomTagsManagerDialogState();
}

class _CustomTagsManagerDialogState extends State<_CustomTagsManagerDialog> {
  late TextEditingController _textController;
  late List<String> _customTags;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _customTags = List<String>.from(widget.customTags);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 添加自定义标签
  void _addCustomTag(String tag) async {
    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty || _customTags.contains(trimmedTag)) return;

    try {
      final provider = Provider.of<UserPreferencesProvider>(
        context,
        listen: false,
      );

      if (provider.isInitialized) {
        await provider.addCustomTag(trimmedTag);
        setState(() {
          _customTags = List<String>.from(provider.tools.customTags);
        });
        _textController.clear();
      }
    } catch (e) {
      debugPrint('添加自定义标签失败: $e');
    }
  }

  /// 删除自定义标签
  void _removeCustomTag(String tag) async {
    try {
      final provider = Provider.of<UserPreferencesProvider>(
        context,
        listen: false,
      );

      if (provider.isInitialized) {
        await provider.removeCustomTag(tag);
        setState(() {
          _customTags = List<String>.from(provider.tools.customTags);
        });
      }
    } catch (e) {
      debugPrint('删除自定义标签失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('管理自定义标签'),
      content: SizedBox(
        width: 450,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加自定义标签输入框
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '输入自定义标签',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _addCustomTag,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addCustomTag(_textController.text),
                  icon: const Icon(Icons.add),
                  tooltip: '添加标签',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 标签数量统计
            Text(
              '自定义标签 (${_customTags.length})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // 自定义标签列表 - 使用Wrap布局提高空间利用率
            Expanded(
              child: _customTags.isEmpty
                  ? Center(
                      child: Text(
                        '暂无自定义标签\n点击上方输入框添加新标签',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _customTags
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                onDeleted: () => _removeCustomTag(tag),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
