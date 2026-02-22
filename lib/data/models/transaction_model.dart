import '../../domain/entities/transaction.dart';

/// Data model for the Transactions table.
class TransactionModel {
  final int id;
  final int studentId;
  final int bankId;
  final double amount;
  final String type;
  final String date;

  const TransactionModel({
    required this.id,
    required this.studentId,
    required this.bankId,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int,
      studentId: map['studentId'] as int,
      bankId: map['bankId'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'bankId': bankId,
      'amount': amount,
      'type': type,
      'date': date,
    };
  }

  LoanTransaction toDomain() {
    return LoanTransaction(
      id: id,
      studentId: studentId,
      bankId: bankId,
      amount: amount,
      type: _parseType(type),
      date: DateTime.parse(date).toLocal(),
    );
  }

  static TransactionType _parseType(String type) {
    switch (type) {
      case 'loanDisbursement':
        return TransactionType.loanDisbursement;
      case 'allowancePayment':
        return TransactionType.allowancePayment;
      case 'loanRepayment':
        return TransactionType.loanRepayment;
      default:
        return TransactionType.allowancePayment;
    }
  }

  static String fromDomainType(TransactionType type) {
    switch (type) {
      case TransactionType.loanDisbursement:
        return 'loanDisbursement';
      case TransactionType.allowancePayment:
        return 'allowancePayment';
      case TransactionType.loanRepayment:
        return 'loanRepayment';
    }
  }
}
