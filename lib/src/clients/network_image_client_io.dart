import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/widgets.dart';

import 'network_image_client.dart';

class NetworkImageClient implements BaseNetworkImageClient {
  final HttpClient _httpClient = HttpClient()..autoUncompress = false;

  final Duration _timeout = const Duration(seconds: 5);

  @override
  Future<Uint8List> load(
    String url, {
    Map<String, String>? headers,
    required StreamController<ImageChunkEvent> chunkEvents,
  }) async {
    try {
      final Uri resolved = Uri.base.resolve(url);
      final HttpClientRequest request =
          await _httpClient.getUrl(resolved).timeout(_timeout);

      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });

      final HttpClientResponse response =
          await request.close().timeout(_timeout);

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: resolved,
        );
      }

      return foundation.consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) async {
          chunkEvents.add(
            ImageChunkEvent(
              cumulativeBytesLoaded: cumulative,
              expectedTotalBytes: total,
            ),
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
