import '../exceptions/app_exceptions.dart';
import '../utils/logger.dart';
import 'error_message_formatter.dart';

/// Utility class for handling errors consistently across the app.
class ErrorHandler {
  ErrorHandler._();

  /// Handles an error and returns a user-friendly message.
  ///
  /// This method:
  /// 1. Logs the error for debugging
  /// 2. Converts the error to an AppException if needed
  /// 3. Returns a user-friendly error message
  static String handleError(
    Object error, {
    String? context,
    StackTrace? stackTrace,
    bool logError = true,
  }) {
    if (logError) {
      final logMessage =
          context != null ? 'Error in $context: $error' : 'Error: $error';
      Logger.error(logMessage, error, stackTrace);
    }

    // If it's already an AppException, use its message
    if (error is AppException) {
      return error.message;
    }

    // Convert to user-friendly message using ErrorMessageFormatter
    return ErrorMessageFormatter.format(error);
  }

  /// Handles an error and returns an AppException.
  ///
  /// This method converts various error types to appropriate AppException.
  static AppException handleErrorAsException(
    Object error, {
    String? context,
    StackTrace? stackTrace,
    bool logError = true,
  }) {
    if (logError) {
      final logMessage =
          context != null ? 'Error in $context: $error' : 'Error: $error';
      Logger.error(logMessage, error, stackTrace);
    }

    // If it's already an AppException, return it
    if (error is AppException) {
      return error;
    }

    // Convert to appropriate exception type based on error
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return NetworkException.fromError(error, stackTrace: stackTrace);
    }

    if (errorString.contains('permission-denied') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return UnauthorizedException.fromError(error, stackTrace: stackTrace);
    }

    if (errorString.contains('not-found') ||
        errorString.contains('not found')) {
      return NotFoundException.fromError(error, stackTrace: stackTrace);
    }

    if (errorString.contains('auth') ||
        errorString.contains('user') ||
        errorString.contains('password') ||
        errorString.contains('email')) {
      return AuthenticationException.fromError(error, stackTrace: stackTrace);
    }

    // Default to RepositoryException for data operations
    return RepositoryException.fromError(error, stackTrace: stackTrace);
  }

  /// Handles an error in a repository context.
  ///
  /// This is a convenience method for repository error handling.
  static String handleRepositoryError(
    Object error, {
    String? operation,
    StackTrace? stackTrace,
  }) {
    return handleError(
      error,
      context: operation != null ? 'Repository.$operation' : 'Repository',
      stackTrace: stackTrace,
    );
  }

  /// Handles an error in an authentication context.
  ///
  /// This is a convenience method for authentication error handling.
  static String handleAuthError(
    Object error, {
    String? operation,
    StackTrace? stackTrace,
  }) {
    handleError(
      error,
      context: operation != null ? 'Auth.$operation' : 'Auth',
      stackTrace: stackTrace,
    );
    return ErrorMessageFormatter.formatAuthError(error);
  }
}
