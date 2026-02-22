/// Domain entity representing a student enrolled in the loan programme.
class Student {
  final int id;
  final String name;
  final int bankId; // Bank assigned — immutable after assignment (Chinese Wall)
  final double loanAmount;
  final double monthlyAllowance;

  const Student({
    required this.id,
    required this.name,
    required this.bankId,
    required this.loanAmount,
    required this.monthlyAllowance,
  });

  Student copyWith({
    int? id,
    String? name,
    int? bankId,
    double? loanAmount,
    double? monthlyAllowance,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      bankId: bankId ?? this.bankId,
      loanAmount: loanAmount ?? this.loanAmount,
      monthlyAllowance: monthlyAllowance ?? this.monthlyAllowance,
    );
  }

  @override
  String toString() =>
      'Student(id: $id, name: $name, bankId: $bankId, loan: $loanAmount)';
}
