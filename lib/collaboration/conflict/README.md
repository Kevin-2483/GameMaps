# 冲突检测与解决 (Conflict Detection & Resolution)

## 📋 模块职责

专门处理实时协作中的冲突检测、分类、解决策略和用户交互，确保多用户并发编辑时的数据完整性和用户体验。

## 🏗️ 架构设计

### 冲突处理架构图
```
┌─────────────────────────────────────────────────────────┐
│              Conflict Management Layer                  │
├─────────────────────────────────────────────────────────┤
│  Conflict Detector  │  Conflict Classifier │ Resolution │
│  ┌────────────────┐ │ ┌──────────────────┐ │ ┌─────────┐ │
│  │ Operation      │ │ │ Conflict Types   │ │ │ Auto    │ │
│  │ Analyzer       │ │ │ Severity Level   │ │ │ Resolve │ │
│  └────────────────┘ │ └──────────────────┘ │ └─────────┘ │
├─────────────────────────────────────────────────────────┤
│  Strategy Manager   │  User Interface    │  History Mgr │
│  ┌────────────────┐ │ ┌──────────────────┐ │ ┌─────────┐ │
│  │ Resolution     │ │ │ Conflict Dialog  │ │ │ Conflict│ │
│  │ Strategies     │ │ │ Preview & Choice │ │ │ History │ │
│  └────────────────┘ │ └──────────────────┘ │ └─────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 设计原则
- **早期检测**：在操作应用前检测潜在冲突
- **智能分类**：根据冲突类型选择合适的解决策略
- **用户友好**：提供直观的冲突解决界面
- **可扩展性**：支持自定义冲突类型和解决策略
- **历史追踪**：记录冲突解决历史便于分析

## 📁 文件结构

```
conflict/
├── detection/                    # 冲突检测
│   ├── conflict_detector.dart
│   ├── operation_analyzer.dart
│   ├── dependency_tracker.dart
│   ├── semantic_analyzer.dart
│   └── conflict_predictor.dart
├── classification/               # 冲突分类
│   ├── conflict_classifier.dart
│   ├── conflict_types.dart
│   ├── severity_evaluator.dart
│   ├── impact_analyzer.dart
│   └── priority_calculator.dart
├── resolution/                   # 冲突解决
│   ├── resolution_engine.dart
│   ├── auto_resolver.dart
│   ├── manual_resolver.dart
│   ├── merge_strategies.dart
│   └── resolution_validator.dart
├── strategies/                   # 解决策略
│   ├── last_writer_wins.dart
│   ├── first_writer_wins.dart
│   ├── merge_strategy.dart
│   ├── user_choice_strategy.dart
│   └── custom_strategies.dart
├── ui/                          # 用户界面
│   ├── conflict_dialog.dart
│   ├── resolution_preview.dart
│   ├── conflict_notification.dart
│   ├── history_viewer.dart
│   └── strategy_selector.dart
├── history/                     # 历史管理
│   ├── conflict_history.dart
│   ├── resolution_tracker.dart
│   ├── analytics_collector.dart
│   └── history_persistence.dart
└── utils/                       # 工具类
    ├── conflict_utils.dart
    ├── merge_algorithms.dart
    ├── diff_calculator.dart
    └── conflict_logger.dart
```

## 🔧 核心组件说明

### ConflictDetector (冲突检测器)
**职责**：检测操作间的冲突
**功能**：
- 实时冲突检测
- 依赖关系分析
- 语义冲突识别
- 预测性冲突检测

**检测算法**：
```dart
class ConflictDetector {
  final DependencyTracker _dependencyTracker = DependencyTracker();
  final SemanticAnalyzer _semanticAnalyzer = SemanticAnalyzer();
  
  Future<List<Conflict>> detectConflicts(
    Operation newOperation,
    List<Operation> concurrentOperations,
  ) async {
    final conflicts = <Conflict>[];
    
    for (final concurrent in concurrentOperations) {
      // 检测直接冲突
      final directConflict = _detectDirectConflict(newOperation, concurrent);
      if (directConflict != null) {
        conflicts.add(directConflict);
      }
      
      // 检测依赖冲突
      final dependencyConflict = await _detectDependencyConflict(newOperation, concurrent);
      if (dependencyConflict != null) {
        conflicts.add(dependencyConflict);
      }
      
      // 检测语义冲突
      final semanticConflict = await _detectSemanticConflict(newOperation, concurrent);
      if (semanticConflict != null) {
        conflicts.add(semanticConflict);
      }
    }
    
    return conflicts;
  }
  
  Conflict? _detectDirectConflict(Operation op1, Operation op2) {
    // 检测操作目标重叠
    if (_operationsOverlap(op1, op2)) {
      return DirectConflict(
        operation1: op1,
        operation2: op2,
        conflictType: _determineConflictType(op1, op2),
        severity: _calculateSeverity(op1, op2),
      );
    }
    return null;
  }
  
  bool _operationsOverlap(Operation op1, Operation op2) {
    // 检查操作是否作用于相同的元素或区域
    if (op1 is ElementOperation && op2 is ElementOperation) {
      return op1.elementId == op2.elementId;
    }
    
    if (op1 is RegionOperation && op2 is RegionOperation) {
      return op1.region.intersects(op2.region);
    }
    
    return false;
  }
}
```

### ConflictClassifier (冲突分类器)
**职责**：对检测到的冲突进行分类和评估
**功能**：
- 冲突类型识别
- 严重程度评估
- 影响范围分析
- 优先级计算

**冲突类型定义**：
```dart
enum ConflictType {
  // 数据冲突
  dataConflict,           // 相同数据的不同修改
  structuralConflict,     // 结构性冲突（如删除vs修改）
  orderingConflict,       // 顺序冲突
  
  // 语义冲突
  semanticConflict,       // 语义上的冲突
  businessRuleConflict,   // 业务规则冲突
  constraintViolation,    // 约束违反
  
  // 并发冲突
  readWriteConflict,      // 读写冲突
  writeWriteConflict,     // 写写冲突
  dependencyConflict,     // 依赖冲突
}

enum ConflictSeverity {
  low,        // 可自动解决
  medium,     // 需要用户确认
  high,       // 需要用户选择
  critical,   // 可能导致数据丢失
}

abstract class Conflict {
  final String id;
  final ConflictType type;
  final ConflictSeverity severity;
  final Operation operation1;
  final Operation operation2;
  final DateTime detectedAt;
  final String description;
  
  Conflict({
    required this.id,
    required this.type,
    required this.severity,
    required this.operation1,
    required this.operation2,
    required this.detectedAt,
    required this.description,
  });
  
  // 获取冲突影响的元素
  List<String> get affectedElements;
  
  // 获取可能的解决策略
  List<ResolutionStrategy> get availableStrategies;
  
  // 预估解决复杂度
  ResolutionComplexity get complexity;
}

class DirectConflict extends Conflict {
  final ConflictRegion region;
  
  DirectConflict({
    required super.id,
    required super.type,
    required super.severity,
    required super.operation1,
    required super.operation2,
    required super.detectedAt,
    required super.description,
    required this.region,
  });
  
  @override
  List<String> get affectedElements {
    return region.elementIds;
  }
  
  @override
  List<ResolutionStrategy> get availableStrategies {
    switch (type) {
      case ConflictType.dataConflict:
        return [
          LastWriterWinsStrategy(),
          FirstWriterWinsStrategy(),
          MergeStrategy(),
          UserChoiceStrategy(),
        ];
      case ConflictType.structuralConflict:
        return [
          UserChoiceStrategy(),
          PreserveStructureStrategy(),
        ];
      default:
        return [UserChoiceStrategy()];
    }
  }
}
```

### ResolutionEngine (解决引擎)
**职责**：执行冲突解决策略
**功能**：
- 策略选择和执行
- 自动解决机制
- 手动解决支持
- 解决结果验证

**解决流程**：
```dart
class ResolutionEngine {
  final Map<ConflictType, ResolutionStrategy> _defaultStrategies = {};
  final ResolutionValidator _validator = ResolutionValidator();
  
  Future<ResolutionResult> resolveConflict(
    Conflict conflict,
    {ResolutionStrategy? strategy}
  ) async {
    // 选择解决策略
    final selectedStrategy = strategy ?? _selectDefaultStrategy(conflict);
    
    try {
      // 执行解决策略
      final resolution = await selectedStrategy.resolve(conflict);
      
      // 验证解决结果
      final validationResult = await _validator.validate(resolution);
      if (!validationResult.isValid) {
        throw ResolutionException('Resolution validation failed: ${validationResult.errors}');
      }
      
      // 应用解决结果
      await _applyResolution(resolution);
      
      // 记录解决历史
      await _recordResolution(conflict, resolution);
      
      return ResolutionResult.success(resolution);
    } catch (e) {
      return ResolutionResult.failure(e.toString());
    }
  }
  
  ResolutionStrategy _selectDefaultStrategy(Conflict conflict) {
    // 根据冲突类型和严重程度选择策略
    if (conflict.severity == ConflictSeverity.low) {
      return _defaultStrategies[conflict.type] ?? LastWriterWinsStrategy();
    } else {
      return UserChoiceStrategy();
    }
  }
  
  Future<void> _applyResolution(Resolution resolution) async {
    switch (resolution.type) {
      case ResolutionType.keepFirst:
        await _applyOperation(resolution.operation1);
        break;
      case ResolutionType.keepSecond:
        await _applyOperation(resolution.operation2);
        break;
      case ResolutionType.merge:
        await _applyOperation(resolution.mergedOperation!);
        break;
      case ResolutionType.custom:
        await _applyCustomResolution(resolution);
        break;
    }
  }
}
```

### 解决策略实现

#### LastWriterWinsStrategy (最后写入者获胜)
```dart
class LastWriterWinsStrategy implements ResolutionStrategy {
  @override
  String get name => 'Last Writer Wins';
  
  @override
  String get description => '保留时间戳较新的操作';
  
  @override
  bool canResolve(Conflict conflict) {
    return conflict.type == ConflictType.dataConflict;
  }
  
  @override
  Future<Resolution> resolve(Conflict conflict) async {
    final op1Time = conflict.operation1.timestamp;
    final op2Time = conflict.operation2.timestamp;
    
    if (op2Time.isAfter(op1Time)) {
      return Resolution(
        type: ResolutionType.keepSecond,
        operation1: conflict.operation1,
        operation2: conflict.operation2,
        strategy: this,
        reason: 'Operation 2 has later timestamp',
      );
    } else {
      return Resolution(
        type: ResolutionType.keepFirst,
        operation1: conflict.operation1,
        operation2: conflict.operation2,
        strategy: this,
        reason: 'Operation 1 has later timestamp',
      );
    }
  }
}
```

#### MergeStrategy (合并策略)
```dart
class MergeStrategy implements ResolutionStrategy {
  final MergeAlgorithm _algorithm = ThreeWayMergeAlgorithm();
  
  @override
  String get name => 'Merge';
  
  @override
  String get description => '尝试自动合并两个操作';
  
  @override
  bool canResolve(Conflict conflict) {
    return _algorithm.canMerge(conflict.operation1, conflict.operation2);
  }
  
  @override
  Future<Resolution> resolve(Conflict conflict) async {
    final mergeResult = await _algorithm.merge(
      conflict.operation1,
      conflict.operation2,
    );
    
    if (mergeResult.isSuccessful) {
      return Resolution(
        type: ResolutionType.merge,
        operation1: conflict.operation1,
        operation2: conflict.operation2,
        mergedOperation: mergeResult.mergedOperation,
        strategy: this,
        reason: 'Successfully merged operations',
      );
    } else {
      throw ResolutionException('Merge failed: ${mergeResult.error}');
    }
  }
}
```

#### UserChoiceStrategy (用户选择策略)
```dart
class UserChoiceStrategy implements ResolutionStrategy {
  @override
  String get name => 'User Choice';
  
  @override
  String get description => '让用户手动选择解决方案';
  
  @override
  bool canResolve(Conflict conflict) => true;
  
  @override
  Future<Resolution> resolve(Conflict conflict) async {
    // 显示冲突解决对话框
    final userChoice = await _showConflictDialog(conflict);
    
    switch (userChoice.choice) {
      case UserChoice.keepFirst:
        return Resolution(
          type: ResolutionType.keepFirst,
          operation1: conflict.operation1,
          operation2: conflict.operation2,
          strategy: this,
          reason: 'User chose to keep first operation',
        );
      case UserChoice.keepSecond:
        return Resolution(
          type: ResolutionType.keepSecond,
          operation1: conflict.operation1,
          operation2: conflict.operation2,
          strategy: this,
          reason: 'User chose to keep second operation',
        );
      case UserChoice.custom:
        return Resolution(
          type: ResolutionType.custom,
          operation1: conflict.operation1,
          operation2: conflict.operation2,
          customOperation: userChoice.customOperation,
          strategy: this,
          reason: 'User provided custom resolution',
        );
    }
  }
  
  Future<UserChoiceResult> _showConflictDialog(Conflict conflict) async {
    final completer = Completer<UserChoiceResult>();
    
    // 显示冲突解决对话框
    showDialog(
      context: _context,
      builder: (context) => ConflictResolutionDialog(
        conflict: conflict,
        onResolved: (result) {
          completer.complete(result);
          Navigator.of(context).pop();
        },
      ),
    );
    
    return completer.future;
  }
}
```

## 🎨 用户界面组件

### ConflictResolutionDialog (冲突解决对话框)
```dart
class ConflictResolutionDialog extends StatefulWidget {
  final Conflict conflict;
  final Function(UserChoiceResult) onResolved;
  
  const ConflictResolutionDialog({
    Key? key,
    required this.conflict,
    required this.onResolved,
  }) : super(key: key);
  
  @override
  _ConflictResolutionDialogState createState() => _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  UserChoice _selectedChoice = UserChoice.keepFirst;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('解决冲突'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('检测到冲突：${widget.conflict.description}'),
          SizedBox(height: 16),
          
          // 冲突详情
          _buildConflictDetails(),
          SizedBox(height: 16),
          
          // 解决选项
          _buildResolutionOptions(),
          SizedBox(height: 16),
          
          // 预览区域
          _buildPreview(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _handleResolve,
          child: Text('解决'),
        ),
      ],
    );
  }
  
  Widget _buildConflictDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('冲突类型：${_getConflictTypeText(widget.conflict.type)}'),
            Text('严重程度：${_getSeverityText(widget.conflict.severity)}'),
            Text('影响元素：${widget.conflict.affectedElements.join(", ")}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResolutionOptions() {
    return Column(
      children: [
        RadioListTile<UserChoice>(
          title: Text('保留第一个操作'),
          subtitle: Text(_getOperationDescription(widget.conflict.operation1)),
          value: UserChoice.keepFirst,
          groupValue: _selectedChoice,
          onChanged: (value) => setState(() => _selectedChoice = value!),
        ),
        RadioListTile<UserChoice>(
          title: Text('保留第二个操作'),
          subtitle: Text(_getOperationDescription(widget.conflict.operation2)),
          value: UserChoice.keepSecond,
          groupValue: _selectedChoice,
          onChanged: (value) => setState(() => _selectedChoice = value!),
        ),
        if (_canMerge())
          RadioListTile<UserChoice>(
            title: Text('尝试合并'),
            subtitle: Text('自动合并两个操作'),
            value: UserChoice.merge,
            groupValue: _selectedChoice,
            onChanged: (value) => setState(() => _selectedChoice = value!),
          ),
      ],
    );
  }
  
  Widget _buildPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ResolutionPreview(
        conflict: widget.conflict,
        selectedChoice: _selectedChoice,
      ),
    );
  }
  
  void _handleResolve() {
    final result = UserChoiceResult(
      choice: _selectedChoice,
      conflict: widget.conflict,
    );
    widget.onResolved(result);
  }
}
```

## 📊 冲突分析和统计

### ConflictAnalytics (冲突分析)
```dart
class ConflictAnalytics {
  final ConflictHistory _history = ConflictHistory();
  
  Future<ConflictReport> generateReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conflicts = await _history.getConflicts(
      startDate: startDate,
      endDate: endDate,
    );
    
    return ConflictReport(
      totalConflicts: conflicts.length,
      conflictsByType: _groupByType(conflicts),
      conflictsBySeverity: _groupBySeverity(conflicts),
      resolutionMethods: _analyzeResolutionMethods(conflicts),
      averageResolutionTime: _calculateAverageResolutionTime(conflicts),
      conflictHotspots: _identifyHotspots(conflicts),
      userConflictRates: _calculateUserConflictRates(conflicts),
    );
  }
  
  Map<ConflictType, int> _groupByType(List<Conflict> conflicts) {
    final grouped = <ConflictType, int>{};
    for (final conflict in conflicts) {
      grouped[conflict.type] = (grouped[conflict.type] ?? 0) + 1;
    }
    return grouped;
  }
  
  List<ConflictHotspot> _identifyHotspots(List<Conflict> conflicts) {
    final elementConflictCounts = <String, int>{};
    
    for (final conflict in conflicts) {
      for (final elementId in conflict.affectedElements) {
        elementConflictCounts[elementId] = (elementConflictCounts[elementId] ?? 0) + 1;
      }
    }
    
    return elementConflictCounts.entries
        .where((entry) => entry.value > 5) // 超过5次冲突的元素
        .map((entry) => ConflictHotspot(
              elementId: entry.key,
              conflictCount: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.conflictCount.compareTo(a.conflictCount));
  }
}

class ConflictReport {
  final int totalConflicts;
  final Map<ConflictType, int> conflictsByType;
  final Map<ConflictSeverity, int> conflictsBySeverity;
  final Map<String, int> resolutionMethods;
  final Duration averageResolutionTime;
  final List<ConflictHotspot> conflictHotspots;
  final Map<String, double> userConflictRates;
  
  ConflictReport({
    required this.totalConflicts,
    required this.conflictsByType,
    required this.conflictsBySeverity,
    required this.resolutionMethods,
    required this.averageResolutionTime,
    required this.conflictHotspots,
    required this.userConflictRates,
  });
}
```

## 🧪 测试策略

### 冲突检测测试
```dart
void main() {
  group('ConflictDetector Tests', () {
    late ConflictDetector detector;
    
    setUp(() {
      detector = ConflictDetector();
    });
    
    test('should detect direct conflict', () async {
      final op1 = UpdateOperation(
        elementId: 'element1',
        changes: {'color': 'red'},
        clientId: 'client1',
        timestamp: DateTime.now(),
      );
      
      final op2 = UpdateOperation(
        elementId: 'element1',
        changes: {'color': 'blue'},
        clientId: 'client2',
        timestamp: DateTime.now(),
      );
      
      final conflicts = await detector.detectConflicts(op1, [op2]);
      
      expect(conflicts, hasLength(1));
      expect(conflicts.first.type, ConflictType.dataConflict);
    });
    
    test('should not detect conflict for different elements', () async {
      final op1 = UpdateOperation(
        elementId: 'element1',
        changes: {'color': 'red'},
        clientId: 'client1',
        timestamp: DateTime.now(),
      );
      
      final op2 = UpdateOperation(
        elementId: 'element2',
        changes: {'color': 'blue'},
        clientId: 'client2',
        timestamp: DateTime.now(),
      );
      
      final conflicts = await detector.detectConflicts(op1, [op2]);
      
      expect(conflicts, isEmpty);
    });
  });
}
```

### 解决策略测试
```dart
void main() {
  group('Resolution Strategy Tests', () {
    test('LastWriterWinsStrategy should keep later operation', () async {
      final strategy = LastWriterWinsStrategy();
      final now = DateTime.now();
      
      final conflict = DirectConflict(
        id: 'conflict1',
        type: ConflictType.dataConflict,
        severity: ConflictSeverity.low,
        operation1: UpdateOperation(
          elementId: 'element1',
          changes: {'color': 'red'},
          clientId: 'client1',
          timestamp: now,
        ),
        operation2: UpdateOperation(
          elementId: 'element1',
          changes: {'color': 'blue'},
          clientId: 'client2',
          timestamp: now.add(Duration(seconds: 1)),
        ),
        detectedAt: DateTime.now(),
        description: 'Color conflict',
        region: ConflictRegion(['element1']),
      );
      
      final resolution = await strategy.resolve(conflict);
      
      expect(resolution.type, ResolutionType.keepSecond);
    });
  });
}
```

## 📋 开发清单

### 第一阶段：基础冲突检测
- [ ] ConflictDetector基础实现
- [ ] 基础冲突类型定义
- [ ] DirectConflict检测算法
- [ ] ConflictClassifier分类器

### 第二阶段：解决策略
- [ ] ResolutionEngine解决引擎
- [ ] LastWriterWinsStrategy实现
- [ ] MergeStrategy基础实现
- [ ] UserChoiceStrategy实现

### 第三阶段：用户界面
- [ ] ConflictResolutionDialog对话框
- [ ] ResolutionPreview预览组件
- [ ] ConflictNotification通知组件
- [ ] HistoryViewer历史查看器

### 第四阶段：高级功能
- [ ] SemanticAnalyzer语义分析
- [ ] ConflictPredictor预测器
- [ ] ConflictAnalytics分析工具
- [ ] 自定义策略支持

## 🔗 依赖关系

- **上游依赖**：models/, sync/
- **下游依赖**：widgets/, services/
- **外部依赖**：flutter, flutter_bloc
- **内部依赖**：utils/, network/

## 📝 开发规范

1. **冲突检测**：确保检测算法的准确性和效率
2. **用户体验**：提供直观的冲突解决界面
3. **策略扩展**：支持自定义解决策略
4. **性能优化**：最小化冲突检测开销
5. **历史记录**：完整记录冲突解决过程
6. **测试覆盖**：确保各种冲突场景的测试覆盖