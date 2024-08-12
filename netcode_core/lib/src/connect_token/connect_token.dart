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

  factory ConnectToken.fromByteData(ByteData data) {
    final dataUint8 = data.buffer.asUint8List();

    int offset = 0;

    final version = dataUint8.sublist(offset, offset + 13);

    final versionEnum = NetcodeVersion.fromAscii(version);
    offset += 13;

    final protocolId = data.getUint64(offset, Endian.little);
    offset += 8;

    final createdAt = data.getUint64(offset, Endian.little);
    offset += 8;

    final expiresAt = data.getUint64(offset, Endian.little);
    offset += 8;

    final nonce = dataUint8.sublist(offset, offset + 24);
    offset += 24;

    final encryptedToken = dataUint8.sublist(offset, offset + 1024);
    offset += 1024;

    final timeout = data.getUint32(offset, Endian.little);
    offset += 4;

    final addressesLength = data.getUint32(offset, Endian.little);
    offset += 4;

    if (addressesLength < 1 || addressesLength > 32) {
      throw Exception("Address length not valid: $addressesLength");
    }

    final addresses = <AddressEndpoint>[];

    for (int i = 0; i < addressesLength; i++) {
      final type = data.getUint8(offset).toInt();
      offset++;

      if (type == 1) {
        // IPV4
        addresses.add(AddressEndpoint.fromRawAddress(data, offset));
        offset += 6;
      } else if (type == 2) {
        // IPV6
        addresses.add(AddressEndpoint.fromRawAddress(data, offset, true));
        offset += 18;
      } else {
        throw Exception('Address type not supported');
      }
    }

    final clientToServerKey = dataUint8.sublist(offset, offset + 32);
    offset += 32;

    final serverToClientKey = dataUint8.sublist(offset, offset + 32);
    offset += 32;

    return ConnectToken(
      version: versionEnum,
      protocolId: protocolId,
      expiresAt: expiresAt,
      createdAt: createdAt,
      nonce: nonce,
      encryptedPrivateToken: encryptedToken,
      timeout: timeout,
      serverAddresses: addresses,
      clientToServerKey: clientToServerKey,
      serverToClientKey: serverToClientKey,
    );
  }
  static Future<ConnectToken> fromClearToken({
    required int protocolId,
    required int createdAt,
    required int expiresAt,
    required Uint8List nonce,
    required Uint8List encryptionKey,
    required PrivateToken token,
    required int timeout,
    required List<AddressEndpoint> serverAddresses,
    required Uint8List clientToServerKey,
    required Uint8List serverToClientKey,
    NetcodeVersion version = NetcodeVersion.v1_02,
  }) async {
    final encryptedToken = await NetcodeEncryption.encryptPrivateToken(
      token: token,
      protocolId: protocolId,
      nonce: nonce,
      encryptionKey: encryptionKey,
      expiresAt: expiresAt,
    );

    return ConnectToken(
      protocolId: protocolId,
      createdAt: createdAt,
      expiresAt: expiresAt,
      nonce: nonce,
      encryptedPrivateToken: encryptedToken,
      timeout: timeout,
      serverAddresses: serverAddresses,
      clientToServerKey: clientToServerKey,
      serverToClientKey: serverToClientKey,
    );
  }

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
      offset++;
    }

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

    for (int i = 0; i < 24; i++) {
      if (i < nonce.length) {
        data.setUint8(offset, nonce[i]);
      }
      offset++;
    }

    for (int i = 0; i < 1024; i++) {
      if (i < encryptedPrivateToken.length) {
        data.setUint8(offset, encryptedPrivateToken[i]);
      }
      offset++;
    }

    data.setUint32(
      offset,
      timeout.toUnsigned(32),
      Endian.little,
    );
    offset += 4;

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
