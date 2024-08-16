import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class EncryptedPacketAssociatedData {
  const EncryptedPacketAssociatedData({
    this.version = NetcodeVersion.v1_02,
    required this.protocolId,
    required this.prefixByte,
  });

  final NetcodeVersion version;
  final int protocolId;
  final int prefixByte;

  factory EncryptedPacketAssociatedData.fromByteData(ByteData data) {
    final uint8list = data.buffer.asUint8List();

    int offset = 0;

    final versionEnum =
        NetcodeVersion.fromAscii(uint8list.sublist(offset, offset + 13));
    offset += 13;

    final protocolID = data.getUint64(offset, Endian.little);
    offset += 8;

    final prefix = data.getUint8(offset);
    offset += 1;

    return EncryptedPacketAssociatedData(
      version: versionEnum,
      protocolId: protocolID,
      prefixByte: prefix,
    );
  }

  ByteData toByteData() {
    final data = ByteData(22);
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

    data.setUint8(offset, prefixByte);

    return data;
  }
}
