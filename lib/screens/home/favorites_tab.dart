import 'package:coffee/repos/favorites_repository.dart';
import 'package:coffee/widgets/coffee_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// {@template screens.home.favorites_tab}
/// A tab which displays the user's favorited images in a [GridView].
/// {@endtemplate}
class FavoritesTab extends ConsumerWidget {
  /// {@macro screens.home.favorites_tab}
  const FavoritesTab({super.key});

  Widget _buildGridView(List<String> favorites) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final imageKey = favorites[index];
        return GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(imageKey.split('/').last),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CoffeeImage(
                imageKey: imageKey,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritedItems = ref.watch(favoritesProvider);
    return favoritedItems.when(
      data: _buildGridView,
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const Icon(Icons.sentiment_dissatisfied),
    );
  }
}
