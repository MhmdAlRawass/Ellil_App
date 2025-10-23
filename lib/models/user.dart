// class for the users from the firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;

  AppUser(this.uid);
}

// Extended class attributes to support purchased audios
class AppUserData {
  final String name;
  final String uid;
  final String email;

  AppUserData({
    required this.name,
    required this.uid,
    required this.email,
  });

  // Deserialize from Firestore/JSON
  factory AppUserData.fromMap(Map<String, dynamic> map) {
    return AppUserData(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
    );
  }

  // Serialize to Firestore/JSON
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'email': email,
    };
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
    );
  }
}
