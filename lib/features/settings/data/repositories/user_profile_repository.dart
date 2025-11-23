import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_profile_model.dart';

class UserProfileRepository extends BaseRepository {
  UserProfileRepository({required super.firestore, required super.firebaseAuth});

  /// Get user profile stream
  Stream<UserProfileModel?> getUserProfileStream() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Stream.value(null);
      }

      return firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        return UserProfileModel.fromFirestore(doc);
      });
    } catch (e) {
      Logger.error('getUserProfileStream failed', e);
      return Stream.value(null);
    }
  }

  /// Get user profile once
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return null;
      }

      final doc = await firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfileModel.fromFirestore(doc);
    } catch (e) {
      Logger.error('getUserProfile failed', e);
      return null;
    }
  }

  /// Save or update user profile
  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      final userId = requiredUserId;

      final data = profile.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
      ).toFirestore();

      // Set createdAt only if it doesn't exist
      if (profile.createdAt == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .set(data, SetOptions(merge: true));

      Logger.info('User profile saved successfully');
    } catch (e) {
      Logger.error('saveUserProfile failed', e);
      rethrow;
    }
  }

  /// Update specific fields in user profile
  Future<void> updateUserProfileFields(Map<String, dynamic> fields) async {
    try {
      final userId = requiredUserId;

      final updateData = {
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .set(updateData, SetOptions(merge: true));

      Logger.info('User profile fields updated successfully');
    } catch (e) {
      Logger.error('updateUserProfileFields failed', e);
      rethrow;
    }
  }
}

