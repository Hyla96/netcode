import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing encrypted packet associated data', () async {
    final protocolId = 1381;
    final prefixByte = 19;

    final associatedData = EncryptedPacketAssociatedData(
      protocolId: protocolId,
      prefixByte: prefixByte,
    );

    final data = associatedData.toByteData();

    final parsed = EncryptedPacketAssociatedData.fromByteData(data);

    expect(parsed.protocolId, protocolId);
    expect(parsed.prefixByte, prefixByte);
  });
}
