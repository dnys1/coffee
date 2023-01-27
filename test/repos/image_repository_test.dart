import 'dart:typed_data';

import 'package:aws_common/aws_common.dart';
import 'package:aws_common/testing.dart';
import 'package:coffee/repos/image_repository.dart';
import 'package:coffee/services/http.dart';
import 'package:coffee/services/image_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class InMemoryImageCacheService implements ImageCacheService {
  final _cache = <String, Uint8List>{};

  @override
  Future<Uint8List?> get(String key) async => _cache[key];

  @override
  Future<void> put(String key, Uint8List imageBytes) async =>
      _cache[key] = imageBytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageRepository', () {
    late ProviderContainer ref;

    setUp(() {
      ref = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWithValue(
            MockAWSHttpClient(
              (request, _) => AWSHttpResponse(statusCode: 500),
            ),
          ),
          imageCacheServiceProvider.overrideWithValue(
            InMemoryImageCacheService(),
          ),
        ],
      );
    });

    tearDown(() => ref.dispose());

    test('returns cached image when image is in cache', () async {
      const key = 'https://example.com/image1.jpg';
      const bytes = [1, 2, 3, 4, 5];
      await ref.read(imageCacheServiceProvider).put(
            key,
            Uint8List.fromList(bytes),
          );

      final imageRepository = ref.read(imageRepositoryProvider);
      final response = await imageRepository.loadImage(key);
      expect(response, bytes);
    });

    test('loads and caches image when not cached', () async {
      const key = 'https://example.com/image1.jpg';
      const bytes = [1, 2, 3, 4, 5];
      ref = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWithValue(
            MockAWSHttpClient(
              (request, _) => AWSHttpResponse(
                statusCode: 200,
                body: bytes,
              ),
            ),
          ),
          imageCacheServiceProvider.overrideWithValue(
            InMemoryImageCacheService(),
          ),
        ],
      );

      final imageRepository = ref.read(imageRepositoryProvider);
      final response = await imageRepository.loadImage(key);
      expect(response, bytes);
      expect(
        ref.read(imageCacheServiceProvider).get(key),
        completion(equals(bytes)),
      );
    });

    test(
      'throws when image is not in cache and could not be retrieved',
      () async {
        const key = 'https://example.com/image1.jpg';
        final imageRepository = ref.read(imageRepositoryProvider);
        expect(
          imageRepository.loadImage(key),
          throwsA(isA<AWSHttpException>()),
        );
      },
    );
  });
}
