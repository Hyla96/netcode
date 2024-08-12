import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:netcode_core/src/address_endpoint.dart';
import 'package:netcode_core/src/connect_token/lib.dart';
import 'package:netcode_core/src/netcode_encryption.dart';
import 'package:netcode_core/src/packages/lib.dart';
import 'package:test/test.dart';

void main() {
  group('Connection request packet', () {
    setUp(() {});

    test('parsing from and to byte data', () async {
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

      final packet = ConnectionRequestPacket(
        protocolId: protocolID,
        expiresAt: timestamp,
        nonce: nonce,
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
