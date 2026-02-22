import '../../domain/entities/access_log.dart';

/// Data model for the AccessLogs table.
class AccessLogModel {
  final int id;
  final int userId;
  final int studentId;
  final String action;
  final String timestamp;
  final String status;

  const AccessLogModel({
    required this.id,
    required this.userId,
    required this.studentId,
    required this.action,
    required this.timestamp,
    required this.status,
  });

  factory AccessLogModel.fromMap(Map<String, dynamic> map) {
    return AccessLogModel(
      id: map['id'] as int,
      userId: map['userId'] as int,
      studentId: map['studentId'] as int,
      action: map['action'] as String,
      timestamp: map['timestamp'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'studentId': studentId,
      'action': action,
      'timestamp': timestamp,
      'status': status,
    };
  }

  AccessLog toDomain() {
    return AccessLog(
      id: id,
      userId: userId,
      studentId: studentId,
      action: action,
      timestamp: DateTime.parse(timestamp).toLocal(),
      status: status == 'ALLOWED' ? AccessStatus.allowed : AccessStatus.denied,
    );
  }

  static AccessLogModel fromDomain(AccessLog log) {
    return AccessLogModel(
      id: log.id,
      userId: log.userId,
      studentId: log.studentId,
      action: log.action,
      timestamp: log.timestamp.toUtc().toIso8601String(),
      status: log.status == AccessStatus.allowed ? 'ALLOWED' : 'DENIED',
    );
  }
}
