import 'dart:typed_data';

import 'package:netcode_core/src/util/byte_manipulation_util.dart';

import 'packet.dart';

class ConnectionDeniedPacket extends EncryptedPacket {
  const ConnectionDeniedPacket({
    required super.sequenceNumber,
  }) : super(data: null);
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
