import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/models/chapter_model.dart';
import 'package:audio_app_example/services/user_progress_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final currentUser = FirebaseAuth.instance.currentUser;
final _userProgressService = UserProgressService();

final bookProgressProvider =
    StreamProvider.family<BookProgress?, String>((ref, bookId) {
  final userId = currentUser?.uid ?? '';
  final refCol = FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("booksProgress")
      .where("bookId", isEqualTo: bookId)
      .limit(1);

  return refCol.snapshots().map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();

    return BookProgress.fromFirestore(data);
  });
});

final userBooksHistoryStreamProvider =
    StreamProvider.family<List<BookHistory>, String>((ref, userId) {
  final refBooks = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('booksHistory')
      .orderBy("startedAt", descending: true);

  return refBooks.snapshots().asyncMap((snapshot) async {
    final futures = snapshot.docs.map((historyDoc) async {
      final bookId = historyDoc['bookId'] as String;
      final finishedAtRaw = historyDoc.data()['finishedAt'];
      final finishedAt =
          finishedAtRaw is Timestamp ? finishedAtRaw.toDate() : null;
      final bookDoc = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();

      return BookHistory(
        book: Book.fromFirestore(bookDoc),
        finishedAt: finishedAt,
        commentsCount: historyDoc.data()['commentsCount'] ?? 0,
      );
    });

    return Future.wait(futures);
  });
});

final chapterProgressProvider = StreamProvider.family
    .autoDispose<Map<String, dynamic>?, String>((ref, chapterId) {
  final userId = currentUser?.uid ?? '';
  final refCol = FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("chaptersProgress")
      .where("chapterId", isEqualTo: chapterId)
      .limit(1);

  return refCol.snapshots().map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  });
});

final userBookChaptersHistoryStreamProvider =
    StreamProvider.family<List<Chapter>, Map<String, String>>((ref, params) {
  final userId = params['userId']!;
  final bookId = params['bookId']!;

  final refChapters = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chaptersHistory')
      .where('bookId', isEqualTo: bookId);

  return refChapters.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Chapter.fromFirestore(doc)).toList();
  });
});

// note: i am getting chapters history snapshot not Chapter
final userChaptersHistoryStreamProvider =
    StreamProvider.family<List<Chapter>, String>((ref, userId) {
  final refChapters = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chaptersHistory')
      .orderBy('startedAt', descending: true);

  return refChapters.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Chapter.fromFirestore(doc)).toList();
  });
});
