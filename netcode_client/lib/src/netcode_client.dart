import 'dart:async';

import 'package:netcode_client/netcode_client.dart';

class NetcodeClient {
  final _stateController = StreamController<NetcodeClientState>.broadcast();

  Stream<NetcodeClientState> get stateAsStream => _stateController.stream;
}
