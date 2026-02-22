import 'package:flutter_test/flutter_test.dart';
import 'package:university_loan_system/domain/entities/access_log.dart';
import 'package:university_loan_system/domain/entities/bank.dart';
import 'package:university_loan_system/domain/entities/student.dart';
import 'package:university_loan_system/domain/entities/user.dart';
import 'package:university_loan_system/domain/repositories/access_log_repository.dart';
import 'package:university_loan_system/domain/repositories/student_repository.dart';
import 'package:university_loan_system/domain/services/chinese_wall_service.dart';

// ── Stub repositories ──────────────────────────────────────────────────────

class _StubStudentRepo implements StudentRepository {
  final Map<int, Student> students;
  _StubStudentRepo(this.students);

  @override
  Future<Student?> getStudentById(int studentId) async =>
      students[studentId];

  @override
  Future<Student?> getStudentByName(String name) async {
    try {
      return students.values.firstWhere(
        (s) => s.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Student>> getAllStudents() async => students.values.toList();

  @override
  Future<List<Student>> getStudentsByBank(int bankId) async =>
      students.values.where((s) => s.bankId == bankId).toList();

  @override
  Future<void> updateLoanAmount(int studentId, double newAmount) async {}

  @override
  Future<List<Bank>> getAllBanks() async => [];
}

class _StubLogRepo implements AccessLogRepository {
  final List<AccessLog> logs = [];

  @override
  Future<void> logAccess(AccessLog log) async => logs.add(log);

  @override
  Future<List<AccessLog>> getAllLogs() async => logs;

  @override
  Future<List<AccessLog>> getLogsByUser(int userId) async =>
      logs.where((l) => l.userId == userId).toList();
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  const zanaco = 1;
  const fnb = 2;

  final alice = Student(
    id: 1,
    name: 'Alice Mwanza',
    bankId: zanaco,
    loanAmount: 15000,
    monthlyAllowance: 1200,
  );
  final bob = Student(
    id: 2,
    name: 'Bob Phiri',
    bankId: fnb,
    loanAmount: 22500,
    monthlyAllowance: 1800,
  );

  final zanacoUser = AppUser(
    id: 2,
    name: 'Zanaco Officer',
    role: UserRole.bank,
    bankId: zanaco,
  );
  final fnbUser = AppUser(
    id: 3,
    name: 'FNB Officer',
    role: UserRole.bank,
    bankId: fnb,
  );
  final adminUser = AppUser(
    id: 1,
    name: 'Admin',
    role: UserRole.admin,
  );

  late _StubStudentRepo studentRepo;
  late _StubLogRepo logRepo;
  late ChineseWallService service;

  setUp(() {
    studentRepo = _StubStudentRepo({alice.id: alice, bob.id: bob});
    logRepo = _StubLogRepo();
    service = ChineseWallService(
      studentRepo: studentRepo,
      logRepo: logRepo,
    );
  });

  group('ChineseWallService', () {
    test('Zanaco officer can access Alice (same bank)', () async {
      final result = await service.checkAccess(
        requestingUser: zanacoUser,
        studentId: alice.id,
        action: 'VIEW',
      );

      expect(result.isAllowed, isTrue);
      expect(result.student?.id, equals(alice.id));
    });

    test('Zanaco officer is DENIED access to Bob (different bank)', () async {
      final result = await service.checkAccess(
        requestingUser: zanacoUser,
        studentId: bob.id,
        action: 'VIEW',
      );

      expect(result.isAllowed, isFalse);
      expect(result.student, isNull);
      expect(result.violationReason, contains('Chinese Wall'));
    });

    test('FNB officer can access Bob (same bank)', () async {
      final result = await service.checkAccess(
        requestingUser: fnbUser,
        studentId: bob.id,
        action: 'VIEW',
      );

      expect(result.isAllowed, isTrue);
      expect(result.student?.id, equals(bob.id));
    });

    test('FNB officer is DENIED access to Alice (different bank)', () async {
      final result = await service.checkAccess(
        requestingUser: fnbUser,
        studentId: alice.id,
        action: 'VIEW',
      );

      expect(result.isAllowed, isFalse);
    });

    test('Admin user can access any student', () async {
      final resultAlice = await service.checkAccess(
        requestingUser: adminUser,
        studentId: alice.id,
        action: 'VIEW',
      );
      final resultBob = await service.checkAccess(
        requestingUser: adminUser,
        studentId: bob.id,
        action: 'VIEW',
      );

      expect(resultAlice.isAllowed, isTrue);
      expect(resultBob.isAllowed, isTrue);
    });

    test('Every access attempt is logged', () async {
      await service.checkAccess(
        requestingUser: zanacoUser,
        studentId: alice.id,
        action: 'VIEW',
      );
      await service.checkAccess(
        requestingUser: zanacoUser,
        studentId: bob.id, // violation
        action: 'SEARCH',
      );

      expect(logRepo.logs.length, equals(2));
    });

    test('Violation is logged with DENIED status', () async {
      await service.checkAccess(
        requestingUser: zanacoUser,
        studentId: bob.id,
        action: 'VIEW',
      );

      final deniedLogs =
          logRepo.logs.where((l) => l.status == AccessStatus.denied).toList();
      expect(deniedLogs.length, equals(1));
    });

    test('getAllowedStudents returns only bank-scoped students', () async {
      final zanacoStudents =
          await service.getAllowedStudents(zanacoUser);
      final fnbStudents = await service.getAllowedStudents(fnbUser);
      final adminStudents = await service.getAllowedStudents(adminUser);

      expect(zanacoStudents.map((s) => s.id), contains(alice.id));
      expect(zanacoStudents.map((s) => s.id), isNot(contains(bob.id)));

      expect(fnbStudents.map((s) => s.id), contains(bob.id));
      expect(fnbStudents.map((s) => s.id), isNot(contains(alice.id)));

      expect(adminStudents.length, equals(2));
    });

    test('Access to non-existent student is denied and logged', () async {
      final result = await service.checkAccess(
        requestingUser: zanacoUser,
        studentId: 9999,
        action: 'VIEW',
      );

      expect(result.isAllowed, isFalse);
      expect(logRepo.logs.last.status, equals(AccessStatus.denied));
    });
  });
}
