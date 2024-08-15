import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class KeepAlivePackageData extends EncryptedPacketData {
  const KeepAlivePackageData(this.clientIndex, this.maxClients);

  final int clientIndex;
  final int maxClients;

  factory KeepAlivePackageData.fromByteData(ByteData data) {
    return KeepAlivePackageData(
      data.getUint32(0, Endian.little),
      data.getUint32(4, Endian.little),
    );
  }

  ByteData toByteData() {
    final data = ByteData(8);

    data.setUint32(0, clientIndex, Endian.little);
    data.setUint32(4, maxClients, Endian.little);

    return data;
  }
}
