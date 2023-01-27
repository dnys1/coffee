import 'dart:typed_data';

import 'package:aws_common/aws_common.dart';
import 'package:coffee/services/image_cache_service.dart';
import 'package:coffee/workers/image_resize_worker.dart';
import 'package:riverpod/riverpod.dart';

/// The [Provider] for [ImageResizeService].
///
/// By default, this uses an [ImageResizeWorker] to resize images.
final imageResizeServiceProvider = Provider<ImageResizeService>(
  (ref) => _ImageResizeWorkerService(
    ref.watch(imageCacheServiceProvider),
  ),
  name: 'ImageResizeService',
);

/// {@template services.image_resize_service}
/// A service which resizes images.
/// {@endtemplate}
abstract class ImageResizeService {
  /// Resizes [imageBytes] to the given [width] and [height].
  Future<Uint8List> resize(
    Uint8List imageBytes, {
    required String key,
    int? width,
    int? height,
  });
}

class _ImageResizeWorkerService implements ImageResizeService {
  _ImageResizeWorkerService(this._imageCacheService);

  final ImageCacheService _imageCacheService;
  static final _logger = AWSLogger().createChild('ImageResizeWorkerService');

  Future<ImageResizeWorker> _createWorker({
    required AWSLogger logger,
  }) async {
    final worker = ImageResizeWorker.create();
    worker.logs.listen(
      (log) => logger.log(
        log.level,
        log.message,
        log.error,
        log.stackTrace,
      ),
    );
    await worker.spawn(
      jsEntrypoint: zReleaseMode ? '/assets/lib/workers/workers.min.js' : null,
    );
    return worker;
  }

  @override
  Future<Uint8List> resize(
    Uint8List imageBytes, {
    required String key,
    int? width,
    int? height,
  }) async {
    var resizedKey = 'resized';
    if (width != null) resizedKey += '_w$width';
    if (height != null) resizedKey += '_h$height';
    resizedKey += '_$key';

    final logger = _logger.createChild(key);
    final resizedImage = await _imageCacheService.get(resizedKey);
    if (resizedImage != null) {
      logger.debug('Loaded $resizedKey from cache.');
      return resizedImage;
    }

    final worker = await _createWorker(logger: logger);
    try {
      final resizedBytes = await worker.resize(
        key: key,
        bytes: imageBytes,
        width: width,
        height: height,
      );
      logger.debug('($key) Resized image. Saving to cache.');
      await _imageCacheService.put(
        resizedKey,
        resizedBytes,
      );
      logger.debug('($key) Saved resized image to cache.');
      return resizedBytes;
    } finally {
      logger.debug('($key) Disposing worker.');
      await worker.close();
    }
  }
}
