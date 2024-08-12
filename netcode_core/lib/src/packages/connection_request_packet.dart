import 'dart:typed_data';

import 'package:netcode_core/src/netcode_version.dart';

import 'packet.dart';

class ConnectionRequestPacket extends Packet {
  const ConnectionRequestPacket({
    required this.protocolId,
    required this.expiresAt,
    required this.nonce,
    required this.encryptedPrivateToken,
    this.version = NetcodeVersion.v1_02,
  });
  final type = PacketType.request;

  final NetcodeVersion version;

  final int protocolId;
  final int expiresAt;
  final Uint8List nonce;
  final Uint8List encryptedPrivateToken;
  factory ConnectionRequestPacket.fromByteData(ByteData data) {
    final uint8list = data.buffer.asUint8List(0);
    int offset = 1;

    final version =
        NetcodeVersion.fromAscii(uint8list.sublist(offset, offset + 13));
    offset += 13;

    final protocolId = data.getUint64(offset, Endian.little);
    offset += 8;

    final expiresAt = data.getUint64(offset, Endian.little);
    offset += 8;

    final nonce = uint8list.sublist(offset, offset + 24);
    offset += 24;

    final encryptedPrivateToken = uint8list.sublist(offset, offset + 1024);
    offset += 1024;

    return ConnectionRequestPacket(
      version: version,
      protocolId: protocolId,
      expiresAt: expiresAt,
      nonce: nonce,
      encryptedPrivateToken: encryptedPrivateToken,
    );
  }

  @override
  ByteData toByteData() {
    // TODO: implement toByteData
    throw UnimplementedError();
  }
}
