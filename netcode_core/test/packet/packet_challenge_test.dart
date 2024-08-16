import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

import '../util/test_util.dart';

void main() {
  setUp(() {});

  test('Parsing connection challenge packet', () async {
    final sequence = 2837123;
    final challengeTokenSequence = 19828;
    final clientId = 177;
    final protocolId = 3117;

    final util = TestUtil();
    final encryptedChallengeToken = await util.getRandomEncryptedChallengeToken(
      clientId: clientId,
    );

    final packetData = ConnectionChallengePacketData(
      challengeTokenSequence: sequence,
      encryptedToken: encryptedChallengeToken,
    );
    final prefixByte = ByteManipulationUtil.generatePrefixByte(
      PacketType.challenge.code,
      sequence,
    );
    final packet = await EncryptedPacket.fromClearPacketData(
      sequenceNumber: sequence,
      packetData: packetData,
      nonce: util.challengeTokenNonce,
      encryptionKey: util.challengeTokenKey,
      protocolId: protocolId,
      prefixByte: prefixByte,
      type: PacketType.challenge,
    );

    expect(packet, isNotNull);

    final data = await packet!.getDecryptedData(
      nonce: util.challengeTokenNonce,
      encryptionKey: util.challengeTokenKey,
      protocolId: protocolId,
    ) as ConnectionChallengePacketData;

    expect(data, isNotNull);

    expect(data.challengeTokenSequence, sequence);
    expect(data.encryptedToken, encryptedChallengeToken);

    final decryptedToken = await NetcodeEncryption.decryptChallengeToken(
      encryptedToken: data.encryptedToken,
      nonce: util.challengeTokenNonce,
      encryptionKey: util.challengeTokenKey,
    );

    expect(decryptedToken.clientId, clientId);
    expect(decryptedToken.userData, util.userData);
  });
}
