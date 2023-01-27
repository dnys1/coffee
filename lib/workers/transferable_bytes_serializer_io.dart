import 'dart:isolate';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';

import 'transferable_bytes_serializer.dart';

/// On VM, there is no way to transfer the byte array in O(1) time, so we have
/// to copy it.
///
/// We could use [TransferableTypedData], but this still requires making a
/// copy. So instead, we use [Isolate.exit] from the worker which _can_ transfer
/// any value it's passed (since it knows it holds the only reference).
///
/// See more discussion here:
/// - https://github.com/dart-lang/sdk/issues/50277
/// - https://github.com/dart-lang/sdk/issues/49587
class TransferableByteSerializerImpl extends TransferableByteSerializer {
  const TransferableByteSerializerImpl() : super.protected();

  @override
  Object serialize(
    Serializers serializers,
    Uint8List bytes, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return bytes;
  }

  @override
  Uint8List deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serialized as Uint8List;
  }
}
