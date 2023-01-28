import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'clients/base_client.dart';
import 'clients/client_io.dart' if (dart.library.html) 'http_client_web.dart'
    as client;

typedef RetryWhen = bool Function();

class NetworkImageProvider extends ImageProvider<NetworkImageProvider> {
  NetworkImageProvider(
    this.url, {
    this.scale = 1,
    this.retryAfter = const Duration(seconds: 1),
    this.retryWhen,
    BaseHttpClient? httpClient,
  }) : _httpClient = httpClient ?? client.HttpClient();

  final String url;
  final double scale;
  final Duration retryAfter;
  final RetryWhen? retryWhen;

  final BaseHttpClient _httpClient;

  @override
  Future<NetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(NetworkImageProvider key, DecoderCallback decode) {
    return OneFrameImageStreamCompleter(
      _loadAndRetry(key, decode),
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<NetworkImageProvider>('Image provider', this),
        DiagnosticsProperty<NetworkImageProvider>('Image key', key),
      ],
    );
  }

  Future<ImageInfo> _loadAndRetry(
    NetworkImageProvider provider,
    DecoderCallback decode,
  ) async {
    try {
      final Uint8List bytes = await _httpClient.load(url);
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      return ImageInfo(
        image: frameInfo.image,
        scale: scale,
        debugLabel: url,
      );
    } catch (e) {
      if (retryWhen?.call() ?? false) {
        return Future.delayed(
          retryAfter,
          () => _loadAndRetry(provider, decode),
        );
      } else {
        rethrow;
      }
    }
  }
}
