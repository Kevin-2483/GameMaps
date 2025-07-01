# Squadron 集成说明

## 1. 添加依赖到 pubspec.yaml

```yaml
dependencies:
  squadron: ^7.1.1
  # ...其他依赖

dev_dependencies:
  squadron_builder: ^7.1.1
  build_runner: ^2.4.7
  # ...其他开发依赖
```

## 2. 生成 Squadron Worker 代码

运行以下命令生成 Squadron Worker 代码：

```bash
dart pub get
dart run build_runner build
```

这将生成以下文件：
- `script_worker_service.worker.g.dart` - Worker 实现
- `script_worker_service.activator.g.dart` - Worker 激活器

## 3. 编译 Web Workers（关键步骤！）

**重要：对于Web平台，必须编译Worker代码为JavaScript或WebAssembly：**

```bash
# 编译为JavaScript
dart compile js "lib/services/scripting/squadron/script_worker_service.worker.g.dart" -o "web/workers/script_worker_service.worker.g.dart.js"

# 或编译为WebAssembly
dart compile wasm "lib/services/scripting/squadron/script_worker_service.worker.g.dart" -o "web/workers/script_worker_service.worker.g.dart.wasm"

# 或同时编译两种格式（推荐）
dart compile js "lib/services/scripting/squadron/script_worker_service.worker.g.dart" -o "web/workers/script_worker_service.worker.g.dart.js"
dart compile wasm "lib/services/scripting/squadron/script_worker_service.worker.g.dart" -o "web/workers/script_worker_service.worker.g.dart.wasm"
```

## 4. 创建web/workers目录结构

确保web目录下有以下结构：
```
web/
├── workers/
│   ├── script_worker_service.worker.g.dart.js
│   └── script_worker_service.worker.g.dart.wasm
├── index.html
└── ...
```

## 5. 更新工厂类

生成和编译代码后，需要在 `squadron_concurrent_web_worker_script_executor.dart` 中：

1. 导入生成的 Worker 类：
```dart
import 'script_worker_service.worker.g.dart';
```

2. 更新 `_createWorkerInstance` 方法：
```dart
Future<_SquadronWorkerInstance> _createWorkerInstance(int workerId) async {
  final worker = ScriptWorkerServiceWorker();
  await worker.start();
  final initialized = await worker.initialize();
  if (!initialized) {
    throw Exception('Failed to initialize Hetu engine in worker $workerId');
  }
  return _SquadronWorkerInstance(id: workerId, worker: worker);
}
```

3. 更新 `_SquadronWorkerInstance` 类：
```dart
class _SquadronWorkerInstance {
  final int id;
  final ScriptWorkerServiceWorker worker;
  bool isBusy = false;
  String? currentTaskId;
  // ...
}
```

## 6. 部署注意事项

### 开发环境
确保 `flutter run -d chrome` 或本地开发服务器能够访问 `web/workers/` 下的编译文件。

### 生产环境
确保Web服务器正确配置：
- 设置正确的MIME类型：
  - `.js` 文件: `application/javascript`
  - `.wasm` 文件: `application/wasm`
- 启用CORS如果需要跨域访问
- 配置正确的Content-Security-Policy允许Worker加载

## 7. 构建脚本

可以创建构建脚本自动化这个过程：

```bash
#!/bin/bash
# build_squadron.sh

echo "生成Squadron代码..."
dart run build_runner build

echo "编译Web Workers..."
dart compile js "lib/services/scripting/squadron/script_worker_service.worker.g.dart" -o "web/workers/script_worker_service.worker.g.dart.js"
dart compile wasm "lib/services/scripting/squadron/script_worker_service.worker.g.dart" -o "web/workers/script_worker_service.worker.g.dart.wasm"

echo "Squadron构建完成！"
```

## 8. 测试 Squadron 执行器

可以通过以下方式使用新的 Squadron 执行器：

```dart
// 创建 Squadron 并发执行器
final executor = ScriptExecutorFactory.create(
  type: ScriptExecutorType.squadronConcurrentWebWorker,
  workerPoolSize: 4,
);

// 使用方式与其他执行器相同
final result = await executor.execute(scriptCode);
```

## 9. 性能优势

Squadron 执行器相比 isolate_manager 的优势：
- 真正的双向通信支持
- 更好的类型安全
- 更简洁的API
- 更完善的错误处理
- 自动生成的Worker代码减少手工错误
- 支持JavaScript和WebAssembly两种编译目标

## 注意事项

1. **编译步骤是必须的**：Web平台必须编译Worker代码
2. **路径配置**：确保 `baseUrl: '~/workers'` 与实际部署路径匹配
3. **类型安全**：复杂对象需要实现序列化/反序列化
4. **错误调试**：编译后的代码调试可能比较困难，建议充分测试

## 常见问题

**Q: Worker文件404错误？**
A: 检查编译是否成功，文件是否部署到正确路径

**Q: Worker无法启动？**
A: 检查浏览器控制台错误，通常是路径或CORS问题

**Q: 类型转换错误？**
A: 在Web平台上，复杂对象可能需要自定义Marshaler
