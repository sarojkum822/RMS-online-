import 'dart:developer' as developer;

class LogService {
  static const String _appParams = '\x1B[35m'; // Magenta
  static const String _errorColor = '\x1B[31m'; // Red
  static const String _infoColor = '\x1B[34m'; // Blue
  static const String _resetColor = '\x1B[0m';

  static void logInfo(String message, [String name = 'App']) {
    developer.log(
      '$_infoColor$message$_resetColor',
      name: name,
      time: DateTime.now(),
    );
  }

  static void logDebug(String message, [String name = 'Debug']) {
    developer.log(
      message,
      name: name,
      time: DateTime.now(),
    );
  }

  static void logError(String message, {dynamic error, StackTrace? stackTrace, String name = 'Error'}) {
    developer.log(
      '$_errorColor$message$_resetColor',
      name: name,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    
    // Also print to console for immediate visibility in some terminals
    if (error != null) {
      print('$_errorColor[ERROR] $message$_resetColor');
      print('$_errorColor  -> $error$_resetColor');
      if (stackTrace != null) {
        print('$_appParams$stackTrace$_resetColor');
      }
    }
  }
}
