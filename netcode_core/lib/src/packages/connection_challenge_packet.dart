import 'dart:typed_data';

import 'package:netcode_core/src/challange_token/lib.dart';
import 'package:netcode_core/src/util/byte_manipulation_util.dart';

import 'packet.dart';

class ConnectionChallengePacket
    extends EncryptedPacket<ConnectionChallengePacketData> {
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
      data: ConnectionChallengePacketData.fromByteData(data),
    );
  }

  @override
  ByteData toByteData() {
    int offset = 0;

    final packetData = this.data.toByteData().buffer.asUint8List();
    final sequenceNumberBytes =
        ByteManipulationUtil.sequenceNumberToBytes(sequenceNumber);

    final data = ByteData(
        1 + sequenceNumberBytes.lengthInBytes + packetData.lengthInBytes);

    data.setUint8(
      offset,
      getFirstByte(sequenceNumberBytes.lengthInBytes),
    );
    offset++;

    for (int i in sequenceNumberBytes.reversed) {
      data.setUint8(offset, i);
      offset++;
    }

    for (final p in packetData) {
      data.setUint8(offset, p);
      offset++;
    }

    return data;
  }
}

class ConnectionChallengePacketData {
  const ConnectionChallengePacketData({
    required this.challengeTokenSequence,
    required this.token,
  });

  final int challengeTokenSequence;
  final ChallengeToken token;

  ByteData toByteData() {
    int offset = 0;

    final data = ByteData(308);
    data.setUint64(
      offset,
      challengeTokenSequence,
      Endian.little,
    );
    offset += 8;

    final tokenData = token.toByteData().buffer.asUint8List();
    for (int i in tokenData) {
      data.setUint8(offset, i);
      offset++;
    }

    return data;
  }

  factory ConnectionChallengePacketData.fromByteData(ByteData data) {
    return ConnectionChallengePacketData(
      challengeTokenSequence: data.getUint64(0, Endian.little),
      token: ChallengeToken.fromByteData(
        data.buffer.asUint8List().sublist(1).buffer.asByteData(),
      ),
    );
  }
}
