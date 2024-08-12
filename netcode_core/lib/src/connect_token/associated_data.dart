import 'dart:typed_data';

import 'package:netcode_core/src/netcode_version.dart';

class AssociatedData {
  const AssociatedData({
    this.version = NetcodeVersion.v1_02,
    required this.protocolId,
    required this.expiresAt,
  });

  final NetcodeVersion version;
  final int protocolId;
  final int expiresAt;

  factory AssociatedData.fromByteData(ByteData data) {
    final uint8list = data.buffer.asUint8List();

    int offset = 0;

    final versionEnum =
        NetcodeVersion.fromAscii(uint8list.sublist(offset, offset + 13));
    offset += 13;

    final protocolID = data.getUint64(offset, Endian.little);
    offset += 8;

    final timestamp = data.getUint64(offset, Endian.little);
    offset += 8;

    return AssociatedData(
      version: versionEnum,
      protocolId: protocolID,
      expiresAt: timestamp,
    );
  }

  ByteData toByteData() {
    final data = ByteData(29);
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
      expiresAt.toUnsigned(64),
      Endian.little,
    );

    return data;
  }
}
