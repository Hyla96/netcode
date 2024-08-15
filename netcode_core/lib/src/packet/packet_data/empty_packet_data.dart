import 'dart:typed_data';

import 'package:netcode_core/netcode_core.dart';

class EmptyPacketData extends PacketData {
  const EmptyPacketData();

  ByteData toByteData() => ByteData(0);
}
