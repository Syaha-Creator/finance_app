import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/core_snackbar.dart';

/// Helper untuk handle common form submission patterns
///
/// Mengurangi duplikasi untuk loading state, error handling, dan success messages
class FormSubmissionHelper {
  FormSubmissionHelper._();

  /// Execute form submission dengan automatic loading state dan error handling
  ///
  /// [context] - BuildContext untuk navigation dan snackbar
  /// [onLoading] - Callback untuk set loading state (setState(() => _isLoading = true))
  /// [onComplete] - Callback untuk set loading state to false (setState(() => _isLoading = false))
  /// [action] - Async operation yang akan dijalankan
  /// [successMessage] - Success message untuk snackbar
  /// [errorMessage] - Custom error message prefix (default: 'Gagal')
  /// [onSuccess] - Optional callback setelah success (default: pop context)
  /// [onError] - Optional callback untuk custom error handling
  ///
  /// Returns true jika success, false jika error
  static Future<bool> executeWithLoading({
    required BuildContext context,
    required VoidCallback onLoading,
    required VoidCallback onComplete,
    required Future<void> Function() action,
    String? successMessage,
    String errorMessage = 'Gagal',
    VoidCallback? onSuccess,
    void Function(Object error)? onError,
  }) async {
    onLoading();

    try {
      await action();

      if (!context.mounted) return false;
      onComplete();

      if (successMessage != null) {
        CoreSnackbar.showSuccess(context, successMessage);
      }

      if (onSuccess != null) {
        onSuccess();
      } else if (context.canPop()) {
        context.pop();
      }

      return true;
    } catch (error) {
      if (!context.mounted) return false;
      onComplete();

      if (onError != null) {
        onError(error);
      } else {
        CoreSnackbar.showError(context, '$errorMessage: ${error.toString()}');
      }

      return false;
    }
  }

  /// Parse amount string dengan thousand separator
  ///
  /// [value] - String dengan format "1.000.000" atau "1000000"
  ///
  /// Returns parsed double value
  static double parseAmount(String value) {
    final cleanValue = value.replaceAll('.', '');
    return double.parse(cleanValue);
  }

  /// Try parse amount string dengan thousand separator
  ///
  /// [value] - String dengan format "1.000.000" atau "1000000"
  ///
  /// Returns parsed double value atau null jika invalid
  static double? tryParseAmount(String value) {
    final cleanValue = value.replaceAll('.', '');
    return double.tryParse(cleanValue);
  }
}
