import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionResponsePacket
    extends EncryptedPacket<ConnectionChallengePacketData> {
  const ConnectionResponsePacket({
    required super.sequenceNumber,
    required super.data,
  });

  final type = PacketType.response;

  factory ConnectionResponsePacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionResponsePacket(
      sequenceNumber: sequenceNumber,
      data: ConnectionChallengePacketData.fromByteData(data),
    );
  }

  @override
  ByteData toByteData() {
    int offset = 0;

    final packetData = this.data.toByteData().buffer.asUint8List();
    final sequenceNumberBytes =
        ByteManipulationUtil.sequenceNumberToBytes(sequenceNumber);

    final data = ByteData(
        1 + sequenceNumberBytes.lengthInBytes + packetData.lengthInBytes);

    data.setUint8(
      offset,
      getFirstByte(sequenceNumberBytes.lengthInBytes),
    );
    offset++;

    for (int i in sequenceNumberBytes.reversed) {
      data.setUint8(offset, i);
      offset++;
    }

    for (final p in packetData) {
      data.setUint8(offset, p);
      offset++;
    }

    return data;
  }
}
