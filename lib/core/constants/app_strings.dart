/// Application-wide string constants.
class AppStrings {
  AppStrings._();

  static const String appTitle = 'UniLoan System';
  static const String appSubtitle = 'University Loan & Allowance Management';

  // Auth
  static const String login = 'Sign In';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String role = 'Role';
  static const String selectRole = 'Select Role';
  static const String invalidCredentials = 'Invalid username or password.';
  static const String logout = 'Sign Out';

  // Roles
  static const String roleAdmin = 'Admin';
  static const String roleBank = 'Bank';
  static const String roleStudent = 'Student';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String students = 'Students';
  static const String transactions = 'Transactions';
  static const String accessLogs = 'Access Logs';
  static const String myLoan = 'My Loan';
  static const String myAllowance = 'My Allowance';
  static const String myTransactions = 'My Transactions';

  // KPI
  static const String totalStudents = 'Total Students';
  static const String totalLoans = 'Total Loans (ZMW)';
  static const String totalAllowancesPaid = 'Allowances Paid (ZMW)';
  static const String totalBanks = 'Total Banks';

  // Chinese Wall
  static const String accessDenied = 'ACCESS DENIED';
  static const String chineseWallViolation =
      'Chinese Wall Policy Violation.\nYou are not authorized to access records belonging to another bank.';
  static const String accessViolationLogged =
      'This access attempt has been logged and flagged.';

  // Bank actions
  static const String processAllowance = 'Process Monthly Allowance';
  static const String updateLoan = 'Update Loan Amount';
  static const String searchStudent = 'Search Student';

  // Status
  static const String allowed = 'ALLOWED';
  static const String denied = 'DENIED';

  // Actions
  static const String viewRecord = 'VIEW';
  static const String processPayment = 'PROCESS_PAYMENT';
  static const String searchAccess = 'SEARCH';
}
