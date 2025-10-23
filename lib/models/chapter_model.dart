import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  final String id;
  final String title;
  final int orderIndex;
  final double durationSeconds;
  final String description;
  final String bookId;
  final String audioUrl;
  final DateTime? createdAt;
  final String? transcript;
  final List<TranscriptWord> transcriptTimings;

  Chapter({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.audioUrl,
    required this.bookId,
    required this.createdAt,
    required this.durationSeconds,
    required this.description,
    required this.transcript,
    required this.transcriptTimings,
  });

  factory Chapter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chapter(
      id: doc.id,
      title: data['title'] ?? '',
      orderIndex: (data['orderIndex'] as int),
      audioUrl: data['audioUrl'] ?? '',
      bookId: data['bookId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      durationSeconds: (data['durationSeconds'] as num).toDouble(),
      description: data['description'] ?? '',
      transcript: data['transcript'] ?? '',
      transcriptTimings: (data['transcriptTimings'] as List<dynamic>?)
              ?.map((e) => TranscriptWord.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'title': title,
  //     'bio': bio,
  //   };
  // }
}

class TranscriptWord {
  final String word;
  final double startTime;
  final double endTime;

  TranscriptWord({
    required this.word,
    required this.startTime,
    required this.endTime,
  });

  factory TranscriptWord.fromMap(Map<String, dynamic> map) {
    return TranscriptWord(
      word: map['word'],
      startTime: map['start_time']?.toDouble() ?? 0.0,
      endTime: map['end_time']?.toDouble() ?? 0.0,
    );
  }
}

// Example:
final List<TranscriptWord> transcriptTimings = [
  TranscriptWord(word: 'yshhd', startTime: 0.28, endTime: 0.68),
  TranscriptWord(word: 'alaqtsad', startTime: 0.72, endTime: 1.261),
];
