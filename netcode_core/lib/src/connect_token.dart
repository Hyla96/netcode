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
    required this.userData,
  });

  final int clientId;
  final int timeout;
  final List<String> serverAddresses;
  final Uint8List clientToServerKey;
  final Uint8List serverToClientKey;
  final Uint8List userData;

  factory PrivateToken.fromBuffer(ByteData data) {
    final addressesLength = data.getUint32(12, Endian.little);
    int offset = 16;
    final addresses = <String>[];

    for (int i = 0; i < addressesLength; i++) {
      final type = data.getUint8(offset).toInt();
      offset++;

      if (type == 1) {
        // IPV4
        var address = "";
        for (int k = 0; k < 4; k++) {
          address += "${k != 0 ? "." : ""}${data.getUint8(offset).toInt()}";
          offset++;
        }
        address += ":";

        address += data.getUint16(offset, Endian.little).toInt().toString();

        offset += 2;
        addresses.add(address);
      } else if (type == 2) {
        // IPV6
        var address = "[";
        for (int k = 0; k < 8; k++) {
          address +=
              "${k != 0 ? ":" : ""}${data.getUint16(offset).toRadixString(16).padLeft(4, "0")}";
          offset += 2;
        }
        address += "]:";

        address += data.getUint16(offset, Endian.little).toInt().toString();

        offset += 2;

        addresses.add(address);
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
}
