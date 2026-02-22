import '../entities/transaction.dart';

/// Abstract contract for transaction data access.
abstract class TransactionRepository {
  /// Fetch all transactions (admin).
  Future<List<LoanTransaction>> getAllTransactions();

  /// Fetch transactions for a specific student.
  Future<List<LoanTransaction>> getTransactionsByStudent(int studentId);

  /// Fetch transactions processed by a specific bank.
  Future<List<LoanTransaction>> getTransactionsByBank(int bankId);

  /// Record a new transaction.
  Future<void> addTransaction(LoanTransaction tx);
}
