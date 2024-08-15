import 'dart:typed_data';

import 'package:netcode_core/src/challange_token/lib.dart';

import 'packet.dart';

class ConnectionChallengePacket extends EncryptedPacket<ChallengeToken> {
  const ConnectionChallengePacket({
    required super.sequenceNumber,
    required super.data,
  });

  final type = PacketType.challenge;

  factory ConnectionChallengePacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionChallengePacket(
      sequenceNumber: sequenceNumber,
      data: ChallengeToken.fromByteData(data),
    );
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
