import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recurring_transaction_model.dart';

class RecurringTransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  RecurringTransactionRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String get _uid {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  // Referensi ke koleksi baru kita
  CollectionReference get _collection =>
      _firestore.collection('recurring_transactions');

  // Mendapatkan semua jadwal transaksi berulang milik pengguna
  Stream<List<RecurringTransactionModel>> getRecurringTransactionsStream() {
    return _collection
        .where('userId', isEqualTo: _uid)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => RecurringTransactionModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Menambah jadwal baru
  Future<void> add(RecurringTransactionModel recurring) async {
    await _collection.add(recurring.toFirestore());
  }

  // Mengupdate jadwal yang ada
  Future<void> update(RecurringTransactionModel recurring) async {
    if (recurring.id == null) throw Exception("ID is required for update");
    await _collection.doc(recurring.id).update(recurring.toFirestore());
  }

  // Menghapus jadwal
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
