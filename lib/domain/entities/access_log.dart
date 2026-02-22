/// Whether an access attempt was allowed or denied.
enum AccessStatus { allowed, denied }

/// Domain entity for an access-log entry (Chinese Wall audit trail).
class AccessLog {
  final int id;
  final int userId;       // The user making the request
  final int studentId;    // The student record being accessed
  final String action;    // e.g. VIEW, SEARCH, PROCESS_PAYMENT
  final DateTime timestamp;
  final AccessStatus status;

  const AccessLog({
    required this.id,
    required this.userId,
    required this.studentId,
    required this.action,
    required this.timestamp,
    required this.status,
  });

  bool get isDenied => status == AccessStatus.denied;

  @override
  String toString() =>
      'AccessLog(userId: $userId, studentId: $studentId, action: $action, status: $status)';
}
