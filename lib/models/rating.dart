import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String? id; // Firebase document ID
  final String customerName;
  final String jobType;
  final String comment;
  final int stars;
  final DateTime? timestamp;
  final String foremanId;

  Rating({
    this.id,
    required this.customerName,
    required this.jobType,
    required this.comment,
    required this.stars,
    required this.foremanId,
    this.timestamp,
  });

  // Factory constructor to convert from Firestore document
  factory Rating.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      jobType: data['jobType'] ?? '',
      comment: data['comment'] ?? '',
      stars: data['stars'] ?? 0,
      foremanId: data['foremanId'] ?? '', 
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate() 
          : null,
    );
  }

  // Factory constructor to convert from map (for local data)
  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      customerName: map['customerName'] ?? '',
      jobType: map['jobType'] ?? '',
      comment: map['comment'] ?? '',
      stars: map['stars'] ?? 0,
      foremanId:map['foremanId'] ?? '', 
      timestamp: map['timestamp'] is Timestamp 
          ? (map['timestamp'] as Timestamp).toDate()
          : map['timestamp'] is DateTime 
              ? map['timestamp'] 
              : null,
    );
  }

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'jobType': jobType,
      'comment': comment,
      'stars': stars,
      'foremanId': foremanId,
      'timestamp': timestamp != null 
          ? Timestamp.fromDate(timestamp!) 
          : FieldValue.serverTimestamp(),
    };
  }

  // Copy with method for easy updates
  Rating copyWith({
    String? id,
    String? customerName,
    String? jobType,
    String? comment,
    String? foremanId,
    int? stars,
    DateTime? timestamp,
  }) {
    return Rating(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      jobType: jobType ?? this.jobType,
      comment: comment ?? this.comment,
      stars: stars ?? this.stars,
      foremanId: foremanId ?? this.foremanId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}