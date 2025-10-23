import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/models/chapter_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressService {
  final _db = FirebaseFirestore.instance;

  // call when starting a new book
  Future<void> initBookProgress(String userId, String bookId) async {
    final ref = _db.collection('users').doc(userId).collection('booksProgress');
    final historyRef =
        _db.collection('users').doc(userId).collection('booksHistory');
    final query = await ref.where("bookId", isEqualTo: bookId).limit(1).get();
    final historyQuery =
        await historyRef.where("bookId", isEqualTo: bookId).limit(1).get();

    if (query.docs.isEmpty) {
      final docRef = ref.doc();

      await docRef.set({
        "id": docRef.id,
        "bookId": bookId,
        "progressPercent": 0,
        "lastPositionSeconds": 0,
        "estimatedTimeRemainingSeconds": null,
        "updatedAt": FieldValue.serverTimestamp(),
        "commentsCount": 0,
      });
    }

    if (historyQuery.docs.isEmpty) {
      final historyDocRef = historyRef.doc();
      await historyDocRef.set({
        "id": historyDocRef.id,
        "bookId": bookId,
        "startedAt": FieldValue.serverTimestamp(),
        "finishedAt": null,
      });
    }
  }

  // call when starting a new chapter
  Future<void> startChapter(
    String userId,
    String chapterId,
    String bookId,
  ) async {
    final progressRef =
        _db.collection("users").doc(userId).collection("chaptersProgress");
    final historyRef =
        _db.collection("users").doc(userId).collection("chaptersHistory");

    // progress
    final cpQuery = await progressRef
        .where("chapterId", isEqualTo: chapterId)
        .limit(1)
        .get();
    if (cpQuery.docs.isEmpty) {
      final docRef = progressRef.doc();
      await docRef.set({
        "id": docRef.id,
        "chapterId": chapterId,
        "bookId": bookId,
        "progressPercent": 0,
        "lastPositionSeconds": 0,
        "estimatedTimeRemainingSeconds": null,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    // history
    final chQuery = await historyRef
        .where("chapterId", isEqualTo: chapterId)
        .limit(1)
        .get();
    if (chQuery.docs.isEmpty) {
      final docRef = historyRef.doc();
      await docRef.set({
        "id": docRef.id,
        "chapterId": chapterId,
        "bookId": bookId,
        "startedAt": FieldValue.serverTimestamp(),
        "finishedAt": null,
      });
    }
  }

  // update chapter
  Future<void> updateChapterProgress(
    String userId,
    String chapterId, {
    required double progressPercent,
    required int lastPositionSeconds,
    int? estimatedTimeRemainingSeconds,
    required String bookId,
  }) async {
    final ref =
        _db.collection("users").doc(userId).collection("chaptersProgress");
    final query =
        await ref.where("chapterId", isEqualTo: chapterId).limit(1).get();

    if (query.docs.isNotEmpty) {
      await ref.doc(query.docs.first.id).update({
        "progressPercent": progressPercent,
        "lastPositionSeconds": lastPositionSeconds,
        "estimatedTimeRemainingSeconds": estimatedTimeRemainingSeconds,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } else {
      await ref.add({
        "chapterId": chapterId,
        "bookId": bookId,
        "progressPercent": progressPercent,
        "lastPositionSeconds": lastPositionSeconds,
        "estimatedTimeRemainingSeconds": estimatedTimeRemainingSeconds,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
    await _updateBookProgress(userId, bookId);
  }

  // update book progress
  Future<void> _updateBookProgress(String userId, String bookId) async {
    final chaptersSnapshot =
        await _db.collection('books').doc(bookId).collection('chapters').get();

    final totalChapters = chaptersSnapshot.docs.length;
    if (totalChapters == 0) return;

    final chaptersRef = _db
        .collection('users')
        .doc(userId)
        .collection('chaptersProgress')
        .where('bookId', isEqualTo: bookId);

    final snapshot = await chaptersRef.get();
    if (snapshot.docs.isEmpty) return;
    double totalPercent = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalPercent += (data['progressPercent'] ?? 0).toDouble();
    }

    double bookProgress = totalPercent / totalChapters;
    final bookRef =
        _db.collection("users").doc(userId).collection("booksProgress");
    final bookQuery =
        await bookRef.where("bookId", isEqualTo: bookId).limit(1).get();

    if (bookQuery.docs.isNotEmpty) {
      await bookRef.doc(bookQuery.docs.first.id).update({
        "progressPercent": bookProgress,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  // mark chapter as done
  Future<void> finishChapter(String userId, String chapterId) async {
    final historyRef =
        _db.collection("users").doc(userId).collection("chaptersHistory");
    final chQuery = await historyRef
        .where("chapterId", isEqualTo: chapterId)
        .limit(1)
        .get();

    if (chQuery.docs.isNotEmpty) {
      await historyRef.doc(chQuery.docs.first.id).update({
        "finishedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<Book>> getAllBooksInHistory(String userId) async {
    final ref = _db.collection('users').doc(userId).collection('booksHistory');
    final snapshot = await ref.get();

    final books = snapshot.docs.map((doc) {
      final data = doc.data();
      return Book.fromFirestore(doc);
    }).toList();

    return books;
  }

  Future<List<Chapter>> getAllChaptersInHistoryForBook(
      String userId, String bookId) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('chaptersHistory')
        .where('bookId', isEqualTo: bookId);
    final snapshot = await ref.get();

    final chapters = snapshot.docs.map((doc) {
      return Chapter.fromFirestore(doc);
    }).toList();

    return chapters;
  }

  Future<int?> getSavedPosition({
    required String userId,
    required String chapterId,
  }) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chaptersProgress')
        .where('chapterId', isEqualTo: chapterId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      return data['lastPositionSeconds'] as int?;
    }

    return null;
  }
}
