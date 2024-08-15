import 'dart:math';
import 'dart:typed_data';

import 'package:netcode_core/src/challange_token/lib.dart';
import 'package:netcode_core/src/packages/lib.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing connection challenge packet', () async {
    final sequence = 2837123;
    final challengeTokenSequence = 19828;
    final clientID = 177;
    final rng = Random();
    final userData = Uint8List.fromList(
      List.generate(
        256,
        (_) => rng.nextInt(256),
      ),
    );

    final token = ChallengeToken(
      clientId: clientID,
      userData: userData,
    );

    final nonce = Uint8List.fromList(
      List.generate(
        12,
        (_) => rng.nextInt(256),
      ),
    );

    final key = Uint8List.fromList(
      List.generate(
        32,
        (_) => rng.nextInt(256),
      ),
    );

    final packet = ConnectionChallengePacket(
      sequenceNumber: sequence,
      data: await ConnectionChallengePacketData.fromClearChallengeToken(
        nonce: nonce,
        key: key,
        challengeTokenSequence: challengeTokenSequence,
        token: token,
      ),
    );

    final data = packet.toByteData();
    final parsedPacket = Packet.fromByteData(data);

    expect(parsedPacket is ConnectionChallengePacket, isTrue);

    final result = parsedPacket as ConnectionChallengePacket;

    expect(result.sequenceNumber, sequence);

    final challengeToken = await result.data.decryptChallengeToken(
      nonce,
      key,
    );

    expect(challengeToken.clientId, token.clientId);
    expect(challengeToken.userData, token.userData);
  });
}
