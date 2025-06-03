import 'package:cloud_firestore/cloud_firestore.dart';

class Workshop {
  final String id; // workshop_id
  final String? ownerId; // FK to users.user_id if a workshop has an owner
  final String typeOfWorkshop;
  final List<String> serviceProvided;
  final String paymentTerms;
  final String operatingHourStart; // Or DateTime/TimeOfDay
  final String operatingHourEnd;   // Or DateTime/TimeOfDay
  final String? ratingId; // Or a full Rating object / average rating

  Workshop({
    required this.id,
    this.ownerId,
    required this.typeOfWorkshop,
    required this.serviceProvided,
    required this.paymentTerms,
    required this.operatingHourStart,
    required this.operatingHourEnd,
    this.ratingId,
  });

  factory Workshop.fromMap(Map<String, dynamic> map, String documentId) {
    return Workshop(
      id: documentId,
      ownerId: map['ownerId'],
      typeOfWorkshop: map['typeOfWorkshop'] ?? '',
      serviceProvided: List<String>.from(map['serviceProvided'] ?? []),
      paymentTerms: map['paymentTerms'] ?? '',
      operatingHourStart: map['operatingHourStart'] ?? '',
      operatingHourEnd: map['operatingHourEnd'] ?? '',
      ratingId: map['ratingId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'typeOfWorkshop': typeOfWorkshop,
      'serviceProvided': serviceProvided,
      'paymentTerms': paymentTerms,
      'operatingHourStart': operatingHourStart,
      'operatingHourEnd': operatingHourEnd,
      'ratingId': ratingId,
    };
  }

  Workshop copyWith({
    String? id,
    String? ownerId,
    String? typeOfWorkshop,
    List<String>? serviceProvided,
    String? paymentTerms,
    String? operatingHourStart,
    String? operatingHourEnd,
    String? ratingId,
  }) {
    return Workshop(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      typeOfWorkshop: typeOfWorkshop ?? this.typeOfWorkshop,
      serviceProvided: serviceProvided ?? this.serviceProvided,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      operatingHourStart: operatingHourStart ?? this.operatingHourStart,
      operatingHourEnd: operatingHourEnd ?? this.operatingHourEnd,
      ratingId: ratingId ?? this.ratingId,
    );
  }
}
