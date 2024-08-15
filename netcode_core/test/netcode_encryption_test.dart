import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

void main() {
  group('Netcode Encryption', () {
    setUp(() {});

    test('encryption and decryption of challenge token', () async {
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

      final encrypted = await NetcodeEncryption.encryptChallengeToken(
        token: token,
        nonce: nonce,
        encryptionKey: key,
      );

      final decrypted = await NetcodeEncryption.decryptChallengeToken(
        encryptedToken: encrypted,
        nonce: nonce,
        encryptionKey: key,
      );

      expect(decrypted.clientId, token.clientId);
      expect(decrypted.userData, token.userData);
    });

    test('encryption and decryption of private token', () async {
      final clientID = 177;
      final protocolID = 1882;
      final timestamp =
          (DateTime.now().add(Duration(hours: 6)).millisecondsSinceEpoch / 1000)
              .floor();
      final rng = Random();
      final clientToServerKey = Uint8List.fromList(
        List.generate(
          32,
          (_) => rng.nextInt(256),
        ),
      );

      final serverToClientKey = Uint8List.fromList(
        List.generate(
          32,
          (_) => rng.nextInt(256),
        ),
      );

      final userData = Uint8List.fromList(
        List.generate(
          256,
          (_) => rng.nextInt(256),
        ),
      );

      final token = PrivateToken(
        clientId: clientID,
        timeout: 30,
        serverAddresses: [
          AddressEndpoint(
            InternetAddress("172.16.254.1"),
            80,
          ),
        ],
        clientToServerKey: clientToServerKey,
        serverToClientKey: serverToClientKey,
        userData: userData,
      );

      final nonce = Uint8List.fromList(
        List.generate(
          24,
          (_) => rng.nextInt(256),
        ),
      );

      final key = Uint8List.fromList(
        List.generate(
          32,
          (_) => rng.nextInt(256),
        ),
      );

      final encrypted = await NetcodeEncryption.encryptPrivateToken(
        token: token,
        protocolId: protocolID,
        nonce: nonce,
        encryptionKey: key,
        expiresAt: timestamp,
      );

      final decrypted = await NetcodeEncryption.decryptPrivateToken(
        encryptedToken: encrypted,
        protocolId: protocolID,
        nonce: nonce,
        encryptionKey: key,
        expiresAt: timestamp,
      );

      expect(decrypted.timeout, token.timeout);
      expect(decrypted.serverToClientKey, token.serverToClientKey);
      expect(decrypted.clientToServerKey, token.clientToServerKey);
      expect(decrypted.clientId, token.clientId);
      expect(decrypted.userData, token.userData);
    });
  });
}
