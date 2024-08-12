import 'dart:typed_data';

import 'packet.dart';

class ConnectionDisconnectPacket extends Packet {
  const ConnectionDisconnectPacket();

  final type = PacketType.disconnect;

  factory ConnectionDisconnectPacket.fromByteData(ByteData data) {
    return ConnectionDisconnectPacket();
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
