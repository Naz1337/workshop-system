import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id; // user_id
  final String name;
  final String email;
  final String contactNumber;
  final String role; // e.g., 'workshop_owner', 'foreman'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'contactNumber': contactNumber,
      'role': role,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? contactNumber,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      role: role ?? this.role,
    );
  }
}
