import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> lists = [];
  List<String> listIDs = [];

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _list =>
      _firestore.collection('users').doc(_userId).collection('lists');

  Future<void> fetchLists() async {
    QuerySnapshot snapshot = await _list.orderBy('timestamp', descending: true).get();
    lists = snapshot.docs.map((doc) => doc['listName'] as String).toList();
    listIDs = snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> addList(String listName) async {
    await _list.add({
      'listName': listName,
      'timestamp': FieldValue.serverTimestamp(),
    });
    lists.insert(0, listName);
  }

  Future<void> updateList(String oldListName, String newListName) async {
    QuerySnapshot snapshot = await _list
        .where('listName', isEqualTo: oldListName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'listName': newListName});
    }
    await fetchLists();
  }

  Future<void> deleteList(String listName) async {
    QuerySnapshot listSnapshot = await _list
        .where('listName', isEqualTo: listName)
        .get();
    for (QueryDocumentSnapshot listDoc in listSnapshot.docs) {
      await _deleteDocumentAndSubcollections(_list.doc(listDoc.id));
    }
    await fetchLists();
  }

  Future<void> _deleteDocumentAndSubcollections(DocumentReference docRef) async {
    var taskcollections = await docRef.collection('tasks').get();
    var historycollections = await docRef.collection('taskHistory').get();
    for (var subDoc in taskcollections.docs) {
      await _deleteDocumentAndSubcollections(docRef.collection('tasks').doc(subDoc.id));
    }
    for (var subDoc in historycollections.docs) {
      await _deleteDocumentAndSubcollections(docRef.collection('taskHistory').doc(subDoc.id));
    }
    await docRef.delete();
  }
}
