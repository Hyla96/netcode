import 'dart:typed_data';

import 'packet.dart';

class ConnectionKeepAlivePacket extends Packet {
  const ConnectionKeepAlivePacket();

  final type = PacketType.keepAlive;

  factory ConnectionKeepAlivePacket.fromByteData(ByteData data) {
    return ConnectionKeepAlivePacket();
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
