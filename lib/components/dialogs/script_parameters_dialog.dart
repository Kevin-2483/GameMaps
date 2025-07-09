import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/new_reactive_script_manager.dart';

/// 脚本参数输入对话框
class ScriptParametersDialog extends StatefulWidget {
  final Map<String, ScriptParameter> parameters;
  final Map<String, dynamic> initialValues;
  final Map<String, dynamic>? defaultValues; // 新增：可选的默认值参数
  final String scriptName;

  const ScriptParametersDialog({
    super.key,
    required this.parameters,
    required this.initialValues,
    this.defaultValues, // 新增：可选的默认值参数
    required this.scriptName,
  });

  @override
  State<ScriptParametersDialog> createState() => _ScriptParametersDialogState();

  /// 显示参数输入对话框
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required Map<String, ScriptParameter> parameters,
    required Map<String, dynamic> initialValues,
    Map<String, dynamic>? defaultValues, // 新增：可选的默认值参数
    required String scriptName,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScriptParametersDialog(
        parameters: parameters,
        initialValues: initialValues,
        defaultValues: defaultValues, // 新增：传递默认值参数
        scriptName: scriptName,
      ),
    );
  }
}

class _ScriptParametersDialogState extends State<ScriptParametersDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _boolValues = {};
  final _formKey = GlobalKey<FormState>();
  bool _hasErrors = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final param in widget.parameters.values) {
      if (param.type == ScriptParameterType.boolean) {
        // 布尔类型使用单独的状态管理
        // 优先级：initialValues > defaultValues > 参数默认值 > false
        final initialValue =
            widget.initialValues[param.name] ??
            widget.defaultValues?[param.name] ??
            (param.defaultValue != null
                ? param.defaultValue!.toLowerCase() == 'true'
                : false);
        _boolValues[param.name] = initialValue is bool
            ? initialValue
            : (initialValue.toString().toLowerCase() == 'true');
      } else {
        // 其他类型使用文本控制器
        // 优先级：initialValues > defaultValues > 参数默认值 > 空字符串
        final initialValue =
            widget.initialValues[param.name]?.toString() ??
            widget.defaultValues?[param.name]?.toString() ??
            param.defaultValue ??
            '';
        _controllers[param.name] = TextEditingController(text: initialValue);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.settings, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '脚本参数设置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 脚本名称
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '脚本: ${widget.scriptName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 参数说明
            if (widget.parameters.isNotEmpty) ...[
              Text(
                '请设置以下参数：',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
            ],

            // 参数输入表单
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.parameters.values
                        .map((param) => _buildParameterField(param))
                        .toList(),
                  ),
                ),
              ),
            ),

            // 错误提示
            if (_hasErrors) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '请检查并修正参数输入错误',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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
        FilledButton(onPressed: _validateAndSubmit, child: const Text('确认')),
      ],
    );
  }

  Widget _buildParameterField(ScriptParameter param) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 参数标签
          Row(
            children: [
              Text(
                param.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (param.isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(param.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getTypeColor(param.type).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getTypeDisplayName(param.type),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getTypeColor(param.type),
                  ),
                ),
              ),
            ],
          ),

          // 参数描述
          if (param.description != null && param.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              param.description!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 参数输入控件
          _buildInputWidget(param),
        ],
      ),
    );
  }

  Widget _buildInputWidget(ScriptParameter param) {
    switch (param.type) {
      case ScriptParameterType.boolean:
        return _buildBooleanInput(param);
      case ScriptParameterType.integer:
        return _buildIntegerInput(param);
      case ScriptParameterType.number:
        return _buildNumberInput(param);
      case ScriptParameterType.string:
        return _buildStringInput(param);
    }
  }

  Widget _buildStringInput(ScriptParameter param) {
    return TextFormField(
      controller: _controllers[param.name],
      decoration: InputDecoration(
        hintText: param.defaultValue ?? '请输入${param.name}',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (param.isRequired && (value == null || value.trim().isEmpty)) {
          return '${param.name}是必填参数';
        }
        return null;
      },
    );
  }

  Widget _buildIntegerInput(ScriptParameter param) {
    return TextFormField(
      controller: _controllers[param.name],
      decoration: InputDecoration(
        hintText: param.defaultValue ?? '请输入整数',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
      validator: (value) {
        if (param.isRequired && (value == null || value.trim().isEmpty)) {
          return '${param.name}是必填参数';
        }
        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
          return '请输入有效的整数';
        }
        return null;
      },
    );
  }

  Widget _buildNumberInput(ScriptParameter param) {
    return TextFormField(
      controller: _controllers[param.name],
      decoration: InputDecoration(
        hintText: param.defaultValue ?? '请输入数字',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      validator: (value) {
        if (param.isRequired && (value == null || value.trim().isEmpty)) {
          return '${param.name}是必填参数';
        }
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return '请输入有效的数字';
        }
        return null;
      },
    );
  }

  Widget _buildBooleanInput(ScriptParameter param) {
    return Row(
      children: [
        Switch(
          value: _boolValues[param.name] ?? false,
          onChanged: (value) {
            setState(() {
              _boolValues[param.name] = value;
            });
          },
        ),
        const SizedBox(width: 8),
        Text(
          _boolValues[param.name] == true ? '是' : '否',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Color _getTypeColor(ScriptParameterType type) {
    switch (type) {
      case ScriptParameterType.string:
        return Colors.blue;
      case ScriptParameterType.integer:
        return Colors.green;
      case ScriptParameterType.number:
        return Colors.orange;
      case ScriptParameterType.boolean:
        return Colors.purple;
    }
  }

  String _getTypeDisplayName(ScriptParameterType type) {
    switch (type) {
      case ScriptParameterType.string:
        return '文本';
      case ScriptParameterType.integer:
        return '整数';
      case ScriptParameterType.number:
        return '数字';
      case ScriptParameterType.boolean:
        return '布尔';
    }
  }

  void _validateAndSubmit() {
    setState(() {
      _hasErrors = false;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _hasErrors = true;
      });
      return;
    }

    // 收集所有参数值
    final result = <String, dynamic>{};

    for (final param in widget.parameters.values) {
      if (param.type == ScriptParameterType.boolean) {
        result[param.name] = _boolValues[param.name] ?? false;
      } else {
        final controller = _controllers[param.name]!;
        final value = controller.text.trim();

        if (value.isNotEmpty) {
          switch (param.type) {
            case ScriptParameterType.integer:
              result[param.name] = int.tryParse(value) ?? 0;
              break;
            case ScriptParameterType.number:
              result[param.name] = double.tryParse(value) ?? 0.0;
              break;
            case ScriptParameterType.string:
            default:
              result[param.name] = value;
              break;
          }
        } else if (param.defaultValue != null) {
          // 使用默认值
          switch (param.type) {
            case ScriptParameterType.integer:
              result[param.name] = int.tryParse(param.defaultValue!) ?? 0;
              break;
            case ScriptParameterType.number:
              result[param.name] = double.tryParse(param.defaultValue!) ?? 0.0;
              break;
            case ScriptParameterType.string:
            default:
              result[param.name] = param.defaultValue!;
              break;
          }
        }
      }
    }

    Navigator.of(context).pop(result);
  }
}
