import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionPayloadPacket extends EncryptedPacket<ByteData> {
  const ConnectionPayloadPacket({
    required super.sequenceNumber,
    required super.data,
  });

  final type = PacketType.payload;

  factory ConnectionPayloadPacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionPayloadPacket(
      sequenceNumber: sequenceNumber,
      data: data,
    );
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
