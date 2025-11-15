import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _checkmarkController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
    );

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anda harus menyetujui syarat dan ketentuan terlebih dahulu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref
            .read(authControllerProvider.notifier)
            .signUpWithEmail(
              displayName: _nameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        AuthErrorSnackbar.show(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AuthBackground(
        gradientColors: [
          AppColors.secondary,
          AppColors.secondaryLight,
          AppColors.primary,
          AppColors.primaryLight,
        ],
        gradientStops: const [0.0, 0.3, 0.7, 1.0],
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Animated Logo and Header - More compact
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 25,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Animated logo - WOW design with gradient and glow!
                                      ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0.05,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0.15,
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withValues(
                                                  alpha: 0.3,
                                                ),
                                                blurRadius: 18,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 6),
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 35,
                                                spreadRadius: 3,
                                                offset: const Offset(0, 12),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Image.asset(
                                              'assets/finance_app_logo.png',
                                              height: 72,
                                              width: 72,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      Text(
                                        'Finance App',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.3),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                      ),
                                      const SizedBox(height: 6),

                                      Text(
                                        'Mulai perjalanan keuangan yang cerdas',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
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
                            ),

                            const SizedBox(height: 24),

                            // Animated Register Form - More compact
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 25,
                                        offset: const Offset(0, 12),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 50,
                                        offset: const Offset(0, 25),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Welcome text - More compact
                                      Text(
                                        'Buat Akun Baru! 🚀',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),

                                      Text(
                                        'Daftar untuk mulai mengelola keuanganmu',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),

                                      // Name Field - More compact
                                      CompactTextField(
                                        controller: _nameController,
                                        label: 'Nama Lengkap',
                                        icon: Icons.person_rounded,
                                        primaryColor: AppColors.secondary,
                                        borderRadius: 14,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Nama tidak boleh kosong';
                                          }
                                          if (value.length < 2) {
                                            return 'Nama minimal 2 karakter';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Email Field - More compact
                                      CompactTextField(
                                        controller: _emailController,
                                        label: 'Email',
                                        icon: Icons.email_rounded,
                                        keyboardType: TextInputType.emailAddress,
                                        primaryColor: AppColors.secondary,
                                        borderRadius: 14,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Email tidak boleh kosong';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Email tidak valid';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Password Field - More compact
                                      CompactTextField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        icon: Icons.lock_rounded,
                                        isPassword: true,
                                        isPasswordVisible: _isPasswordVisible,
                                        onPasswordVisibilityToggle: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                        primaryColor: AppColors.secondary,
                                        borderRadius: 14,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password tidak boleh kosong';
                                          }
                                          if (value.length < 6) {
                                            return 'Password minimal 6 karakter';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Confirm Password Field - More compact
                                      CompactTextField(
                                        controller: _confirmPasswordController,
                                        label: 'Konfirmasi Password',
                                        icon: Icons.lock_reset_rounded,
                                        isPassword: true,
                                        isPasswordVisible: _isConfirmPasswordVisible,
                                        onPasswordVisibilityToggle: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                        primaryColor: AppColors.secondary,
                                        borderRadius: 14,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Konfirmasi password tidak boleh kosong';
                                          }
                                          if (value != _passwordController.text) {
                                            return 'Password tidak cocok';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),

                                      // Terms and Conditions - More compact
                                      _buildCompactTermsCheckbox(theme),
                                      const SizedBox(height: 20),

                                      // Register Button - More compact
                                      CompactButton(
                                        onPressed: _isLoading ? null : _submit,
                                        height: 44,
                                        borderRadius: 14,
                                        gradientColors: const [
                                          AppColors.secondary,
                                          AppColors.secondaryLight,
                                        ],
                                        shadowColor: AppColors.secondary,
                                        child: _isLoading
                                            ? SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      const AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                'Daftar Sekarang',
                                                style: theme.textTheme
                                                    .titleMedium?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Login Link - More compact
                                      _buildCompactLoginLink(theme),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildCompactTermsCheckbox(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
                if (_agreeToTerms) {
                  _checkmarkController.forward();
                } else {
                  _checkmarkController.reverse();
                }
              });
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _agreeToTerms ? AppColors.secondary : Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color:
                      _agreeToTerms ? AppColors.secondary : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child:
                  _agreeToTerms
                      ? ScaleTransition(
                        scale: _checkmarkAnimation,
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                  fontSize: 11,
                ),
                children: [
                  const TextSpan(text: 'Saya setuju dengan '),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Masuk Sekarang',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  decorationThickness: 2,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
