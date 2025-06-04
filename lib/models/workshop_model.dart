
class Workshop {
  final String id; // workshop_id
  final String? ownerId; // FK to users.user_id if a workshop has an owner
  final String typeOfWorkshop;
  final List<String> serviceProvided;
  final String paymentTerms;
  final String operatingHourStart; // Or DateTime/TimeOfDay
  final String operatingHourEnd;   // Or DateTime/TimeOfDay
  final String? ratingId;
  final String? workshopName; // Added workshopName
  final String? address; // Added address
  final String? workshopContactNumber; // Added workshopContactNumber
  final String? workshopEmail; // Added workshopEmail
  Workshop({
    required this.id,
    this.ownerId,
    required this.typeOfWorkshop,
    required this.serviceProvided,
    required this.paymentTerms,
    required this.operatingHourStart,
    required this.operatingHourEnd,
    this.ratingId,
    this.workshopName,
    this.address,
    this.workshopContactNumber,
    this.workshopEmail,
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
      workshopName: map['workshopName'],
      address: map['address'],
      workshopContactNumber: map['workshopContactNumber'],
      workshopEmail: map['workshopEmail'],
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
      'workshopName': workshopName,
      'address': address,
      'workshopContactNumber': workshopContactNumber,
      'workshopEmail': workshopEmail,
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
    String? workshopName,
    String? address,
    String? workshopContactNumber,
    String? workshopEmail,
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
      workshopName: workshopName ?? this.workshopName,
      address: address ?? this.address,
      workshopContactNumber: workshopContactNumber ?? this.workshopContactNumber,
      workshopEmail: workshopEmail ?? this.workshopEmail,
    );
  }
}
