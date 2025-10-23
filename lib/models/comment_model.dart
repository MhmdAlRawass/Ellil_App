import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String bookId;
  final String chapterId;
  final String commentText;
  final int chapterTimestampSeconds;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chapterId,
    required this.chapterTimestampSeconds,
    required this.commentText,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      chapterId: data['chapterId'] ?? '',
      commentText: data['commentText'] ?? data['comment_text'] ?? '',
      chapterTimestampSeconds: data['chapterTimestampSeconds'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'chapterId': chapterId,
      'commentText': commentText,
      'chapterTimestampSeconds': chapterTimestampSeconds,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
