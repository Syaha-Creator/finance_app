import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/core_snackbar.dart';

/// Helper untuk handle common AsyncValue patterns
///
/// Mengurangi duplikasi untuk handle loading, error, dan success states
class AsyncValueHelper {
  AsyncValueHelper._();

  /// Handle AsyncValue result untuk form submission
  ///
  /// [context] - BuildContext untuk navigation dan snackbar
  /// [state] - AsyncValue state dari controller
  /// [successMessage] - Success message untuk snackbar
  /// [errorMessagePrefix] - Prefix untuk error message (default: 'Gagal')
  /// [onSuccess] - Optional callback setelah success (default: pop context)
  /// [onError] - Optional callback untuk custom error handling
  ///
  /// Returns true jika success, false jika error atau loading
  static bool handleFormResult<T>({
    required BuildContext context,
    required AsyncValue<T> state,
    required String successMessage,
    String errorMessagePrefix = 'Gagal',
    VoidCallback? onSuccess,
    void Function(Object error)? onError,
  }) {
    return state.when(
      data: (_) {
        CoreSnackbar.showSuccess(context, successMessage);
        if (onSuccess != null) {
          onSuccess();
        } else if (context.canPop()) {
          context.pop();
        }
        return true;
      },
      loading: () => false,
      error: (error, _) {
        if (onError != null) {
          onError(error);
        } else {
          CoreSnackbar.showError(
            context,
            '$errorMessagePrefix: ${error.toString()}',
          );
        }
        return false;
      },
    );
  }

  /// Handle AsyncValue result dengan custom data handler
  ///
  /// [context] - BuildContext untuk navigation dan snackbar
  /// [state] - AsyncValue state dari controller
  /// [onData] - Callback untuk handle data
  /// [onError] - Optional callback untuk custom error handling
  /// [errorMessagePrefix] - Prefix untuk error message (default: 'Gagal')
  ///
  /// Returns true jika success, false jika error atau loading
  static bool handleResult<T>({
    required BuildContext context,
    required AsyncValue<T> state,
    required void Function(T data) onData,
    void Function(Object error)? onError,
    String errorMessagePrefix = 'Gagal',
  }) {
    return state.when(
      data: (data) {
        onData(data);
        return true;
      },
      loading: () => false,
      error: (error, _) {
        if (onError != null) {
          onError(error);
        } else {
          CoreSnackbar.showError(
            context,
            '$errorMessagePrefix: ${error.toString()}',
          );
        }
        return false;
      },
    );
  }
}

