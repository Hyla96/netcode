import 'dart:async';
import 'dart:typed_data';

import 'package:netcode_core/src/challange_token/lib.dart';
import 'package:netcode_core/src/netcode_encryption.dart';
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
  ConnectionChallengePacketData({
    required this.challengeTokenSequence,
    required this.encryptedToken,
  });

  final int challengeTokenSequence;
  final Uint8List encryptedToken;
  final _decryptedToken = Completer<ChallengeToken>();

  ByteData toByteData() {
    int offset = 0;

    final data = ByteData(308);
    data.setUint64(
      offset,
      challengeTokenSequence,
      Endian.little,
    );
    offset += 8;

    for (int i in encryptedToken) {
      data.setUint8(offset, i);
      offset++;
    }

    return data;
  }

  factory ConnectionChallengePacketData.fromByteData(ByteData data) {
    return ConnectionChallengePacketData(
      challengeTokenSequence: data.getUint64(0, Endian.little),
      encryptedToken: data.buffer.asUint8List().sublist(8),
    );
  }

  static Future<ConnectionChallengePacketData> fromClearChallengeToken({
    required ChallengeToken token,
    required Uint8List nonce,
    required Uint8List key,
    required int challengeTokenSequence,
  }) async {
    final encrypted = await NetcodeEncryption.encryptChallengeToken(
      token: token,
      nonce: nonce,
      encryptionKey: key,
    );

    return ConnectionChallengePacketData(
      challengeTokenSequence: challengeTokenSequence,
      encryptedToken: encrypted,
    );
  }

  Future<ChallengeToken> decryptChallengeToken(
    Uint8List nonce,
    Uint8List key,
  ) async {
    if (_decryptedToken.isCompleted) {
      return _decryptedToken.future;
    }

    final token = await NetcodeEncryption.decryptChallengeToken(
      encryptedToken: encryptedToken,
      nonce: nonce,
      encryptionKey: key,
    );

    _decryptedToken.complete(token);

    return token;
  }
}
