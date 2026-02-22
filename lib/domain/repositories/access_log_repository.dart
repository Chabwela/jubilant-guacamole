import '../entities/access_log.dart';

/// Abstract contract for access-log operations.
abstract class AccessLogRepository {
  /// Persist a new log entry.
  Future<void> logAccess(AccessLog log);

  /// Fetch all log entries (admin).
  Future<List<AccessLog>> getAllLogs();

  /// Fetch logs for a specific user.
  Future<List<AccessLog>> getLogsByUser(int userId);
}
