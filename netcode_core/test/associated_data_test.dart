import 'package:netcode_core/src/connect_token/lib.dart';
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
        protocolId: 1882,
        expiresAt: timestamp,
      );

      final newData = AssociatedData.fromByteData(data.toByteData());

      expect(newData.expiresAt, timestamp);
      expect(newData.protocolId, protocol);
      expect(newData.version, data.version);
    });
  });
}
