import 'package:sqflite/sqflite.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

/// SQLite-backed implementation of [TransactionRepository].
class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<List<LoanTransaction>> getAllTransactions() async {
    final db = await DatabaseHelper.database;
    final rows =
        await db.query('Transactions', orderBy: 'date DESC');
    return rows.map((r) => TransactionModel.fromMap(r).toDomain()).toList();
  }

  @override
  Future<List<LoanTransaction>> getTransactionsByStudent(
      int studentId) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'Transactions',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => TransactionModel.fromMap(r).toDomain()).toList();
  }

  @override
  Future<List<LoanTransaction>> getTransactionsByBank(int bankId) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'Transactions',
      where: 'bankId = ?',
      whereArgs: [bankId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => TransactionModel.fromMap(r).toDomain()).toList();
  }

  @override
  Future<void> addTransaction(LoanTransaction tx) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'Transactions',
      {
        'studentId': tx.studentId,
        'bankId': tx.bankId,
        'amount': tx.amount,
        'type': TransactionModel.fromDomainType(tx.type),
        'date': tx.date.toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
