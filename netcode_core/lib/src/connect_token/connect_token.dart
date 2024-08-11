import 'dart:async';
import 'dart:typed_data';

import 'package:netcode_core/src/address_endpoint.dart';
import 'package:netcode_core/src/connect_token/lib.dart';
import 'package:netcode_core/src/netcode_encryption.dart';
import 'package:netcode_core/src/netcode_version.dart';

class ConnectToken {
  ConnectToken({
    required this.protocolId,
    required this.createdAt,
    required this.expiresAt,
    required this.nonce,
    required this.encryptedPrivateToken,
    required this.timeout,
    required this.serverAddresses,
    required this.clientToServerKey,
    required this.serverToClientKey,
    this.version = NetcodeVersion.v1_02,
  });

  final NetcodeVersion version;
  final int protocolId;
  final int createdAt;
  final int expiresAt;
  final Uint8List nonce;
  final Uint8List encryptedPrivateToken;
  final int timeout;
  final List<AddressEndpoint> serverAddresses;
  final Uint8List clientToServerKey;
  final Uint8List serverToClientKey;

  final _decryptedToken = Completer<PrivateToken>();

  Future<PrivateToken> decryptPrivateToken(Uint8List key) async {
    if (_decryptedToken.isCompleted) {
      return _decryptedToken.future;
    }

    final decrypted = await NetcodeEncryption.decryptPrivateToken(
      encryptedToken: encryptedPrivateToken,
      protocolId: protocolId,
      nonce: nonce,
      encryptionKey: key,
      expiresAt: expiresAt,
    );

    _decryptedToken.complete(decrypted);

    return decrypted;
  }
}
