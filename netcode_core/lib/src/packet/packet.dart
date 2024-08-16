import 'dart:async';
import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

abstract class Packet {
  const Packet({
    required this.type,
  });

  final PacketType type;

  ByteData toByteData();
  static Packet? fromByteData(ByteData data) {
    final type = PacketType.fromCode(data.getUint8(0).toUnsigned(8));
    if (type == PacketType.request) {
      return ConnectionRequestPacket.fromByteData(data);
    }
    return EncryptedPacket.fromByteData(data);
  }
}

class EncryptedPacket<T extends EncryptedPacketData> extends Packet {
  EncryptedPacket({
    required this.sequenceNumber,
    required this.encryptedData,
    required super.type,
  });

  final int sequenceNumber;
  final ByteData encryptedData;
  final _decryptedData = Completer<EncryptedPacketData>();

  Future<EncryptedPacketData?> getDecryptedData({
    required Uint8List encryptionKey,
    required int protocolId,
  }) async {
    if (_decryptedData.isCompleted) {
      return _decryptedData.future;
    }

    final sequenceNumberBytes =
        ByteManipulationUtil.sequenceNumberToBytes(sequenceNumber);

    final firstByte = getFirstByte(sequenceNumberBytes.lengthInBytes);

    final decrypted = (await NetcodeEncryption.decryptPacketData(
      encryptedData: encryptedData.buffer.asUint8List(),
      sequenceNumber: sequenceNumberBytes,
      encryptionKey: encryptionKey,
      protocolId: protocolId,
      prefixByte: firstByte,
    ))
        .buffer
        .asByteData();

    final parsed = switch (PacketType.fromCode((firstByte >> 4))) {
      PacketType.denied => EmptyPacketData(),
      PacketType.challenge =>
        ConnectionChallengePacketData.fromByteData(decrypted),
      PacketType.response =>
        ConnectionChallengePacketData.fromByteData(decrypted),
      PacketType.keepAlive => KeepAlivePackageData.fromByteData(decrypted),
      PacketType.payload => PayloadPacketData(decrypted),
      PacketType.disconnect => EmptyPacketData(),
      _ => null,
    };

    if (parsed != null) {
      _decryptedData.complete(parsed);
    }

    return parsed;
  }

  static Future<EncryptedPacket<T>>?
      fromClearPacketData<T extends EncryptedPacketData>({
    required T packetData,
    required Uint8List encryptionKey,
    required int sequenceNumber,
    required int protocolId,
    required int prefixByte,
    required PacketType type,
  }) async {
    final encryptedData = await NetcodeEncryption.encryptPacketData(
      data: packetData.toByteData().buffer.asUint8List(),
      sequenceNumber:
          ByteManipulationUtil.sequenceNumberToBytes(sequenceNumber),
      encryptionKey: encryptionKey,
      protocolId: protocolId,
      prefixByte: prefixByte,
    );

    return EncryptedPacket(
      sequenceNumber: sequenceNumber,
      encryptedData: encryptedData.buffer.asByteData(),
      type: type,
    );
  }

  static EncryptedPacket? fromByteData(ByteData data) {
    if (data.lengthInBytes < 18) {
      return null;
    }

    int offset = 0;

    final firstByte = data.getUint8(0);
    final sequenceLength = firstByte & 0x0F;
    final codeByte = firstByte >> 4;

    if (codeByte > 7 ||
        sequenceLength < 1 ||
        sequenceLength > 8 ||
        (data.lengthInBytes < 1 + sequenceLength + 16)) {
      return null;
    }

    final type = PacketType.fromCode(codeByte);

    if (type == null) {
      return null;
    }

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

    switch (type) {
      case PacketType.disconnect:
      case PacketType.denied:
        if (packetData.lengthInBytes != 0) return null;
      case PacketType.challenge:
      case PacketType.response:
        if (packetData.lengthInBytes != 308) return null;
      case PacketType.keepAlive:
        if (packetData.lengthInBytes != 8) return null;
      case PacketType.payload:
        if (packetData.lengthInBytes < 1 || packetData.lengthInBytes > 1200)
          return null;
      case PacketType.request:
        return null;
    }

    return EncryptedPacket(
      sequenceNumber: sequenceNumber,
      encryptedData: packetData,
      type: type,
    );
  }

  ByteData toByteData() {
    int offset = 0;

    final packetData = encryptedData.buffer.asUint8List();

    final sequenceNumberBytes =
        ByteManipulationUtil.sequenceNumberToBytes(sequenceNumber);

    final data = ByteData(
        1 + sequenceNumberBytes.lengthInBytes + packetData.lengthInBytes);

    data.setUint8(
      offset,
      getFirstByte(sequenceNumberBytes.lengthInBytes),
    );
    offset++;

    data.buffer.asUint8List().setRange(
          offset,
          offset + sequenceNumberBytes.lengthInBytes,
          sequenceNumberBytes.reversed,
        );
    offset += sequenceNumberBytes.lengthInBytes;

    data.buffer.asUint8List().setRange(
          offset,
          offset + packetData.lengthInBytes,
          packetData,
        );
    offset += packetData.lengthInBytes;

    return data;
  }
}
