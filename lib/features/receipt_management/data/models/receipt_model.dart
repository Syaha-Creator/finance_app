import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_model.freezed.dart';
part 'receipt_model.g.dart';

enum ReceiptStatus { pending, processed, archived }

@freezed
class ReceiptModel with _$ReceiptModel {
  const factory ReceiptModel({
    required String id,
    required String userId,
    required String imageUrl,
    String? ocrText,
    String? merchantName,
    String? merchantAddress,
    DateTime? transactionDate,
    double? totalAmount,
    String? currency,
    List<String>? items,
    String? notes,
    required ReceiptStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    double? latitude,
    double? longitude,
    String? locationAddress,
  }) = _ReceiptModel;

  factory ReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiptModelFromJson(json);

  factory ReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReceiptModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ocrText: data['ocrText'],
      merchantName: data['merchantName'],
      merchantAddress: data['merchantAddress'],
      transactionDate:
          data['transactionDate'] != null
              ? (data['transactionDate'] as Timestamp).toDate()
              : null,
      totalAmount:
          data['totalAmount'] != null
              ? (data['totalAmount'] as num).toDouble()
              : null,
      currency: data['currency'],
      items: data['items'] != null ? List<String>.from(data['items']) : null,
      notes: data['notes'],
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      latitude: data['latitude'] != null
          ? (data['latitude'] as num).toDouble()
          : null,
      longitude: data['longitude'] != null
          ? (data['longitude'] as num).toDouble()
          : null,
      locationAddress: data['locationAddress'] as String?,
    );
  }

  const ReceiptModel._();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'ocrText': ocrText,
      'merchantName': merchantName,
      'merchantAddress': merchantAddress,
      'transactionDate':
          transactionDate != null ? Timestamp.fromDate(transactionDate!) : null,
      'totalAmount': totalAmount,
      'currency': currency,
      'items': items,
      'notes': notes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
    };
  }

  static ReceiptStatus _parseStatus(dynamic raw) {
    if (raw is String) {
      final String normalized = raw.contains('.') ? raw.split('.').last : raw;
      try {
        return ReceiptStatus.values.byName(normalized);
      } catch (_) {
        return ReceiptStatus.pending;
      }
    }
    return ReceiptStatus.pending;
  }
}
