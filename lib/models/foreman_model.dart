import 'package:cloud_firestore/cloud_firestore.dart';

class Foreman {
  final String id; // foreman_id
  final String? userId; // If foreman is linked to a user
  final String foremanName;
  final String foremanEmail;
  final String foremanBankAccountNo;
  final int yearsOfExperience;
  final String? resumeUrl; // Added resumeUrl
  final String? ratingId; // Or a full Rating object / average rating

  Foreman({
    required this.id,
    this.userId,
    required this.foremanName,
    required this.foremanEmail,
    required this.foremanBankAccountNo,
    required this.yearsOfExperience,
    this.resumeUrl, // Added resumeUrl
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
      resumeUrl: map['resumeUrl'], // Added resumeUrl
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
      'resumeUrl': resumeUrl, // Added resumeUrl
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
    String? resumeUrl, // Added resumeUrl
    String? ratingId,
  }) {
    return Foreman(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foremanName: foremanName ?? this.foremanName,
      foremanEmail: foremanEmail ?? this.foremanEmail,
      foremanBankAccountNo: foremanBankAccountNo ?? this.foremanBankAccountNo,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      resumeUrl: resumeUrl ?? this.resumeUrl, // Added resumeUrl
      ratingId: ratingId ?? this.ratingId,
    );
  }
}
