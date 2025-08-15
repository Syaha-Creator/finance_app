import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
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
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    // --- Gaya input didefinisikan di sini agar bisa digunakan kembali ---
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
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai perjalanan keuanganmu bersama kami.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Nama Lengkap',
                  ),
                  validator:
                      (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
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
                      (v) =>
                          v!.length < 6 ? 'Password minimal 6 karakter' : null,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
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
                          : const Text(
                            'DAFTAR',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
