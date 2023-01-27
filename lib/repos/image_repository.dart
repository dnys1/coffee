import 'dart:typed_data';

import 'package:aws_common/aws_common.dart';
import 'package:coffee/services/image_cache_service.dart';
import 'package:coffee/services/image_download_service.dart';
import 'package:coffee/services/image_resize_service.dart';
import 'package:riverpod/riverpod.dart';

/// The [Provider] for [ImageRepository].
final imageRepositoryProvider = Provider<ImageRepository>(
  (ref) => _ImageRepositoryImpl(
    ref.watch(imageCacheServiceProvider),
    ref.watch(imageResizeServiceProvider),
    ref.watch(imageDownloadServiceProvider),
  ),
  name: 'ImageRepository',
);

/// A repository which provides access to images.
abstract class ImageRepository {
  /// Loads an image from the cache or downloads it.
  Future<Uint8List> loadImage(String key);

  /// Resizes an image.
  Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    required String key,
    int? width,
    int? height,
  });

  /// Saves an image to the cache.
  Future<void> saveImage(String key, Uint8List bytes);
}

class _ImageRepositoryImpl implements ImageRepository {
  const _ImageRepositoryImpl(
    this._imageCacheService,
    this._imageResizeService,
    this._imageDownloadService,
  );

  static final _logger = AWSLogger().createChild('ImageRepository');

  final ImageCacheService _imageCacheService;
  final ImageResizeService _imageResizeService;
  final ImageDownloadService _imageDownloadService;

  @override
  Future<Uint8List> loadImage(String key) async {
    var bytes = await _imageCacheService.get(key);
    if (bytes == null) {
      _logger.debug('Cache miss for $key, fetching...');
      bytes = await _imageDownloadService.download(key);
      await saveImage(key, bytes);
    }
    return bytes;
  }

  @override
  Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    required String key,
    int? width,
    int? height,
  }) =>
      _imageResizeService.resize(
        imageBytes,
        key: key,
        width: width,
        height: height,
      );

  @override
  Future<void> saveImage(String key, Uint8List bytes) =>
      _imageCacheService.put(key, bytes);
}
