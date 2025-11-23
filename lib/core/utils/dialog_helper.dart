import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Helper untuk common dialog patterns
///
/// Mengurangi duplikasi untuk confirmation dialogs, delete dialogs, dll
class DialogHelper {
  DialogHelper._();

  /// Show delete confirmation dialog
  ///
  /// [context] - BuildContext untuk show dialog
  /// [title] - Dialog title (default: 'Hapus')
  /// [message] - Confirmation message
  /// [itemName] - Optional item name untuk display di message
  /// [onConfirm] - Callback ketika user confirm delete
  /// [onCancel] - Optional callback ketika user cancel
  /// [confirmText] - Confirm button text (default: 'Ya, Hapus')
  /// [cancelText] - Cancel button text (default: 'Batal')
  static Future<void> showDeleteConfirmation({
    required BuildContext context,
    String title = 'Hapus',
    String? message,
    String? itemName,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Ya, Hapus',
    String cancelText = 'Batal',
  }) {
    final finalMessage = message ??
        (itemName != null
            ? 'Apakah Anda yakin ingin menghapus "$itemName"? Tindakan ini tidak dapat dibatalkan.'
            : 'Apakah Anda yakin ingin menghapus item ini? Tindakan ini tidak dapat dibatalkan.');

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title),
            ),
          ],
        ),
        content: Text(finalMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog dengan custom configuration
  ///
  /// [context] - BuildContext untuk show dialog
  /// [title] - Dialog title
  /// [message] - Confirmation message
  /// [confirmText] - Confirm button text
  /// [cancelText] - Cancel button text
  /// [confirmColor] - Confirm button color
  /// [confirmIcon] - Confirm button icon
  /// [onConfirm] - Callback ketika user confirm
  /// [onCancel] - Optional callback ketika user cancel
  static Future<void> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String cancelText = 'Batal',
    Color confirmColor = AppColors.primary,
    IconData? confirmIcon,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: confirmIcon != null
            ? Row(
                children: [
                  Icon(confirmIcon, color: confirmColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title)),
                ],
              )
            : Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show permission dialog untuk request permission dari settings
  ///
  /// [context] - BuildContext untuk show dialog
  /// [title] - Dialog title
  /// [message] - Permission explanation message
  ///
  /// Returns true jika user ingin buka settings, false jika cancel
  static Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

