import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_network_image/src/attempt.dart';

import 'clients/clients.dart';

typedef RetryWhen = bool Function(Attempt attempt);

class NetworkImageProvider extends ImageProvider<NetworkImageProvider> {
  const NetworkImageProvider(
    this.url, {
    this.scale = 1,
    this.retryAfter = const Duration(seconds: 1),
    this.retryWhen,
    this.headers,
    this.httpClient = const NetworkImageClient(),
  });

  /// The URL of the image to be loaded.
  final String url;

  /// The scale factor to be applied to the image. A value of 1.0 represents the original size.
  final double scale;

  /// The duration to wait before retrying a failed image load.
  final Duration retryAfter;

  /// A callback function that determines whether to retry after a failed.
  final RetryWhen? retryWhen;

  /// Optional headers to be sent with the HTTP request.
  final Map<String, String>? headers;

  /// Optional custom HTTP client. If not provided, the default client is used.
  final BaseNetworkImageClient httpClient;

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
      codec: _loadAndRetry(
        key,
        chunkEvents,
        decode,
        startedAt: DateTime.now(),
      ),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<NetworkImageProvider>('Image provider', this),
        DiagnosticsProperty<NetworkImageProvider>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAndRetry(
    NetworkImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode, {
    required DateTime startedAt,
    int attemptsCounter = 0,
  }) async {
    try {
      final Uint8List bytes = await httpClient.load(
        url,
        headers: headers,
        chunkEvents: chunkEvents,
      );
      final ui.ImmutableBuffer buffer =
          await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      final Attempt attempt = Attempt(
        totalDuration: DateTime.now().difference(startedAt),
        counter: attemptsCounter,
      );
      final bool canRetry = retryWhen?.call(attempt) ?? false;
      if (canRetry) {
        return Future.delayed(
          retryAfter,
          () => _loadAndRetry(
            key,
            chunkEvents,
            decode,
            startedAt: startedAt,
            attemptsCounter: attemptsCounter + 1,
          ),
        );
      } else {
        rethrow;
      }
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NetworkImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImageProvider')}("$url", scale: $scale)';
}
