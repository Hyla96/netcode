import 'package:netcode_core/src/netcode_encryption.dart';
import 'package:test/test.dart';

void main() {
  group('Associated Data', () {
    setUp(() {});

    test('Testing parsing', () {
      final protocol = 1882;
      final timestamp =
          (DateTime.now().add(Duration(hours: 8)).millisecondsSinceEpoch / 1000)
              .floor();

      final data = AssociatedData(
        protocolID: 1882,
        expiresAt: timestamp,
      );

      final v = data.version.asAscii;

      final raw = data.toByteData();

      final newData = AssociatedData.fromByteData(raw);

      expect(newData.expiresAt, timestamp);
      expect(newData.protocolID, protocol);
      expect(newData.version, data.version);
    });
  });
}
