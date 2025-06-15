import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  @override
  State<TagsManager> createState() => _TagsManagerState();
}

class _TagsManagerState extends State<TagsManager> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _inputText = '';
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _updateSuggestions();
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
      _filteredSuggestions = widget.suggestedTags
          .where((tag) => !widget.tags.contains(tag))
          .toList();
      return;
    }

    _filteredSuggestions = widget.suggestedTags
        .where((tag) => 
            !widget.tags.contains(tag) && 
            tag.toLowerCase().contains(_inputText.toLowerCase()))
        .toList();
  }

  /// 添加标签
  void _addTag(String tag) {
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
      label: Text(
        tag,
        style: const TextStyle(fontSize: 12),
      ),
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
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1,
      ),
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
        if (widget.showSuggestions && _filteredSuggestions.isNotEmpty && !widget.readOnly) ...[
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
            children: _filteredSuggestions.take(10).map(_buildSuggestionChip).toList(),
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
/// 提供一个独立的对话框来管理标签
class TagsManagerDialog extends StatefulWidget {
  /// 初始标签列表
  final List<String> initialTags;
  
  /// 对话框标题
  final String title;
  
  /// 其他配置参数
  final int? maxTags;
  final List<String> suggestedTags;
  final String? Function(String tag)? tagValidator;

  const TagsManagerDialog({
    super.key,
    required this.initialTags,
    this.title = '管理标签',
    this.maxTags,
    this.suggestedTags = const [],
    this.tagValidator,
  });

  @override
  State<TagsManagerDialog> createState() => _TagsManagerDialogState();
}

class _TagsManagerDialogState extends State<TagsManagerDialog> {
  late List<String> _currentTags;

  @override
  void initState() {
    super.initState();
    _currentTags = List<String>.from(widget.initialTags);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: TagsManager(
          tags: _currentTags,
          onTagsChanged: (tags) {
            setState(() {
              _currentTags = tags;
            });
          },
          maxTags: widget.maxTags,
          suggestedTags: widget.suggestedTags,
          tagValidator: widget.tagValidator,
          hintText: '添加新标签',
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
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => TagsManagerDialog(
        initialTags: initialTags,
        title: title,
        maxTags: maxTags,
        suggestedTags: suggestedTags,
        tagValidator: tagValidator,
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
      '待办',
      '完成',
      '草稿',
      '审核',
      '归档',
      '临时',
      '备注',
      '标记',
      '高优先级',
      '低优先级',
      '工作',
      '个人',
      '项目',
      '会议',
      '计划',
      '想法',
      '资源',
      '参考',
    ];
  }
}
