import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum AssetType {
  cash,
  bankAccount,
  eWallet,
  stocks,
  mutualFunds,
  crypto,
  property,
  vehicle,
  other,
}

String assetTypeToString(AssetType type) {
  switch (type) {
    case AssetType.cash:
      return 'Uang Tunai';
    case AssetType.bankAccount:
      return 'Rekening Bank';
    case AssetType.eWallet:
      return 'Dompet Digital';
    case AssetType.stocks:
      return 'Saham';
    case AssetType.mutualFunds:
      return 'Reksadana';
    case AssetType.crypto:
      return 'Aset Kripto';
    case AssetType.property:
      return 'Properti';
    case AssetType.vehicle:
      return 'Kendaraan';
    case AssetType.other:
      return 'Lainnya';
  }
}

class AssetModel extends Equatable {
  final String? id;
  final String userId;
  final String name;
  final AssetType type;
  final double value;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  const AssetModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.value,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory AssetModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AssetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',

      type: AssetType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AssetType.other,
      ),
      value: (data['value'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name,
      'value': value,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  AssetModel copyWith({
    String? id,
    String? userId,
    String? name,
    AssetType? type,
    double? value,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    type,
    value,
    createdAt,
    lastUpdatedAt,
  ];
}
