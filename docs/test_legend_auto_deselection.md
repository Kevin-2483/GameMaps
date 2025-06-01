# 图例自动取消选择功能测试

## 功能描述
当切换到其他图层时，如果当前选择的图例项与新选择的图层没有绑定关系，图例应该自动取消选择。

## 实现的修改

### 1. MapEditorPage 修改
- 在 `onLayerSelected` 回调中添加了 `_clearIncompatibleLegendSelection()` 调用
- 新增 `_clearIncompatibleLegendSelection()` 方法，用于检查和清除不兼容的图例选择

### 2. LegendGroupManagementDrawer 修改
- 在 `didUpdateWidget` 方法中添加了图层选择变化的检测
- 新增 `clearIncompatibleLegendSelection()` 方法，用于清除抽屉中的图例选择
- 在图层变化和图层列表变化时自动调用清除方法

## 测试场景

### 场景1：基本自动取消选择
1. 创建两个图层：图层A 和 图层B
2. 创建一个图例组，只绑定到图层A
3. 选择图层A，然后选择图例组中的一个图例项
4. 切换到图层B
5. **预期结果**：图例项应该自动取消选择

### 场景2：图例组可见性变化
1. 选择一个图例项
2. 将图例组设置为不可见
3. **预期结果**：图例项应该自动取消选择

### 场景3：多图层绑定情况
1. 创建图层A、B、C
2. 创建图例组，绑定到图层A和图层B
3. 选择图层A，选择图例项
4. 切换到图层B
5. **预期结果**：图例项应该保持选中（因为图层B也绑定了该图例组）
6. 切换到图层C
7. **预期结果**：图例项应该自动取消选择（因为图层C没有绑定该图例组）

### 场景4：无绑定图例组
1. 创建图例组，不绑定任何图层
2. 选择任意图层，选择图例项
3. 切换到其他图层
4. **预期结果**：图例项应该保持选中（因为没有绑定限制）

## 技术实现细节

### 主要逻辑流程
1. 用户切换图层 → LayerPanel.onLayerSelected()
2. MapEditorPage.onLayerSelected() → setState() + _clearIncompatibleLegendSelection()
3. _clearIncompatibleLegendSelection() 执行以下检查：
   - 是否有选中的图例项
   - 查找包含该图例项的图例组
   - 检查图例组是否可见
   - 检查新选中的图层是否绑定了该图例组
   - 如果检查失败，清除图例选择

### LegendGroupManagementDrawer 同步
- 通过 didUpdateWidget 监听图层变化
- 调用 clearIncompatibleLegendSelection() 清除内部状态
- 通过回调通知父组件状态变化

## 边界情况处理
- 没有选中图例项时：直接返回，不执行任何操作
- 没有当前地图或图例组时：直接返回
- 找不到对应图例组时：清除选择
- 图例组不可见时：清除选择
- 没有选中图层时：清除选择
- 图例组没有绑定任何图层时：保持选择（向后兼容）

## 性能考虑
- 使用 WidgetsBinding.instance.addPostFrameCallback 避免在build期间调用setState
- 只在图层真正变化时执行检查，避免不必要的计算
- 提前返回减少不必要的处理
