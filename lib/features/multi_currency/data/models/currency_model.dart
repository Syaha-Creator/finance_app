import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CurrencyModel extends Equatable {
  final String id;
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate;
  final DateTime lastUpdated;
  final bool isBaseCurrency;

  const CurrencyModel({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.exchangeRate,
    required this.lastUpdated,
    required this.isBaseCurrency,
  });

  factory CurrencyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CurrencyModel(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      symbol: data['symbol'] ?? '',
      exchangeRate: (data['exchangeRate'] ?? 1.0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      isBaseCurrency: data['isBaseCurrency'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'exchangeRate': exchangeRate,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isBaseCurrency': isBaseCurrency,
    };
  }

  CurrencyModel copyWith({
    String? id,
    String? code,
    String? name,
    String? symbol,
    double? exchangeRate,
    DateTime? lastUpdated,
    bool? isBaseCurrency,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isBaseCurrency: isBaseCurrency ?? this.isBaseCurrency,
    );
  }

  // Convert amount from this currency to base currency
  double convertToBase(double amount) {
    return amount * exchangeRate;
  }

  // Convert amount from base currency to this currency
  double convertFromBase(double amount) {
    return amount / exchangeRate;
  }

  // Convert amount from this currency to another currency
  double convertToCurrency(double amount, CurrencyModel targetCurrency) {
    if (isBaseCurrency) {
      return amount * targetCurrency.exchangeRate;
    } else if (targetCurrency.isBaseCurrency) {
      return convertToBase(amount);
    } else {
      // Convert to base first, then to target
      final baseAmount = convertToBase(amount);
      return targetCurrency.convertFromBase(baseAmount);
    }
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    symbol,
    exchangeRate,
    lastUpdated,
    isBaseCurrency,
  ];
}

// Predefined currencies
class PredefinedCurrencies {
  static List<CurrencyModel> get currencies => [
    CurrencyModel(
      id: 'idr',
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      exchangeRate: 1.0,
      lastUpdated: DateTime.now(),
      isBaseCurrency: true,
    ),
    CurrencyModel(
      id: 'usd',
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      exchangeRate: 0.000065,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'eur',
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      exchangeRate: 0.000060,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'sgd',
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      exchangeRate: 0.000088,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'jpy',
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      exchangeRate: 0.0098,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'cny',
      code: 'CNY',
      name: 'Chinese Yuan',
      symbol: '¥',
      exchangeRate: 0.00047,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'gbp',
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      exchangeRate: 0.000052,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'aud',
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      exchangeRate: 0.000099,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'cad',
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      exchangeRate: 0.000089,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
    CurrencyModel(
      id: 'chf',
      code: 'CHF',
      name: 'Swiss Franc',
      symbol: 'CHF',
      exchangeRate: 0.000057,
      lastUpdated: DateTime.now(),
      isBaseCurrency: false,
    ),
  ];
}
