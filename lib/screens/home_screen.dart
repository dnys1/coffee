import 'package:coffee/repos/favorites_repository.dart';
import 'package:coffee/screens/home/explore_tab.dart';
import 'package:coffee/screens/home/favorites_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The different tabs of the [HomeScreen].
enum CoffeeTab { favorites, explore }

/// The currently selected tab.
final selectedTab = StateProvider<CoffeeTab>((ref) => CoffeeTab.explore);

/// {@template screens.home}
/// The main route for the app, which shows the [FavoritesTab] and the
/// [ExploreTab].
/// {@endtemplate}
class HomeScreen extends ConsumerWidget {
  /// {@macro screens.home}
  const HomeScreen({super.key});

  static const _tabs = [
    FavoritesTab(),
    ExploreTab(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRandomCoffee = ref.watch(randomCoffee).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee'),
      ),
      body: Center(
        child: _tabs[ref.watch(selectedTab).index],
      ),
      floatingActionButton: ref.watch(selectedTab) == CoffeeTab.favorites
          ? null
          : FloatingActionButton.extended(
              onPressed: currentRandomCoffee == null
                  ? null
                  : () {
                      final isFavorite =
                          (ref.read(favoritesProvider).valueOrNull ?? [])
                              .contains(currentRandomCoffee);
                      final repo = ref.read(favoritesRepositoryProvider);
                      if (!isFavorite) {
                        repo.favorite(currentRandomCoffee);
                      } else {
                        repo.unfavorite(currentRandomCoffee);
                      }
                    },
              icon: const Icon(Icons.favorite),
              label: const Text('Favorite'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: ref.watch(selectedTab).index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.coffee),
            label: 'Explore',
          ),
        ],
        onDestinationSelected: (index) {
          // When clicking away from the random coffee tab, we want to
          // invalidate the random coffee so that it is regenerated when
          // the user comes back to the tab.
          if (index != CoffeeTab.explore.index) {
            ref.invalidate(randomCoffee);
          }
          ref.read(selectedTab.notifier).state = CoffeeTab.values[index];
        },
      ),
    );
  }
}
