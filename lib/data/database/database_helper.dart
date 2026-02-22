import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Handles SQLite database initialisation, schema creation, and demo data seeding.
class DatabaseHelper {
  static const String _dbName = 'uniloan.db';
  static const int _dbVersion = 1;

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // ── Schema ──────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Banks (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL,
        username TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL,
        role     TEXT    NOT NULL,
        bankId   INTEGER,
        FOREIGN KEY (bankId) REFERENCES Banks(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Students (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        name             TEXT    NOT NULL,
        bankId           INTEGER NOT NULL,
        loanAmount       REAL    NOT NULL DEFAULT 0,
        monthlyAllowance REAL    NOT NULL DEFAULT 0,
        FOREIGN KEY (bankId) REFERENCES Banks(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Transactions (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        bankId    INTEGER NOT NULL,
        amount    REAL    NOT NULL,
        type      TEXT    NOT NULL,
        date      TEXT    NOT NULL,
        FOREIGN KEY (studentId) REFERENCES Students(id),
        FOREIGN KEY (bankId)    REFERENCES Banks(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE AccessLogs (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        userId    INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        action    TEXT    NOT NULL,
        timestamp TEXT    NOT NULL,
        status    TEXT    NOT NULL,
        FOREIGN KEY (userId) REFERENCES Users(id)
      )
    ''');

    // ── Seed data ────────────────────────────────────────────────────────────
    await _seedData(db);
  }

  /// Insert demo banks, users, students, and initial transactions.
  ///
  /// SECURITY NOTE: Passwords here are stored in plain text for demo purposes only.
  /// In production, use a secure hashing algorithm (e.g., bcrypt/Argon2) and
  /// compare using constant-time functions to prevent timing attacks.
  static Future<void> _seedData(Database db) async {
    // Banks
    final zanaco = await db.insert('Banks', {'name': 'Zanaco'});
    final fnb = await db.insert('Banks', {'name': 'FNB'});

    // Admin user (no bankId)
    await db.insert('Users', {
      'name': 'System Administrator',
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
      'bankId': null,
    });

    // Bank users
    await db.insert('Users', {
      'name': 'Zanaco Officer',
      'username': 'zanaco',
      'password': 'zanaco123',
      'role': 'bank',
      'bankId': zanaco,
    });

    await db.insert('Users', {
      'name': 'FNB Officer',
      'username': 'fnb',
      'password': 'fnb123',
      'role': 'bank',
      'bankId': fnb,
    });

    // Students — Alice belongs to Zanaco, Bob belongs to FNB
    final alice = await db.insert('Students', {
      'name': 'Alice Mwanza',
      'bankId': zanaco,
      'loanAmount': 15000.00,
      'monthlyAllowance': 1200.00,
    });

    final bob = await db.insert('Students', {
      'name': 'Bob Phiri',
      'bankId': fnb,
      'loanAmount': 22500.00,
      'monthlyAllowance': 1800.00,
    });

    // Student user accounts
    await db.insert('Users', {
      'name': 'Alice Mwanza',
      'username': 'alice',
      'password': 'alice123',
      'role': 'student',
      'bankId': zanaco,
    });

    await db.insert('Users', {
      'name': 'Bob Phiri',
      'username': 'bob',
      'password': 'bob123',
      'role': 'student',
      'bankId': fnb,
    });

    final now = DateTime.now().toUtc();

    // Seed some initial transactions
    await db.insert('Transactions', {
      'studentId': alice,
      'bankId': zanaco,
      'amount': 15000.00,
      'type': 'loanDisbursement',
      'date': now.subtract(const Duration(days: 90)).toIso8601String(),
    });

    await db.insert('Transactions', {
      'studentId': alice,
      'bankId': zanaco,
      'amount': 1200.00,
      'type': 'allowancePayment',
      'date': now.subtract(const Duration(days: 60)).toIso8601String(),
    });

    await db.insert('Transactions', {
      'studentId': alice,
      'bankId': zanaco,
      'amount': 1200.00,
      'type': 'allowancePayment',
      'date': now.subtract(const Duration(days: 30)).toIso8601String(),
    });

    await db.insert('Transactions', {
      'studentId': bob,
      'bankId': fnb,
      'amount': 22500.00,
      'type': 'loanDisbursement',
      'date': now.subtract(const Duration(days: 90)).toIso8601String(),
    });

    await db.insert('Transactions', {
      'studentId': bob,
      'bankId': fnb,
      'amount': 1800.00,
      'type': 'allowancePayment',
      'date': now.subtract(const Duration(days: 60)).toIso8601String(),
    });

    await db.insert('Transactions', {
      'studentId': bob,
      'bankId': fnb,
      'amount': 1800.00,
      'type': 'allowancePayment',
      'date': now.subtract(const Duration(days: 30)).toIso8601String(),
    });
  }
}
