import 'package:audio_app_example/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final _books = FirebaseFirestore.instance.collection(('books'));
  final _users = FirebaseFirestore.instance.collection('users');

  Stream<List<Book>> getBooksStream() {
    return _books.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Future<Book?> getBookById(String id) async {
    final doc = await _books.doc(id).get();
    if (!doc.exists) return null;
    return Book.fromFirestore(doc);
  }

  Future<List<Book>> getPurchasedBooks(String userId) async {
    final purchases = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('booksPurchased')
        .get();

    if (purchases.docs.isEmpty) {
      return [];
    }

    final bookIds = purchases.docs.map((doc) => doc['bookId'] as String);
    final booksQuery = await _books
        .where(FieldPath.documentId, whereIn: bookIds.toList())
        .get();

    return booksQuery.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }

  Stream<List<Book>> getPurchasedBooksStream(String userId) {
    final userBooksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('booksPurchased');

    return userBooksRef.snapshots().asyncMap((purchaseSnapshot) async {
      if (purchaseSnapshot.docs.isEmpty) return [];

      final bookIds =
          purchaseSnapshot.docs.map((doc) => doc['bookId'] as String).toList();

      // Firestore 'whereIn' only supports up to 10 IDs at once; consider batching for >10
      if (bookIds.isEmpty) return [];

      final booksQuery = await FirebaseFirestore.instance
          .collection('books')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      return booksQuery.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Future<bool> isBookPurchased(String userId, String bookId) async {
    final doc =
        await _users.doc(userId).collection('booksPurchased').doc(bookId).get();
    return doc.exists;
  }
}
