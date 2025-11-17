import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment_model.freezed.dart';
part 'investment_model.g.dart';

enum InvestmentType { stock, mutualFund, crypto, bond, gold, property, other }

enum InvestmentStatus { active, sold, matured }

@freezed
class InvestmentModel with _$InvestmentModel {
  const factory InvestmentModel({
    required String id,
    required String userId,
    required String name,
    required String symbol,
    required InvestmentType type,
    required double quantity,
    required double averagePrice,
    required double currentPrice,
    required double totalInvested,
    required double currentValue,
    required double profitLoss,
    required double profitLossPercentage,
    required InvestmentStatus status,
    required DateTime purchaseDate,
    DateTime? sellDate,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _InvestmentModel;

  factory InvestmentModel.fromJson(Map<String, dynamic> json) =>
      _$InvestmentModelFromJson(json);

  factory InvestmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      symbol: data['symbol'] ?? '',
      type: _parseType(data['type']),
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      averagePrice: (data['averagePrice'] ?? 0.0).toDouble(),
      currentPrice: (data['currentPrice'] ?? 0.0).toDouble(),
      totalInvested: (data['totalInvested'] ?? 0.0).toDouble(),
      currentValue: (data['currentValue'] ?? 0.0).toDouble(),
      profitLoss: (data['profitLoss'] ?? 0.0).toDouble(),
      profitLossPercentage: (data['profitLossPercentage'] ?? 0.0).toDouble(),
      status: _parseStatus(data['status']),
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      sellDate:
          data['sellDate'] != null
              ? (data['sellDate'] as Timestamp).toDate()
              : null,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  const InvestmentModel._();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'symbol': symbol,
      'type': type.name,
      'quantity': quantity,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'profitLoss': profitLoss,
      'profitLossPercentage': profitLossPercentage,
      'status': status.name,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'sellDate': sellDate != null ? Timestamp.fromDate(sellDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate current value and profit/loss
  InvestmentModel calculateCurrentMetrics(double newCurrentPrice) {
    final newCurrentValue = quantity * newCurrentPrice;
    final newProfitLoss = newCurrentValue - totalInvested;
    final newProfitLossPercentage =
        totalInvested > 0 ? (newProfitLoss / totalInvested) * 100 : 0.0;

    return copyWith(
      currentPrice: newCurrentPrice,
      currentValue: newCurrentValue,
      profitLoss: newProfitLoss,
      profitLossPercentage: newProfitLossPercentage,
      updatedAt: DateTime.now(),
    );
  }

  // Add more quantity to existing investment
  InvestmentModel addQuantity(
    double additionalQuantity,
    double additionalPrice,
  ) {
    final newTotalQuantity = quantity + additionalQuantity;
    final newTotalInvested =
        totalInvested + (additionalQuantity * additionalPrice);
    final newAveragePrice = newTotalInvested / newTotalQuantity;
    final newCurrentValue = newTotalQuantity * currentPrice;
    final newProfitLoss = newCurrentValue - newTotalInvested;
    final newProfitLossPercentage =
        newTotalInvested > 0 ? (newProfitLoss / newTotalInvested) * 100 : 0.0;

    return copyWith(
      quantity: newTotalQuantity,
      averagePrice: newAveragePrice,
      totalInvested: newTotalInvested,
      currentValue: newCurrentValue,
      profitLoss: newProfitLoss,
      profitLossPercentage: newProfitLossPercentage,
      updatedAt: DateTime.now(),
    );
  }

  // Sell partial quantity
  InvestmentModel sellPartial(double sellQuantity, double sellPrice) {
    if (sellQuantity >= quantity) {
      return copyWith(
        status: InvestmentStatus.sold,
        sellDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final remainingQuantity = quantity - sellQuantity;
    final remainingInvested = (remainingQuantity / quantity) * totalInvested;
    final remainingCurrentValue = remainingQuantity * currentPrice;
    final remainingProfitLoss = remainingCurrentValue - remainingInvested;
    final remainingProfitLossPercentage =
        remainingInvested > 0
            ? (remainingProfitLoss / remainingInvested) * 100
            : 0.0;

    return copyWith(
      quantity: remainingQuantity,
      totalInvested: remainingInvested,
      currentValue: remainingCurrentValue,
      profitLoss: remainingProfitLoss,
      profitLossPercentage: remainingProfitLossPercentage,
      updatedAt: DateTime.now(),
    );
  }
}

InvestmentType _parseType(dynamic raw) {
  if (raw is String) {
    final normalized = raw.contains('.') ? raw.split('.').last : raw;
    try {
      return InvestmentType.values.byName(normalized);
    } catch (_) {
      return InvestmentType.other;
    }
  }
  return InvestmentType.other;
}

InvestmentStatus _parseStatus(dynamic raw) {
  if (raw is String) {
    final normalized = raw.contains('.') ? raw.split('.').last : raw;
    try {
      return InvestmentStatus.values.byName(normalized);
    } catch (_) {
      return InvestmentStatus.active;
    }
  }
  return InvestmentStatus.active;
}
