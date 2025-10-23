import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/author_model.dart';
import 'package:audio_app_example/models/loading.dart';
import 'package:audio_app_example/models/narrator_model.dart';
import 'package:audio_app_example/models/publisher_model.dart';
import 'package:audio_app_example/providers/author_notifier.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/narrator_notifier.dart';
import 'package:audio_app_example/providers/publisher_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/author/author.dart';
import 'package:audio_app_example/screens/tabs/book_zone/book/book.dart';
import 'package:audio_app_example/screens/tabs/book_zone/narrator/narrator.dart';
import 'package:audio_app_example/screens/tabs/book_zone/publisher/publisher.dart';
import 'package:audio_app_example/widgets/book_zone/author/author_card.dart';
import 'package:audio_app_example/widgets/book_zone/book_list/book_card.dart';
import 'package:audio_app_example/widgets/book_zone/narrator/narrator_card.dart';
import 'package:audio_app_example/widgets/book_zone/publisher/publisher_card.dart';
import 'package:audio_app_example/widgets/responsive_logo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooksListScreen extends ConsumerStatefulWidget {
  const BooksListScreen({super.key});

  @override
  ConsumerState<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends ConsumerState<BooksListScreen> {
  String selectedTabKey = 'books';
  Widget activeWidget = Container();
  bool _isShowingDetailScreen = false;
  final _searchController = TextEditingController();
  String searchQuery = '';

  // Select tab
  void onPressedSelectTab(
      String key, Map<String, String> tabLabels, AppLanguage lang) {
    if (key != selectedTabKey) {
      setState(() {
        selectedTabKey = key;
        activeWidget = _buildMainPage(tabLabels, lang, _searchController);
      });
    }
  }

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
  }

  // Navigate back from detail screens
  void onPressedBackward(Map<String, String> tabLabels, AppLanguage lang) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isShowingDetailScreen = false;
        activeWidget = _buildMainPage(tabLabels, lang, _searchController);
      });
    });
  }

  // Navigate to detail screens
  void onPressedNavigateTo(
    String key,
    Map<String, String> tabLabels,
    AppLanguage? lang, {
    String? bookId,
    Author? author,
    Narrator? narrator,
    Publisher? publisher,
  }) {
    setState(() {
      switch (key) {
        case 'books':
          if (bookId != null) {
            activeWidget = BookScreen(
              bookId: bookId,
              onPressedBackward: () => onPressedBackward(tabLabels, lang!),
            );
            _isShowingDetailScreen = true;
          }
          break;
        case 'authors':
          if (author != null) {
            activeWidget = AuthorScreen(
              onPressedBook: (value) =>
                  onPressedNavigateTo('books', tabLabels, lang, bookId: value),
              author: author,
            );
            _isShowingDetailScreen = true;
          }
          break;
        case 'narrators':
          if (narrator != null) {
            activeWidget = NarratorScreen(
              onPressedBook: (book) {
                onPressedNavigateTo('books', tabLabels, lang, bookId: book);
              },
              narrator: narrator,
              narrationCount: 2,
            );
            _isShowingDetailScreen = true;
          }
          break;
        case 'publishers':
          if (publisher != null) {
            activeWidget = PublisherScreen(
              onPressedBook: (value) =>
                  onPressedNavigateTo('books', tabLabels, lang, bookId: value),
              publisher: publisher,
            );
            _isShowingDetailScreen = true;
          }
          break;
      }
    });
  }

  // --- Build list ---
  Widget _buildList(Map<String, String> tabLabels, AppLanguage lang) {
    final booksAsync = ref.watch(bookProvider);
    final authorsAsync = ref.watch(authorProvider);
    final narratorsAsync = ref.watch(narratorProvider);
    final publishersAsync = ref.watch(publisherProvider);

    switch (selectedTabKey) {
      case 'books':
        return booksAsync.when(
          loading: () => const Center(child: Loading()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (books) {
            final filteredBooks = books.where((book) {
              return book.name.toLowerCase().contains(searchQuery);
            }).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return GestureDetector(
                  onTap: () => onPressedNavigateTo(
                    'books',
                    tabLabels,
                    lang,
                    bookId: book.id,
                  ),
                  child: BookCard(
                    imageUrl: book.imageUrl,
                    title: book.name,
                    subtitle: book.price > 0
                        ? '\$${book.price.toStringAsFixed(2)}'
                        : 'Free',
                  ),
                );
              },
            );
          },
        );

      case 'authors':
        if (authorsAsync.isLoading || booksAsync.isLoading) {
          return const Center(child: Loading());
        }
        if (authorsAsync.hasError) {
          return Center(child: Text('Error: ${authorsAsync.error}'));
        }
        if (booksAsync.hasError) {
          return Center(child: Text('Error: ${booksAsync.error}'));
        }

        final authors = authorsAsync.value ?? [];
        final books = booksAsync.value ?? [];
        final filteredAuthors = authors.where((author) {
          return author.name.toLowerCase().contains(searchQuery);
        }).toList();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredAuthors.length,
          itemBuilder: (context, index) {
            final author = filteredAuthors[index];
            final booksCount =
                books.where((b) => b.authorId == author.id).length;
            return GestureDetector(
              onTap: () => onPressedNavigateTo(
                'authors',
                tabLabels,
                lang,
                author: author,
              ),
              child: AuthorCard(
                author: author,
              ),
            );
          },
        );

      case 'narrators':
        return narratorsAsync.when(
          loading: () => const Center(child: Loading()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (narrators) {
            final filteredNarrators = narrators.where((narrator) {
              return narrator.name.toLowerCase().contains(searchQuery);
            }).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredNarrators.length,
              itemBuilder: (context, index) {
                final narrator = filteredNarrators[index];
                return GestureDetector(
                  onTap: () => onPressedNavigateTo(
                    'narrators',
                    tabLabels,
                    lang,
                    narrator: narrator,
                  ),
                  child: NarratorCard(
                    narrator: narrator,
                  ),
                );
              },
            );
          },
        );

      case 'publishers':
        return publishersAsync.when(
          loading: () => const Center(child: Loading()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (publishers) {
            final filteredPublishers = publishers.where((publisher) {
              return publisher.name.toLowerCase().contains(searchQuery);
            }).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPublishers.length,
              itemBuilder: (context, index) {
                final publisher = filteredPublishers[index];
                return GestureDetector(
                  onTap: () => onPressedNavigateTo(
                    'publishers',
                    tabLabels,
                    lang,
                    publisher: publisher,
                  ),
                  child: PublisherCard(
                    publisher: publisher,
                  ),
                );
              },
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMainPage(Map<String, String> tabLabels, AppLanguage lang,
      TextEditingController controller) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width < 600 ? 16 : 32,
        vertical: size.width < 600 ? 0 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          _buildSearchBar(lang, context, controller, onSearchChanged),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
              double spacing = 12;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 4.5,
                children: tabLabels.entries.map((entry) {
                  return GestureDetector(
                    onTap: () => onPressedSelectTab(entry.key, tabLabels, lang),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: selectedTabKey == entry.key
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1)
                            : Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedTabKey == entry.key
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selectedTabKey == entry.key
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildList(tabLabels, lang)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final lang = ref.watch(languageProvider);
    final tabLabels = {
      'books': AppLocalizations.tr('books', lang),
      'authors': AppLocalizations.tr('authors', lang),
      'narrators': AppLocalizations.tr('narrators', lang),
      'publishers': AppLocalizations.tr('publishers', lang),
    };

    if (!_isShowingDetailScreen) {
      activeWidget = _buildMainPage(tabLabels, lang, _searchController);
    }

    return Scaffold(
      appBar: AppBar(
        leading: _isShowingDetailScreen
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_sharp),
                alignment: Alignment.center,
                onPressed: () => onPressedBackward(tabLabels, lang),
              )
            : null,
        automaticallyImplyLeading: false,
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
      body: activeWidget,
    );
  }
}

Widget _buildSearchBar(AppLanguage lang, BuildContext context,
    TextEditingController controller, Function(String) onChanged) {
  return SearchBar(
    controller: controller,
    leading: const Icon(Icons.search),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    hintText: AppLocalizations.tr('search', lang),
    onChanged: onChanged,
    // Background based on theme
    backgroundColor: WidgetStatePropertyAll(
      Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]!
          : Colors.grey[800]!,
    ),

    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    ),
  );
}
