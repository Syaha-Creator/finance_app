import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/investment_model.dart';
import '../../data/repositories/investment_repository.dart';

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final investmentsProvider = StreamProvider<List<InvestmentModel>>((ref) {
  final repository = ref.watch(investmentRepositoryProvider);
  return repository.getInvestments();
});

final activeInvestmentsProvider = StreamProvider<List<InvestmentModel>>((ref) {
  final repository = ref.watch(investmentRepositoryProvider);
  return repository.getActiveInvestments();
});

final investmentsByTypeProvider =
    StreamProvider.family<List<InvestmentModel>, InvestmentType>((ref, type) {
      final repository = ref.watch(investmentRepositoryProvider);
      return repository.getInvestmentsByType(type);
    });

final portfolioSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(investmentRepositoryProvider);
  return repository.getPortfolioSummary();
});

final investmentByIdProvider = FutureProvider.family<InvestmentModel?, String>((
  ref,
  investmentId,
) {
  final repository = ref.watch(investmentRepositoryProvider);
  return repository.getInvestmentById(investmentId);
});

class InvestmentNotifier extends StateNotifier<AsyncValue<void>> {
  final InvestmentRepository _repository;

  InvestmentNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addInvestment(InvestmentModel investment) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addInvestment(investment);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateInvestment(InvestmentModel investment) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateInvestment(investment);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteInvestment(String investmentId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteInvestment(investmentId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCurrentPrice(String investmentId, double newPrice) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCurrentPrice(investmentId, newPrice);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addQuantity(
    String investmentId,
    double quantity,
    double price,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addQuantity(investmentId, quantity, price);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sellPartial(
    String investmentId,
    double quantity,
    double price,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sellPartial(investmentId, quantity, price);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsSold(String investmentId, double sellPrice) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsSold(investmentId, sellPrice);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final investmentNotifierProvider =
    StateNotifierProvider<InvestmentNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(investmentRepositoryProvider);
      return InvestmentNotifier(repository);
    });
