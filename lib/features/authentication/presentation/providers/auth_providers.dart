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

  /// Helper method to execute async operations with loading/error handling
  Future<void> _executeOperation(Future<void> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      await operation();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _executeOperation(
      () => _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _executeOperation(
      () => _authRepository.signInWithEmail(email: email, password: password),
    );
  }

  Future<void> signInWithGoogle() async {
    await _executeOperation(() => _authRepository.signInWithGoogle());
  }

  Future<void> resetPassword({required String email}) async {
    await _executeOperation(() => _authRepository.resetPassword(email: email));
  }

  Future<void> sendEmailVerification() async {
    await _executeOperation(() => _authRepository.sendEmailVerification());
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
