import 'dart:async';

import 'package:aws_common/aws_common.dart';
import 'package:coffee/database/database.dart';
import 'package:riverpod/riverpod.dart';

/// A [Provider] for accessing slices of the favorites.
///
/// This differs from [FavoritesRepository.watchFavorites] in that it combines
/// the initial value given by [FavoritesRepository.listFavorites] and the
/// stream into a single stream.
final favoritesProvider = StreamProvider<List<String>>(
  (ref) {
    final db = ref.watch(favoritesRepositoryProvider);
    final controller = StreamController<List<String>>(sync: true);
    db.listFavorites().then(
      (favorites) {
        controller.add(favorites);
        db.watchFavorites().forward(controller, cancelOnError: true);
      },
      onError: controller.addError,
    );
    ref.onDispose(controller.close);
    return controller.stream;
  },
  name: 'favorites',
);

/// The [Provider] for [FavoritesRepository].
final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => ref.watch(databaseProvider),
);

/// A repository which provides access to favorites.
abstract class FavoritesRepository {
  /// Returns the list of favorites.
  Future<List<String>> listFavorites();

  /// Returns a stream of updates to favorites.
  Stream<List<String>> watchFavorites();

  /// Adds an image to the favorites.
  Future<void> favorite(String imageKey);

  /// Removes an image from the favorites.
  Future<void> unfavorite(String imageKey);
}
