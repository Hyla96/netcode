import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing empty packet data', () async {
    final packetData = EmptyPacketData();

    final data = packetData.toByteData();

    expect(data.lengthInBytes, 0);
  });
}
