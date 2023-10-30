import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'clients/clients.dart';

typedef RetryWhen = bool Function(Duration totalDuration);

class NetworkImageProvider extends ImageProvider<NetworkImageProvider> {
  NetworkImageProvider(
    this.url, {
    this.scale = 1,
    this.retryAfter = const Duration(seconds: 1),
    this.retryWhen,
    this.headers,
    BaseNetworkImageClient? httpClient,
  }) : _httpClient = httpClient ?? NetworkImageClient();

  final String url;
  final double scale;
  final Duration retryAfter;
  final RetryWhen? retryWhen;
  final Map<String, String>? headers;

  final BaseNetworkImageClient _httpClient;

  Duration _totalDuration = Duration.zero;

  @override
  Future<NetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    NetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAndRetry(key, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: scale,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<NetworkImageProvider>('Image provider', this),
        DiagnosticsProperty<NetworkImageProvider>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAndRetry(
    NetworkImageProvider provider,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    try {
      final Uint8List bytes = await _httpClient.load(
        url,
        headers: headers,
        chunkEvents: chunkEvents,
      );
      return ui.instantiateImageCodec(bytes);
    } catch (e) {
      if (retryWhen?.call(_totalDuration) ?? false) {
        return Future.delayed(
          retryAfter,
          () {
            _totalDuration += retryAfter;
            return _loadAndRetry(provider, chunkEvents);
          },
        );
      } else {
        rethrow;
      }
    }
  }
}
