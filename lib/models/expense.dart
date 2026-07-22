class Expense {
  final String id;
  final String userId;
  final String groceryStore;
  final double amount;
  final String notes;
  final DateTime dateCreated;

  Expense({
    required this.id,
    required this.userId,
    required this.groceryStore,
    required this.amount,
    required this.notes,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'groceryStore': groceryStore,
        'amount': amount,
        'notes': notes,
        'dateCreated': dateCreated.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        groceryStore: map['groceryStore'] ?? 'Unknown',
        amount: (map['amount'] ?? 0).toDouble(),
        notes: map['notes'] ?? '',
        dateCreated: DateTime.parse(map['dateCreated']),
      );
}
