import 'package:coffee/scaffold.dart';
import 'package:coffee/services/random_coffee_service.dart';
import 'package:coffee/widgets/coffee_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [Provider] hook for [RandomCoffeeService.getRandomCoffee].
final randomCoffee = FutureProvider.autoDispose<String>(
  (ref) {
    final service = ref.watch(randomCoffeeService);
    return service.getRandomCoffee();
  },
  name: 'randomCoffee',
);

/// {@template screens.home.explore_tab}
/// The tab for exploring random coffees and adding favorites to the collection.
/// {@endtemplate}
class ExploreTab extends ConsumerWidget {
  /// {@macro screens.home.explore_tab}
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coffee = ref.watch(randomCoffee);
    return coffee.when(
      data: (url) => LayoutBuilder(
        builder: (context, constraints) {
          return CoffeeImage(
            imageKey: url,
            width: constraints.maxWidth,
          );
        },
      ),
      loading: () => const SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) {
        showErrorSnackBar(error);
        return const Icon(Icons.sentiment_dissatisfied);
      },
    );
  }
}
