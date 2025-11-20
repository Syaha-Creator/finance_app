import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/services/unverified_user_cleanup_service.dart';
import '../../../../core/utils/logger.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Helper method to handle async Firebase Auth exceptions consistently
  Future<T> _handleAuthExceptionAsync<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation();
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase Auth Exception on $operationName', e);
      throw Exception(e.message);
    } catch (e) {
      AppLogger.error('Error during $operationName', e);
      rethrow;
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _handleAuthExceptionAsync(() async {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(displayName);

      // Send email verification automatically after sign up
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      await userCredential.user?.reload();
      return _firebaseAuth.currentUser;
    }, 'Email Sign Up');
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _handleAuthExceptionAsync(() async {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check and cleanup unverified user if needed
      if (userCredential.user != null) {
        await _checkAndCleanupUnverifiedUser(userCredential.user!);
      }

      return userCredential.user;
    }, 'Email Sign In');
  }

  /// Check and cleanup unverified user if expired
  Future<void> _checkAndCleanupUnverifiedUser(User user) async {
    try {
      await UnverifiedUserCleanupService.checkAndCleanupIfNeeded(user);
    } catch (e) {
      // Silent fail - don't block login
      AppLogger.error('Error in unverified user cleanup check', e);
    }
  }

  Future<User?> signInWithGoogle() async {
    return _handleAuthExceptionAsync(() async {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    }, 'Google Sign In');
  }

  Future<void> resetPassword({required String email}) async {
    await _handleAuthExceptionAsync(
      () => _firebaseAuth.sendPasswordResetEmail(email: email),
      'Reset Password',
    );
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    await _handleAuthExceptionAsync(() async {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        AppLogger.info('Email verification sent successfully');
      } else if (user == null) {
        throw Exception('No user is currently signed in');
      } else {
        throw Exception('Email is already verified');
      }
    }, 'Send Email Verification');
  }

  /// Check if current user's email is verified
  bool isEmailVerified() {
    final user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Reload current user to get latest email verification status
  Future<void> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      AppLogger.error('Error during Reload User', e);
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signOut() async {
    try {
      // Delete FCM token before signing out
      // This removes the device token from Firestore
      await FCMService().deleteToken();

      // Sign out from Google Sign In
      await _googleSignIn.signOut();

      // Sign out from Firebase Auth
      await _firebaseAuth.signOut();

      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Error during Sign Out', e);
      rethrow;
    }
  }
}
