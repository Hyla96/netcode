import 'dart:typed_data';

import 'packet.dart';

class ConnectionPayloadPacket extends EncryptedPacket {
  const ConnectionPayloadPacket({
    required super.sequenceNumber,
    required super.packetData,
  });

  final type = PacketType.payload;

  factory ConnectionPayloadPacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionPayloadPacket(
      sequenceNumber: sequenceNumber,
      packetData: data,
    );
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
