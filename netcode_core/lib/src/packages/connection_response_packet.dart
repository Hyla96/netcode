import 'dart:typed_data';

import 'packet.dart';

class ConnectionResponsePacket extends Packet {
  const ConnectionResponsePacket();
  final type = PacketType.response;
  factory ConnectionResponsePacket.fromByteData(ByteData data) {
    return ConnectionResponsePacket();
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
