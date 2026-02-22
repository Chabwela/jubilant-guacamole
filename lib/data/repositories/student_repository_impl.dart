import '../../domain/entities/bank.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../database/database_helper.dart';
import '../models/bank_model.dart';
import '../models/student_model.dart';

/// SQLite-backed implementation of [StudentRepository].
class StudentRepositoryImpl implements StudentRepository {
  @override
  Future<List<Student>> getAllStudents() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query('Students', orderBy: 'name ASC');
    return rows.map((r) => StudentModel.fromMap(r).toDomain()).toList();
  }

  @override
  Future<List<Student>> getStudentsByBank(int bankId) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'Students',
      where: 'bankId = ?',
      whereArgs: [bankId],
      orderBy: 'name ASC',
    );
    return rows.map((r) => StudentModel.fromMap(r).toDomain()).toList();
  }

  @override
  Future<Student?> getStudentById(int studentId) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'Students',
      where: 'id = ?',
      whereArgs: [studentId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudentModel.fromMap(rows.first).toDomain();
  }

  @override
  Future<Student?> getStudentByName(String name) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'Students',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudentModel.fromMap(rows.first).toDomain();
  }

  @override
  Future<void> updateLoanAmount(int studentId, double newAmount) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'Students',
      {'loanAmount': newAmount},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  @override
  Future<List<Bank>> getAllBanks() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query('Banks', orderBy: 'name ASC');
    return rows.map((r) => BankModel.fromMap(r).toDomain()).toList();
  }
}
