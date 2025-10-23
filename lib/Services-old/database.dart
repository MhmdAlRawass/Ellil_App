import 'package:audio_app_example/main.dart';
import 'package:audio_app_example/models/audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  // Firebase instances
  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference<Map<String, dynamic>> audioCollection =
      FirebaseFirestore.instance.collection("audios");

  // Save user in Firestore
  Future<void> saveUser(
      String name, String email, DateTime? dateOfBirth) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth)
          : FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Save FCM token
  Future<void> saveToken(String? token) async {
    return await userCollection.doc(uid).update({'token': token});
  }

  // Retrieve user's information from Firestore
  AppUserData _userFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    if (data == null) throw Exception("user not found");
    return AppUserData(
      name: data['name'],
      uid: snapshot.id,
      email: data['email'] ?? '',
    );
  }

  Stream<AppUserData> get user {
    return userCollection.doc(uid).snapshots().map(_userFromSnapshot);
  }

  List<AppUserData> _userListFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return _userFromSnapshot(doc);
    }).toList();
  }

  Stream<List<AppUserData>> get users {
    return userCollection.snapshots().map(_userListFromSnapshot);
  }

  // --- AUDIO SECTION WITH PAYWALL SUPPORT ---

  // Retrieve audio from Firestore
  AppAudioData _audioFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    if (data == null) throw Exception("audio not found");
    return AppAudioData(
      name: data['Name'],
      uid: snapshot.id,
      author: data['Author'],
      description: data['Description'],
      price: data['price'] != null ? (data['price'] as num).toDouble() : 0.0,
      purchased:
          data['purchased'] ?? false, // Will be handled in UI by user info!
    );
  }

  Stream<AppAudioData> get audio {
    return audioCollection.doc(uid).snapshots().map(_audioFromSnapshot);
  }

  List<AppAudioData> _audioListFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return _audioFromSnapshot(doc);
    }).toList();
  }

  Stream<List<AppAudioData>> get audios {
    return audioCollection
        .orderBy('Date', descending: true)
        .snapshots()
        .map(_audioListFromSnapshot);
  }

  // --- SEARCH AND ICON AUDIO (Paywall attributes included) ---

  AppAudioData _audioSearch(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    if (data == null) throw Exception("audio not found");
    if (data['Name'].contains(research)) {
      return AppAudioData(
        name: data['Name'],
        uid: snapshot.id,
        author: data['Author'],
        description: data['Description'],
        price: data['price'] != null ? (data['price'] as num).toDouble() : 0.0,
        purchased: data['purchased'] ?? false,
      );
    }
    return AppAudioData(
        name: '|||', uid: snapshot.id, author: '|||', description: '|||');
  }

  Stream<AppAudioData> get searchAudio {
    return audioCollection.doc(uid).snapshots().map(_audioSearch);
  }

  List<AppAudioData> _audioListSearch(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return _audioSearch(doc);
    }).toList();
  }

  Stream<List<AppAudioData>> get searchAudios {
    return audioCollection.snapshots().map(_audioListSearch);
  }

  AppAudioData _audioIcon(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    if (data == null) throw Exception("audio not found");
    if (data['Playlists'].contains(research)) {
      return AppAudioData(
        name: data['Name'],
        uid: snapshot.id,
        author: data['Author'],
        description: data['Description'],
        price: data['price'] != null ? (data['price'] as num).toDouble() : 0.0,
        purchased: data['purchased'] ?? false,
      );
    }
    return AppAudioData(
        name: '|||', uid: snapshot.id, author: '|||', description: '|||');
  }

  Stream<AppAudioData> get iconAudio {
    return audioCollection.doc(uid).snapshots().map(_audioIcon);
  }

  List<AppAudioData> _audioListIcon(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      return _audioIcon(doc);
    }).toList();
  }

  Stream<List<AppAudioData>> get iconAudios {
    return audioCollection.snapshots().map(_audioListIcon);
  }

  // ---- PAYWALL / PURCHASE METHODS ----

  /// Purchase an audio: add its ID to user's purchasedAudioIds list in Firestore
  Future<void> purchaseAudio(String audioId) async {
    await userCollection.doc(uid).update({
      'purchasedAudioIds': FieldValue.arrayUnion([audioId])
    });
  }

  /// Check if a user has purchased a given audio (from Firestore)
  Future<bool> hasPurchasedAudio(String audioId) async {
    var snap = await userCollection.doc(uid).get();
    var data = snap.data();
    if (data == null) return false;
    List<dynamic>? purchases = data['purchasedAudioIds'];
    return purchases != null && purchases.contains(audioId);
  }
}
