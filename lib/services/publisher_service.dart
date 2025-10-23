import 'package:audio_app_example/models/publisher_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublisherService {
  final CollectionReference publishersRef =
      FirebaseFirestore.instance.collection('publishers');

  Future<void> addPublisher(Publisher publisher) async {
    await publishersRef.doc(publisher.id).set(publisher.toFirestore());
  }

  Future<Publisher?> getPublisher(String id) async {
    final doc = await publishersRef.doc(id).get();
    if (doc.exists) return Publisher.fromFirestore(doc);
    return null;
  }

  Future<List<Publisher>> getAllPublishers() async {
    final querySnapshot = await publishersRef.get();
    return querySnapshot.docs
        .map((doc) => Publisher.fromFirestore(doc))
        .toList();
  }

  Future<void> updatePublisher(Publisher publisher) async {
    await publishersRef.doc(publisher.id).update(publisher.toFirestore());
  }

  Future<void> deletePublisher(String id) async {
    await publishersRef.doc(id).delete();
  }
}
