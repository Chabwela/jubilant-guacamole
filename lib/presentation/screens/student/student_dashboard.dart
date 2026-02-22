import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/user.dart';
import '../../providers/student_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/kpi_card.dart';

/// Student dashboard — read-only view of personal loan, allowance, and transactions.
class StudentDashboard extends ConsumerWidget {
  final AppUser user;

  const StudentDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the student record whose bankId matches the current user
    final studentsAsync = ref.watch(allStudentsProvider(user));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text(AppStrings.logout),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          // Find the student record that matches the logged-in user by name.
          Student? student;
          try {
            student = students.firstWhere(
              (s) => s.name.toLowerCase() == user.name.toLowerCase(),
            );
          } catch (_) {
            student = students.isNotEmpty ? students.first : null;
          }
          if (student == null) {
            return const EmptyState(
              message: 'Your student record could not be found.',
              icon: Icons.person_off_outlined,
            );
          }

          final txAsync =
              ref.watch(studentTransactionsProvider(student.id));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryAccent,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Your loan & allowance summary',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // KPI cards
                LayoutBuilder(builder: (context, constraints) {
                  final cols = constraints.maxWidth > 600 ? 2 : 1;
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2,
                    children: [
                      KpiCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: AppStrings.myLoan,
                        value: AppDateUtils.formatCurrency(
                            student.loanAmount),
                        iconColor: AppColors.primary,
                      ),
                      KpiCard(
                        icon: Icons.payments_outlined,
                        label: AppStrings.myAllowance,
                        value: AppDateUtils.formatCurrency(
                            student.monthlyAllowance),
                        iconColor: AppColors.success,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Transaction history
                SectionCard(
                  title: AppStrings.myTransactions,
                  child: txAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: AppLoadingIndicator(),
                    ),
                    error: (e, _) =>
                        Center(child: Text('Error: $e')),
                    data: (transactions) => transactions.isEmpty
                        ? const EmptyState(
                            message: 'No transactions yet.')
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('TYPE')),
                                DataColumn(
                                    label: Text('AMOUNT'),
                                    numeric: true),
                                DataColumn(label: Text('DATE')),
                              ],
                              rows: transactions
                                  .map(
                                    (tx) => DataRow(cells: [
                                      DataCell(Text('#${tx.id}')),
                                      DataCell(Text(tx.type.label)),
                                      DataCell(Text(
                                          AppDateUtils.formatCurrency(
                                              tx.amount))),
                                      DataCell(Text(
                                          AppDateUtils.formatDate(
                                              tx.date))),
                                    ]),
                                  )
                                  .toList(),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
