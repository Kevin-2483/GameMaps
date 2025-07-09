# 协作UI组件 (Collaboration Widgets)

## 📋 模块职责

提供实时协作功能的用户界面组件，包括协作状态显示、冲突解决界面、用户在线指示等，与现有地图编辑器UI无缝集成。

## 🏗️ 架构设计

### UI组件层次结构
```
MapEditorPage (现有)
├── CollaborationOverlay (新增)
│   ├── CollaborationStatusBar
│   ├── OnlineUsersPanel
│   ├── NetworkTopologyIndicator
│   └── ConflictNotificationBanner
├── CollaborationDialogs (新增)
│   ├── ConflictResolutionDialog
│   ├── UserInviteDialog
│   └── NetworkStatusDialog
└── CollaborationIndicators (新增)
    ├── UserCursors
    ├── SelectionHighlights
    └── OperationAnimations
```

### 设计原则
- **非侵入式**：不影响现有地图编辑功能
- **响应式设计**：适配不同屏幕尺寸
- **实时更新**：状态变更立即反映到UI
- **用户友好**：直观的视觉反馈和交互
- **可配置性**：支持显示/隐藏协作元素

## 📁 文件结构

```
widgets/
├── collaboration_overlay.dart       # 协作功能覆盖层
├── status/                         # 状态显示组件
│   ├── collaboration_status_bar.dart
│   ├── online_users_panel.dart
│   ├── network_indicator.dart
│   └── sync_progress_indicator.dart
├── dialogs/                        # 对话框组件
│   ├── conflict_resolution_dialog.dart
│   ├── user_invite_dialog.dart
│   ├── network_status_dialog.dart
│   └── collaboration_settings_dialog.dart
├── indicators/                     # 实时指示器
│   ├── user_cursors.dart
│   ├── selection_highlights.dart
│   ├── operation_animations.dart
│   └── presence_indicators.dart
├── panels/                         # 面板组件
│   ├── topology_visualizer.dart
│   ├── conflict_history_panel.dart
│   ├── operation_history_panel.dart
│   └── performance_monitor_panel.dart
├── notifications/                  # 通知组件
│   ├── conflict_notification.dart
│   ├── user_join_notification.dart
│   ├── network_alert.dart
│   └── sync_notification.dart
└── common/                        # 通用组件
    ├── user_avatar.dart
    ├── connection_status_icon.dart
    ├── animated_counter.dart
    └── collaboration_theme.dart
```

## 🔧 核心组件说明

### CollaborationOverlay
**职责**：协作功能的主覆盖层
**功能**：
- 管理所有协作UI组件的显示
- 处理组件间的布局协调
- 响应协作状态变更
- 提供统一的主题和样式

**使用方式**：
```dart
class MapEditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack([
        // 现有地图编辑器内容
        MapEditorContent(),
        
        // 新增协作覆盖层
        CollaborationOverlay(),
      ]),
    );
  }
}
```

### CollaborationStatusBar
**职责**：显示协作状态概览
**显示内容**：
- 在线用户数量
- 连接状态指示
- 网络质量指示
- 同步状态

**UI设计**：
```
[👥 3] [🟢 已连接] [📶 良好] [🔄 同步中] [⚙️]
```

### OnlineUsersPanel
**职责**：显示在线用户列表和状态
**功能**：
- 用户头像和昵称
- 在线状态指示
- 当前活动显示
- 用户权限标识

**UI布局**：
```
┌─ 在线用户 (3) ────────┐
│ 👤 张三    🟢 编辑中  │
│ 👤 李四    🟡 查看中  │
│ 👤 王五    🔴 离线    │
└─────────────────────┘
```

### ConflictResolutionDialog
**职责**：处理冲突解决的用户界面
**功能**：
- 冲突详情展示
- 解决方案选择
- 预览变更效果
- 确认和取消操作

**交互流程**：
```
1. 检测到冲突 → 显示通知
2. 用户点击查看 → 打开解决对话框
3. 展示冲突详情 → 提供解决选项
4. 用户选择方案 → 预览效果
5. 确认应用 → 同步解决结果
```

### UserCursors
**职责**：显示其他用户的实时光标位置
**功能**：
- 光标位置实时更新
- 用户标识显示
- 平滑动画过渡
- 自动隐藏机制

**视觉设计**：
```
     张三
      ↓
   ┌─────┐
   │  ▲  │ ← 彩色光标
   └─────┘
```

## 🎨 视觉设计规范

### 颜色方案
```dart
class CollaborationColors {
  static const Color online = Color(0xFF4CAF50);      // 绿色 - 在线
  static const Color offline = Color(0xFF9E9E9E);     // 灰色 - 离线
  static const Color conflict = Color(0xFFF44336);     // 红色 - 冲突
  static const Color syncing = Color(0xFF2196F3);     // 蓝色 - 同步中
  static const Color warning = Color(0xFFFF9800);     // 橙色 - 警告
}
```

### 图标规范
- **连接状态**：🟢 已连接, 🟡 连接中, 🔴 断开
- **用户状态**：👤 用户, 👑 超级节点, 🔧 管理员
- **操作类型**：➕ 添加, ✏️ 编辑, 🗑️ 删除, 🔄 同步
- **网络质量**：📶 优秀, 📶 良好, 📶 一般, ❌ 差

### 动画规范
- **进入动画**：淡入 + 缩放 (300ms)
- **退出动画**：淡出 + 缩放 (200ms)
- **状态变更**：颜色渐变 (150ms)
- **光标移动**：贝塞尔曲线 (100ms)

## 📱 响应式设计

### 屏幕适配
```dart
class ResponsiveLayout {
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width > 1200;
  
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width > 600;
  
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width <= 600;
}
```

### 布局策略
- **桌面端**：侧边栏 + 状态栏 + 覆盖层
- **平板端**：底部面板 + 浮动按钮
- **移动端**：最小化显示 + 手势操作

## 🔄 状态管理集成

### BlocBuilder使用
```dart
class CollaborationStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollaborationBloc, CollaborationState>(
      builder: (context, state) {
        return Container(
          child: _buildStatusContent(state),
        );
      },
    );
  }
}
```

### 多Bloc监听
```dart
class ConflictNotificationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ConflictBloc, ConflictState>(
          listener: _handleConflictState,
        ),
        BlocListener<CollaborationBloc, CollaborationState>(
          listener: _handleCollaborationState,
        ),
      ],
      child: _buildBanner(),
    );
  }
}
```

## 🧪 测试策略

### Widget测试
```dart
void main() {
  group('CollaborationStatusBar', () {
    testWidgets('should display online user count', (tester) async {
      // Given
      await tester.pumpWidget(
        BlocProvider<CollaborationBloc>(
          create: (_) => mockCollaborationBloc,
          child: CollaborationStatusBar(),
        ),
      );
      
      // When
      when(mockCollaborationBloc.state).thenReturn(
        CollaborationActive(onlineUsers: ['user1', 'user2']),
      );
      
      // Then
      expect(find.text('2'), findsOneWidget);
    });
  });
}
```

### 集成测试
- 用户交互流程测试
- 状态变更响应测试
- 动画效果测试

### 视觉回归测试
- 截图对比测试
- 不同屏幕尺寸测试
- 主题切换测试

## 🎯 用户体验优化

### 性能优化
- **懒加载**：按需渲染组件
- **虚拟滚动**：大量用户列表优化
- **防抖动**：避免频繁状态更新
- **内存管理**：及时释放动画资源

### 可访问性
- **语义标签**：为屏幕阅读器提供描述
- **键盘导航**：支持Tab键导航
- **高对比度**：支持高对比度模式
- **字体缩放**：支持系统字体大小设置

## 📋 开发清单

### 第一阶段：基础组件
- [ ] CollaborationOverlay主覆盖层
- [ ] CollaborationStatusBar状态栏
- [ ] OnlineUsersPanel用户面板
- [ ] 基础状态指示器

### 第二阶段：交互组件
- [ ] ConflictResolutionDialog冲突对话框
- [ ] UserCursors用户光标
- [ ] SelectionHighlights选择高亮
- [ ] 通知组件

### 第三阶段：高级功能
- [ ] TopologyVisualizer拓扑可视化
- [ ] PerformanceMonitor性能监控
- [ ] OperationAnimations操作动画
- [ ] 主题和样式完善

## 🔗 依赖关系

- **上游依赖**：blocs/, models/
- **下游依赖**：无
- **外部依赖**：flutter, flutter_bloc
- **内部依赖**：现有UI组件系统

## 📝 开发规范

1. **组件命名**：使用描述性的英文命名
2. **状态管理**：优先使用BlocBuilder/BlocListener
3. **样式分离**：将样式定义在单独的类中
4. **动画使用**：合理使用动画提升用户体验
5. **性能考虑**：避免不必要的重建和渲染
6. **可访问性**：确保组件支持无障碍访问