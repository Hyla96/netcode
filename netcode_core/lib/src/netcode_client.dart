class NetcodeClient {
  // Authenticates the client with the backend
  Future<void> authenticate() async {}

  // Request the backend to play a game and receive a connect token
  Future<void> play() async {}

  // Use the connect token to create a UDP connection with the game server
  Future<void> connectToServer() async {}

  // Send packages over the UDP connection created
  Future<void> sendPackage(dynamic data) async {}
}
