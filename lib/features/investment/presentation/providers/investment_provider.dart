import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/investment_model.dart';
import '../../data/repositories/investment_repository.dart';

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final investmentsProvider = StreamProvider.autoDispose<List<InvestmentModel>>((
  ref,
) {
  final investmentRepository = ref.watch(investmentRepositoryProvider);
  return investmentRepository.getInvestments();
});

final activeInvestmentsProvider =
    StreamProvider.autoDispose<List<InvestmentModel>>((ref) {
      final investmentRepository = ref.watch(investmentRepositoryProvider);
      return investmentRepository.getActiveInvestments();
    });

final portfolioSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final investments = await ref.watch(investmentsProvider.future);

      final totalInvestments = investments.length;
      final activeInvestments =
          investments.where((i) => i.status == InvestmentStatus.active).length;
      final totalInvested = investments.fold<double>(
        0,
        (sum, inv) => sum + inv.totalInvested,
      );
      final currentValue = investments.fold<double>(
        0,
        (sum, inv) => sum + inv.currentValue,
      );
      final totalProfitLoss = investments.fold<double>(
        0,
        (sum, inv) => sum + inv.profitLoss,
      );

      return {
        'totalInvestments': totalInvestments,
        'activeInvestments': activeInvestments,
        'totalInvested': totalInvested,
        'currentValue': currentValue,
        'totalProfitLoss': totalProfitLoss,
      };
    });

final investmentNotifierProvider =
    StateNotifierProvider.autoDispose<InvestmentController, AsyncValue<void>>((
      ref,
    ) {
      return InvestmentController(
        investmentRepository: ref.watch(investmentRepositoryProvider),
        ref: ref,
      );
    });

class InvestmentController extends BaseController {
  final InvestmentRepository _investmentRepository;

  InvestmentController({
    required InvestmentRepository investmentRepository,
    required super.ref,
  }) : _investmentRepository = investmentRepository;

  List<ProviderOrFamily> get _investmentProvidersToInvalidate => [
    investmentsProvider,
    activeInvestmentsProvider,
    portfolioSummaryProvider,
  ];

  Future<void> addInvestment(InvestmentModel investment) async {
    await executeWithLoading(
      () => _investmentRepository.addInvestment(investment),
      providersToInvalidate: _investmentProvidersToInvalidate,
    );
  }

  Future<void> updateInvestment(InvestmentModel investment) async {
    await executeWithLoading(
      () => _investmentRepository.updateInvestment(investment),
      providersToInvalidate: _investmentProvidersToInvalidate,
    );
  }

  Future<void> deleteInvestment(String investmentId) async {
    await executeWithLoading(
      () => _investmentRepository.deleteInvestment(investmentId),
      providersToInvalidate: _investmentProvidersToInvalidate,
    );
  }

  Future<void> updateCurrentPrice(String investmentId, double newPrice) async {
    await executeWithLoading(
      () => _investmentRepository.updateCurrentPrice(investmentId, newPrice),
      providersToInvalidate: _investmentProvidersToInvalidate,
    );
  }

  Future<void> addQuantity(
    String investmentId,
    double quantity,
    double price,
  ) async {
    await executeWithLoading(
      () => _investmentRepository.addQuantity(investmentId, quantity, price),
      providersToInvalidate: _investmentProvidersToInvalidate,
    );
  }

  Future<void> sellPartial(
    String investmentId,
    double quantity,
    double price,
  ) async {
    await executeWithLoading(
      () => _investmentRepository.sellPartial(investmentId, quantity, price),
      providersToInvalidate: _investmentProvidersToInvalidate,
    );
  }

  Future<void> markAsSold(String investmentId, double sellPrice) async {
    await executeWithLoading(
      () => _investmentRepository.markAsSold(investmentId, sellPrice),
      providersToInvalidate: _investmentProvidersToInvalidate,
    );
  }
}
