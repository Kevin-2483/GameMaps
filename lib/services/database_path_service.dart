// 条件导入：Web平台使用Web实现，其他平台使用存根实现
export 'database_path_service_stub.dart'
    if (dart.library.html) 'database_path_service_web.dart';
