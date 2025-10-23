import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String name;
  final String about;
  final String authorId;
  final String narratorId;
  final String publisherId;
  final double price;
  final DateTime createdAt;
  final String imageUrl;
  final double durationSeconds;
  final String genre;
  final bool isRecommended;

  Book({
    required this.id,
    required this.name,
    required this.about,
    required this.authorId,
    required this.narratorId,
    required this.publisherId,
    required this.price,
    required this.createdAt,
    required this.imageUrl,
    required this.durationSeconds,
    required this.genre,
    this.isRecommended = false,
  });

  // Map<String, dynamic>
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Safely get isRecommended
    bool recommended = false;
    if (data.containsKey('isRecommended')) {
      final val = data['isRecommended'];
      if (val is bool) {
        recommended = val;
      } else if (val is int) {
        recommended = val != 0;
      } else if (val is String) {
        recommended = val.toLowerCase() == 'true';
      }
    }

    return Book(
      id: doc.id,
      name: data['name'] ?? '',
      about: data['about'] ?? '',
      authorId: data['authorId'] ?? '',
      narratorId: data['narratorId'] ?? '',
      publisherId: data['publisherId'] ?? '',
      genre: data['genre'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      isRecommended: recommended,
      durationSeconds: (data['durationSeconds'] ?? 0).toDouble(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'about': about,
      'author_id': authorId,
      'narrator_id': narratorId,
      'publisher_id': publisherId,
      'price': price,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

class BookProgress {
  final String bookId;
  final int commentsCount;
  final String id;
  final double progressPercent;
  final DateTime updatedAt;

  BookProgress({
    required this.bookId,
    required this.commentsCount,
    required this.id,
    required this.progressPercent,
    required this.updatedAt,
  });

  factory BookProgress.fromFirestore(data) {
    return BookProgress(
      bookId: data['bookId'] ?? '',
      commentsCount: (data['commentsCount'] ?? 0) as int,
      id: data['id'] ?? '',
      progressPercent: (data['progressPercent'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class BookWithProgress {
  final Book book;
  final BookProgress bookProgress;

  BookWithProgress({
    required this.book,
    required this.bookProgress,
  });
}

class BookHistory {
  final Book book;
  final DateTime? finishedAt;
  final int? commentsCount;

  BookHistory({
    required this.book,
    this.finishedAt,
    this.commentsCount,
  });
}
