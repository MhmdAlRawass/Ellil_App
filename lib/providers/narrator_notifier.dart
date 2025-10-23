import 'package:audio_app_example/models/narrator_model.dart';
import 'package:audio_app_example/services/narrator_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NarratorNotifier extends AsyncNotifier<List<Narrator>> {
  final _service = NarratorService();

  @override
  Future<List<Narrator>> build() async {
    return await _service.getAllNarrators();
  }

  List<Narrator> getAll() => state.asData?.value ?? [];

  Narrator? getById(String id) {
    try {
      return getAll().firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}

final narratorProvider =
    AsyncNotifierProvider<NarratorNotifier, List<Narrator>>(
        NarratorNotifier.new);
