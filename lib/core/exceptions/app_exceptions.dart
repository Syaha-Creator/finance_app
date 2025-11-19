/// Base exception class for all app exceptions.
abstract class AppException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() => message;
}

/// Exception thrown when a repository operation fails.
class RepositoryException extends AppException {
  const RepositoryException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  factory RepositoryException.fromError(
    Object error, {
    String? customMessage,
    StackTrace? stackTrace,
  }) {
    return RepositoryException(
      customMessage ?? 'Terjadi kesalahan saat mengakses data',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception thrown when authentication fails.
class AuthenticationException extends AppException {
  const AuthenticationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  factory AuthenticationException.fromError(
    Object error, {
    String? customMessage,
    StackTrace? stackTrace,
  }) {
    return AuthenticationException(
      customMessage ?? 'Gagal melakukan autentikasi',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception thrown when a network operation fails.
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.fromError(
    Object error, {
    String? customMessage,
    StackTrace? stackTrace,
  }) {
    return NetworkException(
      customMessage ??
          'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception thrown when a validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Exception thrown when a user is not authorized to perform an operation.
class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  factory UnauthorizedException.fromError(
    Object error, {
    String? customMessage,
    StackTrace? stackTrace,
  }) {
    return UnauthorizedException(
      customMessage ?? 'Anda tidak memiliki izin untuk melakukan operasi ini',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception thrown when a resource is not found.
class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  factory NotFoundException.fromError(
    Object error, {
    String? customMessage,
    StackTrace? stackTrace,
  }) {
    return NotFoundException(
      customMessage ?? 'Data tidak ditemukan',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
