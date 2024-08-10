import 'dart:convert';

enum NetcodeVersion {
  v1_02("NETCODE 1.02");

  const NetcodeVersion(this.name);
  final String name;
  List<int> get asAscii => AsciiEncoder().convert(name);
}
