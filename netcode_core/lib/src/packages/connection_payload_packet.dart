import 'dart:typed_data';

import 'packet.dart';

class ConnectionPayloadPacket extends Packet {
  const ConnectionPayloadPacket();

  final type = PacketType.payload;

  factory ConnectionPayloadPacket.fromByteData(ByteData data) {
    return ConnectionPayloadPacket();
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
