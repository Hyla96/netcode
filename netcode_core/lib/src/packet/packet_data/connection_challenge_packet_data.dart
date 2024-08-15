import 'dart:async';
import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionChallengePacketData extends EncryptedPacketData {
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
      encryptedToken: data.buffer.asUint8List(8),
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
