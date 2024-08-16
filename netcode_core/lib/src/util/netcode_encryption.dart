import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:netcode_core/netcode_core.dart';

class NetcodeEncryption {
  static Future<Uint8List> encryptPrivateToken({
    required PrivateToken token,
    required int protocolId,
    required Uint8List nonce,
    required Uint8List encryptionKey,
    required int expiresAt,
    NetcodeVersion version = NetcodeVersion.v1_02,
  }) async {
    if (nonce.lengthInBytes != PRIVATE_TOKEN_NONCE_LENGTH) {
      throw ("Nonce must have $PRIVATE_TOKEN_NONCE_LENGTH bytes");
    }

    final algorithm = Xchacha20.poly1305Aead();

    final out = Uint8List(PRIVATE_TOKEN_MAX_LENGTH);

    final secretBox = await algorithm.encrypt(
      token
          .toByteData()
          .buffer
          .asUint8List()
          .sublist(0, PRIVATE_TOKEN_MAX_LENGTH - PRIVATE_TOKEN_HMAC_LENGTH),
      secretKey: SecretKey(encryptionKey),
      nonce: nonce,
      aad: PrivateTokenAssociatedData(
        protocolId: protocolId,
        expiresAt: expiresAt,
        version: version,
      ).toByteData().buffer.asUint8List(),
    );

    out.setRange(
      0,
      PRIVATE_TOKEN_MAX_LENGTH - PRIVATE_TOKEN_HMAC_LENGTH,
      secretBox.cipherText,
    );

    out.setRange(
      PRIVATE_TOKEN_MAX_LENGTH - PRIVATE_TOKEN_HMAC_LENGTH,
      1024,
      secretBox.mac.bytes,
    );

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

    if (nonce.lengthInBytes != PRIVATE_TOKEN_NONCE_LENGTH) {
      throw ("Nonce must have $PRIVATE_TOKEN_NONCE_LENGTH bytes");
    }

    final cleartext = await algorithm.decrypt(
      SecretBox(
        encryptedToken.sublist(
          0,
          PRIVATE_TOKEN_MAX_LENGTH - PRIVATE_TOKEN_HMAC_LENGTH,
        ),
        nonce: nonce,
        mac: Mac(
          encryptedToken.sublist(
            PRIVATE_TOKEN_MAX_LENGTH - PRIVATE_TOKEN_HMAC_LENGTH,
            PRIVATE_TOKEN_MAX_LENGTH,
          ),
        ),
      ),
      secretKey: SecretKey(encryptionKey),
      aad: PrivateTokenAssociatedData(
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

  static Future<Uint8List> encryptChallengeToken({
    required ChallengeToken token,
    required Uint8List nonce,
    required Uint8List encryptionKey,
  }) async {
    if (nonce.lengthInBytes != CHALLENGE_TOKEN_NONCE_LENGTH) {
      throw ("Nonce must have $CHALLENGE_TOKEN_NONCE_LENGTH bytes");
    }

    final algorithm = Chacha20.poly1305Aead();

    final out = Uint8List(CHALLENGE_TOKEN_MAX_LENGTH);

    final secretBox = await algorithm.encrypt(
      token
          .toByteData()
          .buffer
          .asUint8List()
          .sublist(0, CHALLENGE_TOKEN_MAX_LENGTH - CHALLENGE_TOKEN_HMAC_LENGTH),
      secretKey: SecretKey(encryptionKey),
      nonce: nonce,
    );

    out.setRange(
      0,
      CHALLENGE_TOKEN_MAX_LENGTH - CHALLENGE_TOKEN_HMAC_LENGTH,
      secretBox.cipherText,
    );

    out.setRange(
      CHALLENGE_TOKEN_MAX_LENGTH - CHALLENGE_TOKEN_HMAC_LENGTH,
      CHALLENGE_TOKEN_MAX_LENGTH,
      secretBox.mac.bytes,
    );

    return out;
  }

  static Future<ChallengeToken> decryptChallengeToken({
    required Uint8List encryptedToken,
    required Uint8List nonce,
    required Uint8List encryptionKey,
  }) async {
    final algorithm = Chacha20.poly1305Aead();

    if (nonce.lengthInBytes != CHALLENGE_TOKEN_NONCE_LENGTH) {
      throw ("Nonce must have $CHALLENGE_TOKEN_NONCE_LENGTH bytes");
    }

    final cleartext = await algorithm.decrypt(
      SecretBox(
        encryptedToken.sublist(
          0,
          CHALLENGE_TOKEN_MAX_LENGTH - CHALLENGE_TOKEN_HMAC_LENGTH,
        ),
        nonce: nonce,
        mac: Mac(
          encryptedToken.sublist(
            CHALLENGE_TOKEN_MAX_LENGTH - CHALLENGE_TOKEN_HMAC_LENGTH,
            CHALLENGE_TOKEN_MAX_LENGTH,
          ),
        ),
      ),
      secretKey: SecretKey(encryptionKey),
    );

    return ChallengeToken.fromByteData(
      ByteData.view(
        Uint8List.fromList(cleartext).buffer,
      ),
    );
  }

  static Future<Uint8List> decryptPacketData({
    required Uint8List encryptedData,
    required Uint8List nonce,
    required Uint8List encryptionKey,
    required int protocolId,
    required int prefixByte,
    NetcodeVersion version = NetcodeVersion.v1_02,
  }) async {
    final algorithm = Chacha20.poly1305Aead();

    final cleartext = await algorithm.decrypt(
      SecretBox(
        encryptedData.sublist(
          0,
          encryptedData.lengthInBytes - ENCRYPTED_TOKEN_MAC_LENGTH,
        ),
        nonce: nonce,
        mac: Mac(
          encryptedData.sublist(
            encryptedData.lengthInBytes - ENCRYPTED_TOKEN_MAC_LENGTH,
            encryptedData.lengthInBytes,
          ),
        ),
      ),
      aad: EncryptedPacketAssociatedData(
        protocolId: protocolId,
        prefixByte: prefixByte,
        version: version,
      ).toByteData().buffer.asUint8List(),
      secretKey: SecretKey(encryptionKey),
    );

    return Uint8List.fromList(cleartext);
  }

  static Future<Uint8List> encryptPacketData({
    required Uint8List data,
    required Uint8List nonce,
    required Uint8List encryptionKey,
    required int protocolId,
    required int prefixByte,
    NetcodeVersion version = NetcodeVersion.v1_02,
  }) async {
    final algorithm = Chacha20.poly1305Aead();

    final secretBox = await algorithm.encrypt(
      data,
      secretKey: SecretKey(encryptionKey),
      nonce: nonce,
      aad: EncryptedPacketAssociatedData(
        protocolId: protocolId,
        version: version,
        prefixByte: prefixByte,
      ).toByteData().buffer.asUint8List(),
    );

    return secretBox.concatenation(nonce: false);
  }
}
