import '../../domain/entities/user.dart';

/// Data model for the Users table. Handles SQLite ↔ domain mapping.
class UserModel {
  final int id;
  final String name;
  final String username;
  final String password;
  final String role;
  final int? bankId;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.bankId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['name'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      bankId: map['bankId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'bankId': bankId,
    };
  }

  AppUser toDomain() {
    return AppUser(
      id: id,
      name: name,
      role: _parseRole(role),
      bankId: bankId,
    );
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'bank':
        return UserRole.bank;
      case 'student':
        return UserRole.student;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }
}
