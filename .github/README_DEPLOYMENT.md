# GitHub Actions 部署配置说明

## 配置概述

此项目已配置为使用 GitHub Actions 自动编译 Flutter Web 应用并部署到 GitHub Pages。

## 文件说明

### `.github/workflows/deploy.yml`
GitHub Actions 工作流文件，负责：
- 检出代码
- 设置 Flutter 环境
- 获取依赖项
- 分析代码
- 运行测试
- 构建 Web 应用
- 部署到 GitHub Pages

### `web/.nojekyll`
告诉 GitHub Pages 不要使用 Jekyll 处理静态文件，这对 Flutter Web 应用是必需的。

## 部署配置步骤

### 1. 仓库设置
1. 在 GitHub 仓库中，转到 `Settings` > `Pages`
2. 在 `Source` 下选择 `GitHub Actions`
3. 保存设置

### 2. 分支配置
确保您的主分支名称是 `main` 或 `master`（工作流已配置为监听这两个分支）。

### 3. 权限设置
工作流已配置了必要的权限：
- `contents: read` - 读取仓库内容
- `pages: write` - 写入 Pages
- `id-token: write` - 身份验证

## 访问应用

部署成功后，您的应用将可以通过以下 URL 访问：
```
https://[你的用户名].github.io/r6box/
```

## 自动触发条件

部署将在以下情况下自动触发：
- 推送到 `main` 或 `master` 分支
- 创建针对 `main` 或 `master` 分支的 Pull Request
- 手动触发（在 Actions 标签页中）

## 构建配置

Web 应用使用以下配置构建：
- `--release` 模式（生产优化）
- `--base-href="/r6box/"` 子路径配置

## 故障排除

### 如果部署失败：
1. 检查 Actions 标签页中的构建日志
2. 确保所有依赖项在 `pubspec.yaml` 中正确配置
3. 确保代码通过 `flutter analyze` 和 `flutter test`

### 如果应用无法加载：
1. 检查浏览器开发者工具的控制台错误
2. 确保 `.nojekyll` 文件存在于 `web` 目录中
3. 验证 GitHub Pages 设置中的源配置

## 本地测试

在推送之前，您可以本地测试 Web 构建：

```bash
flutter build web --release --base-href="/r6box/"
cd build/web
python -m http.server 8000
```

然后访问 `http://localhost:8000`
