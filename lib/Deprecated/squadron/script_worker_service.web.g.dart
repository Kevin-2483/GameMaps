// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: WorkerGenerator 7.1.4 (Squadron 7.1.1)
// **************************************************************************

import 'package:squadron/squadron.dart';

import 'script_worker_service.dart';

void main() {
  /// Web entry point for ScriptWorkerService
  run($ScriptWorkerServiceInitializer);
}

EntryPoint $getScriptWorkerServiceActivator(SquadronPlatformType platform) {
  if (platform.isJs) {
    return Squadron.uri('~/workers/script_worker_service.web.g.dart.js');
  } else if (platform.isWasm) {
    return Squadron.uri('~/workers/script_worker_service.web.g.dart.wasm');
  } else {
    throw UnsupportedError('${platform.label} not supported.');
  }
}
