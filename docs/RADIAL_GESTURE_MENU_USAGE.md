# 径向手势菜单组件使用指南

## 概述

`RadialGestureMenu` 是一个高度可定制的径向菜单组件，支持中键手势操作、多级子菜单、动画效果和丰富的视觉定制选项。

## 基本用法

### 1. 导入组件

```dart
import 'package:your_app/components/common/radial_gesture_menu.dart';
```

### 2. 创建菜单项

```dart
final List<RadialMenuItem> menuItems = [
  RadialMenuItem(
    label: '文件',
    icon: Icons.folder,
    onTap: () => print('文件被点击'),
    subItems: [
      RadialMenuItem(
        label: '新建',
        icon: Icons.add,
        onTap: () => print('新建文件'),
      ),
      RadialMenuItem(
        label: '打开',
        icon: Icons.open_in_new,
        onTap: () => print('打开文件'),
      ),
    ],
  ),
  RadialMenuItem(
    label: '编辑',
    icon: Icons.edit,
    onTap: () => print('编辑被点击'),
  ),
  RadialMenuItem(
    label: '视图',
    icon: Icons.visibility,
    onTap: () => print('视图被点击'),
  ),
];
```

### 3. 使用组件

```dart
RadialGestureMenu(
  menuItems: menuItems,
  child: Container(
    width: 400,
    height: 300,
    color: Colors.grey[200],
    child: Center(
      child: Text('在此区域按住中键显示菜单'),
    ),
  ),
)
```

## 配置选项

### 基本配置

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `menuItems` | `List<RadialMenuItem>` | 必需 | 菜单项列表 |
| `child` | `Widget` | 必需 | 子组件，菜单将覆盖在其上方 |
| `radius` | `double` | `120.0` | 菜单半径 |
| `centerRadius` | `double` | `30.0` | 中心区域半径 |
| `opacity` | `double` | `0.95` | 菜单整体透明度 |

### 视觉定制

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `plateColor` | `Color` | `Color(0xFF2D2D2D)` | 菜单背景色 |
| `itemColor` | `Color` | `Color(0xFF404040)` | 菜单项背景色 |
| `hoverColor` | `Color` | `Color(0xFF505050)` | 悬停时背景色 |
| `textColor` | `Color` | `Colors.white` | 文字颜色 |
| `iconColor` | `Color` | `Colors.white` | 图标颜色 |
| `borderColor` | `Color` | `Color(0xFF606060)` | 边框颜色 |

### 动画配置

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `animationDuration` | `Duration` | `Duration(milliseconds: 300)` | 动画持续时间 |
| `cardAnimationDelay` | `Duration` | `Duration(milliseconds: 50)` | 卡片动画延迟 |

### 其他选项

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `debugMode` | `bool` | `false` | 调试模式，显示调试信息 |
| `onItemSelected` | `Function(RadialMenuItem)?` | `null` | 项目选择回调 |

## RadialMenuItem 配置

### 基本属性

```dart
RadialMenuItem(
  label: '菜单项名称',        // 显示文本
  icon: Icons.example,        // 图标
  onTap: () => {},           // 点击回调
  subItems: [],              // 子菜单项（可选）
)
```

### 子菜单

```dart
RadialMenuItem(
  label: '父菜单',
  icon: Icons.folder,
  subItems: [
    RadialMenuItem(
      label: '子菜单1',
      icon: Icons.child_care,
      onTap: () => print('子菜单1被点击'),
    ),
    RadialMenuItem(
      label: '子菜单2',
      icon: Icons.child_friendly,
      onTap: () => print('子菜单2被点击'),
    ),
  ],
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:your_app/components/common/radial_gesture_menu.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuItems = [
      RadialMenuItem(
        label: '文件',
        icon: Icons.folder,
        subItems: [
          RadialMenuItem(
            label: '新建',
            icon: Icons.add,
            onTap: () => _showSnackBar(context, '新建文件'),
          ),
          RadialMenuItem(
            label: '打开',
            icon: Icons.open_in_new,
            onTap: () => _showSnackBar(context, '打开文件'),
          ),
          RadialMenuItem(
            label: '保存',
            icon: Icons.save,
            onTap: () => _showSnackBar(context, '保存文件'),
          ),
        ],
      ),
      RadialMenuItem(
        label: '编辑',
        icon: Icons.edit,
        subItems: [
          RadialMenuItem(
            label: '复制',
            icon: Icons.copy,
            onTap: () => _showSnackBar(context, '复制'),
          ),
          RadialMenuItem(
            label: '粘贴',
            icon: Icons.paste,
            onTap: () => _showSnackBar(context, '粘贴'),
          ),
        ],
      ),
      RadialMenuItem(
        label: '视图',
        icon: Icons.visibility,
        onTap: () => _showSnackBar(context, '切换视图'),
      ),
      RadialMenuItem(
        label: '工具',
        icon: Icons.build,
        onTap: () => _showSnackBar(context, '打开工具'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('径向菜单示例'),
      ),
      body: RadialGestureMenu(
        menuItems: menuItems,
        radius: 150.0,
        centerRadius: 40.0,
        plateColor: Color(0xFF1E1E1E),
        itemColor: Color(0xFF2D2D2D),
        hoverColor: Color(0xFF404040),
        textColor: Colors.white,
        iconColor: Colors.blue,
        debugMode: false,
        onItemSelected: (item) {
          print('选择了: ${item.label}');
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mouse,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  '按住中键显示径向菜单',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
```

## 操作说明

### 基本操作

1. **显示菜单**: 在组件区域内按住鼠标中键
2. **选择项目**: 移动鼠标到目标项目上，松开中键
3. **进入子菜单**: 悬停在有子菜单的项目上会自动进入
4. **返回上级**: 移动鼠标到中心区域会返回上级菜单
5. **取消菜单**: 在中心区域松开中键会关闭菜单

### 子菜单特性

- 进入子菜单时，菜单会自动旋转，使第一个子菜单项对准鼠标位置
- 子菜单的旋转角度在进入时固定，不会随鼠标移动而改变
- 支持多级嵌套子菜单

## 自定义主题

### 深色主题

```dart
RadialGestureMenu(
  plateColor: Color(0xFF1A1A1A),
  itemColor: Color(0xFF2D2D2D),
  hoverColor: Color(0xFF404040),
  textColor: Colors.white,
  iconColor: Colors.blue,
  borderColor: Color(0xFF505050),
  // ... 其他配置
)
```

### 浅色主题

```dart
RadialGestureMenu(
  plateColor: Color(0xFFF5F5F5),
  itemColor: Color(0xFFFFFFFF),
  hoverColor: Color(0xFFE0E0E0),
  textColor: Colors.black87,
  iconColor: Colors.blue,
  borderColor: Color(0xFFCCCCCC),
  // ... 其他配置
)
```

## 注意事项

1. **性能**: 避免在菜单项过多时使用过于复杂的动画
2. **可访问性**: 确保颜色对比度符合可访问性标准
3. **响应式**: 在不同屏幕尺寸下测试菜单的可用性
4. **手势冲突**: 注意与其他手势操作的冲突

## 故障排除

### 常见问题

1. **菜单不显示**: 检查是否正确按住中键
2. **选择错误**: 确保鼠标在目标项目区域内
3. **动画卡顿**: 减少菜单项数量或简化动画
4. **颜色显示异常**: 检查颜色值是否正确

### 调试模式

启用调试模式可以在控制台查看详细信息：

```dart
RadialGestureMenu(
  debugMode: true,
  // ... 其他配置
)
```

## 更新日志

- **v1.0.0**: 初始版本，支持基本径向菜单功能
- **v1.1.0**: 添加子菜单支持和动画优化
- **v1.2.0**: 改进子菜单旋转逻辑，优化用户体验