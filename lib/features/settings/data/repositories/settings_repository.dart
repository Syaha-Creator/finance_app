import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../models/setting_model.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  SettingsRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  // --- FUNGSI BARU UNTUK MENGGABUNGKAN DATA ---

  Stream<List<CategoryModel>> getCombinedStream(String collectionName) {
    final userId = _uid;
    if (userId == null) return Stream.value([]);

    // 1. Stream untuk data default
    final defaultStream = _firestore
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

    // 2. Stream untuk data kustom pengguna
    final userStream = _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userId)
        .collection(collectionName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => CategoryModel(
                      id: doc.id,
                      name: doc['name'] as String,
                      isDefault: false,
                    ),
                  )
                  .toList(),
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

  // --- FUNGSI LAMA (PENAMBAHAN) DIMODIFIKASI UNTUK MENYIMPAN KE SUB-KOLEKSI ---

  Future<void> addCustomData(String collectionName, String name) async {
    final userId = _uid;
    if (userId == null) throw Exception("Pengguna tidak login");
    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userId)
        .collection(collectionName)
        .add({'name': name});
  }

  // --- FUNGSI BARU UNTUK MENGHAPUS ---

  Future<void> deleteCustomData(String collectionName, String docId) async {
    final userId = _uid;
    if (userId == null) throw Exception("Pengguna tidak login");
    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userId)
        .collection(collectionName)
        .doc(docId)
        .delete();
  }
}
