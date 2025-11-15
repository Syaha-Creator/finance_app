import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ReceiptStatus { pending, processed, archived }

class ReceiptModel extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String? ocrText;
  final String? merchantName;
  final String? merchantAddress;
  final DateTime? transactionDate;
  final double? totalAmount;
  final String? currency;
  final List<String>? items;
  final String? notes;
  final ReceiptStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReceiptModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.ocrText,
    this.merchantName,
    this.merchantAddress,
    this.transactionDate,
    this.totalAmount,
    this.currency,
    this.items,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

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
    );
  }

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

  ReceiptModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? ocrText,
    String? merchantName,
    String? merchantAddress,
    DateTime? transactionDate,
    double? totalAmount,
    String? currency,
    List<String>? items,
    String? notes,
    ReceiptStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReceiptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      ocrText: ocrText ?? this.ocrText,
      merchantName: merchantName ?? this.merchantName,
      merchantAddress: merchantAddress ?? this.merchantAddress,
      transactionDate: transactionDate ?? this.transactionDate,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    imageUrl,
    ocrText,
    merchantName,
    merchantAddress,
    transactionDate,
    totalAmount,
    currency,
    items,
    notes,
    status,
    createdAt,
    updatedAt,
  ];
}
