


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
      id: json['id'],
      foremanId: json['foremanId'],
      foremanName: json['foremanName'],
      salary: json['salary'],
      isPaid: json['isPaid'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foremanId': foremanId,
      'foremanName': foremanName,
      'salary': salary,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}