import 'dart:typed_data';

abstract class BaseNetworkImageClient {
  Future<Uint8List> load(
    String url, {
    Map<String, String>? headers,
  });
}
