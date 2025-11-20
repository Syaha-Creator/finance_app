/// Model untuk expense berdasarkan lokasi
/// Dipisahkan dari widget untuk reusability
class LocationExpense {
  final String locationName;
  final double totalAmount;
  final int transactionCount;
  final double? latitude;
  final double? longitude;
  final DateTime lastTransactionDate;

  LocationExpense({
    required this.locationName,
    required this.totalAmount,
    required this.transactionCount,
    this.latitude,
    this.longitude,
    required this.lastTransactionDate,
  });
}

