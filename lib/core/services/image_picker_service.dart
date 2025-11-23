import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/permission_helper.dart';
import '../widgets/core_snackbar.dart';

/// Service for handling image picking with permission checks
///
/// Mengurangi duplikasi untuk image picker logic
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery with permission check
  ///
  /// [context] - BuildContext untuk permission dialog
  /// [maxWidth] - Maximum width (default: 512)
  /// [maxHeight] - Maximum height (default: 512)
  /// [imageQuality] - Image quality 0-100 (default: 80)
  ///
  /// Returns File if image is picked, null otherwise
  static Future<File?> pickImageFromGallery(
    BuildContext context, {
    double maxWidth = 512,
    double maxHeight = 512,
    int imageQuality = 80,
  }) async {
    try {
      // Request storage permission first
      if (!await PermissionHelper.requestStoragePermission(context)) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        CoreSnackbar.showError(context, 'Gagal memilih gambar: $e');
      }
      return null;
    }
  }

  /// Pick image from camera with permission check
  ///
  /// [context] - BuildContext untuk permission dialog
  /// [maxWidth] - Maximum width (default: 512)
  /// [maxHeight] - Maximum height (default: 512)
  /// [imageQuality] - Image quality 0-100 (default: 80)
  ///
  /// Returns File if image is picked, null otherwise
  static Future<File?> pickImageFromCamera(
    BuildContext context, {
    double maxWidth = 512,
    double maxHeight = 512,
    int imageQuality = 80,
  }) async {
    try {
      // Request camera permission first
      if (!await PermissionHelper.requestCameraPermission(context)) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        CoreSnackbar.showError(context, 'Gagal mengambil foto: $e');
      }
      return null;
    }
  }
}

