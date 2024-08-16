import 'dart:math';
import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing connection challenge packet', () async {
    final sequence = 2837123;
    final challengeTokenSequence = 19828;
    final clientId = 177;
    final protocolId = 3117;
    final rng = Random();
    final userData = Uint8List.fromList(
      List.generate(
        256,
        (_) => rng.nextInt(256),
      ),
    );

    final token = ChallengeToken(
      clientId: clientId,
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

    print('token');
    print(token.toByteData().buffer.asUint8List());

    final packet = await EncryptedPacket.fromClearPacketData(
      sequenceNumber:
          ByteManipulationUtil.sequenceNumberToBytes(sequence).lengthInBytes,
      packetData: await ConnectionChallengePacketData.fromClearChallengeToken(
        token: token,
        nonce: nonce,
        key: key,
        challengeTokenSequence: challengeTokenSequence,
      ),
      nonce: nonce,
      encryptionKey: key,
      protocolId: protocolId,
      prefixByte: PacketType.challenge.code << 4 | sequence,
      type: PacketType.challenge,
    );

    final decryptedData = await packet?.getDecryptedData(
      nonce: nonce,
      encryptionKey: key,
      protocolId: protocolId,
    );

    expect(packet, isNotNull);

    final data = packet!.toByteData();
    final parsedPacket = Packet.fromByteData(data) as EncryptedPacket;

    expect(parsedPacket.sequenceNumber, sequence);
  });
}
