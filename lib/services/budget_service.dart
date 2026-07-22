import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantrysaver/models/expense.dart';

class BudgetService {
  BudgetService({required this.firebaseEnabled});

  final bool firebaseEnabled;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Expense>> fetchExpenses(String userId) async {
    if (!firebaseEnabled) return [];
    final snapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('dateCreated', descending: true)
        .get();
    return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
  }

  Stream<List<Expense>> streamExpenses(String userId) {
    if (!firebaseEnabled) return Stream.value([]);
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final expenses = snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
      expenses.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      return expenses;
    });
  }

  Future<void> addExpense(Expense expense) async {
    if (!firebaseEnabled) return;
    await _firestore.collection('expenses').doc(expense.id).set(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    if (!firebaseEnabled) return;
    await _firestore.collection('expenses').doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    if (!firebaseEnabled) return;
    await _firestore.collection('expenses').doc(expenseId).delete();
  }
}
