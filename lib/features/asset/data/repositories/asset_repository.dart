import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../models/asset_model.dart';

class AssetRepository extends BaseRepository {
  AssetRepository({required super.firestore, required super.firebaseAuth});

  // Mendapatkan stream/aliran data semua aset milik pengguna saat ini
  Stream<List<AssetModel>> getAssetsStream() {
    return createStreamQuery<AssetModel>(
      collectionName: FirestoreConstants.assetsCollection,
      fromFirestore: (doc) => AssetModel.fromFirestore(doc),
      orderByField: 'lastUpdatedAt',
      descending: true,
      userIdField: 'userId',
    );
  }

  // Menambah aset baru
  Future<void> addAsset(AssetModel asset) async {
    final data = asset.toFirestore();
    await addDocument(
      collectionName: FirestoreConstants.assetsCollection,
      data: data,
      requireUserId: true,
    );
  }

  // Mengupdate aset yang sudah ada
  Future<void> updateAsset(AssetModel asset) async {
    if (asset.id == null) {
      throw Exception('Asset ID is null, cannot update.');
    }

    final data = asset.copyWith(lastUpdatedAt: DateTime.now()).toFirestore();
    await updateDocument(
      collectionName: FirestoreConstants.assetsCollection,
      documentId: asset.id!,
      data: data,
      userIdField: 'userId', // Security: validate user ownership
    );
  }

  // Menghapus aset
  Future<void> deleteAsset(String assetId) async {
    await deleteDocument(
      collectionName: FirestoreConstants.assetsCollection,
      documentId: assetId,
      userIdField: 'userId', // Security: validate user ownership
    );
  }
}
