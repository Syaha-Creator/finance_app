import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper untuk common navigation patterns
///
/// Mengurangi duplikasi untuk navigation operations
class NavigationHelper {
  NavigationHelper._();

  /// Pop context jika bisa, dengan optional result
  ///
  /// [context] - BuildContext untuk navigation
  /// [result] - Optional result untuk return
  ///
  /// Returns true jika berhasil pop, false jika tidak bisa pop
  static bool popIfPossible(BuildContext context, [Object? result]) {
    if (context.canPop()) {
      context.pop(result);
      return true;
    }
    return false;
  }

  /// Pop context menggunakan Navigator.of(context).pop()
  ///
  /// [context] - BuildContext untuk navigation
  /// [result] - Optional result untuk return
  static void pop(BuildContext context, [Object? result]) {
    Navigator.of(context).pop(result);
  }

  /// Pop context dengan check mounted
  ///
  /// [context] - BuildContext untuk navigation
  /// [mounted] - Check apakah widget masih mounted
  /// [result] - Optional result untuk return
  ///
  /// Returns true jika berhasil pop, false jika tidak mounted atau tidak bisa pop
  static bool popIfMounted(
    BuildContext context,
    bool mounted, [
    Object? result,
  ]) {
    if (!mounted) return false;
    return popIfPossible(context, result);
  }
}
