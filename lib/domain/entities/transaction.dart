/// Types of financial transactions in the system.
enum TransactionType { loanDisbursement, allowancePayment, loanRepayment }

extension TransactionTypeLabel on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.loanDisbursement:
        return 'Loan Disbursement';
      case TransactionType.allowancePayment:
        return 'Allowance Payment';
      case TransactionType.loanRepayment:
        return 'Loan Repayment';
    }
  }
}

/// Domain entity for a financial transaction.
class LoanTransaction {
  final int id;
  final int studentId;
  final int bankId;
  final double amount;
  final TransactionType type;
  final DateTime date;

  const LoanTransaction({
    required this.id,
    required this.studentId,
    required this.bankId,
    required this.amount,
    required this.type,
    required this.date,
  });

  @override
  String toString() =>
      'LoanTransaction(id: $id, studentId: $studentId, amount: $amount, type: $type)';
}
