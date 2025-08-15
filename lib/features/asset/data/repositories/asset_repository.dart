import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/asset_model.dart';

class AssetRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  AssetRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot perform asset operations.');
    }
    return user.uid;
  }

  // Collection reference untuk 'assets'
  CollectionReference get _assetCollection => _firestore.collection('assets');

  // Mendapatkan stream/aliran data semua aset milik pengguna saat ini
  Stream<List<AssetModel>> getAssetsStream() {
    return _assetCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final assets =
              snapshot.docs
                  .map((doc) => AssetModel.fromFirestore(doc))
                  .toList();
          // Urutkan berdasarkan tanggal update terbaru
          assets.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
          return assets;
        });
  }

  // Menambah aset baru
  Future<void> addAsset(AssetModel asset) async {
    final now = DateTime.now();
    final assetWithData = asset.copyWith(
      userId: _currentUserId,
      createdAt: now,
      lastUpdatedAt: now,
    );
    await _assetCollection.add(assetWithData.toFirestore());
  }

  // Mengupdate aset yang sudah ada
  Future<void> updateAsset(AssetModel asset) async {
    if (asset.id == null) throw Exception('Asset ID is null, cannot update.');

    final assetWithTimestamp = asset.copyWith(lastUpdatedAt: DateTime.now());
    await _assetCollection
        .doc(asset.id)
        .update(assetWithTimestamp.toFirestore());
  }

  // Menghapus aset
  Future<void> deleteAsset(String assetId) async {
    await _assetCollection.doc(assetId).delete();
  }
}
