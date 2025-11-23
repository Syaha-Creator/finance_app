import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/presentation/base_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return AuthController(authRepository: authRepository, ref: ref);
    });

class AuthController extends BaseController {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository, required super.ref})
    : _authRepository = authRepository,
      super();

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await executeWithLoading(
      () => _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
      providersToInvalidate:
          [], // Auth state handled by authStateChangesProvider
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await executeWithLoading(
      () => _authRepository.signInWithEmail(email: email, password: password),
      providersToInvalidate:
          [], // Auth state handled by authStateChangesProvider
    );
  }

  Future<void> signInWithGoogle() async {
    await executeWithLoading(
      () => _authRepository.signInWithGoogle(),
      providersToInvalidate:
          [], // Auth state handled by authStateChangesProvider
    );
  }

  Future<void> resetPassword({required String email}) async {
    await executeWithLoading(
      () => _authRepository.resetPassword(email: email),
      providersToInvalidate:
          [], // Auth state handled by authStateChangesProvider
    );
  }

  Future<void> sendEmailVerification() async {
    await executeWithLoading(
      () => _authRepository.sendEmailVerification(),
      providersToInvalidate:
          [], // Auth state handled by authStateChangesProvider
    );
  }

  Future<void> reloadUser() async {
    try {
      await _authRepository.reloadUser();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  bool isEmailVerified() {
    return _authRepository.isEmailVerified();
  }

  User? get currentUser => _authRepository.currentUser;

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
