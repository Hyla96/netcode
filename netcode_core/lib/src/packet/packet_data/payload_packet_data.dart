import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class PayloadPacketData extends EncryptedPacketData {
  const PayloadPacketData(this.data);
  final ByteData data;
  ByteData toByteData() => this.data;
}
