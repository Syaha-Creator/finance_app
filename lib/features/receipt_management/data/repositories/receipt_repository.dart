import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/receipt_model.dart';

class ReceiptRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ReceiptRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _auth = auth,
       _storage = storage;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all receipts for current user
  Stream<List<ReceiptModel>> getReceipts() {
    if (_userId.isEmpty) {
      return Stream.value(<ReceiptModel>[]);
    }

    return _firestore
        .collection(FirestoreConstants.receiptsCollection)
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ReceiptModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get receipts by status
  Stream<List<ReceiptModel>> getReceiptsByStatus(ReceiptStatus status) {
    if (_userId.isEmpty) {
      return Stream.value(<ReceiptModel>[]);
    }

    return _firestore
        .collection(FirestoreConstants.receiptsCollection)
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: status.toString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ReceiptModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get pending receipts
  Stream<List<ReceiptModel>> getPendingReceipts() {
    return getReceiptsByStatus(ReceiptStatus.pending);
  }

  // Get processed receipts
  Stream<List<ReceiptModel>> getProcessedReceipts() {
    return getReceiptsByStatus(ReceiptStatus.processed);
  }

  // Add new receipt
  Future<String> addReceipt(ReceiptModel receipt, File imageFile) async {
    try {
      if (_userId.isEmpty) {
        throw Exception(
          'User tidak terautentikasi. Silakan login terlebih dahulu.',
        );
      }

      // Upload image to Firebase Storage
      final imageUrl = await _uploadImage(imageFile);

      // Create receipt with image URL
      final receiptData = receipt.copyWith(
        userId: _userId,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final receiptMap = receiptData.toFirestore();
      final docRef = await _firestore
          .collection(FirestoreConstants.receiptsCollection)
          .add(receiptMap);

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambahkan struk: $e');
    }
  }

  // Update receipt
  Future<void> updateReceipt(ReceiptModel receipt) async {
    try {
      final receiptData = receipt.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(FirestoreConstants.receiptsCollection)
          .doc(receipt.id)
          .update(receiptData.toFirestore());
    } catch (e) {
      throw Exception('Failed to update receipt: $e');
    }
  }

  // Delete receipt
  Future<void> deleteReceipt(String receiptId) async {
    try {
      // Get receipt to delete image
      final receiptDoc =
          await _firestore
              .collection(FirestoreConstants.receiptsCollection)
              .doc(receiptId)
              .get();

      if (receiptDoc.exists) {
        final receipt = ReceiptModel.fromFirestore(receiptDoc);

        // Delete image from storage
        if (receipt.imageUrl.isNotEmpty) {
          await _deleteImage(receipt.imageUrl);
        }

        // Delete document
        await _firestore
            .collection(FirestoreConstants.receiptsCollection)
            .doc(receiptId)
            .delete();
      }
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }

  // Mark receipt as processed
  Future<void> markAsProcessed(String receiptId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.receiptsCollection)
          .doc(receiptId)
          .update({
            'status': ReceiptStatus.processed.toString(),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Failed to mark receipt as processed: $e');
    }
  }

  // Mark receipt as archived
  Future<void> markAsArchived(String receiptId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.receiptsCollection)
          .doc(receiptId)
          .update({
            'status': ReceiptStatus.archived.toString(),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Failed to mark receipt as archived: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName =
          'receipts/${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      Logger.warn('Failed to delete image: $e');
      // Don't throw error for image deletion failure
    }
  }

  // Get receipts summary for dashboard
  Future<Map<String, dynamic>> getReceiptsSummary() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User tidak terautentikasi');
      }

      final receiptsSnapshot =
          await _firestore
              .collection(FirestoreConstants.receiptsCollection)
              .where('userId', isEqualTo: _userId)
              .get();

      final receipts =
          receiptsSnapshot.docs
              .map((doc) => ReceiptModel.fromFirestore(doc))
              .toList();

      final totalReceipts = receipts.length;
      final pendingReceipts =
          receipts.where((r) => r.status == ReceiptStatus.pending).length;
      final processedReceipts =
          receipts.where((r) => r.status == ReceiptStatus.processed).length;
      final archivedReceipts =
          receipts.where((r) => r.status == ReceiptStatus.archived).length;

      final totalAmount = receipts
          .where((r) => r.totalAmount != null)
          .fold(0.0, (total, receipt) => total + (receipt.totalAmount ?? 0));

      return {
        'totalReceipts': totalReceipts,
        'pendingReceipts': pendingReceipts,
        'processedReceipts': processedReceipts,
        'archivedReceipts': archivedReceipts,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      throw Exception('Failed to get receipts summary: $e');
    }
  }

  // Search receipts by text
  Future<List<ReceiptModel>> searchReceipts(String query) async {
    try {
      final receiptsSnapshot =
          await _firestore
              .collection(FirestoreConstants.receiptsCollection)
              .where('userId', isEqualTo: _userId)
              .get();

      final receipts =
          receiptsSnapshot.docs
              .map((doc) => ReceiptModel.fromFirestore(doc))
              .toList();

      // Simple text search
      return receipts.where((receipt) {
        final searchText = query.toLowerCase();
        return receipt.merchantName?.toLowerCase().contains(searchText) ==
                true ||
            receipt.ocrText?.toLowerCase().contains(searchText) == true ||
            receipt.notes?.toLowerCase().contains(searchText) == true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search receipts: $e');
    }
  }
}
