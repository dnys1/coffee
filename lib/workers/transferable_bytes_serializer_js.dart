import 'dart:async';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';

import 'transferable_bytes_serializer.dart';

/// On Web, we transfer the underlying buffer to avoid a copy by adding the
/// buffer to the worker bee's transferable array.
///
/// In effect, we end up doing this:
/// https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Transferable_objects#transferring_objects_between_threads
class TransferableByteSerializerImpl extends TransferableByteSerializer {
  const TransferableByteSerializerImpl() : super.protected();

  @override
  Object serialize(
    Serializers serializers,
    Uint8List bytes, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final transfer = Zone.current[#transfer] as List<Object>;
    transfer.add(bytes.buffer);
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
