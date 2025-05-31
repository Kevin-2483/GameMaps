# 图例选择验证功能测试

## 实现的功能

已实现图例项选择验证规则，限制用户只能在满足以下条件时选择图例项：

1. **图例组可见性**：图例组必须是可见状态
2. **图层选择状态**：至少有一个绑定到该图例组的图层被选中

## 验证位置

### 1. LegendGroupManagementDrawer（图例管理抽屉）
- **文件**：`lib/pages/map_editor/widgets/legend_group_management_drawer.dart`
- **方法**：`_selectLegendItem()` 
- **验证逻辑**：`_canSelectLegendItem()`
- **用户反馈**：弹出对话框显示具体的限制原因

### 2. MapCanvas（地图画布）
- **文件**：`lib/pages/map_editor/widgets/map_canvas.dart`
- **方法**：`_onLegendTap()` 和 `_onLegendDoubleTap()`
- **验证逻辑**：`_canSelectLegendItem()`
- **用户反馈**：SnackBar 显示限制消息

## 验证逻辑详情

### 核心验证函数：`_canSelectLegendItem()`

1. **查找图例组**：根据图例项ID找到对应的图例组
2. **检查可见性**：图例组的 `isVisible` 属性必须为 `true`
3. **获取绑定图层**：找到所有 `legendGroupIds` 包含该图例组ID的图层
4. **检查图层选择**：验证当前选中的图层是否在绑定图层列表中

### 错误消息

- **图例组不可见**：`"无法选择图例：图例组当前不可见，请先显示图例组"`
- **无选中绑定图层**：`"无法选择图例：请先选择一个绑定了此图例组的图层"`

## 测试场景

### 场景1：图例组不可见
1. 隐藏图例组（点击眼睛图标）
2. 尝试在管理抽屉中点击图例项
3. **预期结果**：显示对话框，提示图例组不可见

### 场景2：无绑定图层被选中
1. 确保图例组可见
2. 选择一个未绑定该图例组的图层（或不选择任何图层）
3. 尝试点击或双击地图上的图例项
4. **预期结果**：显示SnackBar，提示需要选择绑定图层

### 场景3：正常选择
1. 确保图例组可见
2. 选择一个绑定了该图例组的图层
3. 点击或双击图例项
4. **预期结果**：正常选择/打开管理抽屉

## 代码变更总结

### LegendGroupManagementDrawer
- 添加 `selectedLayer` 参数接收当前选中图层
- 重写 `_selectLegendItem()` 方法，添加验证逻辑
- 新增 `_canSelectLegendItem()` 验证函数
- 新增 `_showSelectionNotAllowedDialog()` 用户反馈

### MapCanvas
- 重写 `_onLegendTap()` 和 `_onLegendDoubleTap()` 方法
- 新增 `_canSelectLegendItem()` 验证函数（独立实现）
- 新增 `_showLegendSelectionNotAllowedMessage()` 用户反馈

### MapEditorPage
- 在 `LegendGroupManagementDrawer` 构造函数中传递 `selectedLayer`

## 兼容性保证

- 当 `allLayers` 为空时，允许选择（向后兼容）
- 当图例组无绑定图层时，允许选择
- 保持原有的API接口不变
