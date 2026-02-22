import 'package:sqflite/sqflite.dart';
import '../../domain/entities/access_log.dart';
import '../../domain/repositories/access_log_repository.dart';
import '../database/database_helper.dart';
import '../models/access_log_model.dart';

/// SQLite-backed implementation of [AccessLogRepository].
class AccessLogRepositoryImpl implements AccessLogRepository {
  @override
  Future<void> logAccess(AccessLog log) async {
    final db = await DatabaseHelper.database;
    final model = AccessLogModel.fromDomain(log);
    await db.insert(
      'AccessLogs',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<AccessLog>> getAllLogs() async {
    final db = await DatabaseHelper.database;
    final rows =
        await db.query('AccessLogs', orderBy: 'timestamp DESC');
    return rows.map((r) => AccessLogModel.fromMap(r).toDomain()).toList();
  }

  @override
  Future<List<AccessLog>> getLogsByUser(int userId) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'AccessLogs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return rows.map((r) => AccessLogModel.fromMap(r).toDomain()).toList();
  }
}
