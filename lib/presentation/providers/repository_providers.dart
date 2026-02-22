import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/access_log_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/access_log_repository.dart';
import '../../domain/services/chinese_wall_service.dart';

// ── Repository providers ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepositoryImpl(),
);

final studentRepositoryProvider = Provider<StudentRepository>(
  (_) => StudentRepositoryImpl(),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (_) => TransactionRepositoryImpl(),
);

final accessLogRepositoryProvider = Provider<AccessLogRepository>(
  (_) => AccessLogRepositoryImpl(),
);

// ── Service providers ───────────────────────────────────────────────────────

final chineseWallServiceProvider = Provider<ChineseWallService>((ref) {
  return ChineseWallService(
    studentRepo: ref.watch(studentRepositoryProvider),
    logRepo: ref.watch(accessLogRepositoryProvider),
  );
});
