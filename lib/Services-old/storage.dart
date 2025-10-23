//file relative to the storage part of firebase
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final storage = FirebaseStorage.instance;
  final CollectionReference<Map<String, dynamic>> audioCollection =
      FirebaseFirestore.instance.collection("Audios");

  Future<void> uploadFile(String path, String author, String title,
      String description, String list) async {
    //uses the file from the import
    File file = File(path);
    int likes = 0;
    int report = 0;
    //store the file
    await storage.ref('audios/$title').putFile(file);
    audioCollection.doc(title).set({
      'Name': title,
      'Author': author,
      'Description': description,
      'Likes': likes,
      'Reports': report,
      'Playlists': list,
      'Date': Timestamp.now()
    });
  }

//saves an audio twin in the firestore
  Future<void> uploadPicture(String path, String title) async {
    File file = File(path);
    await storage.ref('images/$title').putFile(file);
  }
}
