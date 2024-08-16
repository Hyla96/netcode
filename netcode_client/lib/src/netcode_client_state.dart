enum NetcodeClientState {
  connectTokenExpired(-6),
  invalidConnectToken(-5),
  connectionTimedOut(-4),
  connectionResponseTimedOut(-3),
  connectionRequestTimedOut(-2),
  connectionDenied(-1),
  disconnected(0),
  sendingConnectionRequest(1),
  sendingConnectionResponse(2),
  connected(3);

  const NetcodeClientState(this.code);
  final int code;
}
