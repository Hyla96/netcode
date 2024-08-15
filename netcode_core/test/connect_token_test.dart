import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

void main() {
  group('Netcode Encryption', () {
    setUp(() {});

    test('encrptyon and decryption of private token', () async {
      final clientID = 177;
      final protocolID = 1882;

      final expiresAt =
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

      final privateToken = PrivateToken(
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

      final encryptedToken = await NetcodeEncryption.encryptPrivateToken(
        token: privateToken,
        protocolId: protocolID,
        nonce: nonce,
        encryptionKey: key,
        expiresAt: expiresAt,
      );

      final token = ConnectToken(
        protocolId: protocolID,
        createdAt: expiresAt,
        expiresAt: expiresAt,
        nonce: nonce,
        encryptedPrivateToken: encryptedToken,
        timeout: privateToken.timeout,
        serverAddresses: privateToken.serverAddresses,
        clientToServerKey: clientToServerKey,
        serverToClientKey: serverToClientKey,
      );

      final data = token.toByteData();

      final parsed = ConnectToken.fromByteData(data);

      expect(parsed.timeout, token.timeout);
      expect(parsed.serverToClientKey, token.serverToClientKey);
      expect(parsed.clientToServerKey, token.clientToServerKey);
    });
  });
}
