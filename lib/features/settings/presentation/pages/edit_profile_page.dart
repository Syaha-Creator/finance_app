import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/auth_helper.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/settings_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _bioController = TextEditingController();
  final _professionController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  DateTime? _dateOfBirth;
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userProfileAsync = ref.read(userProfileStreamProvider);
    userProfileAsync.whenData((profile) {
      if (profile != null) {
        setState(() {
          _nameController.text = profile.displayName;
          _phoneController.text = profile.phoneNumber ?? '';
          _addressController.text = profile.address ?? '';
          _cityController.text = profile.city ?? '';
          _countryController.text = profile.country ?? '';
          _bioController.text = profile.bio ?? '';
          _professionController.text = profile.profession ?? '';
          _dateOfBirth = profile.dateOfBirth;
          _selectedGender = profile.gender;
        });
      } else {
        // Fallback to Firebase Auth
        final user = ref.read(authStateChangesProvider).value;
        if (user != null) {
          setState(() {
            _nameController.text = user.displayName ?? '';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePickerService.pickImageFromGallery(context);
    if (image != null && mounted) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _takePhoto() async {
    final image = await ImagePickerService.pickImageFromCamera(context);
    if (image != null && mounted) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String> _uploadImageAndGetURL() async {
    if (_selectedImage == null) {
      throw Exception('No image selected');
    }

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

    // Update photoURL in Firebase Auth
    await user.updatePhotoURL(downloadURL);

    return downloadURL;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Check email verification before allowing profile edit
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    if (user == null) {
      CoreSnackbar.showError(context, 'User tidak ditemukan');
      return;
    }

    if (AuthHelper.needsEmailVerification(user)) {
      CoreSnackbar.showWarning(
        context,
        'Silakan verifikasi email Anda terlebih dahulu sebelum mengedit profil.',
      );
      // Navigate to email verification page
      if (mounted) {
        context.go(RoutePaths.emailVerification);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use repository directly instead of controller to avoid autoDispose issues
      final profileRepository = ref.read(userProfileRepositoryProvider);

      final displayName = _nameController.text.trim();

      // Update display name in Firebase Auth
      await user.updateDisplayName(displayName);
      if (!mounted) return;

      // Create user profile model
      final currentProfile = await profileRepository.getUserProfile();
      if (!mounted) return;

      final profile = UserProfileModel(
        userId: user.uid,
        displayName: displayName,
        email: user.email,
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
        country:
            _countryController.text.trim().isEmpty
                ? null
                : _countryController.text.trim(),
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        profession:
            _professionController.text.trim().isEmpty
                ? null
                : _professionController.text.trim(),
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
        createdAt: currentProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Upload image first if selected (to get photoURL)
      String? photoURL = user.photoURL;
      if (_selectedImage != null) {
        photoURL = await _uploadImageAndGetURL();
        if (!mounted) return;
      }

      // Update profile with photoURL
      final profileWithPhoto = profile.copyWith(photoURL: photoURL);

      // Save user profile to Firestore using repository directly
      await profileRepository.saveUserProfile(profileWithPhoto);
      if (!mounted) return;

      // Invalidate provider to refresh UI
      ref.invalidate(userProfileStreamProvider);
      if (!mounted) return;

      // Reload user to get latest data
      await user.reload();
      if (!mounted) return;

      CoreSnackbar.showSuccess(context, 'Profil berhasil diperbarui!');
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CoreSnackbar.showError(context, 'Gagal memperbarui profil: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          const SizedBox(height: 20),

          // Phone Number Field
          CoreTextField(
            controller: _phoneController,
            label: 'Nomor Telepon',
            hint: 'Masukkan nomor telepon (opsional)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                // Basic phone validation
                if (value.trim().length < 8) {
                  return 'Nomor telepon minimal 8 digit';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Date of Birth Field
          CoreDatePicker(
            selectedDate: _dateOfBirth,
            onDateSelected: (date) {
              setState(() {
                _dateOfBirth = date;
              });
            },
            label: 'Tanggal Lahir',
            hint: 'Pilih tanggal lahir (opsional)',
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            onClear:
                _dateOfBirth != null
                    ? () {
                      setState(() {
                        _dateOfBirth = null;
                      });
                    }
                    : null,
          ),
          const SizedBox(height: 20),

          // Gender Field
          CoreDropdown<Gender>(
            value: _selectedGender,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            label: 'Jenis Kelamin',
            hint: 'Pilih jenis kelamin (opsional)',
            icon: Icons.person_outline,
            items:
                Gender.values.map((gender) {
                  String label;
                  IconData icon;
                  Color color;
                  switch (gender) {
                    case Gender.male:
                      label = 'Laki-laki';
                      icon = Icons.male;
                      color = AppColors.primary;
                      break;
                    case Gender.female:
                      label = 'Perempuan';
                      icon = Icons.female;
                      color = AppColors.accent;
                      break;
                    case Gender.other:
                      label = 'Lainnya';
                      icon = Icons.person;
                      color = AppColors.secondary;
                      break;
                    case Gender.preferNotToSay:
                      label = 'Tidak ingin menyebutkan';
                      icon = Icons.visibility_off;
                      color = Colors.grey;
                      break;
                  }
                  return DropdownMenuItem<Gender>(
                    value: gender,
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 12),
                        Text(label),
                      ],
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),

          // Address Field
          CoreTextField(
            controller: _addressController,
            label: 'Alamat',
            hint: 'Masukkan alamat lengkap (opsional)',
            icon: Icons.home_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          // City Field
          CoreTextField(
            controller: _cityController,
            label: 'Kota',
            hint: 'Masukkan kota (opsional)',
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 20),

          // Country Field
          CoreTextField(
            controller: _countryController,
            label: 'Negara',
            hint: 'Masukkan negara (opsional)',
            icon: Icons.public_outlined,
          ),
          const SizedBox(height: 20),

          // Profession Field
          CoreTextField(
            controller: _professionController,
            label: 'Profesi',
            hint: 'Masukkan profesi Anda (opsional)',
            icon: Icons.work_outline,
          ),
          const SizedBox(height: 20),

          // Bio Field
          CoreTextField(
            controller: _bioController,
            label: 'Tentang Saya',
            hint: 'Ceritakan tentang diri Anda (opsional)',
            icon: Icons.description_outlined,
            maxLines: 4,
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
