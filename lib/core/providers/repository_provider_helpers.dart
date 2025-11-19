import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/base_repository.dart';
import 'firebase_providers.dart';

/// Helper function to create a repository provider for BaseRepository subclasses.
///
/// This reduces boilerplate when creating repository providers that need
/// FirebaseFirestore and FirebaseAuth.
///
/// Example:
/// ```dart
/// final assetRepositoryProvider = createRepositoryProvider<AssetRepository>(
///   (firestore, auth) => AssetRepository(
///     firestore: firestore,
///     firebaseAuth: auth,
///   ),
/// );
/// ```
Provider<T> createRepositoryProvider<T extends BaseRepository>(
  T Function(FirebaseFirestore firestore, FirebaseAuth auth) factory,
) {
  return Provider<T>((ref) {
    return factory(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
    );
  });
}

/// Helper function to create a repository provider that also needs FirebaseStorage.
///
/// Example:
/// ```dart
/// final receiptRepositoryProvider = createRepositoryProviderWithStorage<ReceiptRepository>(
///   (firestore, auth, storage) => ReceiptRepository(
///     firestore: firestore,
///     firebaseAuth: auth,
///     storage: storage,
///   ),
/// );
/// ```
Provider<T> createRepositoryProviderWithStorage<T>(
  T Function(
    FirebaseFirestore firestore,
    FirebaseAuth auth,
    FirebaseStorage storage,
  )
  factory,
) {
  return Provider<T>((ref) {
    return factory(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
      ref.watch(firebaseStorageProvider),
    );
  });
}
