import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum InvestmentType { stock, mutualFund, crypto, bond, gold, property, other }

enum InvestmentStatus { active, sold, matured }

class InvestmentModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String symbol;
  final InvestmentType type;
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final double totalInvested;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercentage;
  final InvestmentStatus status;
  final DateTime purchaseDate;
  final DateTime? sellDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvestmentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.totalInvested,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.status,
    required this.purchaseDate,
    this.sellDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      symbol: data['symbol'] ?? '',
      type: InvestmentType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => InvestmentType.other,
      ),
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      averagePrice: (data['averagePrice'] ?? 0.0).toDouble(),
      currentPrice: (data['currentPrice'] ?? 0.0).toDouble(),
      totalInvested: (data['totalInvested'] ?? 0.0).toDouble(),
      currentValue: (data['currentValue'] ?? 0.0).toDouble(),
      profitLoss: (data['profitLoss'] ?? 0.0).toDouble(),
      profitLossPercentage: (data['profitLossPercentage'] ?? 0.0).toDouble(),
      status: InvestmentStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => InvestmentStatus.active,
      ),
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

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'symbol': symbol,
      'type': type.toString(),
      'quantity': quantity,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'profitLoss': profitLoss,
      'profitLossPercentage': profitLossPercentage,
      'status': status.toString(),
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'sellDate': sellDate != null ? Timestamp.fromDate(sellDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  InvestmentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? symbol,
    InvestmentType? type,
    double? quantity,
    double? averagePrice,
    double? currentPrice,
    double? totalInvested,
    double? currentValue,
    double? profitLoss,
    double? profitLossPercentage,
    InvestmentStatus? status,
    DateTime? purchaseDate,
    DateTime? sellDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      totalInvested: totalInvested ?? this.totalInvested,
      currentValue: currentValue ?? this.currentValue,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
      status: status ?? this.status,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      sellDate: sellDate ?? this.sellDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    symbol,
    type,
    quantity,
    averagePrice,
    currentPrice,
    totalInvested,
    currentValue,
    profitLoss,
    profitLossPercentage,
    status,
    purchaseDate,
    sellDate,
    notes,
    createdAt,
    updatedAt,
  ];
}
