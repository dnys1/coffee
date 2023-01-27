import 'package:coffee/repos/favorites_repository.dart';
import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';

import 'connect.dart'
    if (dart.library.js_util) 'connect_js.dart'
    if (dart.library.io) 'connect_io.dart';

part 'database.g.dart';

/// The [Provider] for [CoffeeDatabase].
final databaseProvider = Provider(
  (ref) {
    final database = CoffeeDatabase();
    ref.onDispose(database.close);
    return database;
  },
  name: 'database',
);

class Favorites extends Table {
  TextColumn get key => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class ImageCache extends Table {
  TextColumn get key => text()();
  BlobColumn get imageBytes => blob()();

  @override
  Set<Column> get primaryKey => {key};
}

/// {@template database.coffee_database}
/// The database for the coffee app, which stores user favorites and the cache
/// of all images.
/// {@endtemplate}
@DriftDatabase(tables: [Favorites, ImageCache])
class CoffeeDatabase extends _$CoffeeDatabase implements FavoritesRepository {
  /// {@macro database.coffee_database}
  CoffeeDatabase([QueryExecutor? executor]) : super(executor ?? connect());

  /// Creates a new [CoffeeDatabase] that uses an in-memory database.
  CoffeeDatabase.inMemory() : this(inMemoryDatabase);

  @override
  int get schemaVersion => 1;

  @override
  Future<List<String>> listFavorites() async {
    final query = select(favorites);
    final result = await query.get();
    return result.map((e) => e.key).toList();
  }

  @override
  Stream<List<String>> watchFavorites() {
    final query = select(favorites);
    return query.watch().map((rows) => rows.map((e) => e.key).toList());
  }

  @override
  Future<void> favorite(String key) async {
    await into(favorites).insertOnConflictUpdate(
      FavoritesCompanion.insert(key: key),
    );
  }

  @override
  Future<void> unfavorite(String key) async {
    await (delete(favorites)..where((t) => t.key.equals(key))).go();
  }

  Future<void> saveImage(String key, Uint8List imageBytes) async {
    await into(imageCache).insertOnConflictUpdate(
      ImageCacheCompanion.insert(key: key, imageBytes: imageBytes),
    );
  }

  Future<Uint8List?> loadImage(String key) async {
    final query = select(imageCache)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.imageBytes;
  }

  /// **WARNING**: Destructive action.
  ///
  /// Deletes all data.
  Future<void> deleteAll() async {
    await delete(favorites).go();
    await delete(imageCache).go();
  }
}
