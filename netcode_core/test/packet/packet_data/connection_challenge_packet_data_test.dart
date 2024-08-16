import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

import '../../util/test_util.dart';

void main() {
  setUp(() {});

  test('Parsing connection challenge packet data', () async {
    final sequence = 1381;

    final util = TestUtil();
    final token = await util.getRandomEncryptedChallengeToken(clientId: 231);

    final packetData = ConnectionChallengePacketData(
      challengeTokenSequence: sequence,
      encryptedToken: token,
    );

    final encrypted = await packetData.decryptChallengeToken(
        util.challengeTokenNonce, util.challengeTokenKey);

    expect(encrypted.clientId, 231);
    expect(packetData.challengeTokenSequence, sequence);

    final data = packetData.toByteData();
    final parsed = ConnectionChallengePacketData.fromByteData(data);

    expect(parsed.challengeTokenSequence, sequence);
    expect(parsed.encryptedToken, packetData.encryptedToken);
  });
}
