import 'dart:typed_data';

abstract class BaseHttpClient {
  Future<Uint8List> load(
    String url, {
    Map<String, String> headers = const {},
  });
}
