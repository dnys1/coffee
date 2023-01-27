import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aws_common/aws_common.dart';
import 'package:coffee/workers/image_resize_worker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<ImageResizeWorker> createWorker() async {
    final worker = ImageResizeWorker.create();
    worker.logs.listen(safePrint);
    await worker.spawn();
    return worker;
  }

  group('ImageResizeWorker', () {
    testWidgets('can resize images', (tester) async {
      await tester.runAsync(() async {
        const key = 'https://example.com/flutter.png';
        final originalBytes = base64.decode(flutterPng);
        const originalSize = ui.Size(300, 372);

        final resizedWidth = originalSize.width ~/ 2;
        final resizedHeight = originalSize.height ~/ 2;

        final worker = await createWorker();
        final response = await worker.resize(
          key: key,
          bytes: originalBytes,
          width: resizedWidth,
        );

        final completer = Completer<ui.Image>.sync();
        ui.decodeImageFromList(response, completer.complete);
        final resizedImage = await completer.future;
        expect(resizedImage.width, resizedWidth);
        expect(resizedImage.height, resizedHeight);
      });
    });

    testWidgets('skips resize when unnecessary', (tester) async {
      await tester.runAsync(() async {
        const key = 'https://example.com/flutter.png';
        final originalBytes = base64.decode(flutterPng);
        const originalSize = ui.Size(300, 372);

        final resizedWidth = originalSize.width.toInt();

        final worker = await createWorker();
        final response = await worker.resize(
          key: key,
          bytes: originalBytes,
          width: resizedWidth,
        );

        expect(response, base64.decode(flutterPng));
      });
    });

    testWidgets('fails with invalid image', (tester) async {
      await tester.runAsync(() async {
        const key = 'key';
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        final worker = await createWorker();
        await expectLater(
          worker.resize(
            key: key,
            bytes: bytes,
            width: 100,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
