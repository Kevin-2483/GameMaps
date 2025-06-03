# 快速部署指南

## 简化后的部署流程

### GitHub Actions 工作流（已简化）

现在的 GitHub Actions 工作流只包含必要的步骤：

1. **检出代码** - 获取仓库代码
2. **设置 Flutter** - 安装 Flutter 环境
3. **缓存依赖** - 缓存 pub 依赖，加速构建
4. **获取依赖** - 运行 `flutter pub get`
5. **构建 Web** - 构建生产版本
6. **部署到 GitHub Pages** - 自动部署

### 本地开发流程

#### 1. 本地测试和验证
```powershell
# 代码分析
flutter analyze

# 运行测试
flutter test

# 快速构建测试（可选）
./scripts/build_only.ps1
```

#### 2. 提交和部署
```powershell
# 提交代码
git add .
git commit -m "你的提交信息"
git push

# GitHub Actions 会自动触发构建和部署
```

### 优势

✅ **更快的构建时间** - 去掉了分析和测试步骤  
✅ **更简单的流程** - 只关注构建和部署  
✅ **本地控制质量** - 在本地进行代码检查和测试  
✅ **避免部署阻塞** - 不会因为测试失败而阻止部署  

### 脚本说明

- `scripts/build_only.ps1` - 只构建，不测试的快速脚本
- `scripts/test_deployment.ps1` - 完整的测试脚本（包含分析和测试）

### GitHub Pages 设置

确保在 GitHub 仓库设置中：
1. 进入 `Settings` → `Pages`
2. 在 `Source` 下选择 `GitHub Actions`
3. 保存设置

### 访问地址

部署成功后，应用将在以下地址可用：
```
https://[你的GitHub用户名].github.io/r6box/
```

### 监控部署状态

- 在 GitHub 仓库的 `Actions` 标签页查看构建状态
- 绿色 ✅ 表示成功，红色 ❌ 表示失败
- 点击具体的工作流可以查看详细日志
