import 'package:rxdart/rxdart.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../models/setting_model.dart';

class SettingsRepository extends BaseRepository {
  SettingsRepository({required super.firestore, required super.firebaseAuth});

  /// Gets combined stream of default data and user custom data.
  /// Combines data from main collection (default) and user subcollection (custom).
  Stream<List<CategoryModel>> getCombinedStream(String collectionName) {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    // 1. Stream untuk data default (dari collection utama)
    final defaultStream = firestore
        .collection(collectionName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => CategoryModel(
                      id: doc.id,
                      name: doc['name'] as String,
                      isDefault: true,
                    ),
                  )
                  .toList(),
        );

    // 2. Stream untuk data kustom pengguna (dari subcollection)
    final userStream = createSubcollectionStreamQuery<CategoryModel>(
      parentCollection: FirestoreConstants.usersCollection,
      subcollectionName: collectionName,
      fromFirestore:
          (doc) => CategoryModel(
            id: doc.id,
            name: doc['name'] as String,
            isDefault: false,
          ),
    );

    // 3. Gabungkan kedua stream
    return Rx.combineLatest2(defaultStream, userStream, (
      List<CategoryModel> defaultItems,
      List<CategoryModel> userItems,
    ) {
      final combined = [...defaultItems, ...userItems];
      combined.sort((a, b) => a.name.compareTo(b.name));
      return combined;
    });
  }

  /// Adds custom data to user's subcollection.
  Future<void> addCustomData(String collectionName, String name) async {
    await addDocumentToSubcollection(
      parentCollection: FirestoreConstants.usersCollection,
      subcollectionName: collectionName,
      data: {'name': name},
    );
  }

  /// Deletes custom data from user's subcollection.
  Future<void> deleteCustomData(String collectionName, String docId) async {
    await deleteDocumentFromSubcollection(
      parentCollection: FirestoreConstants.usersCollection,
      subcollectionName: collectionName,
      documentId: docId,
    );
  }
}
