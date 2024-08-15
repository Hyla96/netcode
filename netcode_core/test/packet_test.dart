import 'dart:typed_data';

import 'package:netcode_core/src/packages/lib.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing encrypted packet', () {
    final typeCode = 3;
    final sequence = 3813431231;

    final data = ByteData(10);

    data.setUint8(0, 0x34);
    data.setUint32(1, sequence);
    data.setUint32(5, sequence, Endian.little);

    final packet = Packet.fromByteData(data);

    expect(packet, isNotNull);
    expect(packet!.type.code, typeCode);
    expect((packet as EncryptedPacket).sequenceNumber, sequence);
  });

  test('Parsing connection denied packet', () {
    final sequence = 2837123;
    final packet = ConnectionDeniedPacket(
      sequenceNumber: sequence,
    );

    final data = packet.toByteData();
    final parsedPacket = Packet.fromByteData(data);
    print(data.buffer.asUint8List());

    expect(packet.sequenceNumber, sequence);
    expect(parsedPacket is ConnectionDeniedPacket, isTrue);

    final result = parsedPacket as ConnectionDeniedPacket;

    expect(result.sequenceNumber, sequence);
  });
}
