import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabIndexProvider = StateProvider<int>((ref) => 0);

/// To carry the bookId when switching to Listening
final currentBookIdProvider = StateProvider<String?>((ref) => null);

/// To carry the chapterId when switching to Listening
final currentChapterIdProvider = StateProvider<String?>((ref) => null);
