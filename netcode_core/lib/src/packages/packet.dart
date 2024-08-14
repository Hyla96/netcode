import 'dart:typed_data';

import 'lib.dart';

abstract class Packet {
  const Packet();

  PacketType get type;

  ByteData toByteData();
  static Packet? fromByteData(ByteData data) {
    final code = data.getUint8(0);
    final type = PacketType.fromCode(code);
    if (type == PacketType.request) {
      return ConnectionRequestPacket.fromByteData(data.buffer.asByteData(1));
    }
    return EncryptedPacket.fromByteData(code, data.buffer.asByteData(1));
  }
}

abstract class EncryptedPacket extends Packet {
  const EncryptedPacket({
    required this.sequenceNumber,
    required this.packetData,
  });

  final int sequenceNumber;
  final ByteData packetData;
  static EncryptedPacket? fromByteData(int firstByte, ByteData data) {
    final type = PacketType.fromCode(firstByte >> 4);
    final sequenceLength = (firstByte << 4);

    final sequenceNumber = data.buffer
        .asUint8List(0, sequenceLength)
        .buffer
        .asByteData(0, 8)
        .getUint64(0, Endian.little);

    final packetData = data.buffer.asByteData(sequenceLength);

    return switch (type) {
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
