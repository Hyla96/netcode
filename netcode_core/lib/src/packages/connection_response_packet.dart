import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionResponsePacket extends EncryptedPacket<ByteData> {
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
      data: data,
    );
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
