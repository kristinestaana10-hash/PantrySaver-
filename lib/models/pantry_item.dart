enum PantryStatus { fresh, expiringSoon, expired }

class PantryItem {
  final String id;
  final String userId;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime purchaseDate;
  final DateTime expirationDate;
  final String storageLocation;
  final String barcode;
  final String imageUrl;
  final DateTime createdAt;

  PantryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expirationDate,
    required this.storageLocation,
    this.barcode = '',
    required this.imageUrl,
    required this.createdAt,
  });

  PantryStatus get status {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;
    if (difference < 0) return PantryStatus.expired;
    if (difference <= 7) return PantryStatus.expiringSoon;
    return PantryStatus.fresh;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'purchaseDate': purchaseDate.toIso8601String(),
        'expirationDate': expirationDate.toIso8601String(),
        'storageLocation': storageLocation,
        'barcode': barcode,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PantryItem.fromMap(Map<String, dynamic> map) => PantryItem(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        category: map['category'] ?? 'Other',
        quantity: (map['quantity'] ?? 0).toInt(),
        unit: map['unit'] ?? 'pcs',
        purchaseDate: DateTime.parse(map['purchaseDate']),
        expirationDate: DateTime.parse(map['expirationDate']),
        storageLocation: map['storageLocation'] ?? 'Pantry',
        barcode: map['barcode'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        createdAt: DateTime.parse(map['createdAt']),
      );
}
