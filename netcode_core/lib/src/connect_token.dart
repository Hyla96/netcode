import 'dart:typed_data';

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
    required this.data,
  });

  final int clientId;
  final int timeout;
  final List<String> serverAddresses;
  final String clientToServerKey;
  final String serverToClientKey;
  final ByteBuffer data;

  factory PrivateToken.fromBuffer(ByteData data) {
    final addressesLength = data.getUint32(12, Endian.little);
    int addressOffset = 16;
    final addresses = <String>[];

    for (int i = 0; i < addressesLength; i++) {
      final type = data.getUint8(addressOffset).toInt();
      addressOffset++;

      if (type == 1) {
        // IPV4
        var address = "";
        for (int k = 0; k < 4; k++) {
          address +=
              "${k != 0 ? "." : ""}${data.getUint8(addressOffset).toInt()}";
          addressOffset++;
        }
        address += ":";

        address +=
            data.getUint16(addressOffset, Endian.little).toInt().toString();

        addressOffset += 2;
        addresses.add(address);
      } else if (type == 2) {
        // IPV6
        var address = "[";
        for (int k = 0; k < 8; k++) {
          address +=
              "${k != 0 ? ":" : ""}${data.getUint16(addressOffset).toRadixString(16).padLeft(4, "0")}";
          addressOffset += 2;
        }
        address += "]:";

        address +=
            data.getUint16(addressOffset, Endian.little).toInt().toString();

        addressOffset += 2;

        addresses.add(address);
      } else {
        throw Exception('Address type not supported');
      }
    }

    return PrivateToken(
      clientId: BigInt.from(data.getUint64(0, Endian.little)).toInt(),
      timeout: BigInt.from(data.getUint32(8, Endian.little)).toInt(),
      serverAddresses: addresses,
      clientToServerKey: '',
      serverToClientKey: '',
      data: Uint64List(0).buffer,
    );
  }
}
