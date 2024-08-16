import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class ByteManipulationUtil {
  static Uint8List sequenceNumberToBytes(int sequenceNumber) {
    final bytes = <int>[];

    while (sequenceNumber != 0) {
      final byte = sequenceNumber & 0xFF;
      bytes.add(byte.toUnsigned(8));
      sequenceNumber >>= 8;
    }

    return Uint8List.fromList(bytes);
  }

  static int generatePrefixByte(int type, int sequence) {
    return type << 4 | sequenceNumberToBytes(sequence).lengthInBytes;
  }
}

extension ByteManipulationExtension on EncryptedPacket {
  int getFirstByte(int sequenceLength) => type.code << 4 | sequenceLength;
}
