
class AppUser {
  final String id; // user_id
  final String name;
  final String email;
  final String contactNumber;
  final String role; // e.g., 'workshop_owner', 'foreman'

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
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

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? contactNumber,
    String? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      role: role ?? this.role,
    );
  }
}
