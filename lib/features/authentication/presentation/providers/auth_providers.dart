import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(false);

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = true;
    try {
      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = false;
      return true;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = true;
    try {
      await _authRepository.signInWithEmail(email: email, password: password);
      state = false;
      return true;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = true;
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      // Error bisa ditangani di sini jika perlu
    }
    if (mounted) {
      state = false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
