import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pantrysaver/models/pantry_item.dart';

class PantryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('pantry_items');

  Stream<List<PantryItem>> streamItems(String userId) {
    return _collection.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) => PantryItem.fromMap(doc.data())).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<void> addItem(PantryItem item) async {
    await _collection.doc(item.id).set(item.toMap());
  }

  Future<void> updateItem(PantryItem item) async {
    await _collection.doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _collection.doc(itemId).delete();
  }

  Future<String> uploadImage(String path, String itemId) async {
    final ref = _storage.ref().child('pantry_images/$itemId.jpg');
    final uploadTask = await ref.putFile(File(path));
    return uploadTask.ref.getDownloadURL();
  }
}
