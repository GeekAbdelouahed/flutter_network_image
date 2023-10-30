import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'network_image_client.dart';

class NetworkImageClient implements BaseNetworkImageClient {
  const NetworkImageClient();

  @override
  Future<Uint8List> load(
    String url, {
    Map<String, String>? headers,
    required StreamController<ImageChunkEvent> chunkEvents,
  }) async {
    try {
      final Stream<FileResponse> streamResponse =
          DefaultCacheManager().getImageFile(
        url,
        key: url,
        headers: headers,
        withProgress: true,
      );

      await for (final FileResponse response in streamResponse) {
        if (response is DownloadProgress) {
          chunkEvents.add(
            ImageChunkEvent(
              cumulativeBytesLoaded: response.downloaded,
              expectedTotalBytes: response.totalSize,
            ),
          );
        }
        if (response is FileInfo) {
          return response.file.readAsBytes();
        }
      }
    } catch (e) {
      rethrow;
    }
    throw NetworkImageLoadException(
      statusCode: 404,
      uri: Uri.parse(url),
    );
  }
}
