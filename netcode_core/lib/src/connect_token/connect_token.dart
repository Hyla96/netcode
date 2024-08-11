import 'dart:async';
import 'dart:io';
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

  ByteData toByteData() {
    final data = ByteData(2048);
    int offset = 0;

    final version = this.version.asAscii;

    for (int i = 0; i < 13; i++) {
      if (i < version.length) {
        data.setUint8(offset, version[i]);
      }
    }
    offset += 13;

    data.setUint64(
      offset,
      protocolId.toUnsigned(64),
      Endian.little,
    );
    offset += 8;

    data.setUint64(
      offset,
      createdAt.toUnsigned(64),
      Endian.little,
    );
    offset += 8;

    data.setUint64(
      offset,
      expiresAt.toUnsigned(64),
      Endian.little,
    );
    offset += 8;

    for (int i = 0; i < nonce.length; i++) {
      if (i < version.length) {
        data.setUint8(offset, nonce[i]);
      }
      offset++;
    }
    offset += nonce.lengthInBytes;

    for (int i = 0; i < 1024; i++) {
      if (i < encryptedPrivateToken.length) {
        data.setUint8(offset, encryptedPrivateToken[i]);
      }
      offset++;
    }

    data.setUint32(
      offset,
      serverAddresses.length.toUnsigned(32),
      Endian.little,
    );
    offset += 4;

    for (final endpoint in serverAddresses) {
      if (endpoint.address.type == InternetAddressType.IPv4) {
        data.setUint8(
          offset,
          1.toUnsigned(8),
        );
      } else if (endpoint.address.type == InternetAddressType.IPv6) {
        data.setUint8(
          offset,
          2.toUnsigned(8),
        );
      } else {
        throw Exception('Address type not valid');
      }

      offset += 1;

      for (final v in endpoint.address.rawAddress) {
        data.setUint8(offset, v);
        offset++;
      }

      data.setUint16(
        offset,
        endpoint.port.toUnsigned(16),
        Endian.little,
      );
      offset += 2;
    }

    for (final key in clientToServerKey) {
      data.setUint8(offset, key);
      offset++;
    }

    for (final key in serverToClientKey) {
      data.setUint8(offset, key);
      offset++;
    }

    return data;
  }
}
