import 'package:netcode_core/src/packages/lib.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing connection denied packet', () {
    final sequence = 2837123;
    final packet = ConnectionDeniedPacket(
      sequenceNumber: sequence,
    );

    final data = packet.toByteData();
    final parsedPacket = Packet.fromByteData(data);
    print(data.buffer.asUint8List());

    expect(parsedPacket is ConnectionDeniedPacket, isTrue);

    final result = parsedPacket as ConnectionDeniedPacket;

    expect(result.sequenceNumber, sequence);
  });
}
