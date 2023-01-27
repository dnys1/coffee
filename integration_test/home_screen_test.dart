import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_common/testing.dart';
import 'package:coffee/database/database.dart';
import 'package:coffee/main.dart';
import 'package:coffee/repos/favorites_repository.dart';
import 'package:coffee/screens/home/explore_tab.dart';
import 'package:coffee/services/http.dart';
import 'package:coffee/services/image_cache_service.dart';
import 'package:coffee/services/image_resize_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('HomeScreen', () {
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

    group('FavoritesTab', () {
      testWidgets('can see all favorites', (tester) async {
        final flutterImage = base64Decode(flutterPng);
        final imageCacheService = ref.read(imageCacheServiceProvider);
        await imageCacheService.put('1', flutterImage);
        await imageCacheService.put('2', flutterImage);
        await imageCacheService.put('3', flutterImage);

        final favoritesRepository = ref.read(favoritesRepositoryProvider);
        await favoritesRepository.favorite('1');
        await favoritesRepository.favorite('2');
        await favoritesRepository.favorite('3');

        await tester.pumpWidget(
          ProviderScope(
            parent: ref,
            child: const MyApp(),
          ),
        );

        await tester.tap(favoritesTabFinder);
        await tester.pumpAndSettle();

        expect(
          coffeeImageFinder,
          findsNWidgets(3),
        );
      });

      testWidgets('can unfavorite an image', (tester) async {
        final flutterImage = base64Decode(flutterPng);
        final imageCacheService = ref.read(imageCacheServiceProvider);
        await imageCacheService.put('1', flutterImage);
        await imageCacheService.put('2', flutterImage);
        await imageCacheService.put('3', flutterImage);

        final favoritesRepository = ref.read(favoritesRepositoryProvider);
        await favoritesRepository.favorite('1');
        await favoritesRepository.favorite('2');
        await favoritesRepository.favorite('3');

        await tester.pumpWidget(
          ProviderScope(
            parent: ref,
            child: const MyApp(),
          ),
        );

        await tester.tap(favoritesTabFinder);
        await tester.pumpAndSettle();

        expect(
          coffeeImageFinder,
          findsNWidgets(3),
        );

        await tester.doubleTap(coffeeImageFinder.first);
        await tester.pump();

        expect(
          coffeeImageFinder,
          findsNWidgets(2),
        );
      });
    });

    group('ExploreTab', () {
      testWidgets('can favorite an image', (tester) async {
        final flutterImage = base64Decode(flutterPng);
        final imageCacheService = ref.read(imageCacheServiceProvider);
        await imageCacheService.put('1', flutterImage);

        await tester.pumpWidget(
          ProviderScope(
            parent: ref,
            overrides: [
              randomCoffee.overrideWith((ref) => '1'),
            ],
            child: const MyApp(),
          ),
        );

        await tester.tap(exploreTabFinder);
        await tester.pumpAndSettle();

        expect(
          coffeeImageFinder,
          findsOneWidget,
        );
        expect(
          bannerFinder,
          findsNothing,
        );

        await tester.tap(favoriteFabFinder);
        await tester.pumpAndSettle();

        expect(
          coffeeImageFinder,
          findsOneWidget,
        );
        expect(
          bannerFinder,
          findsOneWidget,
        );

        await tester.tap(favoritesTabFinder);
        await tester.pumpAndSettle();

        expect(
          coffeeImageFinder,
          findsOneWidget,
        );
      });

      testWidgets('shows error snackbar when offline', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              httpClientProvider.overrideWithValue(
                MockAWSHttpClient((request, isCancelled) {
                  throw AWSHttpException(request, 'offline');
                }),
              )
            ],
            child: const MyApp(),
          ),
        );

        await tester.tap(exploreTabFinder);
        await tester.pumpAndSettle();

        expect(errorSnackBarFinder, findsOneWidget);
      });
    });
  });
}
