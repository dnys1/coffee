import 'dart:async';
import 'dart:typed_data';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:coffee/workers/transferable_bytes_serializer.dart';
import 'package:image/image.dart'
    show copyResize, decodeImage, encodeNamedImage;
import 'package:worker_bee/worker_bee.dart';

import 'image_resize_worker.worker.dart';

part 'image_resize_worker.g.dart';

/// {@template workers.image_resize_worker}
/// A worker bee which resizes images.
/// {@endtemplate}
@WorkerBee('lib/workers/workers.dart')
abstract class ImageResizeWorker
    extends WorkerBeeBase<ImageResizeRequest, Uint8List> {
  /// {@macro workers.image_resize_worker}
  ImageResizeWorker() : super(serializers: _serializers);

  /// {@macro workers.image_resize_worker}
  factory ImageResizeWorker.create() = ImageResizeWorkerImpl;

  /// Resizes an image using this worker.
  ///
  /// Either [width] or [height] must be provided.
  Future<Uint8List> resize({
    required String key,
    required Uint8List bytes,
    int? width,
    int? height,
  }) async {
    final request = ImageResizeRequest(
      (b) => b
        ..key = key
        ..bytes = bytes
        ..width = width
        ..height = height,
    );
    add(request);
    final result = await Result.release(this.result);
    return result!;
  }

  Future<Uint8List> _resizeImage({
    required String key,
    required Uint8List bytes,
    required int? width,
    required int? height,
  }) async {
    final image = decodeImage(bytes);
    logger.info('Decoded $key: ${image?.width}x${image?.height}');
    if (image == null) {
      throw Exception('Unable to decode image: $key');
    }
    if (width != null && width >= image.width ||
        height != null && height >= image.height) {
      logger.info('Skipping resize.');
      return bytes;
    }
    var scale = 1.0;
    if (width != null && height != null) {
      scale = width / image.width;
      if (height / image.height < scale) {
        scale = height / image.height;
      }
    } else if (width != null) {
      scale = width / image.width;
    } else {
      scale = height! / image.height;
    }
    final resized = copyResize(
      image,
      width: (image.width * scale).toInt(),
      height: (image.height * scale).toInt(),
    );
    logger.info('Resized $key: ${resized.width}x${resized.height}');
    final resizedBytes = encodeNamedImage(resized, key);
    logger.info('Encoded $key: ${resizedBytes?.length} bytes');
    if (resizedBytes == null) {
      throw Exception('Unable to encode image: $key');
    }
    return Uint8List.fromList(resizedBytes);
  }

  @override
  Future<Uint8List> run(
    Stream<ImageResizeRequest> listen,
    StreamSink<Uint8List> respond,
  ) async {
    final request = await listen.first;
    return _resizeImage(
      key: request.key,
      bytes: request.bytes,
      width: request.width,
      height: request.height,
    );
  }
}

/// {@template workers.image_resize_request}
/// A request to resize an image by an [ImageResizeWorker].
/// {@endtemplate}
abstract class ImageResizeRequest
    implements Built<ImageResizeRequest, ImageResizeRequestBuilder> {
  /// {@macro workers.image_resize_request}
  factory ImageResizeRequest([
    void Function(ImageResizeRequestBuilder) updates,
  ]) = _$ImageResizeRequest;
  const ImageResizeRequest._();

  @BuiltValueHook(finalizeBuilder: true)
  static void _finalize(ImageResizeRequestBuilder b) {
    if (b.width == null && b.height == null) {
      throw ArgumentError('Either width or height must be provided.');
    }
  }

  /// The key of the image.
  String get key;

  /// The bytes of the image.
  Uint8List get bytes;

  /// The width to resize the image to.
  ///
  /// If [height] is also provided, the image will be resized to fit within the
  /// given dimensions. If only [width] is provided, the image will be resized
  /// to the given width, maintaining the aspect ratio.
  int? get width;

  /// The height to resize the image to.
  ///
  /// If [width] is also provided, the image will be resized to fit within the
  /// given dimensions. If only [height] is provided, the image will be resized
  /// to the given height, maintaining the aspect ratio.
  int? get height;

  static Serializer<ImageResizeRequest> get serializer =>
      _$imageResizeRequestSerializer;

  @override
  String toString() =>
      'ImageResizeRequest(key: $key, width: $width, height: $height)';
}

@SerializersFor([
  ImageResizeRequest,
])
final Serializers _serializers = (_$_serializers.toBuilder()
      ..add(const TransferableByteSerializer()))
    .build();
