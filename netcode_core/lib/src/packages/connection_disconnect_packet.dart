import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionDisconnectPacket extends EncryptedPacket {
  const ConnectionDisconnectPacket({
    required super.sequenceNumber,
  }) : super(data: null);
  final type = PacketType.disconnect;

  factory ConnectionDisconnectPacket.fromByteData(
    int sequenceNumber,
  ) {
    return ConnectionDisconnectPacket(
      sequenceNumber: sequenceNumber,
    );
  }

  @override
  ByteData toByteData() {
    int offset = 0;
    final sequenceNumberBytes =
        ByteManipulationUtil.sequenceNumberToBytes(sequenceNumber);

    final data = ByteData(1 + sequenceNumberBytes.lengthInBytes);
    data.setUint8(
      offset,
      getFirstByte(sequenceNumberBytes.lengthInBytes),
    );
    offset++;

    for (int i in sequenceNumberBytes.reversed) {
      data.setUint8(offset, i);
      offset++;
    }

    return data;
  }
}
