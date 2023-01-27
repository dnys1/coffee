import 'dart:convert';

import 'package:coffee/database/database.dart';
import 'package:coffee/repos/favorites_repository.dart';
import 'package:coffee/services/image_cache_service.dart';
import 'package:coffee/services/image_resize_service.dart';
import 'package:coffee/widgets/coffee_image.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('CoffeeImage', () {
    late ProviderContainer ref;

    setUp(() {
      ref = ProviderContainer(
        overrides: [
          imageResizeServiceProvider.overrideWithValue(
            FakeImageResizeService(),
          ),
          databaseProvider.overrideWithValue(CoffeeDatabase.inMemory()),
        ],
      );
    });

    tearDown(() => ref.dispose());

    testWidgets('can favorite an unfavorited, cached image', (tester) async {
      final flutterImage = base64Decode(flutterPng);
      final imageCacheService = ref.read(imageCacheServiceProvider);
      await imageCacheService.put('1', flutterImage);

      await tester.pumpWidget(
        ProviderScope(
          parent: ref,
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Center(child: CoffeeImage(imageKey: '1')),
          ),
        ),
      );
      expect(
        circularProgressFinder,
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      expect(
        rawImageFinder,
        findsOneWidget,
      );
      expect(
        bannerFinder,
        findsNothing,
      );

      await tester.doubleTap(coffeeImageFinder);
      await tester.pumpAndSettle();

      expect(
        rawImageFinder,
        findsOneWidget,
      );
      expect(
        bannerFinder,
        findsOneWidget,
      );
    });

    testWidgets('can unfavorite a favorited, cached image', (tester) async {
      final flutterImage = base64Decode(flutterPng);
      final imageCacheService = ref.read(imageCacheServiceProvider);
      await imageCacheService.put('1', flutterImage);

      final favoritesRepository = ref.read(favoritesRepositoryProvider);
      await favoritesRepository.favorite('1');

      await tester.pumpWidget(
        ProviderScope(
          parent: ref,
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Center(child: CoffeeImage(imageKey: '1')),
          ),
        ),
      );
      expect(
        circularProgressFinder,
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      expect(
        rawImageFinder,
        findsOneWidget,
      );
      expect(
        bannerFinder,
        findsOneWidget,
      );

      await tester.doubleTap(coffeeImageFinder);
      await tester.pump();
      await tester.pump();

      expect(
        rawImageFinder,
        findsOneWidget,
      );
      expect(
        bannerFinder,
        findsNothing,
      );
    });
  });
}
