import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_providers.dart';
import '../widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/core_snackbar.dart';
import '../../../../core/utils/error_message_formatter.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/services/unverified_user_cleanup_service.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage>
    with TickerProviderStateMixin {
  bool _isResending = false;
  bool _isChecking = false;
  Timer? _checkTimer;
  int? _daysRemaining;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPeriodicCheck();
    _updateDaysRemaining();
  }

  void _updateDaysRemaining() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final daysRemaining = UnverifiedUserCleanupService.getDaysUntilExpiry(
        user,
      );
      setState(() {
        _daysRemaining = daysRemaining;
      });
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
  }

  void _startPeriodicCheck() {
    // Check email verification status every 3 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _checkEmailVerification();
      }
    });
  }

  /// Helper method to handle async operations with loading state
  Future<void> _executeWithLoadingState({
    required bool Function() isBusy,
    required void Function(bool) setBusy,
    required Future<void> Function() operation,
    void Function()? onSuccess,
    void Function(Object)? onError,
  }) async {
    if (isBusy()) return;

    setBusy(true);
    try {
      await operation();
      if (mounted && onSuccess != null) {
        onSuccess();
      }
    } catch (e) {
      if (mounted && onError != null) {
        onError(e);
      }
    } finally {
      if (mounted) {
        setBusy(false);
      }
    }
  }

  /// Helper method to show error message
  void _showError(Object error) {
    CoreSnackbar.showError(
      context,
      ErrorMessageFormatter.formatAuthError(error),
    );
  }

  Future<void> _checkEmailVerification() async {
    await _executeWithLoadingState(
      isBusy: () => _isChecking,
      setBusy: (value) => setState(() => _isChecking = value),
      operation: () async {
        await ref.read(authControllerProvider.notifier).reloadUser();
        final isVerified =
            ref.read(authControllerProvider.notifier).isEmailVerified();

        if (isVerified && mounted) {
          _checkTimer?.cancel();
          CoreSnackbar.showSuccess(context, 'Email berhasil diverifikasi!');
          // Navigate to main page
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go(RoutePaths.main);
            }
          });
        } else {
          // Update days remaining
          _updateDaysRemaining();
        }
      },
      onError: (_) {
        // Silent fail - just continue checking
      },
    );
  }

  Future<void> _resendVerificationEmail() async {
    await _executeWithLoadingState(
      isBusy: () => _isResending,
      setBusy: (value) => setState(() => _isResending = value),
      operation: () async {
        await ref.read(authControllerProvider.notifier).sendEmailVerification();
      },
      onSuccess: () {
        final state = ref.read(authControllerProvider);
        state.when(
          data: (_) {
            CoreSnackbar.showSuccess(
              context,
              'Email verifikasi telah dikirim! Silakan cek inbox Anda.',
            );
          },
          loading: () {},
          error: (error, _) => _showError(error),
        );
      },
      onError: _showError,
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String? _getUserEmail() {
    return ref.read(authControllerProvider.notifier).currentUser?.email;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userEmail = _getUserEmail();

    return Scaffold(
      body: AuthBackground(
        gradientColors: [
          AppColors.secondary,
          AppColors.secondaryLight,
          AppColors.primary,
          AppColors.primaryLight,
        ],
        gradientStops: const [0.0, 0.3, 0.7, 1.0],
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Animated Logo and Header
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: [
                                  ScaleTransition(
                                    scale: _pulseAnimation,
                                    child: const AuthLogo(),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Verifikasi Email',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Silakan verifikasi email Anda untuk melanjutkan',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Main Card Container
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 60,
                                      offset: const Offset(0, 30),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Email Address Section
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.email_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Email Verifikasi',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            AppColors
                                                                .onPrimaryContainer,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  userEmail ?? 'Loading...',
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            theme
                                                                .colorScheme
                                                                .onSurface,
                                                      ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Instructions Section
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.info_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Langkah-langkah:',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          _buildInstructionStep(
                                            theme,
                                            '1',
                                            'Buka email Anda',
                                            Icons.email_outlined,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildInstructionStep(
                                            theme,
                                            '2',
                                            'Cari email dari My Finance',
                                            Icons.search_rounded,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildInstructionStep(
                                            theme,
                                            '3',
                                            'Klik link verifikasi di email',
                                            Icons.link_rounded,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildInstructionStep(
                                            theme,
                                            '4',
                                            'Anda akan otomatis kembali ke aplikasi',
                                            Icons.check_circle_outline_rounded,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Auto-checking indicator
                                    if (_isChecking)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.infoContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.primary),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Memeriksa status verifikasi...',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors
                                                            .onPrimaryContainer,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryContainer
                                              .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.sync_rounded,
                                              size: 16,
                                              color: AppColors.secondary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Memeriksa otomatis setiap 3 detik',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors
                                                            .onSecondaryContainer,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 20),

                                    // Resend button
                                    CompactButton(
                                      onPressed:
                                          _isResending
                                              ? null
                                              : _resendVerificationEmail,
                                      gradientColors: [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                      child:
                                          _isResending
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                              : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.send_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Kirim Ulang Email',
                                                    style: theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Check status button
                                    OutlinedButton(
                                      onPressed:
                                          _isChecking
                                              ? null
                                              : _checkEmailVerification,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      child:
                                          _isChecking
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.primary),
                                                ),
                                              )
                                              : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.refresh_rounded,
                                                    color: AppColors.primary,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Cek Status Sekarang',
                                                    style: theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.copyWith(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Warning about account expiry
                          if (_daysRemaining != null && _daysRemaining! > 0)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    _daysRemaining! <= 2
                                        ? AppColors.error.withValues(alpha: 0.1)
                                        : AppColors.warning.withValues(
                                          alpha: 0.1,
                                        ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      _daysRemaining! <= 2
                                          ? AppColors.error.withValues(
                                            alpha: 0.3,
                                          )
                                          : AppColors.warning.withValues(
                                            alpha: 0.3,
                                          ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _daysRemaining! <= 2
                                        ? Icons.warning_amber_rounded
                                        : Icons.info_outline_rounded,
                                    color:
                                        _daysRemaining! <= 2
                                            ? AppColors.error
                                            : AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _daysRemaining! <= 2
                                              ? 'Peringatan: Akun akan dihapus dalam $_daysRemaining hari!'
                                              : 'Sisa waktu: $_daysRemaining hari untuk verifikasi',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    _daysRemaining! <= 2
                                                        ? AppColors.error
                                                        : AppColors
                                                            .onAccentContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Akun yang tidak diverifikasi dalam 7 hari akan otomatis dihapus',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    _daysRemaining! <= 2
                                                        ? AppColors.error
                                                            .withValues(
                                                              alpha: 0.8,
                                                            )
                                                        : AppColors
                                                            .onAccentContainer
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Back to login / Logout button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .signOut();
                                  context.go(RoutePaths.auth);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 18,
                                ),
                                label: Text(
                                  'Keluar & Kembali ke Login',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
    ThemeData theme,
    String number,
    String text,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
