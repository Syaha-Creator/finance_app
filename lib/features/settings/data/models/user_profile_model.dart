import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

enum Gender { male, female, other, preferNotToSay }

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String userId,
    required String displayName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Gender? gender,
    String? address,
    String? city,
    String? country,
    String? bio,
    String? profession,
    String? photoURL,
    String? currency, // Currency preference (e.g., 'IDR', 'USD')
    String? language, // Language preference (e.g., 'id', 'en')
    @Default(false) bool emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfileModel(
      userId: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      dateOfBirth:
          data['dateOfBirth'] != null
              ? (data['dateOfBirth'] as Timestamp).toDate()
              : null,
      gender:
          data['gender'] != null
              ? _parseGender(data['gender'] as String)
              : null,
      address: data['address'] as String?,
      city: data['city'] as String?,
      country: data['country'] as String?,
      bio: data['bio'] as String?,
      profession: data['profession'] as String?,
      photoURL: data['photoURL'] as String?,
      currency: data['currency'] as String?,
      language: data['language'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  const UserProfileModel._();

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (gender != null) 'gender': gender!.name,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (bio != null) 'bio': bio,
      if (profession != null) 'profession': profession,
      if (photoURL != null) 'photoURL': photoURL,
      if (currency != null) 'currency': currency,
      if (language != null) 'language': language,
      'emailVerified': emailVerified,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static Gender? _parseGender(String? value) {
    if (value == null) return null;
    try {
      return Gender.values.firstWhere(
        (e) => e.name == value,
        orElse: () => Gender.preferNotToSay,
      );
    } catch (e) {
      return null;
    }
  }
}
