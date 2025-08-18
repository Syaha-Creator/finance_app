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

  // Mendapatkan stream/aliran data semua aset milik pengguna saat ini
  Stream<List<AssetModel>> getAssetsStream() {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return Stream.value([]);
      }

      final query = _firestore
          .collection('assets')
          .where('userId', isEqualTo: userId)
          .orderBy('lastUpdatedAt', descending: true);

      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => AssetModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            return <AssetModel>[];
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Menambah aset baru
  Future<void> addAsset(AssetModel asset) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final data = asset.toFirestore();
      await _firestore.collection('assets').add(data);
    } catch (e) {
      rethrow;
    }
  }

  // Mengupdate aset yang sudah ada
  Future<void> updateAsset(AssetModel asset) async {
    if (asset.id == null) throw Exception('Asset ID is null, cannot update.');

    try {
      final data = asset.copyWith(lastUpdatedAt: DateTime.now()).toFirestore();
      await _firestore.collection('assets').doc(asset.id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Menghapus aset
  Future<void> deleteAsset(String assetId) async {
    try {
      await _firestore.collection('assets').doc(assetId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
