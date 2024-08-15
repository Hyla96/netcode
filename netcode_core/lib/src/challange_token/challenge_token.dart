import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ChallengeToken {
  const ChallengeToken({
    required this.clientId,
    required this.userData,
  });

  final int clientId;
  final Uint8List userData;
  factory ChallengeToken.fromByteData(ByteData data) {
    int offset = 0;

    final clientId = data.getUint64(offset, Endian.little);
    offset += 8;

    final userData = data.buffer.asUint8List(offset, 256);

    return ChallengeToken(
      clientId: clientId,
      userData: userData,
    );
  }

  ByteData toByteData() {
    final data = ByteData(CHALLENGE_TOKEN_MAX_LENGTH);

    int offset = 0;

    data.setUint64(offset, clientId.toUnsigned(64), Endian.little);
    offset += 8;

    for (int i = 0; i < 256; i++) {
      if (i < userData.length) {
        data.setUint8(offset, userData[i]);
      }
      offset++;
    }

    return data;
  }
}
