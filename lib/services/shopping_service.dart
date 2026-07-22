import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantrysaver/models/shopping_item.dart';

class ShoppingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ShoppingItem>> streamItems(String userId) {
    return _firestore
        .collection('shopping_list')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) => ShoppingItem.fromMap(doc.data())).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<void> addItem(ShoppingItem item) async {
    await _firestore.collection('shopping_list').doc(item.id).set(item.toMap());
  }

  Future<void> updateItem(ShoppingItem item) async {
    await _firestore.collection('shopping_list').doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('shopping_list').doc(itemId).delete();
  }
}
