import 'package:cloud_firestore/cloud_firestore.dart';
class Foreman {
  final String id; // foreman_id
  final String? userId; // If foreman is linked to a user
  final String foremanName;
  final String foremanEmail;
  final String foremanBankAccountNo;
  final int yearsOfExperience;
  final String? resumeUrl;
  final String? ratingId;
  final String? pastExperienceDetails; // Added pastExperienceDetails
  final String? skills; // Added skills

  Foreman({
    required this.id,
    this.userId,
    required this.foremanName,
    required this.foremanEmail,
    required this.foremanBankAccountNo,
    required this.yearsOfExperience,
    this.resumeUrl,
    this.ratingId,
    this.pastExperienceDetails, // Added pastExperienceDetails
    this.skills, // Added skills
  });

  factory Foreman.fromMap(Map<String, dynamic> map, String documentId) {
    return Foreman(
      id: documentId,
      userId: map['userId'],
      foremanName: map['foremanName'] ?? '',
      foremanEmail: map['foremanEmail'] ?? '',
      foremanBankAccountNo: map['foremanBankAccountNo'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      resumeUrl: map['resumeUrl'],
      ratingId: map['ratingId'],
      pastExperienceDetails: map['pastExperienceDetails'], // Added pastExperienceDetails
      skills: map['skills'], // Added skills
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foremanName': foremanName,
      'foremanEmail': foremanEmail,
      'foremanBankAccountNo': foremanBankAccountNo,
      'yearsOfExperience': yearsOfExperience,
      'resumeUrl': resumeUrl,
      'ratingId': ratingId,
      'pastExperienceDetails': pastExperienceDetails, // Added pastExperienceDetails
      'skills': skills, // Added skills
    };
  }

  Foreman copyWith({
    String? id,
    String? userId,
    String? foremanName,
    String? foremanEmail,
    String? foremanBankAccountNo,
    int? yearsOfExperience,
    String? resumeUrl,
    String? ratingId,
    String? pastExperienceDetails, // Added pastExperienceDetails
    String? skills, // Added skills
  }) {
    return Foreman(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foremanName: foremanName ?? this.foremanName,
      foremanEmail: foremanEmail ?? this.foremanEmail,
      foremanBankAccountNo: foremanBankAccountNo ?? this.foremanBankAccountNo,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      ratingId: ratingId ?? this.ratingId,
      pastExperienceDetails: pastExperienceDetails ?? this.pastExperienceDetails, // Added pastExperienceDetails
      skills: skills ?? this.skills, // Added skills
    );
  }

// Create Foreman from Firestore document
factory Foreman.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Foreman(
    id: doc.id,
    userId: data['userId'],
    foremanName: data['foremanName'] ?? '',
    foremanEmail: data['foremanEmail'] ?? '',
    foremanBankAccountNo: data['foremanBankAccountNo'] ?? '',
    yearsOfExperience: data['yearsOfExperience'] ?? 0,
    resumeUrl: data['resumeUrl'],
    ratingId: data['ratingId'],
    pastExperienceDetails: data['pastExperienceDetails'],
    skills: data['skills'],
  );
}
}
