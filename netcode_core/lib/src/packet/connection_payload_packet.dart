import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

typedef PayloadPacketDataParser = T Function<T extends PayloadPacketData>(
    ByteData);

class ConnectionPayloadPacket<T extends PayloadPacketData>
    extends EncryptedPacket<T> {
  const ConnectionPayloadPacket({
    required super.sequenceNumber,
    required super.data,
  });

  final type = PacketType.payload;

  factory ConnectionPayloadPacket.fromByteData(
    int sequenceNumber,
    ByteData data, {
    PayloadPacketDataParser? parser,
  }) {
    return ConnectionPayloadPacket(
      sequenceNumber: sequenceNumber,
      data: parser?.call(data) ?? PayloadPacketData(data) as T,
    );
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
