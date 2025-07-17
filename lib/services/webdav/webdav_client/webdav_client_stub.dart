// Stub implementation for WebDAV client
// This file should never be used in practice

class Client {
  static Client newClient(
    String url, {
    String? user,
    String? password,
    bool debug = false,
  }) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  void setConnectTimeout(int timeout) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  void setSendTimeout(int timeout) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  void setReceiveTimeout(int timeout) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  Future<List<dynamic>> readDir(String path) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  Future<void> mkdirAll(String path) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  Future<void> writeFromFile(String localPath, String remotePath) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  Future<void> read2File(String remotePath, String localPath) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }

  Future<void> remove(String path) {
    throw UnsupportedError('WebDAV client is not supported on this platform');
  }
}

Client newClient(
  String url, {
  String? user,
  String? password,
  bool debug = false,
}) {
  throw UnsupportedError('WebDAV client is not supported on this platform');
}