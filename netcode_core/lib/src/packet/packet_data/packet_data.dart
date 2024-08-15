import 'dart:typed_data';

abstract class PacketData {
  const PacketData();
  ByteData toByteData();
}
