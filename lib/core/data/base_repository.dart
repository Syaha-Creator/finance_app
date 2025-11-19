import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/performance_service.dart';
import '../utils/logger.dart';

/// Base repository class that provides common functionality for all repositories.
///
/// This class provides:
/// - Access to FirebaseFirestore and FirebaseAuth
/// - Helper methods for common operations (userId validation, error handling)
/// - Consistent error handling patterns
class BaseRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  BaseRepository({required this.firestore, required this.firebaseAuth});

  /// Gets the current user ID, returns null if user is not logged in.
  String? get currentUserId => firebaseAuth.currentUser?.uid;

  /// Gets the current user ID, throws exception if user is not logged in.
  /// Use this when the operation requires a logged-in user.
  String get requiredUserId {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User tidak login');
    }
    return userId;
  }

  /// Gets a collection reference for the given collection name.
  CollectionReference getCollection(String collectionName) {
    return firestore.collection(collectionName);
  }

  /// Gets a document reference for the given collection and document ID.
  DocumentReference getDocument(String collectionName, String documentId) {
    return firestore.collection(collectionName).doc(documentId);
  }

  /// Creates a stream query with error handling.
  /// Returns an empty list stream if userId is null or on error.
  /// SECURITY: If userIdField is provided, it will ALWAYS filter by current user's ID.
  /// If userIdField is null, this method will throw an exception to prevent
  /// accidentally querying all users' data.
  Stream<List<T>> createStreamQuery<T>({
    required String collectionName,
    required T Function(DocumentSnapshot) fromFirestore,
    String? orderByField,
    bool descending = true,
    List<WhereCondition>? whereConditions,
    String? userIdField,
    bool requireUserIdFilter = true, // Security: default to true
  }) {
    try {
      final userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return Stream.value(<T>[]);
      }

      Query query = firestore.collection(collectionName);

      // SECURITY: Always filter by userId if userIdField is provided
      // If requireUserIdFilter is true and userIdField is null, throw exception
      if (requireUserIdFilter && userIdField == null) {
        throw Exception(
          'Security: userIdField is required for $collectionName to prevent accessing all users\' data',
        );
      }

      // Add userId filter if userIdField is provided
      if (userIdField != null) {
        query = query.where(userIdField, isEqualTo: userId);
      }

      // Add additional where conditions
      if (whereConditions != null) {
        for (final condition in whereConditions) {
          query = query.where(condition.field, isEqualTo: condition.value);
        }
      }

      // Add orderBy if provided
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
          })
          .handleError((error) {
            Logger.error('Stream query failed for $collectionName', error);
            return <T>[];
          });
    } catch (e) {
      Logger.error('createStreamQuery failed for $collectionName', e);
      return Stream.value(<T>[]);
    }
  }

  /// Adds a document to a collection.
  /// Throws exception if userId is required but not available.
  /// Note: If data already contains 'userId', it won't be overwritten.
  Future<void> addDocument({
    required String collectionName,
    required Map<String, dynamic> data,
    bool requireUserId = true,
  }) async {
    return PerformanceService().traceDatabaseOperation(
      'add_$collectionName',
      () async {
        try {
          if (requireUserId && !data.containsKey('userId')) {
            final userId = requiredUserId;
            data['userId'] = userId;
          }

          await firestore.collection(collectionName).add(data);
        } catch (e) {
          Logger.error('addDocument failed for $collectionName', e);
          rethrow;
        }
      },
    );
  }

  /// Updates a document in a collection.
  /// Validates that the document belongs to the current user before updating.
  /// Throws exception if userId validation fails.
  Future<void> updateDocument({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> data,
    String? userIdField,
  }) async {
    return PerformanceService().traceDatabaseOperation(
      'update_$collectionName',
      () async {
        try {
          // Validate userId if userIdField is provided
          if (userIdField != null) {
            final userId = requiredUserId;
            final doc =
                await firestore
                    .collection(collectionName)
                    .doc(documentId)
                    .get();

            if (!doc.exists) {
              throw Exception('Document tidak ditemukan');
            }

            final docData = doc.data();
            if (docData == null || docData[userIdField] != userId) {
              throw Exception(
                'Anda tidak memiliki izin untuk mengubah data ini',
              );
            }
          }

          await firestore
              .collection(collectionName)
              .doc(documentId)
              .update(data);
        } catch (e) {
          Logger.error(
            'updateDocument failed for $collectionName/$documentId',
            e,
          );
          rethrow;
        }
      },
    );
  }

  /// Deletes a document from a collection.
  /// Validates that the document belongs to the current user before deleting.
  /// Throws exception if userId validation fails.
  Future<void> deleteDocument({
    required String collectionName,
    required String documentId,
    String? userIdField,
  }) async {
    return PerformanceService().traceDatabaseOperation(
      'delete_$collectionName',
      () async {
        try {
          // Validate userId if userIdField is provided
          if (userIdField != null) {
            final userId = requiredUserId;
            final doc =
                await firestore
                    .collection(collectionName)
                    .doc(documentId)
                    .get();

            if (!doc.exists) {
              throw Exception('Document tidak ditemukan');
            }

            final docData = doc.data();
            if (docData == null || docData[userIdField] != userId) {
              throw Exception(
                'Anda tidak memiliki izin untuk menghapus data ini',
              );
            }
          }

          await firestore.collection(collectionName).doc(documentId).delete();
        } catch (e) {
          Logger.error(
            'deleteDocument failed for $collectionName/$documentId',
            e,
          );
          rethrow;
        }
      },
    );
  }

  /// Gets a single document by ID.
  /// SECURITY: If userIdField is provided, validates that the document
  /// belongs to the current user. Throws exception if validation fails.
  Future<T?> getDocumentById<T>({
    required String collectionName,
    required String documentId,
    required T Function(DocumentSnapshot) fromFirestore,
    String? userIdField,
  }) async {
    return PerformanceService().traceDatabaseOperation(
      'get_$collectionName',
      () async {
        try {
          final doc =
              await firestore.collection(collectionName).doc(documentId).get();

          if (!doc.exists) {
            return null;
          }

          // SECURITY: Validate userId if userIdField is provided
          if (userIdField != null) {
            final userId = requiredUserId;
            final docData = doc.data();
            if (docData == null) {
              throw Exception('Data tidak ditemukan');
            }
            // doc.data() returns Map<String, dynamic>? for Firestore documents
            if (docData[userIdField] != userId) {
              throw Exception(
                'Anda tidak memiliki izin untuk mengakses data ini',
              );
            }
          }

          return fromFirestore(doc);
        } catch (e) {
          Logger.error(
            'getDocumentById failed for $collectionName/$documentId',
            e,
          );
          rethrow;
        }
      },
    );
  }

  /// Gets multiple documents by query.
  /// SECURITY: If userIdField is provided, it will ALWAYS filter by current user's ID.
  /// If userIdField is null and requireUserIdFilter is true, throws exception.
  Future<List<T>> getDocumentsByQuery<T>({
    required String collectionName,
    required T Function(DocumentSnapshot) fromFirestore,
    List<WhereCondition>? whereConditions,
    String? orderByField,
    bool descending = true,
    int? limit,
    String? userIdField,
    bool requireUserIdFilter = true, // Security: default to true
  }) async {
    return PerformanceService().traceDatabaseOperation(
      'query_$collectionName',
      () async {
        try {
          // SECURITY: Validate userId if required
          if (requireUserIdFilter && userIdField == null) {
            throw Exception(
              'Security: userIdField is required for $collectionName to prevent accessing all users\' data',
            );
          }

          final userId = requireUserIdFilter ? requiredUserId : currentUserId;
          if (requireUserIdFilter && (userId == null || userId.isEmpty)) {
            return <T>[];
          }

          Query query = firestore.collection(collectionName);

          // SECURITY: Always filter by userId if userIdField is provided
          if (userIdField != null && userId != null) {
            query = query.where(userIdField, isEqualTo: userId);
          }

          if (whereConditions != null) {
            for (final condition in whereConditions) {
              query = query.where(condition.field, isEqualTo: condition.value);
            }
          }

          if (orderByField != null) {
            query = query.orderBy(orderByField, descending: descending);
          }

          if (limit != null) {
            query = query.limit(limit);
          }

          final snapshot = await query.get();
          return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
        } catch (e) {
          Logger.error('getDocumentsByQuery failed for $collectionName', e);
          rethrow;
        }
      },
    );
  }

  /// Gets a subcollection reference for the given user document and subcollection name.
  /// Pattern: users/{userId}/subcollectionName
  CollectionReference getSubcollection({
    required String parentCollection,
    required String subcollectionName,
    String? userId,
  }) {
    final targetUserId = userId ?? requiredUserId;
    return firestore
        .collection(parentCollection)
        .doc(targetUserId)
        .collection(subcollectionName);
  }

  /// Creates a stream query for a subcollection.
  /// Pattern: users/{userId}/subcollectionName
  Stream<List<T>> createSubcollectionStreamQuery<T>({
    required String parentCollection,
    required String subcollectionName,
    required T Function(DocumentSnapshot) fromFirestore,
    String? orderByField,
    bool descending = true,
    List<WhereCondition>? whereConditions,
    String? userId,
  }) {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null || targetUserId.isEmpty) {
        return Stream.value(<T>[]);
      }

      Query query = getSubcollection(
        parentCollection: parentCollection,
        subcollectionName: subcollectionName,
        userId: targetUserId,
      );

      if (whereConditions != null) {
        for (final condition in whereConditions) {
          query = query.where(condition.field, isEqualTo: condition.value);
        }
      }

      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
          })
          .handleError((error) {
            Logger.error(
              'Subcollection stream query failed for $parentCollection/$subcollectionName',
              error,
            );
            return <T>[];
          });
    } catch (e) {
      Logger.error(
        'createSubcollectionStreamQuery failed for $parentCollection/$subcollectionName',
        e,
      );
      return Stream.value(<T>[]);
    }
  }

  /// Adds a document to a subcollection.
  /// Pattern: users/{userId}/subcollectionName
  Future<void> addDocumentToSubcollection({
    required String parentCollection,
    required String subcollectionName,
    required Map<String, dynamic> data,
    String? userId,
  }) async {
    try {
      final targetUserId = userId ?? requiredUserId;
      await getSubcollection(
        parentCollection: parentCollection,
        subcollectionName: subcollectionName,
        userId: targetUserId,
      ).add(data);
    } catch (e) {
      Logger.error(
        'addDocumentToSubcollection failed for $parentCollection/$subcollectionName',
        e,
      );
      rethrow;
    }
  }

  /// Deletes a document from a subcollection.
  /// Pattern: users/{userId}/subcollectionName
  Future<void> deleteDocumentFromSubcollection({
    required String parentCollection,
    required String subcollectionName,
    required String documentId,
    String? userId,
  }) async {
    try {
      final targetUserId = userId ?? requiredUserId;
      await getSubcollection(
        parentCollection: parentCollection,
        subcollectionName: subcollectionName,
        userId: targetUserId,
      ).doc(documentId).delete();
    } catch (e) {
      Logger.error(
        'deleteDocumentFromSubcollection failed for $parentCollection/$subcollectionName/$documentId',
        e,
      );
      rethrow;
    }
  }
}

/// Helper class for where conditions in Firestore queries.
class WhereCondition {
  final String field;
  final dynamic value;

  WhereCondition({required this.field, required this.value});
}
