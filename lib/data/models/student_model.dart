import '../../domain/entities/student.dart';

/// Data model for the Students table.
class StudentModel {
  final int id;
  final String name;
  final int bankId;
  final double loanAmount;
  final double monthlyAllowance;

  const StudentModel({
    required this.id,
    required this.name,
    required this.bankId,
    required this.loanAmount,
    required this.monthlyAllowance,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as int,
      name: map['name'] as String,
      bankId: map['bankId'] as int,
      loanAmount: (map['loanAmount'] as num).toDouble(),
      monthlyAllowance: (map['monthlyAllowance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bankId': bankId,
      'loanAmount': loanAmount,
      'monthlyAllowance': monthlyAllowance,
    };
  }

  Student toDomain() {
    return Student(
      id: id,
      name: name,
      bankId: bankId,
      loanAmount: loanAmount,
      monthlyAllowance: monthlyAllowance,
    );
  }
}
