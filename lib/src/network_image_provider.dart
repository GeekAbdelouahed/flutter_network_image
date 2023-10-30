import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'clients/clients.dart';

typedef RetryWhen = bool Function();

class NetworkImageProvider extends ImageProvider<NetworkImageProvider> {
  NetworkImageProvider(
    this.url, {
    this.scale = 1,
    this.retryAfter = const Duration(seconds: 1),
    this.retryWhen,
    this.headers = const {},
    BaseNetworkImageClient? httpClient,
  }) : _httpClient = httpClient ?? NetworkImageClient();

  final String url;
  final double scale;
  final Duration retryAfter;
  final RetryWhen? retryWhen;
  final Map<String, String> headers;

  final BaseNetworkImageClient _httpClient;

  @override
  Future<NetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      NetworkImageProvider key, DecoderBufferCallback decode) {
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
    DecoderBufferCallback decode,
  ) async {
    try {
      final Uint8List bytes = await _httpClient.load(url, headers: headers);
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
