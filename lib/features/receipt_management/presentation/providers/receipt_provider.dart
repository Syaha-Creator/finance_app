import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/receipt_model.dart';
import '../../data/repositories/receipt_repository.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
});

final receiptsProvider = StreamProvider.autoDispose<List<ReceiptModel>>((ref) {
  final receiptRepository = ref.watch(receiptRepositoryProvider);
  return receiptRepository.getReceipts();
});

final pendingReceiptsProvider = StreamProvider.autoDispose<List<ReceiptModel>>((
  ref,
) {
  final receiptRepository = ref.watch(receiptRepositoryProvider);
  return receiptRepository.getPendingReceipts();
});

final processedReceiptsProvider =
    StreamProvider.autoDispose<List<ReceiptModel>>((ref) {
      final receiptRepository = ref.watch(receiptRepositoryProvider);
      return receiptRepository.getProcessedReceipts();
    });

final receiptsSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final receiptRepository = ref.watch(receiptRepositoryProvider);
      return await receiptRepository.getReceiptsSummary();
    });

final receiptNotifierProvider =
    StateNotifierProvider.autoDispose<ReceiptController, AsyncValue<void>>((
      ref,
    ) {
      return ReceiptController(
        receiptRepository: ref.watch(receiptRepositoryProvider),
        ref: ref,
      );
    });

class ReceiptController extends StateNotifier<AsyncValue<void>> {
  final ReceiptRepository _receiptRepository;
  final Ref _ref;

  ReceiptController({
    required ReceiptRepository receiptRepository,
    required Ref ref,
  }) : _receiptRepository = receiptRepository,
       _ref = ref,
       super(const AsyncValue.data(null));

  Future<void> addReceipt(ReceiptModel receipt, File imageFile) async {
    state = const AsyncValue.loading();
    try {
      await _receiptRepository.addReceipt(receipt, imageFile);
      _ref.invalidate(receiptsProvider);
      _ref.invalidate(pendingReceiptsProvider);
      _ref.invalidate(processedReceiptsProvider);
      _ref.invalidate(receiptsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateReceipt(ReceiptModel receipt) async {
    state = const AsyncValue.loading();
    try {
      await _receiptRepository.updateReceipt(receipt);
      _ref.invalidate(receiptsProvider);
      _ref.invalidate(pendingReceiptsProvider);
      _ref.invalidate(processedReceiptsProvider);
      _ref.invalidate(receiptsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteReceipt(String receiptId) async {
    state = const AsyncValue.loading();
    try {
      await _receiptRepository.deleteReceipt(receiptId);
      _ref.invalidate(receiptsProvider);
      _ref.invalidate(pendingReceiptsProvider);
      _ref.invalidate(processedReceiptsProvider);
      _ref.invalidate(receiptsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsProcessed(String receiptId) async {
    state = const AsyncValue.loading();
    try {
      await _receiptRepository.markAsProcessed(receiptId);
      _ref.invalidate(receiptsProvider);
      _ref.invalidate(pendingReceiptsProvider);
      _ref.invalidate(processedReceiptsProvider);
      _ref.invalidate(receiptsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsArchived(String receiptId) async {
    state = const AsyncValue.loading();
    try {
      await _receiptRepository.markAsArchived(receiptId);
      _ref.invalidate(receiptsProvider);
      _ref.invalidate(pendingReceiptsProvider);
      _ref.invalidate(processedReceiptsProvider);
      _ref.invalidate(receiptsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
