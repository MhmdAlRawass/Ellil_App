import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/services/book.service.dart';

// class PurchasedBooksNotifier extends FamilyAsyncNotifier<List<Book>, String> {
//   final _service = BookService();

//   @override
//   Future<List<Book>> build(String userId) async {
//     return await _service.getPurchasedBooks(userId);
//   }
// }

// final purchasedBooksProvider =
//     AsyncNotifierProvider.family<PurchasedBooksNotifier, List<Book>, String>(
//   PurchasedBooksNotifier.new,
// );

final purchasedBooksProvider =
    StreamProvider.family<List<Book>, String>((ref, userId) {
  final service = BookService();
  return service.getPurchasedBooksStream(userId);
});
