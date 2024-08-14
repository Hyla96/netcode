import 'dart:typed_data';

import 'packet.dart';

class ConnectionKeepAlivePacket extends EncryptedPacket {
  const ConnectionKeepAlivePacket({
    required super.sequenceNumber,
    required super.packetData,
  });

  final type = PacketType.keepAlive;

  factory ConnectionKeepAlivePacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionKeepAlivePacket(
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
