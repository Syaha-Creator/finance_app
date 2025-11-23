import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/core_snackbar.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';

/// Helper untuk operasi yang berkaitan dengan user
///
/// Mengurangi duplikasi logic untuk check userId dan error handling
class UserHelper {
  UserHelper._();

  /// Get current user ID dari auth state
  ///
  /// Returns null jika user tidak ditemukan
  static String? getCurrentUserId(WidgetRef ref) {
    final authState = ref.read(authStateChangesProvider);
    return authState.value?.uid;
  }

  /// Check dan get current user ID, show error jika null
  ///
  /// [ref] - WidgetRef untuk access providers
  /// [context] - BuildContext untuk show snackbar
  /// [errorMessage] - Custom error message (default: 'Pengguna tidak ditemukan. Silakan login ulang.')
  ///
  /// Returns user ID jika ditemukan, null jika tidak ditemukan (dan sudah show error)
  static String? requireUserId(
    WidgetRef ref,
    BuildContext context, {
    String errorMessage = 'Pengguna tidak ditemukan. Silakan login ulang.',
  }) {
    final userId = getCurrentUserId(ref);

    if (userId == null) {
      CoreSnackbar.showError(context, errorMessage);
      return null;
    }

    return userId;
  }

  /// Check apakah user sudah login
  ///
  /// Returns true jika user sudah login, false jika belum
  static bool isLoggedIn(WidgetRef ref) {
    final authState = ref.read(authStateChangesProvider);
    return authState.value != null;
  }
}
