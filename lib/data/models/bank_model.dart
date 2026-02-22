import '../../domain/entities/bank.dart';

/// Data model for the Banks table.
class BankModel {
  final int id;
  final String name;

  const BankModel({required this.id, required this.name});

  factory BankModel.fromMap(Map<String, dynamic> map) {
    return BankModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  Bank toDomain() => Bank(id: id, name: name);
}
