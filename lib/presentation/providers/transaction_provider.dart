import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import 'repository_providers.dart';

/// Provides all transactions (admin).
final allTransactionsProvider =
    FutureProvider.autoDispose<List<LoanTransaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getAllTransactions();
});

/// Provides transactions for a specific student.
final studentTransactionsProvider = FutureProvider.autoDispose
    .family<List<LoanTransaction>, int>((ref, studentId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsByStudent(studentId);
});

/// Provides transactions for a specific bank.
final bankTransactionsProvider = FutureProvider.autoDispose
    .family<List<LoanTransaction>, int>((ref, bankId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsByBank(bankId);
});
