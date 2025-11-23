import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/dialog_helper.dart';

/// Helper class for handling permissions
///
/// Mengurangi duplikasi untuk permission request logic
class PermissionHelper {
  PermissionHelper._(); // Private constructor

  /// Request camera permission with dialog support
  ///
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.camera.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      final shouldOpenSettings = await DialogHelper.showPermissionDialog(
        context: context,
        title: 'Izin Kamera Diperlukan',
        message:
            'Aplikasi membutuhkan izin akses kamera untuk mengambil foto profil. Silakan aktifkan izin kamera di pengaturan.',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
        status = await Permission.camera.status;
        return status.isGranted;
      }
      return false;
    }

    return false;
  }

  /// Request storage permission with dialog support
  ///
  /// Handles both Android 13+ (photos) and older versions (storage)
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
      if (await Permission.photos.status.isGranted) {
        return true;
      }

      if (await Permission.photos.status.isDenied) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }

      if (await Permission.photos.status.isPermanentlyDenied) {
        if (!context.mounted) return false;
        final shouldOpenSettings = await DialogHelper.showPermissionDialog(
          context: context,
          title: 'Izin Galeri Diperlukan',
          message:
              'Aplikasi membutuhkan izin akses galeri untuk memilih foto profil. Silakan aktifkan izin galeri di pengaturan.',
        );

        if (shouldOpenSettings) {
          await openAppSettings();
          final status = await Permission.photos.status;
          return status.isGranted;
        }
        return false;
      }

      // For older Android versions
      if (await Permission.storage.status.isGranted) {
        return true;
      }

      if (await Permission.storage.status.isDenied) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }

      if (await Permission.storage.status.isPermanentlyDenied) {
        if (!context.mounted) return false;
        final shouldOpenSettings = await DialogHelper.showPermissionDialog(
          context: context,
          title: 'Izin Penyimpanan Diperlukan',
          message:
              'Aplikasi membutuhkan izin akses penyimpanan untuk memilih foto profil. Silakan aktifkan izin penyimpanan di pengaturan.',
        );

        if (shouldOpenSettings) {
          await openAppSettings();
          final status = await Permission.storage.status;
          return status.isGranted;
        }
        return false;
      }

      return false;
    } else {
      // iOS doesn't need explicit storage permission for image picker
      return true;
    }
  }
}

