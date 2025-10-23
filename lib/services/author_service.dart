import 'package:audio_app_example/models/author_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorService {
  final CollectionReference authorsRef =
      FirebaseFirestore.instance.collection('authors');

  Future<void> addAuthor(Author author) async {
    await authorsRef.doc(author.id).set(author.toFirestore());
  }

  Future<Author?> getAuthor(String id) async {
    final doc = await authorsRef.doc(id).get();
    if (doc.exists) return Author.fromFirestore(doc);
    return null;
  }

  Future<List<Author>> getAllAuthors() async {
    final querySnapshot = await authorsRef.get();
    return querySnapshot.docs.map((doc) => Author.fromFirestore(doc)).toList();
  }

  Future<void> updateAuthor(Author author) async {
    await authorsRef.doc(author.id).update(author.toFirestore());
  }

  Future<void> deleteAuthor(String id) async {
    await authorsRef.doc(id).delete();
  }
}
