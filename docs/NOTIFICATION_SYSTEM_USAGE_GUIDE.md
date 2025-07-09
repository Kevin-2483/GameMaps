# 通知系统使用指南

本文档介绍如何使用新的通知系统替换传统的 SnackBar，以及如何设置默认位置为中下。

## 快速开始

### 1. 基本使用方法

#### 替换 SnackBar 的简单方法

```dart
// 原来的 SnackBar 写法
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('操作成功')),
);

// 新的通知系统写法
context.showSuccessSnackBar('操作成功');
```

#### 使用扩展方法（推荐）

```dart
// 成功消息
context.showSuccessSnackBar('操作成功');

// 错误消息
context.showErrorSnackBar('操作失败');

// 信息消息
context.showInfoSnackBar('提示信息');

// 自定义类型
context.showNotificationSnackBar(
  '自定义消息',
  type: NotificationType.warning,
  position: NotificationPosition.bottomCenter, // 中下位置
);
```

### 2. 设置默认位置为中下

#### 方法一：修改配置文件

在 `notification_models.dart` 中修改默认位置：

```dart
class NotificationConfig {
  // 修改默认位置为中下
  final NotificationPosition defaultPosition;
  
  const NotificationConfig({
    this.defaultPosition = NotificationPosition.bottomCenter, // 设置为中下
    // ... 其他配置
  });
}
```

#### 方法二：在使用时指定位置

```dart
// 直接指定位置
NotificationService.instance.showSuccess(
  '操作成功',
  position: NotificationPosition.bottomCenter,
);

// 或使用扩展方法
context.showNotificationSnackBar(
  '消息内容',
  position: NotificationPosition.bottomCenter,
);
```

### 3. 高级功能

#### 常驻通知（替换持久 SnackBar）

```dart
NotificationService.instance.show(
  message: '这是一个常驻通知',
  type: NotificationType.info,
  position: NotificationPosition.bottomCenter,
  isPersistent: true, // 常驻显示
  showCloseButton: true, // 显示关闭按钮
);
```

#### 带边框效果的通知

```dart
NotificationService.instance.show(
  message: '加载中...',
  type: NotificationType.info,
  position: NotificationPosition.bottomCenter,
  borderEffect: NotificationBorderEffect.loading, // 旋转加载边框
  isPersistent: true,
);
```

#### 更新通知内容（不重新播放动画）

```dart
// 显示初始通知
NotificationService.instance.show(
  id: 'update_demo',
  message: '正在处理...',
  type: NotificationType.info,
  position: NotificationPosition.bottomCenter,
  isPersistent: true,
  borderEffect: NotificationBorderEffect.loading,
);

// 2秒后更新内容
Future.delayed(Duration(seconds: 2), () {
  NotificationService.instance.updateNotification(
    notificationId: 'update_demo',
    message: '处理完成！',
    type: NotificationType.success,
    borderEffect: NotificationBorderEffect.glow,
    isPersistent: false,
    duration: Duration(seconds: 3),
  );
});
```

## 迁移指南

### 常见 SnackBar 用法的替换

#### 1. 简单消息

```dart
// 原来
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('保存成功')),
);

// 现在
context.showSuccessSnackBar('保存成功');
```

#### 2. 错误消息

```dart
// 原来
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('保存失败'),
    backgroundColor: Colors.red,
  ),
);

// 现在
context.showErrorSnackBar('保存失败');
```

#### 3. 带动作的 SnackBar

```dart
// 原来
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('文件已删除'),
    action: SnackBarAction(
      label: '撤销',
      onPressed: () {
        // 撤销操作
      },
    ),
  ),
);

// 现在
NotificationService.instance.show(
  message: '文件已删除',
  type: NotificationType.warning,
  position: NotificationPosition.bottomCenter,
  showCloseButton: true,
  onTap: () {
    // 点击通知执行撤销操作
  },
);
```

#### 4. 持久显示的 SnackBar

```dart
// 原来
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('请保持网络连接'),
    duration: Duration(days: 1), // 很长的时间
  ),
);

// 现在
NotificationService.instance.show(
  message: '请保持网络连接',
  type: NotificationType.warning,
  position: NotificationPosition.bottomCenter,
  isPersistent: true, // 常驻显示
  showCloseButton: true,
);
```

### 批量替换示例

在现有代码中，你可以搜索以下模式并替换：

#### 搜索模式：
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('$message')),
);
```

#### 替换为：
```dart
context.showInfoSnackBar('$message');
```

#### 搜索模式（错误消息）：
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('$message'),
    backgroundColor: Colors.red,
  ),
);
```

#### 替换为：
```dart
context.showErrorSnackBar('$message');
```

## 位置选项

新的通知系统支持以下位置：

- `NotificationPosition.topLeft` - 左上角
- `NotificationPosition.topCenter` - 上方中央
- `NotificationPosition.topRight` - 右上角
- `NotificationPosition.centerLeft` - 左侧中央
- `NotificationPosition.center` - 屏幕中央
- `NotificationPosition.centerRight` - 右侧中央
- `NotificationPosition.bottomLeft` - 左下角
- `NotificationPosition.bottomCenter` - 下方中央（推荐用于替换 SnackBar）
- `NotificationPosition.bottomRight` - 右下角

## 配置选项

### 全局配置

```dart
// 在应用启动时配置
NotificationService.instance.configure(
  NotificationConfig(
    defaultPosition: NotificationPosition.bottomCenter,
    defaultDuration: Duration(seconds: 4),
    animationDuration: Duration(milliseconds: 300),
    // ... 其他配置
  ),
);
```

### 主题配置

```dart
NotificationService.instance.configure(
  NotificationConfig(),
  NotificationTheme(
    // 自定义颜色和样式
  ),
);
```

## 最佳实践

1. **使用扩展方法**：优先使用 `context.showSuccessSnackBar()` 等扩展方法，代码更简洁。

2. **设置合适的位置**：对于替换 SnackBar，推荐使用 `NotificationPosition.bottomCenter`。

3. **合理使用常驻通知**：只对重要的状态信息使用 `isPersistent: true`。

4. **利用更新功能**：对于需要显示进度的操作，使用 `updateNotification` 而不是重新创建通知。

5. **适当的持续时间**：根据消息重要性设置合适的显示时间。

## 示例代码

完整的使用示例可以参考 `notification_test_page.dart` 文件中的各种演示功能。