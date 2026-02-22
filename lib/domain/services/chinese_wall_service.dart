import '../entities/access_log.dart';
import '../entities/student.dart';
import '../entities/user.dart';
import '../repositories/access_log_repository.dart';
import '../repositories/student_repository.dart';

/// Result returned by a Chinese Wall access check.
class AccessCheckResult {
  final bool isAllowed;
  final Student? student; // Non-null when access is granted
  final String? violationReason;

  const AccessCheckResult.allowed(this.student)
      : isAllowed = true,
        violationReason = null;

  const AccessCheckResult.denied(this.violationReason)
      : isAllowed = false,
        student = null;
}

/// Enforces the Chinese Wall (Conflict-of-Interest) security model.
///
/// Core rule: A bank user may ONLY access students assigned to their own bank.
/// Any attempt to access a student from a different bank is a policy violation.
/// Every access attempt — successful or not — is written to AccessLogs.
class ChineseWallService {
  final StudentRepository _studentRepo;
  final AccessLogRepository _logRepo;

  ChineseWallService({
    required StudentRepository studentRepo,
    required AccessLogRepository logRepo,
  })  : _studentRepo = studentRepo,
        _logRepo = logRepo;

  /// Attempts to access [studentId] on behalf of [requestingUser].
  ///
  /// Returns [AccessCheckResult.allowed] if access is permitted, or
  /// [AccessCheckResult.denied] if the Chinese Wall policy is violated.
  /// An [AccessLog] entry is always persisted regardless of outcome.
  Future<AccessCheckResult> checkAccess({
    required AppUser requestingUser,
    required int studentId,
    required String action,
  }) async {
    // Admins are super-users: always allowed, still logged.
    if (requestingUser.isAdmin) {
      await _writeLog(
        userId: requestingUser.id,
        studentId: studentId,
        action: action,
        status: AccessStatus.allowed,
      );
      final student = await _studentRepo.getStudentById(studentId);
      return AccessCheckResult.allowed(student);
    }

    final student = await _studentRepo.getStudentById(studentId);

    if (student == null) {
      // Student not found — deny and log.
      await _writeLog(
        userId: requestingUser.id,
        studentId: studentId,
        action: action,
        status: AccessStatus.denied,
      );
      return const AccessCheckResult.denied('Student record not found.');
    }

    // ---------------------------------------------------------------
    // CHINESE WALL ENFORCEMENT
    // For a bank user, their bankId must match the student's bankId.
    // If it does not, the access is a policy violation and must be denied.
    // ---------------------------------------------------------------
    final bool bankMatches = requestingUser.bankId == student.bankId;

    if (!bankMatches) {
      // Log the VIOLATION before denying.
      await _writeLog(
        userId: requestingUser.id,
        studentId: studentId,
        action: action,
        status: AccessStatus.denied,
      );
      return const AccessCheckResult.denied(
        'Chinese Wall Policy Violation: '
        'The requested student belongs to a different bank.',
      );
    }

    // Access is permitted.
    await _writeLog(
      userId: requestingUser.id,
      studentId: studentId,
      action: action,
      status: AccessStatus.allowed,
    );
    return AccessCheckResult.allowed(student);
  }

  /// Convenience method: returns only students the [bankUser] is allowed to see.
  /// For bank users this is strictly students in their assigned bank.
  /// For admins this returns ALL students.
  Future<List<Student>> getAllowedStudents(AppUser user) async {
    if (user.isAdmin) {
      return _studentRepo.getAllStudents();
    }
    if (user.isBank && user.bankId != null) {
      return _studentRepo.getStudentsByBank(user.bankId!);
    }
    return [];
  }

  Future<void> _writeLog({
    required int userId,
    required int studentId,
    required String action,
    required AccessStatus status,
  }) async {
    final log = AccessLog(
      id: 0, // Auto-assigned by DB
      userId: userId,
      studentId: studentId,
      action: action,
      timestamp: DateTime.now().toUtc(),
      status: status,
    );
    await _logRepo.logAccess(log);
  }
}
