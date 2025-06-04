# GitHub Pages 部署完整配置指南

## 📋 概述

此项目已完全配置为使用 GitHub Actions 自动构建 Flutter Web 应用并部署到 GitHub Pages。

## 🚀 快速开始

### 1. 推送代码到 GitHub
```bash
git add .
git commit -m "配置 GitHub Pages 自动部署"
git push origin main
```

### 2. 启用 GitHub Pages
1. 访问您的 GitHub 仓库
2. 点击 `Settings` 标签
3. 在左侧菜单中找到 `Pages`
4. 在 `Source` 部分选择 `GitHub Actions`
5. 保存设置

### 3. 等待部署完成
- 访问 `Actions` 标签查看构建进度
- 构建成功后，应用将可通过 `https://[你的用户名].github.io/r6box/` 访问

## 📁 已创建的文件

### GitHub Actions 工作流
- `.github/workflows/deploy.yml` - 自动部署工作流
- `.github/README_DEPLOYMENT.md` - 部署说明文档

### Web 配置文件
- `web/.nojekyll` - 告诉 GitHub Pages 不使用 Jekyll
- `web/manifest.json` - 更新了 PWA 配置以支持子路径

### 测试脚本
- `scripts/test_deployment.sh` - Linux/macOS 本地测试脚本
- `scripts/test_deployment.ps1` - Windows PowerShell 本地测试脚本

## 🔧 工作流配置说明

### 触发条件
- 推送到 `main` 或 `master` 分支
- 针对 `main` 或 `master` 分支的 Pull Request
- 手动触发

### 构建步骤
1. **环境设置** - Ubuntu 最新版 + Flutter 3.24.x
2. **依赖缓存** - 缓存 pub 依赖以加速构建
3. **代码检查** - 运行 `flutter analyze` 和 `flutter test`
4. **Web 构建** - 使用 CanvasKit 渲染器构建生产版本
5. **部署** - 自动部署到 GitHub Pages

### 构建参数
```bash
flutter build web --release --base-href="/r6box/" --web-renderer canvaskit
```

## 🌐 本地测试

### Windows (PowerShell)
```powershell
./scripts/test_deployment.ps1
```

### Linux/macOS
```bash
chmod +x scripts/test_deployment.sh
./scripts/test_deployment.sh
```

### 手动测试
```bash
flutter build web --release --base-href="/r6box/" --web-renderer canvaskit
cd build/web
python -m http.server 8000
# 访问 http://localhost:8000
```

## 🔒 权限配置

工作流已配置以下权限：
- `contents: read` - 读取仓库内容
- `pages: write` - 写入 GitHub Pages
- `id-token: write` - OIDC 身份验证

## ⚙️ 高级配置

### 自定义域名
如果您有自定义域名，可以：
1. 在仓库 `Settings` > `Pages` 中设置自定义域名
2. 修改 `.github/workflows/deploy.yml` 中的 `--base-href` 参数为 `"/"`

### 环境变量
可以在 GitHub 仓库的 `Settings` > `Secrets and variables` > `Actions` 中添加环境变量。

### 分支保护
建议为 `main` 分支启用分支保护规则：
1. `Settings` > `Branches`
2. 添加规则保护 `main` 分支
3. 启用 "Require status checks to pass before merging"
4. 选择 "build" 作为必需的状态检查

## 🐛 故障排除

### 构建失败
1. 检查 Actions 日志中的错误信息
2. 确保代码通过 `flutter analyze` 和 `flutter test`
3. 验证所有依赖项在 `pubspec.yaml` 中正确配置

### 应用无法访问
1. 确认 GitHub Pages 已启用且源设置为 "GitHub Actions"
2. 检查构建是否成功完成
3. 等待 DNS 传播（可能需要几分钟）

### 资源加载失败
1. 确保 `web/.nojekyll` 文件存在
2. 验证 `manifest.json` 中的路径配置
3. 检查浏览器开发者工具的网络面板

## 📊 性能优化

### 已启用的优化
- CanvasKit 渲染器（更好的性能和兼容性）
- 生产构建优化
- 依赖缓存
- 并发控制

### 进一步优化建议
- 启用 web 压缩（在服务器层面）
- 使用 CDN 加速资源加载
- 监控 Core Web Vitals

## 📈 监控部署

### GitHub Actions
- 在 `Actions` 标签页监控构建状态
- 设置通知以接收构建失败警报

### 应用性能
- 使用 Google PageSpeed Insights 测试性能
- 使用浏览器开发者工具分析加载时间

## 🔄 更新流程

1. 开发新功能或修复 bug
2. 本地测试：`./scripts/test_deployment.ps1`
3. 提交并推送代码
4. GitHub Actions 自动构建和部署
5. 验证部署的应用

## 📞 支持

如果遇到问题：
1. 查看 GitHub Actions 构建日志
2. 检查本地构建是否正常
3. 参考 Flutter Web 部署官方文档
4. 查看 GitHub Pages 状态页面
