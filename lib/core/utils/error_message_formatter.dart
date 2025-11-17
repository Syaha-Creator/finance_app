/// Utility class untuk memformat error message menjadi user-friendly
class ErrorMessageFormatter {
  ErrorMessageFormatter._();

  /// Format error message menjadi user-friendly
  /// Mengubah technical error menjadi pesan yang mudah dipahami user
  static String format(dynamic error) {
    if (error == null) {
      return 'Terjadi kesalahan yang tidak diketahui';
    }

    final errorString = error.toString().toLowerCase();

    // Firebase Auth Errors
    if (errorString.contains('user-not-found')) {
      return 'Email tidak ditemukan. Pastikan email yang Anda masukkan benar.';
    }
    if (errorString.contains('wrong-password')) {
      return 'Password salah. Silakan coba lagi.';
    }
    if (errorString.contains('email-already-in-use')) {
      return 'Email sudah terdaftar. Silakan gunakan email lain atau masuk dengan email ini.';
    }
    if (errorString.contains('weak-password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    }
    if (errorString.contains('invalid-email')) {
      return 'Format email tidak valid. Pastikan email yang Anda masukkan benar.';
    }
    if (errorString.contains('user-disabled')) {
      return 'Akun Anda telah dinonaktifkan. Silakan hubungi administrator.';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
    }
    if (errorString.contains('operation-not-allowed')) {
      return 'Operasi tidak diizinkan. Silakan hubungi administrator.';
    }
    if (errorString.contains('network-request-failed') ||
        errorString.contains('network error')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';
    }

    // Firestore Errors
    if (errorString.contains('permission-denied')) {
      return 'Anda tidak memiliki izin untuk melakukan operasi ini.';
    }
    if (errorString.contains('unavailable')) {
      return 'Layanan sedang tidak tersedia. Silakan coba lagi nanti.';
    }
    if (errorString.contains('deadline-exceeded')) {
      return 'Waktu permintaan habis. Silakan coba lagi.';
    }

    // Generic Errors
    if (errorString.contains('timeout')) {
      return 'Waktu permintaan habis. Periksa koneksi internet Anda.';
    }
    if (errorString.contains('connection') || errorString.contains('connect')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }
    if (errorString.contains('not found')) {
      return 'Data tidak ditemukan.';
    }
    if (errorString.contains('unauthorized') || errorString.contains('unauthorised')) {
      return 'Anda tidak memiliki izin untuk melakukan operasi ini.';
    }
    if (errorString.contains('forbidden')) {
      return 'Akses ditolak. Silakan hubungi administrator.';
    }

    // Format error message yang lebih user-friendly
    // Hapus prefix "Exception: " atau "Error: " jika ada
    String message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    } else if (message.startsWith('Error: ')) {
      message = message.substring(7);
    }

    // Jika masih terlalu technical, berikan pesan default
    if (message.contains('firebase') ||
        message.contains('firestore') ||
        message.contains('platformexception')) {
      return 'Terjadi kesalahan saat memproses permintaan. Silakan coba lagi.';
    }

    return message;
  }

  /// Format error untuk authentication
  static String formatAuthError(dynamic error) {
    final formatted = format(error);
    
    // Tambahkan konteks khusus untuk auth errors
    if (formatted.contains('email') || formatted.contains('password')) {
      return formatted;
    }
    
    return 'Gagal melakukan autentikasi: $formatted';
  }

  /// Format error untuk data operations (CRUD)
  static String formatDataError(dynamic error, {String? operation}) {
    final formatted = format(error);
    final operationText = operation ?? 'operasi';
    
    if (formatted.contains('tidak memiliki izin') ||
        formatted.contains('permission')) {
      return formatted;
    }
    
    return 'Gagal melakukan $operationText: $formatted';
  }
}

