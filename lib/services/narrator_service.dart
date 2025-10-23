import 'package:audio_app_example/models/narrator_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NarratorService {
  final CollectionReference narratorsRef =
      FirebaseFirestore.instance.collection('narrators');

  Future<void> addNarrator(Narrator narrator) async {
    await narratorsRef.doc(narrator.id).set(narrator.toFirestore());
  }

  Future<Narrator?> getNarrator(String id) async {
    final doc = await narratorsRef.doc(id).get();
    if (doc.exists) return Narrator.fromFirestore(doc);
    return null;
  }

  Future<List<Narrator>> getAllNarrators() async {
    final querySnapshot = await narratorsRef.get();
    return querySnapshot.docs.map((doc) => Narrator.fromFirestore(doc)).toList();
  }

  Future<void> updateNarrator(Narrator narrator) async {
    await narratorsRef.doc(narrator.id).update(narrator.toFirestore());
  }

  Future<void> deleteNarrator(String id) async {
    await narratorsRef.doc(id).delete();
  }

  
}
