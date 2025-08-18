import '../data/models/currency_model.dart';

class CurrencyService {
  // Mock exchange rates (in real app, this would come from an API)
  static const Map<String, double> _mockExchangeRates = {
    'USD': 0.000065,
    'EUR': 0.000060,
    'SGD': 0.000088,
    'JPY': 0.0098,
    'CNY': 0.00047,
    'GBP': 0.000052,
    'AUD': 0.000099,
    'CAD': 0.000089,
    'CHF': 0.000057,
  };

  // Get current exchange rates from API (mock implementation)
  static Future<Map<String, double>> getCurrentExchangeRates() async {
    try {
      // In a real app, you would call an API like:
      // final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/IDR'));
      // final data = json.decode(response.body);
      // return data['rates'];

      // For now, return mock data
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate API delay
      return _mockExchangeRates;
    } catch (e) {
      print('Error fetching exchange rates: $e');
      return _mockExchangeRates; // Fallback to mock data
    }
  }

  // Convert amount between currencies
  static double convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
    Map<String, double> exchangeRates,
  ) {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    if (fromCurrency == 'IDR') {
      // Converting from IDR to another currency
      final rate = exchangeRates[toCurrency];
      if (rate != null) {
        return amount * rate;
      }
    } else if (toCurrency == 'IDR') {
      // Converting to IDR from another currency
      final rate = exchangeRates[fromCurrency];
      if (rate != null) {
        return amount / rate;
      }
    } else {
      // Converting between two non-IDR currencies
      final fromRate = exchangeRates[fromCurrency];
      final toRate = exchangeRates[toCurrency];
      if (fromRate != null && toRate != null) {
        // Convert to IDR first, then to target currency
        final idrAmount = amount / fromRate;
        return idrAmount * toRate;
      }
    }

    return amount; // Return original amount if conversion fails
  }

  // Format currency amount with proper symbol and formatting
  static String formatCurrency(double amount, String currencyCode) {
    final symbol = _getCurrencySymbol(currencyCode);
    final formattedAmount = _formatAmount(amount, currencyCode);
    return '$symbol$formattedAmount';
  }

  // Get currency symbol
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'IDR':
        return 'Rp ';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'SGD':
        return 'S\$';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'GBP':
        return '£';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF ';
      default:
        return '';
    }
  }

  // Format amount based on currency
  static String _formatAmount(double amount, String currencyCode) {
    switch (currencyCode) {
      case 'IDR':
        return _formatIDR(amount);
      case 'JPY':
        return _formatJPY(amount);
      case 'CNY':
        return _formatCNY(amount);
      default:
        return _formatDecimal(amount);
    }
  }

  // Format IDR with thousand separators
  static String _formatIDR(double amount) {
    final intPart = amount.toInt();
    final decimalPart = amount - intPart;

    String result = intPart.toString();
    final groups = <String>[];

    while (result.isNotEmpty) {
      final start = result.length > 3 ? result.length - 3 : 0;
      groups.insert(0, result.substring(start));
      result = result.substring(0, start);
    }

    final formatted = groups.join('.');

    if (decimalPart > 0) {
      return '$formatted,${(decimalPart * 100).round()}';
    }

    return formatted;
  }

  // Format JPY (no decimal places)
  static String _formatJPY(double amount) {
    return amount.toInt().toString();
  }

  // Format CNY (2 decimal places)
  static String _formatCNY(double amount) {
    return amount.toStringAsFixed(2);
  }

  // Format decimal currencies (2 decimal places)
  static String _formatDecimal(double amount) {
    return amount.toStringAsFixed(2);
  }

  // Get currency info by code
  static CurrencyModel? getCurrencyByCode(String code) {
    return PredefinedCurrencies.currencies
        .where((currency) => currency.code == code)
        .firstOrNull;
  }

  // Get all available currencies
  static List<CurrencyModel> getAllCurrencies() {
    return PredefinedCurrencies.currencies;
  }

  // Update exchange rates for a specific currency
  static Future<void> updateExchangeRate(
    String currencyCode,
    double newRate,
  ) async {
    try {
      // In a real app, you would update the rate in your database
      // For now, just print the update
      print('Updated exchange rate for $currencyCode: $newRate');
    } catch (e) {
      print('Error updating exchange rate: $e');
    }
  }

  // Get historical exchange rates (mock implementation)
  static Future<List<Map<String, dynamic>>> getHistoricalRates(
    String currencyCode,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // In a real app, you would call an API for historical data
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 300));

      final days = endDate.difference(startDate).inDays;
      final rates = <Map<String, dynamic>>[];

      for (int i = 0; i <= days; i++) {
        final date = startDate.add(Duration(days: i));
        final baseRate = _mockExchangeRates[currencyCode] ?? 0.0;
        final variation =
            (DateTime.now().millisecondsSinceEpoch % 100 - 50) /
            10000; // Random small variation
        final rate = baseRate + variation;

        rates.add({'date': date, 'rate': rate});
      }

      return rates;
    } catch (e) {
      print('Error fetching historical rates: $e');
      return [];
    }
  }

  // Calculate currency conversion with fees
  static double convertWithFees(
    double amount,
    String fromCurrency,
    String toCurrency,
    Map<String, double> exchangeRates,
    double feePercentage,
  ) {
    final convertedAmount = convertCurrency(
      amount,
      fromCurrency,
      toCurrency,
      exchangeRates,
    );
    final fee = convertedAmount * (feePercentage / 100);
    return convertedAmount - fee;
  }

  // Get currency conversion summary
  static Map<String, dynamic> getConversionSummary(
    double amount,
    String fromCurrency,
    String toCurrency,
    Map<String, double> exchangeRates,
    double feePercentage,
  ) {
    final originalAmount = amount;
    final convertedAmount = convertCurrency(
      amount,
      fromCurrency,
      toCurrency,
      exchangeRates,
    );
    final fee = convertedAmount * (feePercentage / 100);
    final finalAmount = convertedAmount - fee;

    return {
      'originalAmount': originalAmount,
      'originalCurrency': fromCurrency,
      'convertedAmount': convertedAmount,
      'targetCurrency': toCurrency,
      'fee': fee,
      'feePercentage': feePercentage,
      'finalAmount': finalAmount,
      'exchangeRate':
          fromCurrency == 'IDR'
              ? (exchangeRates[toCurrency] ?? 1.0)
              : (1 / (exchangeRates[fromCurrency] ?? 1.0)),
    };
  }
}
