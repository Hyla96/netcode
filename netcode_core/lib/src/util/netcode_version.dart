import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

enum NetcodeVersion {
  v1_02("NETCODE 1.02");

  const NetcodeVersion(this.name);
  final String name;
  Uint8List get asAscii => AsciiEncoder().convert(name + "\x00");

  static NetcodeVersion fromAscii(Uint8List ascii) {
    Function eq = const ListEquality().equals;
    if (NetcodeVersion.values.any(
      (v) => eq(
        v.asAscii.toList(),
        ascii.toList(),
      ),
    )) {
      return NetcodeVersion.values.firstWhere(
        (v) => eq(
          v.asAscii.toList(),
          ascii.toList(),
        ),
      );
    }

    throw Exception("Version is not valid");
  }
}
