import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

/// Service untuk cleanup unverified users saat login
///
/// Check dan hapus user yang tidak verified lebih dari 7 hari
class UnverifiedUserCleanupService {
  static const int _expiryDays = 7;

  /// Check dan cleanup unverified user saat login
  ///
  /// Jika user belum verified lebih dari 7 hari, hapus account
  static Future<bool> checkAndCleanupIfNeeded(User user) async {
    try {
      // Skip Google users (already verified)
      final isGoogleUser = user.providerData.any(
        (provider) => provider.providerId == 'google.com',
      );

      if (isGoogleUser || user.emailVerified) {
        return false; // User sudah verified, tidak perlu cleanup
      }

      // Check creation time
      final creationTime = user.metadata.creationTime;
      if (creationTime == null) {
        return false;
      }

      final now = DateTime.now();
      final daysSinceCreation = now.difference(creationTime).inDays;

      if (daysSinceCreation >= _expiryDays) {
        AppLogger.info(
          'User ${user.uid} tidak verified selama $daysSinceCreation hari, akan dihapus',
        );

        // Delete user data from Firestore
        await _deleteUserData(user.uid);

        // Delete user from Auth
        await user.delete();

        AppLogger.info('Unverified user ${user.uid} berhasil dihapus');
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Error checking unverified user cleanup', e);
      return false;
    }
  }

  /// Delete user data from Firestore
  static Future<void> _deleteUserData(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(userId);

      // Check if user document exists
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        return;
      }

      // Delete all subcollections
      final subcollections = ['categories', 'paymentMethods', 'incomeSources'];

      for (final subcollection in subcollections) {
        final subcollectionRef = userDocRef.collection(subcollection);
        final subcollectionDocs = await subcollectionRef.get();

        final deletePromises = subcollectionDocs.docs.map(
          (doc) => doc.reference.delete(),
        );
        await Future.wait(deletePromises);
      }

      // Delete user document
      await userDocRef.delete();

      AppLogger.info('User data $userId berhasil dihapus dari Firestore');
    } catch (e) {
      AppLogger.error('Error deleting user data from Firestore', e);
      // Don't throw - continue with auth deletion
    }
  }

  /// Get days until expiry untuk unverified user
  static int? getDaysUntilExpiry(User user) {
    try {
      final isGoogleUser = user.providerData.any(
        (provider) => provider.providerId == 'google.com',
      );

      if (isGoogleUser || user.emailVerified) {
        return null; // User sudah verified
      }

      final creationTime = user.metadata.creationTime;
      if (creationTime == null) {
        return null;
      }

      final now = DateTime.now();
      final daysSinceCreation = now.difference(creationTime).inDays;
      final daysRemaining = _expiryDays - daysSinceCreation;

      return daysRemaining > 0 ? daysRemaining : 0;
    } catch (e) {
      AppLogger.error('Error calculating days until expiry', e);
      return null;
    }
  }
}
