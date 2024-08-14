import 'dart:typed_data';

import 'packet.dart';

class ConnectionDisconnectPacket extends EncryptedPacket {
  const ConnectionDisconnectPacket({
    required super.packetData,
    required super.sequenceNumber,
  });

  final type = PacketType.disconnect;

  factory ConnectionDisconnectPacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionDisconnectPacket(
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
