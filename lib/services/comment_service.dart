import 'package:audio_app_example/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Comment>> getCommentsByBookIdAndUserId(
      String bookId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('commentsHistory')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    } catch (err) {
      print('Error fetching Comments for book $bookId: $err');
      return [];
    }
  }

  Future<Comment?> getCommentById(String commentId, String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('commentsHistory')
          .doc(commentId)
          .get();

      if (!doc.exists) return null;

      return Comment.fromFirestore(doc);
    } catch (e) {
      print('Error fetching Comment $commentId for user $userId: $e');
      return null;
    }
  }

  Future<void> createComment({
    required String userId,
    required String bookId,
    required String chapterId,
    required int chapterTimestampSeconds,
    required String commentText,
    DateTime? createdAt,
  }) async {
    try {
      final bookRef =
          _firestore.collection('users').doc(userId).collection('booksHistory');

      final getBookDoc = await bookRef.doc(bookId).get();

      final data = getBookDoc.data();
      final commentsCount = (data?['commentsCount'] ?? 0) as int;
      final ref = _firestore
          .collection("users")
          .doc(userId)
          .collection("commentsHistory");

      final commentRef = ref.doc();

      final comment = Comment(
        id: commentRef.id,
        userId: userId,
        bookId: bookId,
        chapterId: chapterId,
        chapterTimestampSeconds: chapterTimestampSeconds,
        commentText: commentText,
        createdAt: createdAt ?? DateTime.now(),
      );

      final querySnapshot =
          await bookRef.where('bookId', isEqualTo: bookId).get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'commentsCount': FieldValue.increment(1),
        });
      }
      await commentRef.set(comment.toFirestore());
    } catch (e) {
      print('Error creating Comment: $e');
    }
  }
}
