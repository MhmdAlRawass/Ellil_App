import 'package:audio_app_example/models/author_model.dart';
import 'package:audio_app_example/services/author_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthorNotifier extends AsyncNotifier<List<Author>> {
  final _service = AuthorService();

  @override
  Future<List<Author>> build() async {
    return await _service.getAllAuthors();
  }

  List<Author> getAll() => state.asData?.value ?? [];

  Author? getById(String id) {
    try {
      return getAll().firstWhere((author) => author.id == id);
    } catch (_) {
      return null;
    }
  }
}

final authorProvider =
    AsyncNotifierProvider<AuthorNotifier, List<Author>>(AuthorNotifier.new);

