// page that opens when the user clicks on a playlist from the home
import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/Loading.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/theme_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/book/book.dart';
import 'package:audio_app_example/widgets/book_zone/book_list/book_card.dart';
import 'package:audio_app_example/widgets/responsive_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Iconlist extends ConsumerStatefulWidget {
  const Iconlist({
    Key? key,
    required this.pressedGenre,
  }) : super(key: key);

  final String pressedGenre;

  @override
  ConsumerState createState() => IconlistState();
}

class IconlistState extends ConsumerState<Iconlist> {
  onPressedBook(String bookId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return BookScreen(
            bookId: bookId,
            needAppBar: true,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Map<String, String> genreMap = {
      'Research': 'Research',
      'Science': 'Science',
      'Literature': 'Literature',
      'أبحاث': 'Research',
      'علوم': 'Science',
      'أدب': 'Literature',
    };
    final canonicalGenre = genreMap[widget.pressedGenre] ?? widget.pressedGenre;

    var size = MediaQuery.of(context).size;
    var width = size.width;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final colors = Theme.of(context).colorScheme;

    final lang = ref.watch(languageProvider);
    final booksAsync = ref.watch(bookProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 4,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.surface,
        iconTheme: IconThemeData(color: colors.onSurface),
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        elevation: 0,
        centerTitle: true,
        title: ResponsiveLogo(
          maxHeight: kToolbarHeight * 0.85,
          isDarkMode: isDarkMode,
        ),
      ),
      body: booksAsync.when(
        error: (error, stackTrace) => Center(
          child: Text(
            '${AppLocalizations.tr('error', lang)}: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        loading: () => const Center(
          child: Loading(),
        ),
        data: (books) {
          final filteredBooks = books.where(
              (b) => b.genre.toLowerCase() == canonicalGenre.toLowerCase());

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: width < 600 ? 16 : 32,
              vertical: width < 600 ? 0 : 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Text(
                    widget.pressedGenre,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredBooks.isNotEmpty)
                    ...filteredBooks.map((book) {
                      return GestureDetector(
                        onTap: () {
                          onPressedBook(book.id);
                        },
                        child: BookCard(
                          imageUrl: book.imageUrl,
                          title: book.name,
                          subtitle: '\$${book.price.toStringAsFixed(2)}',
                        ),
                      );
                    })
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.tr('no_books_found', lang),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.tr('check_other_genres', lang),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
