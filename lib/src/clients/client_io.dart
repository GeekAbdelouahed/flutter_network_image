import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/widgets.dart';

import 'base_client.dart';

class HttpClient implements BaseHttpClient {
  final io.HttpClient _httpClient = io.HttpClient()..autoUncompress = false;

  @override
  Future<Uint8List> load(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    try {
      final Uri resolved = Uri.base.resolve(url);
      final io.HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers.forEach((String name, String value) {
        request.headers.add(name, value);
      });

      final io.HttpClientResponse response = await request.close();

      if (response.statusCode != io.HttpStatus.ok) {
        throw NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: resolved,
        );
      }

      return foundation.consolidateHttpClientResponseBytes(response);
    } catch (e) {
      rethrow;
    }
  }
}
