import 'package:coffee/repos/favorites_repository.dart';
import 'package:coffee/repos/image_repository.dart';
import 'package:coffee/scaffold.dart';
import 'package:coffee/theme.dart';
import 'package:coffee/widgets/coffee_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// {@template widgets.coffee_image}
/// A widget which displays a coffee image with the given [imageKey].
///
/// The image will be cached locally and resized to the given [width] and
/// [height] for better performance.
/// {@endtemplate}
class CoffeeImage extends ConsumerWidget {
  /// {@macro widgets.coffee_image}
  const CoffeeImage({
    super.key,
    required this.imageKey,
    this.width,
    this.height,
  });

  /// The key (URL) of the image to display.
  final String imageKey;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onDoubleTap: () {
        final isFavorite =
            (ref.read(favoritesProvider).valueOrNull ?? []).contains(imageKey);
        if (!isFavorite) {
          ref.read(favoritesRepositoryProvider).favorite(imageKey);
        } else {
          ref.read(favoritesRepositoryProvider).unfavorite(imageKey);
        }
      },
      child: Image(
        image: CoffeeImageProvider(
          imageKey,
          imageRepository: ref.watch(imageRepositoryProvider),
          cacheWidth: width?.round(),
          cacheHeight: height?.round(),
        ),
        fit: BoxFit.cover,
        frameBuilder: (context, image, frame, wasSynchronouslyLoaded) {
          return Consumer(
            builder: (context, ref, image) {
              final isFavorite =
                  (ref.watch(favoritesProvider).valueOrNull ?? [])
                      .contains(imageKey);
              if (!isFavorite) {
                return image!;
              }
              return Banner(
                message: 'Favorite',
                location: BannerLocation.topEnd,
                color: Colors.white,
                textStyle: const TextStyle(
                  color: favoritePink,
                  fontSize: 12,
                ),
                child: image,
              );
            },
            child: image,
          );
        },
        loadingBuilder: (context, image, loadingProgress) {
          if (loadingProgress != null && loadingProgress.isCompleted) {
            return image;
          }
          return const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          showErrorSnackBar(error);
          return const Center(
            child: Icon(Icons.coffee),
          );
        },
      ),
    );
  }
}
