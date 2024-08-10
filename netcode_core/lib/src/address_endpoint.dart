import 'dart:io';
import 'dart:typed_data';

class AddressEndpoint {
  const AddressEndpoint(
    this.address,
    this.port,
  );

  final InternetAddress address;
  final int port;

  factory AddressEndpoint.fromRawAddress(ByteData data, int offset,
      [bool IPV6 = false]) {
    final address =
        data.buffer.asUint8List().sublist(offset, offset + (IPV6 ? 16 : 4));
    return AddressEndpoint(
      InternetAddress.fromRawAddress(
        address,
        type: IPV6 ? InternetAddressType.IPv6 : InternetAddressType.IPv4,
      ),
      data.getUint16(
        offset + (IPV6 ? 16 : 4),
        Endian.little,
      ),
    );
  }

  String toString() {
    if (address.type == InternetAddressType.IPv6) {
      return "[${address.address}]:${port}";
    }
    return "${address.address}:${port}";
  }
}
