// import 'dart:async';

import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/services/book.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// class BookNotifier extends AsyncNotifier<List<Book>> {
//   final _service = BookService();

//   @override
//   Future<List<Book>> build() async {
//     return await _service.getAllBooks();
//   }

//   List<Book> getAll() {
//     return state.asData?.value ?? [];
//   }

//   Book? getById(String id) {
//     try {
//       return getAll().firstWhere((book) => book.id == id);
//     } catch (_) {
//       return null;
//     }
//   }
// }

// final bookProvider =
//     AsyncNotifierProvider<BookNotifier, List<Book>>(BookNotifier.new);

final bookProvider = StreamProvider<List<Book>>((ref) {
  final service = BookService();
  return service.getBooksStream();
});
