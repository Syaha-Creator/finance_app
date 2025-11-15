import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../data/models/receipt_model.dart';
import '../../data/repositories/receipt_repository.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    storage: FirebaseStorage.instance,
  );
});

final receiptsProvider = StreamProvider<List<ReceiptModel>>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.getReceipts();
});

final pendingReceiptsProvider = StreamProvider<List<ReceiptModel>>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.getPendingReceipts();
});

final processedReceiptsProvider = StreamProvider<List<ReceiptModel>>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.getProcessedReceipts();
});

final receiptsSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.getReceiptsSummary();
});

class ReceiptNotifier extends StateNotifier<AsyncValue<void>> {
  final ReceiptRepository _repository;

  ReceiptNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addReceipt(ReceiptModel receipt, File imageFile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addReceipt(receipt, imageFile);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateReceipt(ReceiptModel receipt) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateReceipt(receipt);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteReceipt(String receiptId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteReceipt(receiptId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsProcessed(String receiptId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsProcessed(receiptId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsArchived(String receiptId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsArchived(receiptId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final receiptNotifierProvider =
    StateNotifierProvider<ReceiptNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(receiptRepositoryProvider);
      return ReceiptNotifier(repository);
    });
