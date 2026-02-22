import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

/// SQLite-backed implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AppUser?> login(String username, String password) async {
    final db = await DatabaseHelper.database;
    // SECURITY NOTE: Plain-text password comparison is used here for demo purposes only.
    // In production, store hashed passwords and use constant-time comparison (e.g., bcrypt).
    final rows = await db.query(
      'Users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim(), password],
    );

    if (rows.isEmpty) return null;

    final model = UserModel.fromMap(rows.first);

    // If the user is a student, look up their student record to get bankId.
    // This ensures the bankId on the domain user matches the student's assigned bank.
    if (model.role == 'student') {
      final studentRows = await db.query(
        'Students',
        where: 'name = ?',
        whereArgs: [model.name],
        limit: 1,
      );
      if (studentRows.isNotEmpty) {
        final bankId = studentRows.first['bankId'] as int?;
        return AppUser(
          id: model.id,
          name: model.name,
          role: UserRole.student,
          bankId: bankId,
        );
      }
    }

    return model.toDomain();
  }
}
