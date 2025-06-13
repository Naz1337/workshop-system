// lib/models/payroll_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class Payroll {
  final String id;
  final String foremanId;
  final String foremanName;
  final double salary;
  final bool isPaid;
  final DateTime createdAt;

  Payroll({
    required this.id,
    required this.foremanId,
    required this.foremanName,
    required this.salary,
    required this.isPaid,
    required this.createdAt,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'] ?? '', // Ensure ID is present
      foremanId: json['foremanId'] ?? '',
      foremanName: json['foremanName'] ?? '',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // ID is usually the document ID, not stored in the document itself
      'foremanId': foremanId,
      'foremanName': foremanName,
      'salary': salary,
      'isPaid': isPaid,
      'createdAt': Timestamp.fromDate(createdAt), // Store as Timestamp
    };
  }
}
