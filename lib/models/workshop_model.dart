
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
  final String? facilities; // Added facilities

  Workshop({
    required this.id,
    this.ownerId,
    required this.typeOfWorkshop,
    required this.serviceProvided,
    required this.paymentTerms,
    required this.operatingHourStart,
    required this.operatingHourEnd,
    this.ratingId,
    this.workshopName, // Added workshopName
    this.address, // Added address
    this.workshopContactNumber, // Added workshopContactNumber
    this.workshopEmail, // Added workshopEmail
    this.facilities, // Added facilities
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
      workshopName: map['workshopName'], // Added workshopName
      address: map['address'], // Added address
      workshopContactNumber: map['workshopContactNumber'], // Added workshopContactNumber
      workshopEmail: map['workshopEmail'], // Added workshopEmail
      facilities: map['facilities'], // Added facilities
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
      'workshopName': workshopName, // Added workshopName
      'address': address, // Added address
      'workshopContactNumber': workshopContactNumber, // Added workshopContactNumber
      'workshopEmail': workshopEmail, // Added workshopEmail
      'facilities': facilities, // Added facilities
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
    String? workshopName, // Added workshopName
    String? address, // Added address
    String? workshopContactNumber, // Added workshopContactNumber
    String? workshopEmail, // Added workshopEmail
    String? facilities, // Added facilities
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
      workshopName: workshopName ?? this.workshopName, // Added workshopName
      address: address ?? this.address, // Added address
      workshopContactNumber: workshopContactNumber ?? this.workshopContactNumber, // Added workshopContactNumber
      workshopEmail: workshopEmail ?? this.workshopEmail, // Added workshopEmail
      facilities: facilities ?? this.facilities, // Added facilities
    );
  }
}
