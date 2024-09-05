import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> tasks = [];
  List<String> taskHistory = [];

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _list => _firestore
      .collection('users')
      .doc(_userId)
      .collection('lists');

  Future<void> fetchTaskName(String listName) async {
    QuerySnapshot listSnapshot = await _list.where('listName', isEqualTo: listName).get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection = listDoc.reference.collection(
          'tasks');
      QuerySnapshot taskSnapshot = await tasksCollection.orderBy(
          'timestamp', descending: true).get();
      tasks = taskSnapshot.docs.map((doc) => doc['taskName'] as String).toList();
      // taskIDs = snapshot.docs.map((doc) => doc.id).toList();
    }
  }

  Future<void> addTask(
      String taskName,
      String taskDescription,
      String priority,
      String startDate,
      String endDate,
      String startTime,
      String endTime,
      bool isReminderOn,
      String listName) async {
    QuerySnapshot listSnapshot = await _list.where('listName', isEqualTo: listName).get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection = listDoc.reference.collection(
          'tasks');
      await tasksCollection.add({
        'taskName': taskName,
        'taskDescription': taskDescription,
        'priority': priority,
        'startDate': startDate,
        'endDate': endDate,
        'startTime': startTime,
        'endTime': endTime,
        'isReminderOn': isReminderOn,
        'listName': listName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      tasks.insert(0, taskName);
    }
  }

  Future<void> addTaskHistory(
      String taskName,
      String taskDescription,
      String priority,
      String startDate,
      String endDate,
      String startTime,
      String endTime,
      bool isReminderOn,
      String listName) async {
    QuerySnapshot listSnapshot = await _list.where('listName', isEqualTo: listName).get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection = listDoc.reference.collection(
          'taskHistory');
      await tasksCollection.add({
        'taskName': taskName,
        'taskDescription': taskDescription,
        'priority': priority,
        'startDate': startDate,
        'endDate': endDate,
        'startTime': startTime,
        'endTime': endTime,
        'isReminderOn': isReminderOn,
        'listName': listName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      taskHistory.insert(0, taskName);
    }
  }

  Future<void> updateTaskName(String oldTaskName, String newTaskName) async {
    QuerySnapshot listSnapshot = await _list.get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection =
      listDoc.reference.collection('tasks');
      QuerySnapshot taskSnapshot = await tasksCollection
          .where('taskName', isEqualTo: oldTaskName)
          .get();
      for (var doc in taskSnapshot.docs) {
        await doc.reference.update({'taskName': newTaskName});
      }
      // await _task.doc(taskID).update({'taskName': newTaskName});
      await fetchTaskName(listName);
    }
  }

    Future<void> updateTaskDetails(String taskName,
        Map<String, dynamic> updatedFields) async {
      QuerySnapshot listSnapshot = await _list.get();
      for (var listDoc in listSnapshot.docs) {
        CollectionReference tasksCollection = listDoc.reference.collection(
            'tasks');
        QuerySnapshot taskSnapshot = await tasksCollection
            .where('taskName', isEqualTo: taskName)
            .get();
        for (var taskDoc in taskSnapshot.docs) {
          await tasksCollection.doc(taskDoc.id).update(updatedFields);
        }
      }
      await fetchTaskDetails(taskName);
    }

    Future<void> deleteTask(String taskName) async {
      QuerySnapshot listSnapshot = await _list.get();
      for (var listDoc in listSnapshot.docs) {
        CollectionReference tasksCollection = listDoc.reference.collection(
            'tasks');
        QuerySnapshot taskSnapshot = await tasksCollection
            .where('taskName', isEqualTo: taskName)
            .get();
        for (var taskDoc in taskSnapshot.docs) {
          await tasksCollection.doc(taskDoc.id).delete();
        }
      }
      await fetchTaskName(listName);
    }

  Future<void> deleteTaskHistory(String taskName) async {
    QuerySnapshot listSnapshot = await _list.get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection = listDoc.reference.collection(
          'taskHistory');
      QuerySnapshot taskSnapshot = await tasksCollection
          .where('taskName', isEqualTo: taskName)
          .get();
      for (var taskDoc in taskSnapshot.docs) {
        await tasksCollection.doc(taskDoc.id).delete();
      }
    }
    await fetchTaskHistory(listName);
  }

    String taskName = '';
    String taskDescription = '';
    String priority = '';
    String startDate = '';
    String endDate = '';
    String startTime = '';
    String endTime = '';
    bool isReminderOn = false;
    String listName = '';

    Future<void> fetchTaskDetails(String fetchTaskName) async {
      QuerySnapshot listSnapshot = await _list.get();
      for (var listDoc in listSnapshot.docs) {
        CollectionReference tasksCollection = listDoc.reference.collection(
            'tasks');
        QuerySnapshot tasksSnapshot = await tasksCollection
            .where('taskName', isEqualTo: fetchTaskName)
            .get();

        for (QueryDocumentSnapshot taskDoc in tasksSnapshot.docs) {
          DocumentSnapshot snapshot = await tasksCollection.doc(taskDoc.id)
              .get();
          taskName = snapshot['taskName'] as String;
          taskDescription = snapshot['taskDescription'] as String;
          priority = snapshot['priority'] as String;
          startDate = snapshot['startDate'] as String;
          endDate = snapshot['endDate'] as String;
          startTime = snapshot['startTime'] as String;
          endTime = snapshot['endTime'] as String;
          isReminderOn = snapshot['isReminderOn'] as bool;
          listName = snapshot['listName'] as String;


        }
      }
    }

  Future<void> fetchHistoryDetails(String fetchTaskName) async {
    QuerySnapshot listSnapshot = await _list.get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection = listDoc.reference.collection(
          'taskHistory');
      QuerySnapshot tasksSnapshot = await tasksCollection
          .where('taskName', isEqualTo: fetchTaskName)
          .get();

      for (QueryDocumentSnapshot taskDoc in tasksSnapshot.docs) {
        DocumentSnapshot snapshot = await tasksCollection.doc(taskDoc.id)
            .get();
        taskName = snapshot['taskName'] as String;
        taskDescription = snapshot['taskDescription'] as String;
        priority = snapshot['priority'] as String;
        startDate = snapshot['startDate'] as String;
        endDate = snapshot['endDate'] as String;
        startTime = snapshot['startTime'] as String;
        endTime = snapshot['endTime'] as String;
        isReminderOn = snapshot['isReminderOn'] as bool;
        listName = snapshot['listName'] as String;
      }
    }
  }

  Future<void> fetchTaskHistory(String listName) async {
    QuerySnapshot listSnapshot = await _list.where('listName', isEqualTo: listName).get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection = listDoc.reference.collection(
          'taskHistory');
      QuerySnapshot taskSnapshot = await tasksCollection.orderBy(
          'timestamp', descending: true).get();
      taskHistory = taskSnapshot.docs.map((doc) => doc['taskName'] as String).toList();
    }
  }


}
