class ConnectionFailureException implements Exception {
  String errMsg() => 'Failed to connect to server.';
}
