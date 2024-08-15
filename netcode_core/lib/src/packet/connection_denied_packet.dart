import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionDeniedPacket extends EncryptedPacket<EmptyPacketData> {
  const ConnectionDeniedPacket({
    required super.sequenceNumber,
  }) : super(
          data: const EmptyPacketData(),
        );
  final type = PacketType.denied;

  factory ConnectionDeniedPacket.fromByteData(
    int sequenceNumber,
  ) {
    return ConnectionDeniedPacket(
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
