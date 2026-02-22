import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/user.dart';
import 'repository_providers.dart';

/// Provides all students (admin) or bank-scoped students (bank user).
final allStudentsProvider = FutureProvider.autoDispose
    .family<List<Student>, AppUser?>((ref, user) async {
  if (user == null) return [];
  final repo = ref.watch(studentRepositoryProvider);
  if (user.isAdmin) return repo.getAllStudents();
  if ((user.isBank || user.isStudent) && user.bankId != null) {
    return repo.getStudentsByBank(user.bankId!);
  }
  return [];
});

/// Provides a single student by ID.
final studentByIdProvider =
    FutureProvider.autoDispose.family<Student?, int>((ref, id) async {
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getStudentById(id);
});

/// Provides all banks.
final allBanksProvider =
    FutureProvider.autoDispose<List<Bank>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getAllBanks();
});
