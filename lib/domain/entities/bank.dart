/// Domain entity representing a bank in the system.
class Bank {
  final int id;
  final String name;

  const Bank({required this.id, required this.name});

  @override
  String toString() => 'Bank(id: $id, name: $name)';
}
