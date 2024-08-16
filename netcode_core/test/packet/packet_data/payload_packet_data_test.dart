import 'dart:math';
import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  test('Parsing payload packet data', () async {
    final payloadData = Uint8List.fromList(
      List.generate(
        256,
        (_) => Random().nextInt(256),
      ),
    );
    final packetData = PayloadPacketData(payloadData.buffer.asByteData());

    final data = packetData.toByteData();

    expect(data.buffer.asUint8List(), payloadData.buffer.asUint8List());
  });
}
