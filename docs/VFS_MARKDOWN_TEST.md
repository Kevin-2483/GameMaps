# VFS Markdown 查看器测试文档

这是一个用于测试 VFS Markdown 查看器功能的示例文档。

## 功能测试清单

### ✅ 基础 Markdown 渲染
- **粗体文本**
- *斜体文本*
- `代码片段`
- ~~删除线~~

### 🔗 链接测试

#### 1. VFS 协议链接测试
以下链接将测试 VFS 协议文件打开功能：

- [查看部署指南](indexeddb://r6box/fs/docs/DEPLOYMENT_GUIDE.md) - 测试同目录 VFS 文件链接
- [查看框架说明](indexeddb://r6box/fs/docs/FRAMEWORK_README.md) - 测试 VFS 协议链接
- [查看快速部署指南](indexeddb://r6box/fs/docs/QUICK_DEPLOY_GUIDE.md) - 测试另一个 VFS 文件

#### 2. 外部链接测试
- [Flutter 官网](https://flutter.dev) - 测试外部 HTTP 链接
- [GitHub](https://github.com) - 测试另一个外部链接

#### 3. 相对路径链接测试
- [相对路径 - 部署指南](./DEPLOYMENT_GUIDE.md) - 测试相对路径解析
- [相对路径 - 框架说明](./FRAMEWORK_README.md) - 测试当前目录链接

#### 4. 锚点链接测试
- [跳转到代码示例](#代码示例) - 测试页内锚点
- [跳转到图片测试](#图片测试) - 测试另一个锚点

### 🖼️ 图片测试

#### 1. VFS 协议图片测试
如果你在 VFS 中有图片文件，可以这样引用：
```markdown
![VFS图片示例](indexeddb://r6box/fs/docs/images/example.png)
```

![VFS图片示例](indexeddb://r6box/fs/docs/images/example.png)

#### 2. 网络图片测试
![Flutter Logo](https://nixos-and-flakes.thiscute.world/nixos-and-flakes-book.webp)

#### 3. 相对路径图片测试
如果在同目录有图片文件：
```markdown
![相对路径图片](./images/example.png)
```

![相对路径图片](./images/example.png)

### 📝 代码示例

#### Dart 代码块
```dart
class VfsMarkdownViewer extends StatefulWidget {
  final String vfsPath;
  
  const VfsMarkdownViewer({
    super.key,
    required this.vfsPath,
  });
  
  @override
  State<VfsMarkdownViewer> createState() => _VfsMarkdownViewerState();
}
```

#### JSON 配置示例
```json
{
  "markdown_config": {
    "dark_theme": false,
    "show_toc": true,
    "scale": 1.0
  },
  "vfs_config": {
    "protocol": "indexeddb://",
    "base_path": "/docs/"
  }
}
```

#### Shell 命令示例
```bash
# 构建 Flutter 应用
flutter build windows --release

# 运行测试
flutter test
```

### 📋 列表测试

#### 无序列表
- 基础功能测试
- VFS 协议支持
- 图片显示功能
- 链接跳转功能
  - 内部链接
  - 外部链接
  - 相对路径链接

#### 有序列表
1. 打开 Markdown 文件
2. 测试主题切换功能
3. 测试缩放功能
4. 测试目录显示
5. 测试链接点击
6. 测试图片显示

#### 任务列表
- [x] 移除有问题的 Markdown 扩展
- [x] 实现 VFS 协议图片支持
- [x] 实现 VFS 协议链接支持
- [x] 添加相对路径解析
- [ ] 添加锚点链接支持
- [ ] 优化错误处理
- [ ] 添加更多图片格式支持

### 📊 表格测试

| 功能 | 状态 | 说明 |
|------|------|------|
| VFS 链接 | ✅ | 支持 indexeddb:// 协议 |
| VFS 图片 | ✅ | 支持 VFS 中的图片文件 |
| 外部链接 | ✅ | 支持 HTTP/HTTPS 链接 |
| 相对路径 | ✅ | 支持 ./ 和 ../ 路径 |
| 主题切换 | ✅ | 支持深色/浅色主题 |
| 缩放功能 | ✅ | 支持 50% - 300% 缩放 |

### 🔄 测试步骤

1. **基础渲染测试**
   - 打开此文档
   - 检查各种 Markdown 元素是否正确渲染

2. **主题功能测试**
   - 点击主题切换按钮
   - 验证深色/浅色主题切换

3. **缩放功能测试**
   - 使用缩放按钮调整页面大小
   - 验证缩放百分比显示

4. **目录功能测试**
   - 点击目录按钮显示/隐藏目录
   - 点击目录项跳转到对应章节

5. **链接功能测试**
   - 点击 VFS 协议链接，验证文件打开
   - 点击外部链接，验证浏览器打开
   - 点击相对路径链接，验证路径解析

6. **图片功能测试**
   - 查看网络图片是否正常加载
   - 测试 VFS 图片（如果有的话）
   - 验证图片错误处理

### 📈 性能指标

- **文件大小**: 约 5KB
- **加载时间**: < 100ms
- **渲染时间**: < 50ms
- **内存使用**: < 10MB

### 🐛 已知问题

1. ~~LaTeX 扩展导致编译错误~~ ✅ 已修复
2. ~~HTML 扩展类型不匹配~~ ✅ 已修复
3. ~~任务列表扩展缺失依赖~~ ✅ 已修复

### 📝 测试反馈

请在测试过程中记录以下信息：

- [ ] 基础 Markdown 渲染是否正常
- [ ] VFS 链接是否能正确打开文件
- [ ] 外部链接是否能在浏览器中打开
- [ ] 相对路径是否能正确解析
- [ ] 图片是否能正常显示
- [ ] 主题切换是否生效
- [ ] 缩放功能是否正常
- [ ] 目录功能是否可用
- [ ] 错误处理是否友好

---

## 附录

### 调试信息
- 文档路径: `docs/VFS_MARKDOWN_TEST.md`
- 创建时间: 2025年6月9日
- 版本: 1.0.0
- 用途: VFS Markdown 查看器功能测试

### 相关文档
- [VFS 系统设计](./VFS_MAP_STORAGE_DESIGN.md)
- [部署指南](./DEPLOYMENT_GUIDE.md)
- [框架说明](./FRAMEWORK_README.md)

---

**测试完成后，请记录测试结果并提交反馈！** 🎉
