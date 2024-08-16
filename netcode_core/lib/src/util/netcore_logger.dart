enum NetcoreLogLevel {
  debug,
  info,
  warning,
  error,
}

class NetcoreLogger {
  static NetcoreLogLevel level = NetcoreLogLevel.debug;

  static log(String message, NetcoreLogLevel level) {
    if (level.index >= level.index) {
      final logLevelString = level.toString().split('.').last.toUpperCase();
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [$logLevelString] $message');
    }
  }

  static void debug(String message) {
    log(message, NetcoreLogLevel.debug);
  }

  static void info(String message) {
    log(message, NetcoreLogLevel.info);
  }

  static void warning(String message) {
    log(message, NetcoreLogLevel.warning);
  }

  static void error(String message) {
    log(message, NetcoreLogLevel.error);
  }
}
