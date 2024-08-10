import 'dart:io';
import 'dart:typed_data';

import 'package:netcode_core/src/address_endpoint.dart';
import 'package:netcode_core/src/netcode_version.dart';

class ConnectToken {
  const ConnectToken({
    this.version = NetcodeVersion.v1_02,
  });

  final NetcodeVersion version;
}

class PrivateToken {
  const PrivateToken({
    required this.clientId,
    required this.timeout,
    required this.serverAddresses,
    required this.clientToServerKey,
    required this.serverToClientKey,
    required this.userData,
  });

  final int clientId;
  final int timeout;
  final List<AddressEndpoint> serverAddresses;
  final Uint8List clientToServerKey;
  final Uint8List serverToClientKey;
  final Uint8List userData;

  factory PrivateToken.fromByteData(ByteData data) {
    final addressesLength = data.getUint32(12, Endian.little);
    int offset = 16;
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
    final cts = Uint8List(32);
    final stc = Uint8List(32);
    final uData = Uint8List(256);

    for (int i = 0; i < 32; i++) {
      cts[i] = data.getUint8(offset);
      offset++;
    }

    for (int i = 0; i < 32; i++) {
      stc[i] = data.getUint8(offset);
      offset++;
    }

    for (int i = 0; i < 256; i++) {
      uData[i] = data.getUint8(offset);
      offset++;
    }

    return PrivateToken(
      clientId: BigInt.from(data.getUint64(0, Endian.little)).toInt(),
      timeout: BigInt.from(data.getUint32(8, Endian.little)).toInt(),
      serverAddresses: addresses,
      clientToServerKey: cts,
      serverToClientKey: stc,
      userData: uData,
    );
  }

  ByteData toByteData() {
    final data = ByteData(1024);
    int offset = 0;

    data.setUint64(
      offset,
      clientId.toUnsigned(64),
      Endian.little,
    );
    offset += 8;

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

    for (final d in userData) {
      data.setUint8(offset, d);
      offset++;
    }

    return data;
  }
}
