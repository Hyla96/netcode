import 'dart:typed_data';

import 'packet.dart';

class ConnectionChallengePacket extends EncryptedPacket {
  const ConnectionChallengePacket({
    required super.sequenceNumber,
    required super.packetData,
  });

  final type = PacketType.challenge;

  factory ConnectionChallengePacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionChallengePacket(
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
