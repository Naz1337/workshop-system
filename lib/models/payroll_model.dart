import 'package:cloud_firestore/cloud_firestore.dart';

class Payroll {
  final String id;
  final String foremanId;
  final double amount;
  final double hoursWorked;
  final String paymentMethod;
  final String status;
  final DateTime timestamp;

  Payroll({
    required this.id,
    required this.foremanId,
    required this.amount,
    required this.hoursWorked,
    required this.paymentMethod,
    this.status = 'Pending',
    required this.timestamp,
  });

  Payroll copyWith({
    String? id,
    String? foremanId,
    double? amount,
    double? hoursWorked,
    String? paymentMethod,
    String? status,
    DateTime? timestamp,
  }) {
    return Payroll(
      id: id ?? this.id,
      foremanId: foremanId ?? this.foremanId,
      amount: amount ?? this.amount,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foremanId': foremanId,
      'amount': amount,
      'hoursWorked': hoursWorked,
      'paymentMethod': paymentMethod,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Payroll.fromMap(String id, Map<String, dynamic> map) {
    return Payroll(
      id: id,
      foremanId: map['foremanId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      hoursWorked: (map['hoursWorked'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? 'Pending',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
