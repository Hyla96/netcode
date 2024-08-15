import 'dart:typed_data';

abstract class EncryptedPacketData {
  const EncryptedPacketData();
  ByteData toByteData();
}
