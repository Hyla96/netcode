import 'dart:typed_data';

import 'packet.dart';

class ConnectionDeniedPacket extends Packet {
  const ConnectionDeniedPacket();
  final type = PacketType.denied;

  factory ConnectionDeniedPacket.fromByteData(ByteData data) {
    return ConnectionDeniedPacket();
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
