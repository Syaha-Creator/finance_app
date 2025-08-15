import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(authControllerProvider.notifier)
            .signInWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
            );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _submitGoogleLogin() async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    final inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: Colors.grey.shade600),

      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF141832),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/finance_app_logo.png',
                  height: 200,
                  width: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selamat Datang Kembali',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: inputDecoration.copyWith(labelText: 'Email'),
                  validator:
                      (v) => v!.isEmpty ? 'Email tidak boleh kosong' : null,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.black87),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed:
                          () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                    ),
                  ),
                  validator:
                      (v) => v!.isEmpty ? 'Password tidak boleh kosong' : null,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitLogin(),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : const Text('MASUK', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade700)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'atau',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _submitGoogleLogin,
                  icon: Image.asset('assets/google_logo.png', height: 22.0),
                  label: const Text('Masuk dengan Google'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                  child: const Text('Belum punya akun? Daftar sekarang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
