import 'dart:async';
import 'dart:ui';

import 'package:coffee/repos/image_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// {@template widgets.coffee_image_provider}
/// An [ImageProvider] which fetches images locally and remotely, and provides
/// resize support for better caching.
/// {@endtemplate}
class CoffeeImageProvider extends ImageProvider<CoffeeImageProvider> {
  /// {@macro widgets.coffee_image_provider}
  CoffeeImageProvider(
    this.url, {
    this.cacheWidth,
    this.cacheHeight,
    required ImageRepository imageRepository,
  }) : _imageRepository = imageRepository;

  /// The URL from which the image will be fetched.
  final String url;

  /// The width to which the image will be resized.
  final int? cacheWidth;

  /// The height to which the image will be resized.
  final int? cacheHeight;

  final ImageRepository _imageRepository;

  @override
  Future<CoffeeImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CoffeeImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
    CoffeeImageProvider key,
    DecoderBufferCallback decode,
  ) {
    final chunkEventController = StreamController<ImageChunkEvent>.broadcast();
    return _ImageStreamCompleter(
      _load(decode, chunkEventController),
      chunkEvents: chunkEventController,
      informationCollector: () sync* {
        yield StringProperty('Image URL', url);
      },
    );
  }

  Future<ImageInfo> _load(
    DecoderBufferCallback decode,
    StreamSink<ImageChunkEvent> chunkEventSink,
  ) async {
    chunkEventSink.add(
      const ImageChunkEvent(
        cumulativeBytesLoaded: 0,
        expectedTotalBytes: null,
      ),
    );
    var bytes = await _imageRepository.loadImage(url);
    chunkEventSink.add(
      ImageChunkEvent(
        cumulativeBytesLoaded: bytes.length,
        expectedTotalBytes: null,
      ),
    );
    var cumBytes = bytes.length;
    if (cacheWidth != null || cacheHeight != null) {
      bytes = await _imageRepository.resizeImage(
        bytes,
        key: url,
        width: cacheWidth,
        height: cacheHeight,
      );
      cumBytes += bytes.length;
      chunkEventSink.add(
        ImageChunkEvent(
          cumulativeBytesLoaded: cumBytes,
          expectedTotalBytes: null,
        ),
      );
    }
    final buffer = await ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(
      buffer,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
    final frame = await codec.getNextFrame();
    chunkEventSink.add(
      ImageChunkEvent(
        cumulativeBytesLoaded: cumBytes,
        expectedTotalBytes: cumBytes,
      ),
    );
    return ImageInfo(image: frame.image);
  }
}

/// A [OneFrameImageStreamCompleter] which reports loading events.
class _ImageStreamCompleter extends ImageStreamCompleter {
  _ImageStreamCompleter(
    Future<ImageInfo> image, {
    required StreamController<ImageChunkEvent> chunkEvents,
    InformationCollector? informationCollector,
  }) {
    chunkEvents.stream.listen(reportImageChunkEvent);
    image.then<void>(
      setImage,
      onError: (Object error, StackTrace stack) {
        reportError(
          context: ErrorDescription('resolving a single-frame image stream'),
          exception: error,
          stack: stack,
          informationCollector: informationCollector,
          silent: true,
        );
      },
    ).whenComplete(() => chunkEvents.close());
  }
}

extension ImageChunkEventCompleted on ImageChunkEvent {
  bool get isCompleted =>
      expectedTotalBytes != null && expectedTotalBytes == cumulativeBytesLoaded;
}
