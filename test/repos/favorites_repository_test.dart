import 'package:coffee/database/database.dart';
import 'package:coffee/repos/favorites_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('FavoritesRepository', () {
    late ProviderContainer ref;

    setUp(() {
      ref = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(CoffeeDatabase.inMemory()),
        ],
      );
    });

    tearDown(() => ref.dispose());

    group('favoritesRepositoryProvider', () {
      test('can favorite and unfavorite', () async {
        final favoritesRepository = ref.read(favoritesRepositoryProvider);
        final favorites = await favoritesRepository.listFavorites();
        expect(favorites, isEmpty);

        await favoritesRepository.favorite('1');
        await favoritesRepository.favorite('2');
        await favoritesRepository.favorite('3');

        final newFavorites = await favoritesRepository.listFavorites();
        expect(newFavorites, ['1', '2', '3']);

        await favoritesRepository.unfavorite('2');
        final updatedFavorites = await favoritesRepository.listFavorites();
        expect(updatedFavorites, ['1', '3']);
      });

      test('can watch favorites', () async {
        final favoritesRepository = ref.read(favoritesRepositoryProvider);
        final favorites = await favoritesRepository.listFavorites();
        expect(favorites, isEmpty);

        final favoritesStream = favoritesRepository.watchFavorites();
        expect(
          favoritesStream,
          emitsInOrder([
            isEmpty,
            ['1'],
            ['1', '2'],
            ['1', '2', '3'],
            ['1', '3'],
          ]),
        );
        await favoritesRepository.favorite('1');
        await Future<void>.delayed(Duration.zero);
        await favoritesRepository.favorite('2');
        await Future<void>.delayed(Duration.zero);
        await favoritesRepository.favorite('3');
        await Future<void>.delayed(Duration.zero);
        await favoritesRepository.unfavorite('2');
      });
    });

    group('favoritesProvider', () {
      test('can watch favorites', () async {
        final favoritesRepository = ref.read(favoritesRepositoryProvider);
        final favoritesStream = ref.read(favoritesProvider.stream);
        await expectLater(favoritesStream, emits(isEmpty));

        expect(
          favoritesStream,
          emitsInOrder([
            isEmpty,
            ['1'],
            ['1', '2'],
            ['1', '2', '3'],
            ['1', '3'],
          ]),
        );
        await favoritesRepository.favorite('1');
        await Future<void>.delayed(Duration.zero);
        await favoritesRepository.favorite('2');
        await Future<void>.delayed(Duration.zero);
        await favoritesRepository.favorite('3');
        await Future<void>.delayed(Duration.zero);
        await favoritesRepository.unfavorite('2');
      });
    });
  });
}
