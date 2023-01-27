import 'dart:async';
import 'dart:typed_data';

import 'package:aws_common/aws_common.dart';
import 'package:coffee/services/http.dart';
import 'package:riverpod/riverpod.dart';

/// The [Provider] for the [ImageDownloadService].
final imageDownloadServiceProvider = Provider(
  (ref) => ImageDownloadService(
    ref.watch(httpClientProvider),
  ),
  name: 'ImageDownloadService',
);

/// {@template services.image_download_service}
/// A service which downloads images from the internet.
/// {@endtemplate}
class ImageDownloadService {
  /// {@macro services.image_download_service}
  const ImageDownloadService(this._client);

  final AWSHttpClient _client;

  /// Downloads the image at the given [url] and stores it in the cache.
  Future<Uint8List> download(String url) async {
    final request = AWSHttpRequest.get(Uri.parse(url));
    final response = await _client.send(request).response;
    if (response.statusCode != 200) {
      throw AWSHttpException(request, await response.decodeBody());
    }
    return Uint8List.fromList(await response.bodyBytes);
  }
}
