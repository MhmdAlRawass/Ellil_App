import 'dart:async';

import 'package:audio_app_example/models/chapter_model.dart';
import 'package:audio_app_example/services/chapter_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChapterNotifier extends AsyncNotifier<List<Chapter>> {
  final _service = ChapterService();
  String _bookId = '';

  @override
  Future<List<Chapter>> build() async {
    if (_bookId.isEmpty) return [];
    return await _service.getChaptersByBookId(_bookId);
  }

  /// Set the bookId before fetching chapters
  void setBook(String bookId) {
    _bookId = bookId;
    // Re-fetch the chapters
    state = const AsyncValue.loading();
    build().then((chapters) {
      state = AsyncValue.data(chapters);
    }).catchError((e, st) {
      state = AsyncValue.error(e, st);
    });
  }

  /// Get chapter by ID from current state
  Chapter? getById(String chapterId) {
    try {
      return state.asData?.value.firstWhere((c) => c.id == chapterId);
    } catch (_) {
      return null;
    }
  }

  Future<List<Chapter>> fetchBook(String bookId) async {
    _bookId = bookId;
    state = const AsyncValue.loading();
    try {
      final chapters = await _service.getChaptersByBookId(bookId);
      state = AsyncValue.data(chapters);
      return chapters;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final chapterProvider =
    AsyncNotifierProvider<ChapterNotifier, List<Chapter>>(ChapterNotifier.new);
