import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CoffeeDatabase', () {
    testWidgets('can save and load images', (tester) async {
      final database = createTestDatabase();

      await tester.runAsync(() async {
        final image = Uint8List.fromList([1, 2, 3, 4, 5]);
        await database.saveImage('key', image);
        final bytes = await database.loadImage('key');
        expect(bytes, image);
      });
    });
  });
}
