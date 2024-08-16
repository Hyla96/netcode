import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

import 'util/test_util.dart';

void main() {
  group('Connection request packet', () {
    setUp(() {});

    test('parsing from and to byte data', () async {
      final clientID = 177;
      final protocolID = 1882;
      final timestamp =
          (DateTime.now().add(Duration(hours: 6)).millisecondsSinceEpoch / 1000)
              .floor();
      final util = TestUtil();

      final encrypted = await util.getRandomEncryptedPrivateToken(
        clientId: clientID,
        protocolId: protocolID,
        timestamp: timestamp,
      );

      final packet = ConnectionRequestPacket(
        protocolId: protocolID,
        expiresAt: timestamp,
        nonce: util.privateTokenNonce,
        encryptedPrivateToken: encrypted,
      );

      final data = packet.toByteData();

      final parsed = Packet.fromByteData(data);

      expect(parsed, isNotNull);
      expect(parsed, isA<ConnectionRequestPacket>());

      final casted = parsed as ConnectionRequestPacket;

      expect(casted.protocolId, packet.protocolId);
      expect(casted.expiresAt, packet.expiresAt);
      expect(casted.nonce, packet.nonce);
      expect(casted.encryptedPrivateToken, packet.encryptedPrivateToken);

      final decrypted = await NetcodeEncryption.decryptPrivateToken(
        encryptedToken: casted.encryptedPrivateToken,
        protocolId: protocolID,
        nonce: util.privateTokenNonce,
        encryptionKey: util.privateTokenKey,
        expiresAt: timestamp,
      );

      expect(decrypted.timeout, 30);
      expect(decrypted.serverToClientKey, util.serverToClientKey);
      expect(decrypted.clientToServerKey, util.clientToServerKey);
      expect(decrypted.clientId, clientID);
      expect(decrypted.userData, util.userData);
    });
  });
}
