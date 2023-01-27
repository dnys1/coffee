import 'dart:typed_data';

import 'package:aws_common/aws_common.dart';
import 'package:coffee/database/database.dart';
import 'package:riverpod/riverpod.dart';

/// A service which provides access to the image cache.
final imageCacheServiceProvider = Provider<ImageCacheService>(
  (ref) => _DriftImageCacheService(ref.watch(databaseProvider)),
  name: 'imageCacheService',
);

/// A service which provides access to the local image cache.
abstract class ImageCacheService {
  /// Gets the value for the given [id].
  Future<Uint8List?> get(String id);

  /// Sets the [value] for the given [id], overwriting any existing value.
  Future<void> put(String id, Uint8List value);
}

class _DriftImageCacheService implements ImageCacheService {
  _DriftImageCacheService(this._database);

  static final _logger = AWSLogger().createChild('DriftImageCacheService');

  final CoffeeDatabase _database;

  @override
  Future<Uint8List?> get(String key) async {
    _logger.debug('Loading $key from database...');
    final bytes = await _database.loadImage(key);
    _logger.debug('Loaded $key from database: ${bytes != null}');
    return bytes;
  }

  @override
  Future<void> put(String key, Uint8List imageBytes) async {
    _logger.debug('Saving $key to database...');
    await _database.saveImage(key, imageBytes);
    _logger.debug('Saved $key to database.');
  }
}
