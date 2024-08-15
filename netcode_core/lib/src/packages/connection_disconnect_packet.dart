import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionDisconnectPacket extends EncryptedPacket<ByteData> {
  const ConnectionDisconnectPacket({
    required super.sequenceNumber,
    required super.data,
  });

  final type = PacketType.disconnect;

  factory ConnectionDisconnectPacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionDisconnectPacket(
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
