import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void warn(String message) {
    debugPrint('[WARN] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    final errorPart = error != null ? ' | error: $error' : '';
    final stackPart = stackTrace != null ? '\n$stackTrace' : '';
    debugPrint('[ERROR] $message$errorPart$stackPart');
  }
}
