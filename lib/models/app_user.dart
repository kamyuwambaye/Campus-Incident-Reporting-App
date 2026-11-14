import 'firestore_helpers.dart';

enum UserRole {
  student('student', 'Student'),
  staff('staff', 'Staff');

  const UserRole(this.id, this.label);

  final String id;
  final String label;

  static UserRole fromId(String? id) =>
      id == UserRole.staff.id ? UserRole.staff : UserRole.student;
}

/// Profile document stored at `users/{uid}`.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department = '',
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final DateTime? createdAt;

  bool get isStaff => role == UserRole.staff;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase());
    final value = parts.join();
    return value.isEmpty ? '?' : value;
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: UserRole.fromId(data['role'] as String?),
      department: (data['department'] as String?) ?? '',
      createdAt: toDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.id,
        'department': department,
        'createdAt': dateToFirestore(createdAt),
      };
}
