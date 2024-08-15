import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ConnectionKeepAlivePacket extends EncryptedPacket<ByteData> {
  const ConnectionKeepAlivePacket({
    required super.sequenceNumber,
    required super.data,
  });

  final type = PacketType.keepAlive;

  factory ConnectionKeepAlivePacket.fromByteData(
    int sequenceNumber,
    ByteData data,
  ) {
    return ConnectionKeepAlivePacket(
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
