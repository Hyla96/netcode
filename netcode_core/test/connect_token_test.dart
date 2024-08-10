import 'dart:typed_data';

import 'package:netcode_core/src/connect_token.dart';
import 'package:test/test.dart';

void main() {
  const clientId = 0x1;
  const timeout = 0x1E;
  const addressesLength = 0x02;
  const ipv4Type = 0x01;
  const ipv6Type = 0x02;
  const address_1 = "172.16.254.1:80";
  const address_2 = "[2001:0db8:0000:0000:0000:ff00:0042:8329]:293";
  const address_3 = "172.16.254.2";

  group('Connect Token', () {
    setUp(() {});

    test('Testing private token parsing', () {
      final buffer = ByteData(1024);

      buffer.setUint64(0, clientId, Endian.little);
      buffer.setUint32(8, timeout, Endian.little);

      buffer.setUint32(12, addressesLength, Endian.little);

      buffer.setUint8(16, ipv4Type);

      final address1 = address_1.split(":")[0];
      final address2 = address_2.split("]:")[0].replaceAll('[', '');
      // final address3 = address_3.split(":")[0];

      final port1 = address_1.split(":")[1];
      final port2 = address_2.split("]:")[1];
      // final port3 = address_3.split(":")[1];

      for (int i = 0; i < 4; i++) {
        buffer.setUint8(17 + i, int.parse(address1.split(".")[i]));
      }

      buffer.setUint16(21, int.parse(port1), Endian.little);

      buffer.setUint8(23, ipv6Type);

      for (int i = 0; i < 8; i++) {
        buffer.setUint16(
          24 + (i * 2),
          int.parse(
            address2.split(":")[i],
            radix: 16,
          ),
        );
      }

      buffer.setUint16(40, int.parse(port2), Endian.little);

      final token = PrivateToken.fromBuffer(buffer);

      expect(token.clientId, 1);
      expect(token.timeout, 30);
      expect(token.serverAddresses[0], address_1);
      expect(token.serverAddresses[1], address_2);
    });
  });
}
