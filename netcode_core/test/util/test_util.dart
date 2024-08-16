import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class TestUtil {
  final privateTokenNonce = Uint8List.fromList(
    List.generate(
      24,
      (_) => Random().nextInt(256),
    ),
  );

  final privateTokenKey = Uint8List.fromList(
    List.generate(
      32,
      (_) => Random().nextInt(256),
    ),
  );

  final challengeTokenNonce = Uint8List.fromList(
    List.generate(
      12,
      (_) => Random().nextInt(256),
    ),
  );

  final challengeTokenKey = Uint8List.fromList(
    List.generate(
      32,
      (_) => Random().nextInt(256),
    ),
  );
  final clientToServerKey = Uint8List.fromList(
    List.generate(
      32,
      (_) => Random().nextInt(256),
    ),
  );

  final serverToClientKey = Uint8List.fromList(
    List.generate(
      32,
      (_) => Random().nextInt(256),
    ),
  );

  final userData = Uint8List.fromList(
    List.generate(
      256,
      (_) => Random().nextInt(256),
    ),
  );

  PrivateToken getPrivateToken({
    int clientId = 177,
  }) {
    return PrivateToken(
      clientId: clientId,
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
  }

  Future<Uint8List> getRandomEncryptedPrivateToken({
    required int timestamp,
    int protocolId = 2983,
    int clientId = 177,
  }) async {
    final token = getPrivateToken(clientId: clientId);

    final encrypted = await NetcodeEncryption.encryptPrivateToken(
      token: token,
      protocolId: protocolId,
      nonce: privateTokenNonce,
      encryptionKey: privateTokenKey,
      expiresAt: timestamp,
    );

    return encrypted;
  }

  Future<Uint8List> getRandomEncryptedChallengeToken({
    int clientId = 177,
  }) async {
    final token = ChallengeToken(
      clientId: clientId,
      userData: userData,
    );

    return NetcodeEncryption.encryptChallengeToken(
      token: token,
      nonce: challengeTokenNonce,
      encryptionKey: challengeTokenKey,
    );
  }
}
