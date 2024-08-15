import 'dart:typed_data';

import 'lib.dart';

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

abstract class EncryptedPacket extends Packet {
  const EncryptedPacket({
    required this.sequenceNumber,
    required this.packetData,
  });

  final int sequenceNumber;
  final ByteData packetData;
  static EncryptedPacket? fromByteData(ByteData data) {
    int offset = 0;

    final firstByte = data.getUint8(0);
    final sequenceLength = firstByte.toUnsigned(4);
    offset++;

    final sequenceNumber = Uint8List.fromList(
      data.buffer
          .asUint8List()
          .sublist(offset, offset + sequenceLength)
          .toList()
        ..addAll(
          List.generate(
            8 - sequenceLength,
            (_) => 0,
          ),
        ),
    ).buffer.asByteData().getUint64(0, Endian.little);
    offset += sequenceLength;

    final packetData = data.buffer.asByteData(offset);

    return switch (PacketType.fromCode((firstByte >> 4).toUnsigned(8))) {
      PacketType.denied =>
        ConnectionDeniedPacket.fromByteData(sequenceNumber, packetData),
      PacketType.challenge =>
        ConnectionChallengePacket.fromByteData(sequenceNumber, packetData),
      PacketType.response =>
        ConnectionResponsePacket.fromByteData(sequenceNumber, packetData),
      PacketType.keepAlive =>
        ConnectionKeepAlivePacket.fromByteData(sequenceNumber, packetData),
      PacketType.payload =>
        ConnectionPayloadPacket.fromByteData(sequenceNumber, packetData),
      PacketType.disconnect =>
        ConnectionDisconnectPacket.fromByteData(sequenceNumber, packetData),
      _ => null,
    };
  }
}

enum PacketType {
  request,
  denied,
  challenge,
  response,
  keepAlive,
  payload,
  disconnect;

  static PacketType? fromCode(int value) {
    return switch (value) {
      0 => PacketType.request,
      1 => PacketType.denied,
      2 => PacketType.challenge,
      3 => PacketType.response,
      4 => PacketType.keepAlive,
      5 => PacketType.payload,
      6 => PacketType.disconnect,
      _ => null
    };
  }

  int get code {
    return switch (this) {
      PacketType.request => 0,
      PacketType.denied => 1,
      PacketType.challenge => 2,
      PacketType.response => 3,
      PacketType.keepAlive => 4,
      PacketType.payload => 5,
      PacketType.disconnect => 6,
    };
  }
}
