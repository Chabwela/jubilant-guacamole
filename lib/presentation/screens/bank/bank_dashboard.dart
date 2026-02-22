import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/user.dart';
import '../../providers/repository_providers.dart';
import '../../providers/student_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/common_widgets.dart';

/// Bank user dashboard — enforces Chinese Wall on all student access.
class BankDashboard extends ConsumerStatefulWidget {
  final AppUser user;

  const BankDashboard({super.key, required this.user});

  @override
  ConsumerState<BankDashboard> createState() => _BankDashboardState();
}

class _BankDashboardState extends ConsumerState<BankDashboard> {
  int _selectedIndex = 0;

  static const _navItems = [
    SidebarItem(icon: Icons.people_outline, label: AppStrings.students, index: 0),
    SidebarItem(icon: Icons.receipt_long_outlined, label: AppStrings.transactions, index: 1),
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
            child: _selectedIndex == 0
                ? _BankStudentsPanel(user: widget.user)
                : _BankTransactionsPanel(bankId: widget.user.bankId!),
          ),
        ],
      ),
    );
  }
}

// ── Students Panel ────────────────────────────────────────────────────────────

class _BankStudentsPanel extends ConsumerStatefulWidget {
  final AppUser user;
  const _BankStudentsPanel({required this.user});

  @override
  ConsumerState<_BankStudentsPanel> createState() =>
      _BankStudentsPanelState();
}

class _BankStudentsPanelState extends ConsumerState<_BankStudentsPanel> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Attempts to "search" a student by ID — triggers Chinese Wall check.
  Future<void> _searchStudent() async {
    final input = _searchCtrl.text.trim();
    final studentId = int.tryParse(input);
    if (studentId == null) {
      _showError('Please enter a valid numeric student ID.');
      return;
    }

    setState(() => _isSearching = true);

    // Run the Chinese Wall check via the service.
    final service = ref.read(chineseWallServiceProvider);
    final result = await service.checkAccess(
      requestingUser: widget.user,
      studentId: studentId,
      action: AppStrings.searchAccess,
    );

    if (!mounted) return;
    setState(() => _isSearching = false);

    if (result.isAllowed && result.student != null) {
      _showStudentDetail(result.student!);
    } else {
      _showChineseWallViolation(result.violationReason);
    }
  }

  void _showStudentDetail(Student student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Student Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Name', student.name),
            _DetailRow('Bank ID', student.bankId.toString()),
            _DetailRow('Loan', AppDateUtils.formatCurrency(student.loanAmount)),
            _DetailRow('Monthly Allowance',
                AppDateUtils.formatCurrency(student.monthlyAllowance)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChineseWallViolation(String? reason) {
    showDialog(
      context: context,
      builder: (_) => _ChineseWallViolationDialog(reason: reason),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// Process monthly allowance for a student.
  Future<void> _processAllowance(Student student) async {
    final txRepo = ref.read(transactionRepositoryProvider);
    final tx = LoanTransaction(
      id: 0,
      studentId: student.id,
      bankId: student.bankId,
      amount: student.monthlyAllowance,
      type: TransactionType.allowancePayment,
      date: DateTime.now().toUtc(),
    );
    await txRepo.addTransaction(tx);

    // Log the access
    final service = ref.read(chineseWallServiceProvider);
    await service.checkAccess(
      requestingUser: widget.user,
      studentId: student.id,
      action: AppStrings.processPayment,
    );

    if (!mounted) return;

    // Invalidate transactions cache
    ref.invalidate(bankTransactionsProvider(widget.user.bankId!));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Allowance of ${AppDateUtils.formatCurrency(student.monthlyAllowance)} processed for ${student.name}.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Update the loan amount for a student.
  Future<void> _updateLoan(Student student) async {
    final ctrl = TextEditingController(text: student.loanAmount.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Loan – ${student.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'New Loan Amount (ZMW)',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Update')),
        ],
      ),
    );

    if (confirmed != true) return;
    final newAmount = double.tryParse(ctrl.text.trim());
    if (newAmount == null || newAmount < 0) {
      _showError('Invalid amount entered.');
      return;
    }

    final repo = ref.read(studentRepositoryProvider);
    await repo.updateLoanAmount(student.id, newAmount);

    // Refresh
    ref.invalidate(allStudentsProvider(widget.user));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loan updated to ${AppDateUtils.formatCurrency(newAmount)} for ${student.name}.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider(widget.user));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar
        _TopBar(
          title: AppStrings.students,
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by student ID…',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search, size: 18),
                            onPressed: _searchStudent,
                          ),
                  ),
                  onSubmitted: (_) => _searchStudent(),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _searchStudent,
                icon: const Icon(Icons.search, size: 16),
                label: const Text(AppStrings.searchStudent),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        // Chinese Wall notice
        Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.07),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.info.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 16, color: AppColors.info),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Chinese Wall Policy: You can only view and process records for students assigned to your bank.',
                  style: TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),

        // Student list
        Expanded(
          child: studentsAsync.when(
            loading: () => const AppLoadingIndicator(),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (students) => students.isEmpty
                ? const EmptyState(message: 'No students assigned to your bank.')
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: SectionCard(
                      title: 'Assigned Students (${students.length})',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('NAME')),
                            DataColumn(
                                label: Text('LOAN AMOUNT'), numeric: true),
                            DataColumn(
                                label: Text('MONTHLY ALLOWANCE'),
                                numeric: true),
                            DataColumn(label: Text('ACTIONS')),
                          ],
                          rows: students
                              .map(
                                (s) => DataRow(cells: [
                                  DataCell(Text('#${s.id}')),
                                  DataCell(Text(s.name)),
                                  DataCell(Text(
                                      AppDateUtils.formatCurrency(s.loanAmount))),
                                  DataCell(Text(AppDateUtils.formatCurrency(
                                      s.monthlyAllowance))),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () =>
                                              _processAllowance(s),
                                          icon: const Icon(Icons.payments_outlined,
                                              size: 14),
                                          label: const Text('Pay',
                                              style: TextStyle(fontSize: 12)),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _updateLoan(s),
                                          icon: const Icon(Icons.edit_outlined,
                                              size: 14),
                                          label: const Text('Loan',
                                              style: TextStyle(fontSize: 12)),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                          ),
                                        ),
                                      ],
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
        ),
      ],
    );
  }
}

// ── Transactions Panel ────────────────────────────────────────────────────────

class _BankTransactionsPanel extends ConsumerWidget {
  final int bankId;
  const _BankTransactionsPanel({required this.bankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(bankTransactionsProvider(bankId));

    return Column(
      children: [
        _TopBar(title: AppStrings.transactions),
        Expanded(
          child: txAsync.when(
            loading: () => const AppLoadingIndicator(),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (transactions) => transactions.isEmpty
                ? const EmptyState(message: 'No transactions yet.')
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: SectionCard(
                      title: 'Transaction History (${transactions.length})',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('STUDENT')),
                            DataColumn(label: Text('TYPE')),
                            DataColumn(label: Text('AMOUNT'), numeric: true),
                            DataColumn(label: Text('DATE')),
                          ],
                          rows: transactions
                              .map(
                                (tx) => DataRow(cells: [
                                  DataCell(Text('#${tx.id}')),
                                  DataCell(Text('Student #${tx.studentId}')),
                                  DataCell(Text(tx.type.label)),
                                  DataCell(Text(
                                      AppDateUtils.formatCurrency(tx.amount))),
                                  DataCell(
                                      Text(AppDateUtils.formatDate(tx.date))),
                                ]),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final Widget? child;

  const _TopBar({required this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog shown when a Chinese Wall violation is detected.
class _ChineseWallViolationDialog extends StatelessWidget {
  final String? reason;

  const _ChineseWallViolationDialog({this.reason});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Red header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              children: [
                const Icon(Icons.gpp_bad_outlined,
                    color: Colors.white, size: 36),
                const SizedBox(height: 8),
                Text(
                  AppStrings.accessDenied,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.chineseWallViolation,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          AppStrings.accessViolationLogged,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Acknowledge'),
        ),
      ],
    );
  }
}
