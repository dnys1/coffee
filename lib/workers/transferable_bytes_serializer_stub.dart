import 'dart:typed_data';

import 'package:built_value/serializer.dart';

import 'transferable_bytes_serializer.dart';

class TransferableByteSerializerImpl extends TransferableByteSerializer {
  const TransferableByteSerializerImpl() : super.protected();

  @override
  Object serialize(
    Serializers serializers,
    Uint8List bytes, {
    FullType specifiedType = FullType.unspecified,
  }) {
    throw UnimplementedError();
  }

  @override
  Uint8List deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    throw UnimplementedError();
  }
}
