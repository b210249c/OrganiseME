import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> transactions = [];

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _transactions =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  Future<void> addTransaction(
    String group,
    String category,
    String name,
    String amount,
    String date,
    String to,
    String description,
  ) async {
    await _transactions.add({
      'group': group,
      'category': category,
      'name': name,
      'amount': amount,
      'date': date,
      'to': to,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String group = '';
  String category = '';
  String name = '';
  String amount = '';
  String date = '';
  String to = '';
  String description = '';

  Future<void> fetchTransactionDetails(String fetchName) async {
    QuerySnapshot transactionSnapshot =
        await _transactions.where('name', isEqualTo: fetchName).get();

    for (QueryDocumentSnapshot transactionDoc in transactionSnapshot.docs) {
      DocumentSnapshot snapshot = await _transactions.doc(transactionDoc.id).get();
      group = snapshot['group'] as String;
      category = snapshot['category'] as String;
      name = snapshot['name'] as String;
      amount = snapshot['amount'] as String;
      date = snapshot['date'] as String;
      to = snapshot['to'] as String;
      description = snapshot['description'] as String;
    }
  }

  Future<void> updateTransactionDetails(
      String name, Map<String, dynamic> updatedFields) async {
    QuerySnapshot transactionSnapshot =
        await _transactions.where('name', isEqualTo: name).get();
    for (var transactionDoc in transactionSnapshot.docs) {
      await _transactions.doc(transactionDoc.id).update(updatedFields);
    }
    await fetchTransactionDetails(name);
  }

  Future<void> deleteTransaction(String name) async {
    QuerySnapshot transactionSnapshot =
        await _transactions.where('name', isEqualTo: name).get();
    for (var transactionDoc in transactionSnapshot.docs) {
      await _transactions.doc(transactionDoc.id).delete();
    }
    await fetchTransactionDetails(name);
  }
}
