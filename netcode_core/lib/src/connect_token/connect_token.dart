import 'package:netcode_core/src/netcode_version.dart';

class ConnectToken {
  const ConnectToken({
    this.version = NetcodeVersion.v1_02,
  });

  final NetcodeVersion version;
}
