import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing keep alive packet data', () async {
    final clientIndex = 29;
    final maxClients = 293;
    final packetData = KeepAlivePackageData(
      clientIndex,
      maxClients,
    );

    final data = packetData.toByteData();
    final parsed = KeepAlivePackageData.fromByteData(data);

    expect(packetData.clientIndex, parsed.clientIndex);
    expect(packetData.maxClients, parsed.maxClients);
  });
}
