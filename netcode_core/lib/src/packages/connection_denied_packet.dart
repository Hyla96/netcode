import 'dart:typed_data';

import 'packet.dart';

class ConnectionDeniedPacket extends EncryptedPacket {
  const ConnectionDeniedPacket({
    required super.sequenceNumber,
    required super.packetData,
  });
  final type = PacketType.denied;

  factory ConnectionDeniedPacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionDeniedPacket(
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
