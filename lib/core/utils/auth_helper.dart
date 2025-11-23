import 'package:firebase_auth/firebase_auth.dart';

/// Helper utility untuk authentication-related checks
///
/// Mengurangi duplikasi logic untuk email verification dan Google Sign-In checks
class AuthHelper {
  AuthHelper._();

  /// Check apakah user adalah Google Sign-In user
  ///
  /// Google Sign-In users dianggap sudah verified karena Google
  /// sudah melakukan verifikasi email mereka
  static bool isGoogleUser(User user) {
    return user.providerData.any((info) => info.providerId == 'google.com');
  }

  /// Check apakah email user sudah verified
  ///
  /// Google Sign-In users dianggap sudah verified
  static bool isEmailVerified(User user) {
    return user.emailVerified || isGoogleUser(user);
  }

  /// Check apakah user perlu verifikasi email
  ///
  /// Returns true jika user belum verified dan bukan Google user
  static bool needsEmailVerification(User user) {
    return !isEmailVerified(user);
  }
}
