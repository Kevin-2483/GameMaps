// Web implementation for WebDAV client
// WebDAV is not supported on web platform due to CORS restrictions

class Client {
  void setConnectTimeout(int timeout) {
    // No-op for web
  }

  void setSendTimeout(int timeout) {
    // No-op for web
  }

  void setReceiveTimeout(int timeout) {
    // No-op for web
  }

  Future<List<dynamic>> readDir(String path) {
    throw UnsupportedError(
      'WebDAV is not supported on web platform due to CORS restrictions. '
      'Please use the desktop or mobile app for WebDAV functionality.',
    );
  }

  Future<void> mkdirAll(String path) {
    throw UnsupportedError(
      'WebDAV is not supported on web platform due to CORS restrictions. '
      'Please use the desktop or mobile app for WebDAV functionality.',
    );
  }

  Future<void> writeFromFile(String localPath, String remotePath) {
    throw UnsupportedError(
      'WebDAV is not supported on web platform due to CORS restrictions. '
      'Please use the desktop or mobile app for WebDAV functionality.',
    );
  }

  Future<void> read2File(String remotePath, String localPath) {
    throw UnsupportedError(
      'WebDAV is not supported on web platform due to CORS restrictions. '
      'Please use the desktop or mobile app for WebDAV functionality.',
    );
  }

  Future<void> remove(String path) {
    throw UnsupportedError(
      'WebDAV is not supported on web platform due to CORS restrictions. '
      'Please use the desktop or mobile app for WebDAV functionality.',
    );
  }
}

Client newClient(
  String url, {
  String? user,
  String? password,
  bool debug = false,
}) {
  return Client();
}
