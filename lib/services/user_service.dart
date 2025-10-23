import 'package:audio_app_example/models/user_model.dart';
import 'package:audio_app_example/models/user_subscription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  Future<UserSubscription?> getUserSubscription(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .where('status', isEqualTo: 'active')
        .orderBy('endsAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return UserSubscription.fromFirestore(snapshot.docs.first.data());
  }

  Stream<User> getUserStreamById(userId) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    return userDoc.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception("User not found");
      }
      return User.fromFirestore(snapshot);
    });
  }

  Stream<UserSubscription?> getUserSubscriptionStream(String userId) {
    final now = DateTime.now();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .where('endsAt', isGreaterThan: now)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return UserSubscription.fromFirestore(doc.data());
    });
  }
}
