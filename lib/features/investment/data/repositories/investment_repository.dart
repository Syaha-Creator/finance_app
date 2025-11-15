import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/investment_model.dart';

class InvestmentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  InvestmentRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all investments for current user
  Stream<List<InvestmentModel>> getInvestments() {
    if (_userId.isEmpty) {
      return Stream.value(<InvestmentModel>[]);
    }

    return _firestore
        .collection('investments')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => InvestmentModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get active investments only
  Stream<List<InvestmentModel>> getActiveInvestments() {
    if (_userId.isEmpty) {
      return Stream.value(<InvestmentModel>[]);
    }

    return _firestore
        .collection('investments')
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: InvestmentStatus.active.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => InvestmentModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get investments by type
  Stream<List<InvestmentModel>> getInvestmentsByType(InvestmentType type) {
    if (_userId.isEmpty) {
      return Stream.value(<InvestmentModel>[]);
    }

    return _firestore
        .collection('investments')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => InvestmentModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get investment by ID
  Future<InvestmentModel?> getInvestmentById(String investmentId) async {
    try {
      final doc =
          await _firestore.collection('investments').doc(investmentId).get();

      if (doc.exists) {
        return InvestmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get investment: $e');
    }
  }

  // Add new investment
  Future<void> addInvestment(InvestmentModel investment) async {
    try {
      final investmentData = investment.copyWith(
        userId: _userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('investments')
          .add(investmentData.toFirestore());
    } catch (e) {
      throw Exception('Failed to add investment: $e');
    }
  }

  // Update investment
  Future<void> updateInvestment(InvestmentModel investment) async {
    try {
      final investmentData = investment.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('investments')
          .doc(investment.id)
          .update(investmentData.toFirestore());
    } catch (e) {
      throw Exception('Failed to update investment: $e');
    }
  }

  // Delete investment
  Future<void> deleteInvestment(String investmentId) async {
    try {
      await _firestore.collection('investments').doc(investmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete investment: $e');
    }
  }

  // Update current price for an investment
  Future<void> updateCurrentPrice(String investmentId, double newPrice) async {
    try {
      final investment = await getInvestmentById(investmentId);
      if (investment != null) {
        final updatedInvestment = investment.calculateCurrentMetrics(newPrice);
        await updateInvestment(updatedInvestment);
      }
    } catch (e) {
      throw Exception('Failed to update current price: $e');
    }
  }

  // Add quantity to existing investment
  Future<void> addQuantity(
    String investmentId,
    double quantity,
    double price,
  ) async {
    try {
      final investment = await getInvestmentById(investmentId);
      if (investment != null) {
        final updatedInvestment = investment.addQuantity(quantity, price);
        await updateInvestment(updatedInvestment);
      }
    } catch (e) {
      throw Exception('Failed to add quantity: $e');
    }
  }

  // Sell partial quantity
  Future<void> sellPartial(
    String investmentId,
    double quantity,
    double price,
  ) async {
    try {
      final investment = await getInvestmentById(investmentId);
      if (investment != null) {
        final updatedInvestment = investment.sellPartial(quantity, price);
        await updateInvestment(updatedInvestment);
      }
    } catch (e) {
      throw Exception('Failed to sell partial: $e');
    }
  }

  // Mark investment as sold
  Future<void> markAsSold(String investmentId, double sellPrice) async {
    try {
      final investment = await getInvestmentById(investmentId);
      if (investment != null) {
        final updatedInvestment = investment.copyWith(
          status: InvestmentStatus.sold,
          sellDate: DateTime.now(),
          currentPrice: sellPrice,
          updatedAt: DateTime.now(),
        );
        await updateInvestment(updatedInvestment);
      }
    } catch (e) {
      throw Exception('Failed to mark as sold: $e');
    }
  }

  // Get portfolio summary
  Future<Map<String, dynamic>> getPortfolioSummary() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User tidak terautentikasi');
      }

      final investmentsSnapshot =
          await _firestore
              .collection('investments')
              .where('userId', isEqualTo: _userId)
              .where('status', isEqualTo: InvestmentStatus.active.name)
              .get();

      final investments =
          investmentsSnapshot.docs
              .map((doc) => InvestmentModel.fromFirestore(doc))
              .toList();

      final totalInvested = investments.fold(
        0.0,
        (total, inv) => total + inv.totalInvested,
      );
      final totalCurrentValue = investments.fold(
        0.0,
        (total, inv) => total + inv.currentValue,
      );
      final totalProfitLoss = investments.fold(
        0.0,
        (total, inv) => total + inv.profitLoss,
      );
      final totalProfitLossPercentage =
          totalInvested > 0 ? (totalProfitLoss / totalInvested) * 100 : 0.0;

      // Group by type
      final typeBreakdown = <String, Map<String, dynamic>>{};
      for (final investment in investments) {
        final typeName = investment.type.toString().split('.').last;
        typeBreakdown[typeName] ??= {
          'count': 0,
          'invested': 0.0,
          'currentValue': 0.0,
          'profitLoss': 0.0,
        };
        typeBreakdown[typeName]!['count'] =
            typeBreakdown[typeName]!['count'] + 1;
        typeBreakdown[typeName]!['invested'] =
            typeBreakdown[typeName]!['invested'] + investment.totalInvested;
        typeBreakdown[typeName]!['currentValue'] =
            typeBreakdown[typeName]!['currentValue'] + investment.currentValue;
        typeBreakdown[typeName]!['profitLoss'] =
            typeBreakdown[typeName]!['profitLoss'] + investment.profitLoss;
      }

      return {
        'totalInvestments': investments.length,
        'totalInvested': totalInvested,
        'totalCurrentValue': totalCurrentValue,
        'totalProfitLoss': totalProfitLoss,
        'totalProfitLossPercentage': totalProfitLossPercentage,
        'typeBreakdown': typeBreakdown,
        'bestPerformer':
            investments.isNotEmpty
                ? investments.reduce(
                  (a, b) =>
                      a.profitLossPercentage > b.profitLossPercentage ? a : b,
                )
                : null,
        'worstPerformer':
            investments.isNotEmpty
                ? investments.reduce(
                  (a, b) =>
                      a.profitLossPercentage < b.profitLossPercentage ? a : b,
                )
                : null,
      };
    } catch (e) {
      throw Exception('Failed to get portfolio summary: $e');
    }
  }

  // Get investment performance over time
  Future<List<Map<String, dynamic>>> getPerformanceHistory(
    String investmentId,
  ) async {
    try {
      // This would typically come from a separate collection tracking price history
      // For now, return mock data
      return [
        {
          'date': DateTime.now().subtract(const Duration(days: 30)),
          'price': 100.0,
          'value': 1000.0,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 20)),
          'price': 105.0,
          'value': 1050.0,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'price': 110.0,
          'value': 1100.0,
        },
        {'date': DateTime.now(), 'price': 115.0, 'value': 1150.0},
      ];
    } catch (e) {
      throw Exception('Failed to get performance history: $e');
    }
  }

  // Search investments
  Future<List<InvestmentModel>> searchInvestments(String query) async {
    try {
      final investmentsSnapshot =
          await _firestore
              .collection('investments')
              .where('userId', isEqualTo: _userId)
              .get();

      final investments =
          investmentsSnapshot.docs
              .map((doc) => InvestmentModel.fromFirestore(doc))
              .toList();

      // Simple text search
      return investments.where((investment) {
        final searchText = query.toLowerCase();
        return investment.name.toLowerCase().contains(searchText) ||
            investment.symbol.toLowerCase().contains(searchText) ||
            investment.notes?.toLowerCase().contains(searchText) == true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search investments: $e');
    }
  }
}
