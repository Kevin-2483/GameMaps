// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_worker_service.dart';

// **************************************************************************
// Generator: WorkerGenerator 7.1.4 (Squadron 7.1.1)
// **************************************************************************

/// Command ids used in operations map
const int _$executeScriptId = 1;
const int _$getExternalFunctionCallsId = 2;
const int _$handleExternalFunctionResponseId = 3;
const int _$initializeId = 4;
const int _$stopWorkerId = 5;
const int _$updateMapDataId = 6;

/// WorkerService operations for ScriptWorkerService
extension on ScriptWorkerService {
  OperationsMap _$getOperations() => OperationsMap({
    _$executeScriptId: ($req) {
      final Stream<String> $res;
      try {
        final $dsr = _$Deser(contextAware: false);
        $res = executeScript($dsr.$0($req.args[0]));
      } finally {}
      return $res;
    },
    _$getExternalFunctionCallsId: ($req) => getExternalFunctionCalls(),
    _$handleExternalFunctionResponseId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return handleExternalFunctionResponse($dsr.$0($req.args[0]));
    },
    _$initializeId: ($req) => initialize(),
    _$stopWorkerId: ($req) => stopWorker(),
    _$updateMapDataId: ($req) {
      final $dsr = _$Deser(contextAware: false);
      return updateMapData($dsr.$0($req.args[0]));
    },
  });
}

/// Invoker for ScriptWorkerService, implements the public interface to invoke the
/// remote service.
base mixin _$ScriptWorkerService$Invoker on Invoker
    implements ScriptWorkerService {
  @override
  Stream<String> executeScript(String requestJson) {
    final Stream $res = stream(_$executeScriptId, args: [requestJson]);
    try {
      final $dsr = _$Deser(contextAware: false);
      return $res.map($dsr.$0);
    } finally {}
  }

  @override
  Stream<String> getExternalFunctionCalls() {
    final Stream $res = stream(_$getExternalFunctionCallsId);
    try {
      final $dsr = _$Deser(contextAware: false);
      return $res.map($dsr.$0);
    } finally {}
  }

  @override
  Future<void> handleExternalFunctionResponse(String responseJson) =>
      send(_$handleExternalFunctionResponseId, args: [responseJson]);

  @override
  Future<bool> initialize() async {
    final dynamic $res = await send(_$initializeId);
    try {
      final $dsr = _$Deser(contextAware: false);
      return $dsr.$1($res);
    } finally {}
  }

  @override
  Future<void> stopWorker() => send(_$stopWorkerId);

  @override
  Future<void> updateMapData(String mapDataJson) =>
      send(_$updateMapDataId, args: [mapDataJson]);
}

/// Facade for ScriptWorkerService, implements other details of the service unrelated to
/// invoking the remote service.
base mixin _$ScriptWorkerService$Facade implements ScriptWorkerService {
  @override
  Future<dynamic> _callExternalFunction(
    String executionId,
    String functionName,
    List<dynamic> arguments,
  ) => throw UnimplementedError();

  @override
  dynamic _serializeResult(dynamic result) => throw UnimplementedError();

  @override
  // ignore: unused_element
  Hetu? get _hetuEngine => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _hetuEngine(void $value) => throw UnimplementedError();

  @override
  // ignore: unused_element
  Map<String, dynamic> get _currentMapData => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _currentMapData(void $value) => throw UnimplementedError();

  @override
  // ignore: unused_element
  Map<String, Completer<dynamic>> get _pendingExternalCalls =>
      throw UnimplementedError();

  @override
  // ignore: unused_element
  StreamController<String> get _externalCallController =>
      throw UnimplementedError();
}

/// WorkerService class for ScriptWorkerService
base class _$ScriptWorkerService$WorkerService extends ScriptWorkerService
    implements WorkerService {
  _$ScriptWorkerService$WorkerService() : super();

  @override
  OperationsMap get operations => _$getOperations();
}

/// Service initializer for ScriptWorkerService
WorkerService $ScriptWorkerServiceInitializer(WorkerRequest $req) =>
    _$ScriptWorkerService$WorkerService();

/// Worker for ScriptWorkerService
base class ScriptWorkerServiceWorker extends Worker
    with _$ScriptWorkerService$Invoker, _$ScriptWorkerService$Facade
    implements ScriptWorkerService {
  ScriptWorkerServiceWorker({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : super(
         $ScriptWorkerServiceActivator(Squadron.platformType),
         threadHook: threadHook,
         exceptionManager: exceptionManager,
       );

  ScriptWorkerServiceWorker.js({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : super(
         $ScriptWorkerServiceActivator(SquadronPlatformType.js),
         threadHook: threadHook,
         exceptionManager: exceptionManager,
       );

  ScriptWorkerServiceWorker.wasm({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
  }) : super(
         $ScriptWorkerServiceActivator(SquadronPlatformType.wasm),
         threadHook: threadHook,
         exceptionManager: exceptionManager,
       );

  @override
  List? getStartArgs() => null;
}

/// Worker pool for ScriptWorkerService
base class ScriptWorkerServiceWorkerPool
    extends WorkerPool<ScriptWorkerServiceWorker>
    with _$ScriptWorkerService$Facade
    implements ScriptWorkerService {
  ScriptWorkerServiceWorkerPool({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : super(
         (ExceptionManager exceptionManager) => ScriptWorkerServiceWorker(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
         concurrencySettings: concurrencySettings,
         exceptionManager: exceptionManager,
       );

  ScriptWorkerServiceWorkerPool.js({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : super(
         (ExceptionManager exceptionManager) => ScriptWorkerServiceWorker.js(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
         concurrencySettings: concurrencySettings,
         exceptionManager: exceptionManager,
       );

  ScriptWorkerServiceWorkerPool.wasm({
    PlatformThreadHook? threadHook,
    ExceptionManager? exceptionManager,
    ConcurrencySettings? concurrencySettings,
  }) : super(
         (ExceptionManager exceptionManager) => ScriptWorkerServiceWorker.wasm(
           threadHook: threadHook,
           exceptionManager: exceptionManager,
         ),
         concurrencySettings: concurrencySettings,
         exceptionManager: exceptionManager,
       );

  @override
  Stream<String> executeScript(String requestJson) =>
      stream((w) => w.executeScript(requestJson));

  @override
  Stream<String> getExternalFunctionCalls() =>
      stream((w) => w.getExternalFunctionCalls());

  @override
  Future<void> handleExternalFunctionResponse(String responseJson) =>
      execute((w) => w.handleExternalFunctionResponse(responseJson));

  @override
  Future<bool> initialize() => execute((w) => w.initialize());

  @override
  Future<void> stopWorker() => execute((w) => w.stopWorker());

  @override
  Future<void> updateMapData(String mapDataJson) =>
      execute((w) => w.updateMapData(mapDataJson));
}

final class _$Deser extends MarshalingContext {
  _$Deser({super.contextAware});
  late final $0 = value<String>();
  late final $1 = value<bool>();
}
