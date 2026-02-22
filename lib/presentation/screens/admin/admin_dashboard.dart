import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/access_log.dart';
import '../../../domain/entities/bank.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/user.dart';
import '../../providers/access_log_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/kpi_card.dart';

/// Complete Admin dashboard with KPI overview, students, transactions, and access logs.
class AdminDashboard extends ConsumerStatefulWidget {
  final AppUser user;

  const AdminDashboard({super.key, required this.user});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

  static const _navItems = [
    SidebarItem(icon: Icons.dashboard_outlined, label: AppStrings.dashboard, index: 0),
    SidebarItem(icon: Icons.people_outline, label: AppStrings.students, index: 1),
    SidebarItem(icon: Icons.receipt_long_outlined, label: AppStrings.transactions, index: 2),
    SidebarItem(icon: Icons.security_outlined, label: AppStrings.accessLogs, index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            user: widget.user,
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
            items: _navItems,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardOverview(user: widget.user);
      case 1:
        return _StudentsPanel(user: widget.user);
      case 2:
        return _TransactionsPanel();
      case 3:
        return _AccessLogsPanel();
      default:
        return _DashboardOverview(user: widget.user);
    }
  }
}

// ── Dashboard Overview ───────────────────────────────────────────────────────

class _DashboardOverview extends ConsumerWidget {
  final AppUser user;
  const _DashboardOverview({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(allStudentsProvider(user));
    final banksAsync = ref.watch(allBanksProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);

    return _PageShell(
      title: AppStrings.dashboard,
      child: studentsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) => transactionsAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (transactions) => banksAsync.when(
            loading: () => const AppLoadingIndicator(),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (banks) => _OverviewContent(
              students: students,
              transactions: transactions,
              banks: banks,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  final List<Student> students;
  final List<LoanTransaction> transactions;
  final List<Bank> banks;

  const _OverviewContent({
    required this.students,
    required this.transactions,
    required this.banks,
  });

  @override
  Widget build(BuildContext context) {
    final totalLoans =
        students.fold<double>(0, (sum, s) => sum + s.loanAmount);
    final totalAllowances = transactions
        .where((t) => t.type == TransactionType.allowancePayment)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                    ? 2
                    : 1;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                KpiCard(
                  icon: Icons.people_outline,
                  label: AppStrings.totalStudents,
                  value: students.length.toString(),
                  iconColor: AppColors.primaryAccent,
                ),
                KpiCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: AppStrings.totalLoans,
                  value: AppDateUtils.formatCurrency(totalLoans),
                  iconColor: AppColors.primary,
                ),
                KpiCard(
                  icon: Icons.payments_outlined,
                  label: AppStrings.totalAllowancesPaid,
                  value: AppDateUtils.formatCurrency(totalAllowances),
                  iconColor: AppColors.success,
                ),
                KpiCard(
                  icon: Icons.account_balance_outlined,
                  label: AppStrings.totalBanks,
                  value: banks.length.toString(),
                  iconColor: AppColors.warning,
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // Recent transactions
          SectionCard(
            title: 'Recent Transactions',
            child: _RecentTransactionsList(transactions: transactions.take(5).toList()),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsList extends StatelessWidget {
  final List<LoanTransaction> transactions;
  const _RecentTransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyState(message: 'No transactions yet.');
    }
    return Column(
      children: transactions.map((tx) {
        return ListTile(
          dense: true,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              tx.type == TransactionType.loanDisbursement
                  ? Icons.account_balance_wallet_outlined
                  : Icons.payments_outlined,
              size: 16,
              color: AppColors.primaryAccent,
            ),
          ),
          title: Text(
            tx.type.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Student #${tx.studentId}  ·  Bank #${tx.bankId}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppDateUtils.formatCurrency(tx.amount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                AppDateUtils.formatDate(tx.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Students Panel ───────────────────────────────────────────────────────────

class _StudentsPanel extends ConsumerWidget {
  final AppUser user;
  const _StudentsPanel({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(allStudentsProvider(user));
    final banksAsync = ref.watch(allBanksProvider);

    return _PageShell(
      title: AppStrings.students,
      child: studentsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) => banksAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (banks) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SectionCard(
              title: 'All Students (${students.length})',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('NAME')),
                    DataColumn(label: Text('BANK')),
                    DataColumn(label: Text('LOAN AMOUNT'), numeric: true),
                    DataColumn(label: Text('MONTHLY ALLOWANCE'), numeric: true),
                  ],
                  rows: students.map((s) {
                    final bankName = banks
                        .firstWhere(
                          (b) => b.id == s.bankId,
                          orElse: () => Bank(id: 0, name: 'Unknown'),
                        )
                        .name;
                    return DataRow(cells: [
                      DataCell(Text('#${s.id}')),
                      DataCell(Text(s.name)),
                      DataCell(Text(bankName)),
                      DataCell(Text(AppDateUtils.formatCurrency(s.loanAmount))),
                      DataCell(Text(AppDateUtils.formatCurrency(s.monthlyAllowance))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Transactions Panel ───────────────────────────────────────────────────────

class _TransactionsPanel extends ConsumerWidget {
  const _TransactionsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(allTransactionsProvider);

    return _PageShell(
      title: AppStrings.transactions,
      child: txAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transactions) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SectionCard(
            title: 'All Transactions (${transactions.length})',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('STUDENT')),
                  DataColumn(label: Text('BANK')),
                  DataColumn(label: Text('TYPE')),
                  DataColumn(label: Text('AMOUNT'), numeric: true),
                  DataColumn(label: Text('DATE')),
                ],
                rows: transactions
                    .map(
                      (tx) => DataRow(cells: [
                        DataCell(Text('#${tx.id}')),
                        DataCell(Text('Student #${tx.studentId}')),
                        DataCell(Text('Bank #${tx.bankId}')),
                        DataCell(Text(tx.type.label)),
                        DataCell(
                            Text(AppDateUtils.formatCurrency(tx.amount))),
                        DataCell(Text(AppDateUtils.formatDate(tx.date))),
                      ]),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Access Logs Panel ────────────────────────────────────────────────────────

class _AccessLogsPanel extends ConsumerWidget {
  const _AccessLogsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allAccessLogsProvider);

    return _PageShell(
      title: AppStrings.accessLogs,
      child: logsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SectionCard(
            title: 'Access Audit Log (${logs.length} entries)',
            child: logs.isEmpty
                ? const EmptyState(
                    message: 'No access events recorded yet.',
                    icon: Icons.security_outlined,
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('USER')),
                        DataColumn(label: Text('STUDENT')),
                        DataColumn(label: Text('ACTION')),
                        DataColumn(label: Text('TIMESTAMP')),
                        DataColumn(label: Text('STATUS')),
                      ],
                      rows: logs
                          .map(
                            (log) => DataRow(cells: [
                              DataCell(Text('#${log.id}')),
                              DataCell(Text('User #${log.userId}')),
                              DataCell(Text('Student #${log.studentId}')),
                              DataCell(Text(log.action)),
                              DataCell(
                                  Text(AppDateUtils.formatIso(
                                      log.timestamp.toIso8601String()))),
                              DataCell(
                                StatusBadge(
                                  label: log.status == AccessStatus.allowed
                                      ? AppStrings.allowed
                                      : AppStrings.denied,
                                  isSuccess:
                                      log.status == AccessStatus.allowed,
                                ),
                              ),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Shared page shell ─────────────────────────────────────────────────────────

class _PageShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _PageShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
