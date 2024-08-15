enum PacketType {
  request,
  denied,
  challenge,
  response,
  keepAlive,
  payload,
  disconnect;

  static PacketType? fromCode(int value) {
    return switch (value) {
      0 => PacketType.request,
      1 => PacketType.denied,
      2 => PacketType.challenge,
      3 => PacketType.response,
      4 => PacketType.keepAlive,
      5 => PacketType.payload,
      6 => PacketType.disconnect,
      _ => null
    };
  }

  int get code {
    return switch (this) {
      PacketType.request => 0,
      PacketType.denied => 1,
      PacketType.challenge => 2,
      PacketType.response => 3,
      PacketType.keepAlive => 4,
      PacketType.payload => 5,
      PacketType.disconnect => 6,
    };
  }
}
