import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '_html.dart' if (dart.library.io) 'dart:io' as html;
import 'network_image_client.dart';

class NetworkImageClient implements BaseNetworkImageClient {
  @override
  Future<Uint8List> load(
    String url, {
    Map<String, String>? headers,
    required StreamController<ImageChunkEvent> chunkEvents,
  }) async {
    final Completer<html.HttpRequest> completer = Completer<html.HttpRequest>();
    final html.HttpRequest request = html.HttpRequest();

    request.open('GET', url, async: true);
    request.responseType = 'arraybuffer';

    headers?.forEach((String header, String value) {
      request.setRequestHeader(header, value);
    });

    request.onLoad.listen((event) {
      final int? status = request.status;
      final bool accepted = status! >= 200 && status < 300;
      final bool fileUri = status == 0;
      final bool notModified = status == 304;
      final bool unknownRedirect = status > 307 && status < 400;
      final bool success =
          accepted || fileUri || notModified || unknownRedirect;

      if (success) {
        completer.complete(request);
      } else {
        completer.completeError(event);
        throw event;
      }
    });

    request.onProgress.listen(
      (event) {
        chunkEvents.add(
          ImageChunkEvent(
            cumulativeBytesLoaded: event.loaded ?? 0,
            expectedTotalBytes: event.total,
          ),
        );
      },
    );

    request.onError.listen(completer.completeError);

    request.send();

    await completer.future;
    return (request.response as ByteBuffer).asUint8List();
  }
}
