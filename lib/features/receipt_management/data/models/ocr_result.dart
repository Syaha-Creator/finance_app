class OcrResult {
  final String? merchantName;
  final String? merchantAddress;
  final DateTime? transactionDate;
  final double? totalAmount;
  final String? currency;
  final List<String>? items;
  final String ocrText;

  const OcrResult({
    required this.merchantName,
    required this.merchantAddress,
    required this.transactionDate,
    required this.totalAmount,
    required this.currency,
    required this.items,
    required this.ocrText,
  });
}
