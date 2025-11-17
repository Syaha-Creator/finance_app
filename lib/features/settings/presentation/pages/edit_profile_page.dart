import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    // Check current status
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      final shouldOpenSettings = await _showPermissionDialog(
        'Izin Kamera Diperlukan',
        'Aplikasi membutuhkan izin akses kamera untuk mengambil foto profil. Silakan aktifkan izin kamera di pengaturan.',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
        // Check again after returning from settings
        status = await Permission.camera.status;
        return status.isGranted;
      }
      return false;
    }

    return false;
  }

  Future<bool> _requestStoragePermission() async {
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
        final shouldOpenSettings = await _showPermissionDialog(
          'Izin Galeri Diperlukan',
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
        final shouldOpenSettings = await _showPermissionDialog(
          'Izin Penyimpanan Diperlukan',
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

  Future<void> _pickImage() async {
    try {
      // Request storage permission first
      if (!await _requestStoragePermission()) {
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      CoreSnackbar.showError(context, 'Gagal memilih gambar: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Request camera permission first
      if (!await _requestCameraPermission()) {
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      CoreSnackbar.showError(context, 'Gagal mengambil foto: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final firebaseStorage = ref.read(firebaseStorageProvider);

      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('User tidak ditemukan');

      final storageRef = firebaseStorage
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      await storageRef.putFile(_selectedImage!);
      final downloadURL = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadURL);

      if (!mounted) return;
      CoreSnackbar.showSuccess(context, 'Foto profil berhasil diperbarui!');
    } catch (e) {
      if (!mounted) return;
      CoreSnackbar.showError(context, 'Gagal upload foto: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('User tidak ditemukan');

      // Update display name
      await user.updateDisplayName(_nameController.text.trim());

      // Upload image if selected
      if (_selectedImage != null) {
        await _uploadImage();
      }

      if (!mounted) return;
      CoreSnackbar.showSuccess(context, 'Profil berhasil diperbarui!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CoreSnackbar.showError(context, 'Gagal memperbarui profil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showPermissionDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
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
                    Text(title),
                  ],
                ),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
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
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Buka Pengaturan'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Photo Section
                _buildProfilePhotoSection(context, user, theme),
                const SizedBox(height: 32),

                // Profile Form Section
                _buildProfileFormSection(context, theme),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(
    BuildContext context,
    User user,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage:
                      _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (user.photoURL != null
                              ? NetworkImage(user.photoURL!) as ImageProvider
                              : null),
                  child:
                      _selectedImage == null && user.photoURL == null
                          ? Icon(
                            Icons.person,
                            size: 60,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                          : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Photo Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildPhotoActionButton(
                  context,
                  'Galeri',
                  Icons.photo_library_outlined,
                  _pickImage,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPhotoActionButton(
                  context,
                  'Kamera',
                  Icons.camera_alt_outlined,
                  _takePhoto,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFormSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Pribadi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name Field
          CoreTextField(
            controller: _nameController,
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap Anda',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              if (value.trim().length < 2) {
                return 'Nama minimal 2 karakter';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ThemeData theme) {
    return CoreLoadingButton(
      onPressed: _saveProfile,
      text: 'SIMPAN PERUBAHAN',
      isLoading: _isLoading,
      height: 56,
      icon: Icons.save_outlined,
    );
  }
}
