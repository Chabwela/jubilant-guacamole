import '../entities/bank.dart';
import '../entities/student.dart';

/// Abstract contract for student/bank data access.
abstract class StudentRepository {
  /// Fetch all students (admin only).
  Future<List<Student>> getAllStudents();

  /// Fetch students assigned to a specific bank.
  Future<List<Student>> getStudentsByBank(int bankId);

  /// Fetch a single student by ID.
  Future<Student?> getStudentById(int studentId);

  /// Fetch a student by their name (case-insensitive).
  Future<Student?> getStudentByName(String name);

  /// Update a student's loan amount.
  Future<void> updateLoanAmount(int studentId, double newAmount);

  /// Fetch all banks.
  Future<List<Bank>> getAllBanks();
}
