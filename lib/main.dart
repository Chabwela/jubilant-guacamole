import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/user.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/admin/admin_dashboard.dart';
import 'presentation/screens/bank/bank_dashboard.dart';
import 'presentation/screens/student/student_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: UniLoanApp(),
    ),
  );
}

/// Root application widget.
class UniLoanApp extends ConsumerWidget {
  const UniLoanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'UniLoan System',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const _RootNavigator(),
    );
  }
}

/// Routes the user to the appropriate screen based on auth state.
class _RootNavigator extends ConsumerWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const LoginScreen();
    }

    return _buildDashboard(user);
  }

  Widget _buildDashboard(AppUser user) {
    switch (user.role) {
      case UserRole.admin:
        return AdminDashboard(user: user);
      case UserRole.bank:
        return BankDashboard(user: user);
      case UserRole.student:
        return StudentDashboard(user: user);
    }
  }
}
