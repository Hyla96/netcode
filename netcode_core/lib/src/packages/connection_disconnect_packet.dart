import 'dart:typed_data';

import 'packet.dart';

class ConnectionDisconnectPacket extends EncryptedPacket<ByteData> {
  const ConnectionDisconnectPacket({
    required super.sequenceNumber,
    required super.data,
  });

  final type = PacketType.disconnect;

  factory ConnectionDisconnectPacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionDisconnectPacket(
      sequenceNumber: sequenceNumber,
      data: data,
    );
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
