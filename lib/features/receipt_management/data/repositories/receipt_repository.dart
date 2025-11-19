import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../../../../core/utils/logger.dart';
import '../models/receipt_model.dart';

class ReceiptRepository extends BaseRepository {
  final FirebaseStorage _storage;

  ReceiptRepository({
    required super.firestore,
    required super.firebaseAuth,
    required FirebaseStorage storage,
  }) : _storage = storage;

  // Get all receipts for current user
  Stream<List<ReceiptModel>> getReceipts() {
    return createStreamQuery<ReceiptModel>(
      collectionName: FirestoreConstants.receiptsCollection,
      fromFirestore: (doc) => ReceiptModel.fromFirestore(doc),
      orderByField: 'createdAt',
      descending: true,
      userIdField: 'userId',
    );
  }

  // Get receipts by status
  Stream<List<ReceiptModel>> getReceiptsByStatus(ReceiptStatus status) {
    return createStreamQuery<ReceiptModel>(
      collectionName: FirestoreConstants.receiptsCollection,
      fromFirestore: (doc) => ReceiptModel.fromFirestore(doc),
      orderByField: 'createdAt',
      descending: true,
      userIdField: 'userId',
      whereConditions: [
        WhereCondition(field: 'status', value: status.toString()),
      ],
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
      // Upload image to Firebase Storage
      final imageUrl = await _uploadImage(imageFile);

      // Create receipt with image URL
      final receiptData = receipt.copyWith(
        userId: requiredUserId,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final receiptMap = receiptData.toFirestore();
      final docRef = await firestore
          .collection(FirestoreConstants.receiptsCollection)
          .add(receiptMap);

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambahkan struk: $e');
    }
  }

  // Update receipt
  Future<void> updateReceipt(ReceiptModel receipt) async {
    final receiptData = receipt.copyWith(updatedAt: DateTime.now());

    await updateDocument(
      collectionName: FirestoreConstants.receiptsCollection,
      documentId: receipt.id,
      data: receiptData.toFirestore(),
      userIdField: 'userId',
    );
  }

  // Delete receipt
  Future<void> deleteReceipt(String receiptId) async {
    try {
      // Get receipt to delete image and validate ownership
      final receipt = await getDocumentById<ReceiptModel>(
        collectionName: FirestoreConstants.receiptsCollection,
        documentId: receiptId,
        fromFirestore: (doc) => ReceiptModel.fromFirestore(doc),
        userIdField: 'userId',
      );

      if (receipt == null) {
        throw Exception('Struk tidak ditemukan');
      }

      // Delete image from storage
      if (receipt.imageUrl.isNotEmpty) {
        await _deleteImage(receipt.imageUrl);
      }

      // Delete document
      await deleteDocument(
        collectionName: FirestoreConstants.receiptsCollection,
        documentId: receiptId,
        userIdField: 'userId',
      );
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }

  // Mark receipt as processed
  Future<void> markAsProcessed(String receiptId) async {
    await updateDocument(
      collectionName: FirestoreConstants.receiptsCollection,
      documentId: receiptId,
      data: {
        'status': ReceiptStatus.processed.toString(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      userIdField: 'userId',
    );
  }

  // Mark receipt as archived
  Future<void> markAsArchived(String receiptId) async {
    await updateDocument(
      collectionName: FirestoreConstants.receiptsCollection,
      documentId: receiptId,
      data: {
        'status': ReceiptStatus.archived.toString(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      userIdField: 'userId',
    );
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      final userId = requiredUserId;
      final fileName =
          'receipts/$userId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child(fileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Logger.error('Failed to upload image', e);
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      Logger.error('Failed to delete image', e);
      // Ignore if file not found, it might have been deleted already
      if (e is! FirebaseException || e.code != 'object-not-found') {
        throw Exception('Gagal menghapus gambar: $e');
      }
    }
  }

  // Get receipts summary for dashboard
  Future<Map<String, dynamic>> getReceiptsSummary() async {
    try {
      final receipts = await getDocumentsByQuery<ReceiptModel>(
        collectionName: FirestoreConstants.receiptsCollection,
        fromFirestore: (doc) => ReceiptModel.fromFirestore(doc),
        userIdField: 'userId',
      );

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
      final receipts = await getDocumentsByQuery<ReceiptModel>(
        collectionName: FirestoreConstants.receiptsCollection,
        fromFirestore: (doc) => ReceiptModel.fromFirestore(doc),
        userIdField: 'userId',
      );

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
