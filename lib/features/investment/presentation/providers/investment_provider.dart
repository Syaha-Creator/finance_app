import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/investment_model.dart';
import '../../data/repositories/investment_repository.dart';

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final investmentsProvider =
    StreamProvider.autoDispose<List<InvestmentModel>>((ref) {
      final investmentRepository = ref.watch(investmentRepositoryProvider);
      return investmentRepository.getInvestments();
    });

final activeInvestmentsProvider =
    StreamProvider.autoDispose<List<InvestmentModel>>((ref) {
      final investmentRepository = ref.watch(investmentRepositoryProvider);
      return investmentRepository.getActiveInvestments();
    });

final portfolioSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final investments = await ref.watch(investmentsProvider.future);
  
  final totalInvestments = investments.length;
  final activeInvestments = investments.where((i) => i.status == InvestmentStatus.active).length;
  final totalInvested = investments.fold<double>(0, (sum, inv) => sum + inv.totalInvested);
  final currentValue = investments.fold<double>(0, (sum, inv) => sum + inv.currentValue);
  final totalProfitLoss = investments.fold<double>(0, (sum, inv) => sum + inv.profitLoss);
  
  return {
    'totalInvestments': totalInvestments,
    'activeInvestments': activeInvestments,
    'totalInvested': totalInvested,
    'currentValue': currentValue,
    'totalProfitLoss': totalProfitLoss,
  };
});

final investmentNotifierProvider =
    StateNotifierProvider.autoDispose<InvestmentController, AsyncValue<void>>((ref) {
      return InvestmentController(
        investmentRepository: ref.watch(investmentRepositoryProvider),
        ref: ref,
      );
    });

class InvestmentController extends StateNotifier<AsyncValue<void>> {
  final InvestmentRepository _investmentRepository;
  final Ref _ref;

  InvestmentController({required InvestmentRepository investmentRepository, required Ref ref})
    : _investmentRepository = investmentRepository,
      _ref = ref,
      super(const AsyncValue.data(null));

  Future<void> addInvestment(InvestmentModel investment) async {
    state = const AsyncValue.loading();
    try {
      await _investmentRepository.addInvestment(investment);
      _ref.invalidate(investmentsProvider);
      _ref.invalidate(activeInvestmentsProvider);
      _ref.invalidate(portfolioSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateInvestment(InvestmentModel investment) async {
    state = const AsyncValue.loading();
    try {
      await _investmentRepository.updateInvestment(investment);
      _ref.invalidate(investmentsProvider);
      _ref.invalidate(activeInvestmentsProvider);
      _ref.invalidate(portfolioSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteInvestment(String investmentId) async {
    state = const AsyncValue.loading();
    try {
      await _investmentRepository.deleteInvestment(investmentId);
      _ref.invalidate(investmentsProvider);
      _ref.invalidate(activeInvestmentsProvider);
      _ref.invalidate(portfolioSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateCurrentPrice(String investmentId, double newPrice) async {
    state = const AsyncValue.loading();
    try {
      await _investmentRepository.updateCurrentPrice(investmentId, newPrice);
      _ref.invalidate(investmentsProvider);
      _ref.invalidate(activeInvestmentsProvider);
      _ref.invalidate(portfolioSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addQuantity(String investmentId, double quantity, double price) async {
    state = const AsyncValue.loading();
    try {
      await _investmentRepository.addQuantity(investmentId, quantity, price);
      _ref.invalidate(investmentsProvider);
      _ref.invalidate(activeInvestmentsProvider);
      _ref.invalidate(portfolioSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sellPartial(String investmentId, double quantity, double price) async {
    state = const AsyncValue.loading();
    try {
      await _investmentRepository.sellPartial(investmentId, quantity, price);
      _ref.invalidate(investmentsProvider);
      _ref.invalidate(activeInvestmentsProvider);
      _ref.invalidate(portfolioSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsSold(String investmentId, double sellPrice) async {
    state = const AsyncValue.loading();
    try {
      await _investmentRepository.markAsSold(investmentId, sellPrice);
      _ref.invalidate(investmentsProvider);
      _ref.invalidate(activeInvestmentsProvider);
      _ref.invalidate(portfolioSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

