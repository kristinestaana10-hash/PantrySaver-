class ShoppingItem {
  final String id;
  final String userId;
  final String itemName;
  final int quantity;
  final bool purchased;
  final DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.quantity,
    required this.purchased,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'itemName': itemName,
        'quantity': quantity,
        'purchased': purchased,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        itemName: map['itemName'] ?? '',
        quantity: (map['quantity'] ?? 0).toInt(),
        purchased: map['purchased'] ?? false,
        createdAt: DateTime.parse(map['createdAt']),
      );
}
