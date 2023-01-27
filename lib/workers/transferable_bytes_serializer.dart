import 'dart:typed_data';

import 'package:built_value/serializer.dart';

import 'transferable_bytes_serializer_stub.dart'
    if (dart.library.io) 'transferable_bytes_serializer_io.dart'
    if (dart.library.js_util) 'transferable_bytes_serializer_js.dart';

/// {@template workers.transferable_byte_serializer}
/// A built_value serializer which can serialize and deserialize [Uint8List].
///
/// On Web, a [Uint8List] is transferred to its destination without copying.
/// On VM, no such mechanism exists, so we must make a copy.
/// {@endtemplate}
abstract class TransferableByteSerializer
    implements PrimitiveSerializer<Uint8List> {
  /// {@macro workers.transferable_byte_serializer}
  const factory TransferableByteSerializer() = TransferableByteSerializerImpl;
  const TransferableByteSerializer.protected();

  @override
  Iterable<Type> get types => const [Uint8List];

  @override
  String get wireName => 'Uint8List';
}
