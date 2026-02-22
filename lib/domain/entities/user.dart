/// Domain-level role enumeration.
enum UserRole { admin, bank, student }

/// Core User entity (role-aware, bank-aware for bank users).
class AppUser {
  final int id;
  final String name;
  final UserRole role;
  final int? bankId; // Only populated for bank & student users

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.bankId,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isBank => role == UserRole.bank;
  bool get isStudent => role == UserRole.student;

  @override
  String toString() => 'AppUser(id: $id, name: $name, role: $role)';
}
