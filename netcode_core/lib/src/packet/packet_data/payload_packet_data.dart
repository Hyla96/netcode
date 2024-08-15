import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class PayloadPacketData extends PacketData {
  const PayloadPacketData(this.data);
  final ByteData data;
  ByteData toByteData() => this.data;
}
