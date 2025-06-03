import 'package:cloud_firestore/cloud_firestore.dart';

class Foreman {
  final String id; // foreman_id
  final String? userId; // If foreman is linked to a user
  final String foremanName;
  final String foremanEmail;
  final String foremanBankAccountNo;
  final int yearsOfExperience;
  final String? ratingId; // Or a full Rating object / average rating

  Foreman({
    required this.id,
    this.userId,
    required this.foremanName,
    required this.foremanEmail,
    required this.foremanBankAccountNo,
    required this.yearsOfExperience,
    this.ratingId,
  });

  factory Foreman.fromMap(Map<String, dynamic> map, String documentId) {
    return Foreman(
      id: documentId,
      userId: map['userId'],
      foremanName: map['foremanName'] ?? '',
      foremanEmail: map['foremanEmail'] ?? '',
      foremanBankAccountNo: map['foremanBankAccountNo'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      ratingId: map['ratingId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foremanName': foremanName,
      'foremanEmail': foremanEmail,
      'foremanBankAccountNo': foremanBankAccountNo,
      'yearsOfExperience': yearsOfExperience,
      'ratingId': ratingId,
    };
  }

  Foreman copyWith({
    String? id,
    String? userId,
    String? foremanName,
    String? foremanEmail,
    String? foremanBankAccountNo,
    int? yearsOfExperience,
    String? ratingId,
  }) {
    return Foreman(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foremanName: foremanName ?? this.foremanName,
      foremanEmail: foremanEmail ?? this.foremanEmail,
      foremanBankAccountNo: foremanBankAccountNo ?? this.foremanBankAccountNo,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      ratingId: ratingId ?? this.ratingId,
    );
  }
}
