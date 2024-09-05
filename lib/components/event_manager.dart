import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> events = [];

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _event =>
      _firestore.collection('users').doc(_userId).collection('events');

  Future<void> addEvent(
     String eventName,
     String eventDescription,
     String startDate,
     String endDate,
     String startTime,
     String endTime,
     bool isReminderOn,
  ) async {
    await _event.add({
      'eventName': eventName,
      'eventDescription': eventDescription,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'isReminderOn': isReminderOn,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String eventName = '';
  String eventDescription = '';
  String startDate = '';
  String endDate = '';
  String startTime = '';
  String endTime = '';
  bool isReminderOn = false;

  Future<void> fetchEventDetails(String fetchEventName) async {
    QuerySnapshot eventSnapshot = await _event
        .where('eventName', isEqualTo: fetchEventName)
        .get();

    for (QueryDocumentSnapshot eventDoc in eventSnapshot.docs) {
        DocumentSnapshot snapshot = await _event.doc(eventDoc.id)
            .get();
        eventName = snapshot['eventName'] as String;
        eventDescription = snapshot['eventDescription'] as String;
        startDate = snapshot['startDate'] as String;
        endDate = snapshot['endDate'] as String;
        startTime = snapshot['startTime'] as String;
        endTime = snapshot['endTime'] as String;
        isReminderOn = snapshot['isReminderOn'] as bool;
      }
    }

  Future<void> updateEventDetails(String eventName,
      Map<String, dynamic> updatedFields) async {
    QuerySnapshot eventSnapshot = await _event
        .where('eventName', isEqualTo: eventName)
        .get();
    for (var eventDoc in eventSnapshot.docs) {
      await _event.doc(eventDoc.id).update(updatedFields);
    }
    await fetchEventDetails(eventName);
  }

  Future<void> deleteEvent(String eventName) async {
    QuerySnapshot eventSnapshot = await _event
        .where('eventName', isEqualTo: eventName)
        .get();
    for (var eventDoc in eventSnapshot.docs) {
      await _event.doc(eventDoc.id).delete();
    }
    await fetchEventDetails(eventName);
  }
}
