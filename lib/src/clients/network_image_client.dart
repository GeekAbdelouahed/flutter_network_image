import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

abstract class BaseNetworkImageClient {
  Future<Uint8List> load(
    String url, {
    Map<String, String>? headers,
    required StreamController<ImageChunkEvent> chunkEvents,
  });
}
