// IO implementation for WebDAV client (non-web platforms)
import 'package:webdav_client/webdav_client.dart' as webdav;

// Re-export the webdav client types and functions
typedef Client = webdav.Client;

Client newClient(
  String url, {
  String? user,
  String? password,
  bool debug = false,
}) {
  return webdav.newClient(
    url,
    user: user ?? '',
    password: password ?? '',
    debug: debug,
  );
}