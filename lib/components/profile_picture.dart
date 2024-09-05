import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePicture {
  File? image;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? profilePictureUrl;
  VoidCallback? onUpdate;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _profilePicture =>
      _firestore.collection('users').doc(_userId).collection('profilePicture');

  void setUpdateCallback(VoidCallback callback) {
    onUpdate = callback;
  }

  Future getPictureFromGallery(BuildContext context, bool isLoading) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      await uploadImage(context);
      await loadProfilePicture(isLoading);
    }
  }

  Future getPictureFromCamera(BuildContext context, bool isLoading) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      await uploadImage(context);
      await loadProfilePicture(isLoading);
    }
  }

  Future showOptions(BuildContext context, bool isLoading) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              getPictureFromGallery(context, isLoading);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();
              getPictureFromCamera(context, isLoading);
            },
          ),
        ],
      ),
    );
  }

  Future<void> uploadImage(BuildContext context) async {
    if (image == null) return;

    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('profilePictures').child(_userId).child(fileName);

      UploadTask uploadTask = storageRef.putFile(image!);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      QuerySnapshot snapshot = await _profilePicture.get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot picture = snapshot.docs.first;
        await _profilePicture.doc(picture.id).update({'profilePictureUrl': downloadUrl});

        profilePictureUrl = downloadUrl;
        onUpdate?.call();
      } else {
        await _profilePicture.add({'profilePictureUrl': downloadUrl, 'uploadedAt': FieldValue.serverTimestamp()});

        profilePictureUrl = downloadUrl;
        onUpdate?.call();
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    }
  }

  Future<void> loadProfilePicture(bool isLoading) async {
    isLoading = true;

    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot picture = await _profilePicture.get();

      if (picture.docs.isNotEmpty) {
        DocumentSnapshot userDoc = picture.docs.first;
        profilePictureUrl = userDoc['profilePictureUrl'];
        onUpdate?.call();
      }
    }

    isLoading = false;
  }
}