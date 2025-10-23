import 'package:audio_app_example/models/chapter_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Chapter>> getChaptersByBookId(String bookId) async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .doc(bookId)
          .collection('chapters')
          .orderBy('orderIndex', descending: false)
          .get();

      return snapshot.docs.map((doc) => Chapter.fromFirestore(doc)).toList();
    } catch (err) {
      print('Error fetching chapters for book $bookId: $err');
      return [];
    }
  }

  Future<Chapter?> getChapterById(String bookId, String chapterId) async {
    try {
      final doc = await _firestore
          .collection('books')
          .doc(bookId)
          .collection('chapters')
          .doc(chapterId)
          .get();

      if (!doc.exists) return null;

      return Chapter.fromFirestore(doc);
    } catch (e) {
      print('Error fetching chapter $chapterId for book $bookId: $e');
      return null;
    }
  }
}
