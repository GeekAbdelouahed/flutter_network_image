import 'dart:async';
import 'dart:typed_data';

import '_client_web.dart'
    if (dart.library.io) 'dart:io'
    if (dart.library.html) 'dart:html' as html;
import 'base_client.dart';

class HttpClient implements BaseHttpClient {
  @override
  Future<Uint8List> load(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    final Completer<html.HttpRequest> completer = Completer<html.HttpRequest>();
    final html.HttpRequest request = html.HttpRequest();

    request.open('GET', url, async: true);
    request.responseType = 'arraybuffer';

    headers.forEach((String header, String value) {
      request.setRequestHeader(header, value);
    });

    request.onLoad.listen((event) {
      final int? status = request.status;
      final bool accepted = status! >= 200 && status < 300;
      final bool fileUri = status == 0; // file:// URIs have status of 0.
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

    request.onError.listen(completer.completeError);

    request.send();

    await completer.future;

    return (request.response as ByteBuffer).asUint8List();
  }
}
