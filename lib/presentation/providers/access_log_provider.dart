import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/access_log.dart';
import 'repository_providers.dart';

/// Provides all access logs (admin).
final allAccessLogsProvider =
    FutureProvider.autoDispose<List<AccessLog>>((ref) async {
  final repo = ref.watch(accessLogRepositoryProvider);
  return repo.getAllLogs();
});
