/// Common form validators untuk mengurangi duplikasi
///
/// Berisi validator-validator yang sering digunakan di berbagai form
class FormValidators {
  FormValidators._();

  /// Validator untuk field yang wajib diisi
  ///
  /// [errorMessage] - Custom error message (default: 'Field ini harus diisi')
  static String? Function(String?)? required({
    String errorMessage = 'Field ini harus diisi',
  }) {
    return (value) {
      if (value == null || value.isEmpty || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validator untuk amount/number yang harus lebih dari 0
  ///
  /// [errorMessage] - Custom error message untuk field kosong
  /// [invalidMessage] - Custom error message untuk nilai tidak valid
  /// [zeroMessage] - Custom error message untuk nilai 0 atau negatif
  static String? Function(String?)? amount({
    String errorMessage = 'Jumlah harus diisi',
    String invalidMessage = 'Jumlah tidak valid',
    String zeroMessage = 'Jumlah harus lebih dari 0',
  }) {
    return (value) {
      if (value == null || value.isEmpty || value.trim().isEmpty) {
        return errorMessage;
      }

      // Remove thousand separators
      final cleanValue = value.replaceAll('.', '');
      final amount = double.tryParse(cleanValue);

      if (amount == null) {
        return invalidMessage;
      }

      if (amount <= 0) {
        return zeroMessage;
      }

      return null;
    };
  }

  /// Validator untuk positive number (bisa decimal)
  ///
  /// [errorMessage] - Custom error message untuk field kosong
  /// [invalidMessage] - Custom error message untuk nilai tidak valid
  /// [zeroMessage] - Custom error message untuk nilai 0 atau negatif
  static String? Function(String?)? positiveNumber({
    String errorMessage = 'Nilai harus diisi',
    String invalidMessage = 'Nilai tidak valid',
    String zeroMessage = 'Nilai harus lebih dari 0',
  }) {
    return amount(
      errorMessage: errorMessage,
      invalidMessage: invalidMessage,
      zeroMessage: zeroMessage,
    );
  }

  /// Validator untuk email
  ///
  /// [errorMessage] - Custom error message untuk field kosong
  /// [invalidMessage] - Custom error message untuk format tidak valid
  static String? Function(String?)? email({
    String errorMessage = 'Email harus diisi',
    String invalidMessage = 'Format email tidak valid',
  }) {
    return (value) {
      if (value == null || value.isEmpty || value.trim().isEmpty) {
        return errorMessage;
      }

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value.trim())) {
        return invalidMessage;
      }

      return null;
    };
  }

  /// Validator untuk password (minimal 6 karakter)
  ///
  /// [errorMessage] - Custom error message untuk field kosong
  /// [minLengthMessage] - Custom error message untuk panjang tidak cukup
  static String? Function(String?)? password({
    String errorMessage = 'Password harus diisi',
    String minLengthMessage = 'Password minimal 6 karakter',
    int minLength = 6,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return errorMessage;
      }

      if (value.length < minLength) {
        return minLengthMessage;
      }

      return null;
    };
  }
}
