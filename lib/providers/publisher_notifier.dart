import 'package:audio_app_example/models/publisher_model.dart';
import 'package:audio_app_example/services/publisher_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublisherNotifier extends AsyncNotifier<List<Publisher>> {
  final _service = PublisherService();

  @override
  Future<List<Publisher>> build() async {
    return await _service.getAllPublishers();
  }

  List<Publisher> getAll() => state.asData?.value ?? [];

  Publisher? getById(String id) {
    try {
      return getAll().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final publisherProvider =
    AsyncNotifierProvider<PublisherNotifier, List<Publisher>>(
        PublisherNotifier.new);
