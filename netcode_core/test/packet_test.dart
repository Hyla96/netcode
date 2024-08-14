import 'dart:typed_data';

import 'package:netcode_core/src/packages/lib.dart';
import 'package:test/test.dart';

void main() {
  group('Packet', () {
    setUp(() {});

    test('Parsing encrypted package', () {
      final typeCode = 3;
      final sequence = 3813431231;

      final data = ByteData(10);

      data.setUint8(0, 0x34);
      data.setUint32(1, sequence, Endian.little);
      data.setUint32(5, sequence, Endian.little);

      final packet = Packet.fromByteData(data);

      expect(packet, isNotNull);
      expect(packet!.type.code, typeCode);
      expect((packet as EncryptedPacket).sequenceNumber, sequence);
    });
  });
}
