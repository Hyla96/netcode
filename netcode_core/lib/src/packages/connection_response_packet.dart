import 'dart:typed_data';

import 'packet.dart';

class ConnectionResponsePacket extends EncryptedPacket {
  const ConnectionResponsePacket({
    required super.sequenceNumber,
    required super.packetData,
  });

  final type = PacketType.response;
  factory ConnectionResponsePacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionResponsePacket(
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
