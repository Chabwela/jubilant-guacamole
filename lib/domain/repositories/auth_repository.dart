import '../entities/user.dart';

/// Abstract contract for authentication operations.
abstract class AuthRepository {
  /// Returns the authenticated [AppUser] or null if credentials are wrong.
  Future<AppUser?> login(String username, String password);
}
