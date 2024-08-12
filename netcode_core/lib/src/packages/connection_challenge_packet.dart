import 'dart:typed_data';

import 'packet.dart';

class ConnectionChallengePacket extends Packet {
  const ConnectionChallengePacket();

  final type = PacketType.challenge;

  factory ConnectionChallengePacket.fromByteData(ByteData data) {
    return ConnectionChallengePacket();
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
