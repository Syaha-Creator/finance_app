import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/repository_provider_helpers.dart';
import '../../data/models/receipt_model.dart';
import '../../data/repositories/receipt_repository.dart';

final receiptRepositoryProvider = createRepositoryProviderWithStorage<ReceiptRepository>(
  (firestore, auth, storage) => ReceiptRepository(
    firestore: firestore,
    firebaseAuth: auth,
    storage: storage,
  ),
);

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

class ReceiptController extends BaseController {
  final ReceiptRepository _receiptRepository;

  ReceiptController({
    required ReceiptRepository receiptRepository,
    required super.ref,
  }) : _receiptRepository = receiptRepository;

  List<ProviderOrFamily> get _receiptProvidersToInvalidate => [
    receiptsProvider,
    pendingReceiptsProvider,
    processedReceiptsProvider,
    receiptsSummaryProvider,
  ];

  Future<void> addReceipt(ReceiptModel receipt, File imageFile) async {
    await executeWithLoading(
      () => _receiptRepository.addReceipt(receipt, imageFile),
      providersToInvalidate: _receiptProvidersToInvalidate,
    );
  }

  Future<void> updateReceipt(ReceiptModel receipt) async {
    await executeWithLoading(
      () => _receiptRepository.updateReceipt(receipt),
      providersToInvalidate: _receiptProvidersToInvalidate,
    );
  }

  Future<void> deleteReceipt(String receiptId) async {
    await executeWithLoading(
      () => _receiptRepository.deleteReceipt(receiptId),
      providersToInvalidate: _receiptProvidersToInvalidate,
    );
  }

  Future<void> markAsProcessed(String receiptId) async {
    await executeWithLoading(
      () => _receiptRepository.markAsProcessed(receiptId),
      providersToInvalidate: _receiptProvidersToInvalidate,
    );
  }

  Future<void> markAsArchived(String receiptId) async {
    await executeWithLoading(
      () => _receiptRepository.markAsArchived(receiptId),
      providersToInvalidate: _receiptProvidersToInvalidate,
    );
  }
}
