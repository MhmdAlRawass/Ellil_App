import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { latin, arabic }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.latin);

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);
