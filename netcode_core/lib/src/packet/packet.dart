import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

abstract class Packet {
  const Packet();

  PacketType get type;

  ByteData toByteData();
  static Packet? fromByteData(ByteData data) {
    final type = PacketType.fromCode(data.getUint8(0).toUnsigned(8));
    if (type == PacketType.request) {
      return ConnectionRequestPacket.fromByteData(data);
    }
    return EncryptedPacket.fromByteData(data);
  }
}

abstract class EncryptedPacket<T extends EncryptedPacketData> extends Packet {
  const EncryptedPacket({
    required this.sequenceNumber,
    required this.data,
  });

  final int sequenceNumber;
  final T data;
  static EncryptedPacket? fromByteData(ByteData data) {
    int offset = 0;

    final firstByte = data.getUint8(0);
    final sequenceLength = firstByte & 0x0F;
    offset++;

    final sequenceNumber = Uint8List.fromList(
      data.buffer.asUint8List(offset, sequenceLength).reversed.toList()
        ..addAll(
          List.generate(
            8 - sequenceLength,
            (_) => 0,
          ),
        ),
    ).buffer.asByteData().getUint64(0, Endian.little);
    offset += sequenceLength;

    final packetData =
        data.buffer.asUint8List().sublist(offset).buffer.asByteData();
    return switch (PacketType.fromCode((firstByte >> 4).toUnsigned(8))) {
      PacketType.denied => ConnectionDeniedPacket.fromByteData(sequenceNumber),
      PacketType.challenge =>
        ConnectionChallengePacket.fromByteData(sequenceNumber, packetData),
      PacketType.response =>
        ConnectionResponsePacket.fromByteData(sequenceNumber, packetData),
      PacketType.keepAlive =>
        ConnectionKeepAlivePacket.fromByteData(sequenceNumber, packetData),
      PacketType.payload =>
        ConnectionPayloadPacket.fromByteData(sequenceNumber, packetData),
      PacketType.disconnect =>
        ConnectionDisconnectPacket.fromByteData(sequenceNumber),
      _ => null,
    };
  }

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
