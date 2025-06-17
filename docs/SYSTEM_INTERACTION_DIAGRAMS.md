# R6Box 系统交互流程图

## 1. 整体数据流架构图

```mermaid
graph TB
    subgraph "用户界面层 (Main Thread)"
        UI[Flutter UI Components]
        AppShell[App Shell Layout]
        PlatformComponents[Platform Specific Components]
    end
    
    subgraph "状态管理层 (Main Thread)"
        MapDataBloc[MapDataBloc]
        MapDataState[MapDataState]
        StreamController[Stream Controllers]
    end
    
    subgraph "脚本管理层 (Main Thread)"
        ReactiveScriptEngine[NewReactiveScriptEngine]
        ScriptManager[NewReactiveScriptManager]
        FunctionHandlers[External Function Handlers]
    end
    
    subgraph "多线程执行层"
        direction TB
        ExecutorInterface[IsolatedScriptExecutor Interface]
        
        subgraph "Desktop Execution"
            DartIsolate[Dart Isolate Thread]
            HetuEngine1[Hetu Script Engine]
        end
        
        subgraph "Web Execution (Planned)"
            WebWorker[Web Worker Thread]
            HetuEngine2[Hetu Script Engine]
        end
    end
    
    subgraph "数据存储层"
        VFS[Virtual File System]
        SQLite[SQLite Database]
        LocalStorage[Local Storage]
    end
    
    %% 主要数据流
    UI -->|用户操作| MapDataBloc
    MapDataBloc -->|状态更新| UI
    MapDataBloc -->|数据变更监听| ReactiveScriptEngine
    ReactiveScriptEngine -->|执行脚本| ExecutorInterface
    ExecutorInterface -->|桌面平台| DartIsolate
    ExecutorInterface -->|Web平台| WebWorker
    FunctionHandlers -->|数据访问| MapDataBloc
    MapDataBloc -->|持久化| VFS
    
    %% 样式
    classDef mainThread fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef workerThread fill:#f1f8e9,stroke:#388e3c,stroke-width:2px
    classDef storage fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    
    class UI,AppShell,MapDataBloc,ReactiveScriptEngine mainThread
    class DartIsolate,WebWorker,HetuEngine1,HetuEngine2 workerThread
    class VFS,SQLite,LocalStorage storage
```

## 2. 响应式数据同步详细流程

```mermaid
sequenceDiagram
    participant User as 用户操作
    participant UI as UI Components
    participant Bloc as MapDataBloc
    participant Listeners as Data Change Listeners
    participant Engine as ScriptEngine
    participant Isolate as Worker Thread
    participant VFS as Virtual File System
    
    %% 用户触发数据变更
    User->>UI: 用户操作(如添加图层)
    UI->>Bloc: add(AddLayerEvent)
    
    %% Bloc处理事件
    Bloc->>Bloc: 处理事件，更新状态
    Bloc->>VFS: 持久化数据
    VFS-->>Bloc: 持久化完成
    
    %% 通知UI更新
    Bloc->>UI: emit(MapDataLoaded)
    UI->>UI: 重建Widget树
    
    %% 通知脚本引擎
    Bloc->>Listeners: 触发数据变更监听器
    Listeners->>Engine: _onMapDataChanged(data)
    Engine->>Engine: 更新数据访问器
    
    %% 如果有运行中的脚本
    opt 有脚本正在执行
        Engine->>Isolate: 发送数据更新消息
        Isolate->>Isolate: 更新脚本执行环境数据
    end
```

## 3. 脚本执行生命周期

```mermaid
stateDiagram-v2
    [*] --> ScriptCreated : 创建脚本
    
    ScriptCreated --> Initializing : 初始化执行器
    Initializing --> Ready : 执行器就绪
    Initializing --> Error : 初始化失败
    
    Ready --> Executing : 开始执行
    Executing --> FunctionCall : 调用外部函数
    FunctionCall --> Executing : 函数返回结果
    Executing --> Completed : 执行完成
    Executing --> Error : 执行错误
    Executing --> Timeout : 执行超时
    
    Completed --> [*]
    Error --> [*]
    Timeout --> [*]
    
    note right of FunctionCall
        外部函数调用通过消息传递
        在主线程执行，结果返回
        工作线程
    end note
```

## 4. 线程间通信机制

```mermaid
graph LR
    subgraph "主线程 (Main Thread)"
        direction TB
        MainUI[UI Thread]
        ScriptEngine[Script Engine]
        ExternalFunctions[External Function Handlers]
        MapDataBloc[Map Data Bloc]
    end
    
    subgraph "工作线程 (Worker Thread)"
        direction TB
        ScriptExecutor[Script Executor]
        HetuInterpreter[Hetu Interpreter]
        FunctionProxy[Function Proxy]
    end
    
    subgraph "消息传递协议"
        direction TB
        ExecuteMessage[Execute Message]
        ResultMessage[Result Message]
        FunctionCallMessage[Function Call Message]
        FunctionResponseMessage[Function Response Message]
        ErrorMessage[Error Message]
        LogMessage[Log Message]
    end
    
    %% 消息流向
    ScriptEngine -->|Send| ExecuteMessage
    ExecuteMessage -->|Receive| ScriptExecutor
    
    ScriptExecutor -->|Send| ResultMessage
    ResultMessage -->|Receive| ScriptEngine
    
    FunctionProxy -->|Send| FunctionCallMessage
    FunctionCallMessage -->|Receive| ExternalFunctions
    
    ExternalFunctions -->|Send| FunctionResponseMessage
    FunctionResponseMessage -->|Receive| FunctionProxy
    
    ScriptExecutor -->|Send| LogMessage
    LogMessage -->|Receive| ScriptEngine
    
    ScriptExecutor -->|Send| ErrorMessage
    ErrorMessage -->|Receive| ScriptEngine
```

## 5. 跨平台执行器选择流程

```mermaid
flowchart TD
    Start([开始初始化脚本执行器]) --> CheckPlatform{检查运行平台}
    
    CheckPlatform -->|kIsWeb = true| WebPath[Web 平台路径]
    CheckPlatform -->|kIsWeb = false| DesktopPath[桌面平台路径]
    
    WebPath --> WebWorkerCheck{Web Worker 是否可用?}
    WebWorkerCheck -->|是| CreateWebWorker[创建 WebWorkerScriptExecutor]
    WebWorkerCheck -->|否| FallbackWeb[使用 Isolate 占位符<br/>并显示警告]
    
    DesktopPath --> CreateIsolate[创建 IsolateScriptExecutor]
    
    CreateWebWorker --> RegisterFunctions[注册外部函数]
    CreateIsolate --> RegisterFunctions
    FallbackWeb --> RegisterFunctions
    
    RegisterFunctions --> Ready([执行器就绪])
    
    style WebWorkerCheck fill:#fff3e0
    style CreateWebWorker fill:#e8f5e8
    style CreateIsolate fill:#e8f5e8
    style FallbackWeb fill:#ffebee
```

## 6. 外部函数调用流程

```mermaid
sequenceDiagram
    participant Script as 脚本代码
    participant Proxy as Function Proxy
    participant IsolateComm as Isolate Communication
    participant MainThread as Main Thread
    participant Handler as Function Handler
    participant DataBloc as MapDataBloc
    
    Script->>Proxy: 调用外部函数 getLayers()
    Proxy->>IsolateComm: 发送函数调用消息
    IsolateComm->>MainThread: 跨线程消息传递
    MainThread->>Handler: 处理函数调用
    Handler->>DataBloc: 获取当前图层数据
    DataBloc-->>Handler: 返回图层列表
    Handler->>Handler: 转换为Map格式
    Handler-->>MainThread: 返回结果
    MainThread-->>IsolateComm: 跨线程返回结果
    IsolateComm-->>Proxy: 接收函数返回值
    Proxy-->>Script: 返回图层数据
```

## 7. 平台适配架构

```mermaid
graph TB
    subgraph "应用层"
        App[R6Box Application]
    end
    
    subgraph "平台检测层"
        PlatformDetector[Platform Detector]
        ConfigManager[Config Manager]
    end
    
    subgraph "平台组件层"
        PlatformAware[Platform Aware Component]
    end
    
    subgraph "具体平台实现"
        Windows[Windows Component<br/>- Native Windows UI<br/>- File System Access<br/>- System Tray]
        
        Web[Web Component<br/>- Progressive Web App<br/>- Browser Storage<br/>- URL Routing]
        
        Android[Android Component<br/>- Material Design<br/>- Android Permissions<br/>- Push Notifications]
        
        iOS[iOS Component<br/>- Cupertino Design<br/>- App Store Integration<br/>- iOS Notifications]
        
        macOS[macOS Component<br/>- Native macOS UI<br/>- Menu Bar Integration<br/>- Touch Bar Support]
        
        Linux[Linux Component<br/>- GTK Integration<br/>- System Tray Support<br/>- Package Management]
    end
    
    App --> PlatformDetector
    PlatformDetector --> ConfigManager
    ConfigManager --> PlatformAware
    
    PlatformAware --> Windows
    PlatformAware --> Web
    PlatformAware --> Android
    PlatformAware --> iOS
    PlatformAware --> macOS
    PlatformAware --> Linux
```

## 8. 数据持久化架构

```mermaid
graph TB
    subgraph "应用数据层"
        MapData[Map Data]
        ScriptData[Script Data]
        UserPrefs[User Preferences]
        LegendData[Legend Data]
    end
    
    subgraph "虚拟文件系统层"
        VFS[Virtual File System]
        VfsMapService[VFS Map Service]
        VfsStorageService[VFS Storage Service]
        LegendVfsService[Legend VFS Service]
    end
    
    subgraph "平台存储适配层"
        WebAdapter[Web Adapter<br/>IndexedDB + LocalStorage]
        MobileAdapter[Mobile Adapter<br/>SQLite + App Sandbox]
        DesktopAdapter[Desktop Adapter<br/>SQLite + File System]
    end
    
    subgraph "物理存储层"
        IndexedDB[(IndexedDB)]
        LocalStorageWeb[(Local Storage)]
        SQLiteMobile[(SQLite Mobile)]
        SQLiteDesktop[(SQLite Desktop)]
        FileSystem[(File System)]
    end
    
    MapData --> VFS
    ScriptData --> VFS
    UserPrefs --> VFS
    LegendData --> VFS
    
    VFS --> VfsMapService
    VFS --> VfsStorageService
    VFS --> LegendVfsService
    
    VfsMapService --> WebAdapter
    VfsMapService --> MobileAdapter
    VfsMapService --> DesktopAdapter
    
    WebAdapter --> IndexedDB
    WebAdapter --> LocalStorageWeb
    MobileAdapter --> SQLiteMobile
    DesktopAdapter --> SQLiteDesktop
    DesktopAdapter --> FileSystem
```

## 9. 错误处理和恢复机制

```mermaid
flowchart TD
    Start[脚本开始执行] --> Execute{执行脚本代码}
    
    Execute -->|成功| Success[执行成功]
    Execute -->|超时| Timeout[执行超时]
    Execute -->|异常| Exception[执行异常]
    Execute -->|语法错误| SyntaxError[语法错误]
    
    Timeout --> LogError[记录错误日志]
    Exception --> LogError
    SyntaxError --> LogError
    
    LogError --> ResetExecutor[重置脚本执行器]
    ResetExecutor --> CleanupResources[清理资源]
    CleanupResources --> NotifyUI[通知UI显示错误]
    
    Success --> ReturnResult[返回执行结果]
    ReturnResult --> UpdateLogs[更新执行日志]
    UpdateLogs --> End[结束]
    
    NotifyUI --> End
    
    style Timeout fill:#ffebee
    style Exception fill:#ffebee
    style SyntaxError fill:#ffebee
    style Success fill:#e8f5e8
```

## 10. 性能监控流程

```mermaid
graph TB
    subgraph "性能监控系统"
        Monitor[Performance Monitor]
        Collector[Metrics Collector]
        Analyzer[Performance Analyzer]
    end
    
    subgraph "监控指标"
        UIPerf[UI 性能<br/>- FPS<br/>- 渲染时间<br/>- 内存使用]
        
        ScriptPerf[脚本性能<br/>- 执行时间<br/>- 内存占用<br/>- 函数调用次数]
        
        DataPerf[数据性能<br/>- I/O 操作时间<br/>- 数据库查询时间<br/>- 网络请求时间]
    end
    
    subgraph "优化策略"
        UIOptimize[UI 优化<br/>- Widget 缓存<br/>- 差分渲染<br/>- 虚拟化列表]
        
        ScriptOptimize[脚本优化<br/>- 代码预编译<br/>- 结果缓存<br/>- 并发控制]
        
        DataOptimize[数据优化<br/>- 数据预加载<br/>- 批量操作<br/>- 缓存策略]
    end
    
    Monitor --> Collector
    Collector --> UIPerf
    Collector --> ScriptPerf
    Collector --> DataPerf
    
    Analyzer --> UIOptimize
    Analyzer --> ScriptOptimize
    Analyzer --> DataOptimize
```

---

这些流程图详细展示了 R6Box 系统中各个组件之间的交互关系，包括：

1. **数据流架构**：展示了从UI到存储的完整数据流
2. **响应式同步**：说明了数据变更如何实时同步到各个组件
3. **脚本执行**：描述了脚本从创建到执行完成的整个生命周期
4. **线程通信**：详细说明了主线程和工作线程之间的消息传递机制
5. **平台适配**：展示了如何根据不同平台选择相应的实现
6. **数据持久化**：说明了数据如何通过VFS层适配到不同平台的存储系统
7. **错误处理**：描述了系统如何处理各种异常情况
8. **性能监控**：展示了性能监控和优化的完整流程

这套架构设计确保了系统的可扩展性、可维护性和跨平台兼容性。
