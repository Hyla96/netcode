import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:netcode_core/src/netcode_version.dart';

import 'connect_token/lib.dart';

class NetcodeEncryption {
  static Future<Uint8List> encryptPrivateToken({
    required PrivateToken token,
    required int protocolId,
    required Uint8List nonce,
    required Uint8List encryptionKey,
    required int expiresAt,
    NetcodeVersion version = NetcodeVersion.v1_02,
  }) async {
    if (nonce.lengthInBytes != 24) {
      throw ("Nonce must have 24 bytes");
    }

    final algorithm = Xchacha20.poly1305Aead();

    final out = Uint8List(1024);

    final secretBox = await algorithm.encrypt(
      token.toByteData().buffer.asUint8List().sublist(0, 1008),
      secretKey: SecretKey(encryptionKey),
      nonce: nonce,
      aad: AssociatedData(
        protocolId: protocolId,
        expiresAt: expiresAt,
        version: version,
      ).toByteData().buffer.asUint8List(),
    );

    out.setRange(0, 1008, secretBox.cipherText);

    out.setRange(1008, 1024, secretBox.mac.bytes);

    return out;
  }

  static Future<PrivateToken> decryptPrivateToken({
    required Uint8List encryptedToken,
    required int protocolId,
    required Uint8List nonce,
    required Uint8List encryptionKey,
    required int expiresAt,
    NetcodeVersion version = NetcodeVersion.v1_02,
  }) async {
    final algorithm = Xchacha20.poly1305Aead();

    final cleartext = await algorithm.decrypt(
      SecretBox(
        encryptedToken.sublist(0, 1008),
        nonce: nonce,
        mac: Mac(encryptedToken.sublist(1008, 1024)),
      ),
      secretKey: SecretKey(encryptionKey),
      aad: AssociatedData(
        protocolId: protocolId,
        expiresAt: expiresAt,
        version: version,
      ).toByteData().buffer.asUint8List(),
    );

    return PrivateToken.fromByteData(
      ByteData.view(
        Uint8List.fromList(cleartext).buffer,
      ),
    );
  }
}
