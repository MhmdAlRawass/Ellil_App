import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/loading.dart';
import 'package:audio_app_example/providers/author_notifier.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/narrator_notifier.dart';
import 'package:audio_app_example/providers/purchased_books_notifier.dart';
import 'package:audio_app_example/providers/user_progress_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/book/book.dart';
import 'package:audio_app_example/widgets/home/continue_listening.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  String searchQuery = '';

  final tabsLabel = [];
  String selectedTabKey = 'history';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _onPressedBook(String bookId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return BookScreen(needAppBar: true, bookId: bookId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final userBooksHistoryAsync =
        ref.watch(userBooksHistoryStreamProvider(currentUser!.uid));
    final purchasedBooksAsync =
        ref.watch(purchasedBooksProvider(currentUser!.uid));
    final booksAsync = ref.watch(bookProvider);
    final authorsAsync = ref.watch(authorProvider);
    final narratorsAsync = ref.watch(narratorProvider);

    if (userBooksHistoryAsync.isLoading ||
        booksAsync.isLoading ||
        authorsAsync.isLoading ||
        narratorsAsync.isLoading ||
        purchasedBooksAsync.isLoading) {
      return const Center(child: Loading());
    }

    if (userBooksHistoryAsync.hasError ||
        booksAsync.hasError ||
        authorsAsync.hasError ||
        narratorsAsync.hasError ||
        purchasedBooksAsync.hasError) {
      final error = userBooksHistoryAsync.error ??
          booksAsync.error ??
          authorsAsync.error ??
          narratorsAsync.error ??
          purchasedBooksAsync.error;
      return Center(child: Text('Failed loading library: $error'));
    }

    // All data available
    final userBooks = userBooksHistoryAsync.value!;
    final authors = authorsAsync.value!;
    final narrators = narratorsAsync.value!;
    final purchasedBooks = purchasedBooksAsync.value!;

    // tabs
    final tabLabels = {
      'history': AppLocalizations.tr('history', lang),
      'purchased': AppLocalizations.tr('purchased', lang),
    };

    void onSearchChanged(String value) {
      setState(() {
        searchQuery = value.toLowerCase();
      });
    }

    Widget buildEmptyState({
      required BuildContext context,
      required AppLanguage lang,
      required IconData icon,
      required String titleKey,
      String? subtitleKey,
      VoidCallback? onAction,
    }) {
      final theme = Theme.of(context);

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                AppLocalizations.tr(titleKey, lang),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitleKey != null) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.tr(subtitleKey, lang),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    AppLocalizations.tr('browse_books', lang),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget buildHistoryWidget() {
      final filteredBooks = userBooks.where((bookHistory) {
        final bookName = bookHistory.book.name.toLowerCase();
        return bookName.contains(searchQuery);
      }).toList();

      if (filteredBooks.isEmpty) {
        return buildEmptyState(
          context: context,
          lang: lang,
          icon: Icons.history_rounded,
          titleKey: searchQuery.isEmpty ? 'no_history_yet' : 'no_results_found',
          subtitleKey:
              searchQuery.isEmpty ? 'start_listening_to_see_books_here' : null,
        );
      }

      return ListView.builder(
        itemCount: filteredBooks.length,
        itemBuilder: (ctx, index) {
          final book = filteredBooks[index];
          final progressAsync = ref.watch(bookProgressProvider(book.book.id));
          final author = authors.firstWhere((author) {
            return author.id == book.book.authorId;
          });
          final narrator = narrators.firstWhere((narrator) {
            return narrator.id == book.book.narratorId;
          });

          return progressAsync.when(
            data: (progressData) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GestureDetector(
                  onTap: () {
                    _onPressedBook(book.book.id);
                  },
                  child: ContinueListening(
                    isLibraryPage: true,
                    book: book.book,
                    writerName: author.name,
                    narratorName: narrator.name,
                    commentsCount: book.commentsCount ?? 0,
                    progressPercent: progressData!.progressPercent,
                    lang: lang,
                  ),
                ),
              );
            },
            loading: () => ListTile(
              title: Text(book.book.name),
              subtitle: const Text("Loading progress..."),
            ),
            error: (err, stack) => ListTile(
                title: Text(book.book.name), subtitle: Text("Error: $err")),
          );
        },
      );
    }

    Widget buildPurchasedWidget() {
      final filteredBooks = purchasedBooks.where((bookHistory) {
        final bookName = bookHistory.name.toLowerCase();
        return bookName.contains(searchQuery);
      }).toList();

      if (filteredBooks.isEmpty) {
        return buildEmptyState(
          context: context,
          lang: lang,
          icon: Icons.shopping_bag_outlined,
          titleKey:
              searchQuery.isEmpty ? 'no_purchased_books' : 'no_results_found',
          subtitleKey:
              searchQuery.isEmpty ? 'buy_audiobooks_to_see_them_here' : null,
          // onAction: () {
          //   // Example navigation to the book zone tab
          //   Navigator.popUntil(context, (route) => route.isFirst);
          // },
        );
      }
      return ListView.builder(
        itemCount: filteredBooks.length,
        itemBuilder: (ctx, index) {
          final book = filteredBooks[index];

          final author = authors.firstWhere(
            (a) => a.id == book.authorId,
            orElse: () => authors.first,
          );

          final narrator = narrators.firstWhere(
            (n) => n.id == book.narratorId,
            orElse: () => narrators.first,
          );

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () => _onPressedBook(book.id),
              child: ContinueListening(
                isLibraryPage: true,
                book: book,
                writerName: author.name,
                narratorName: narrator.name,
                isPurchasedTab: true,
                lang: lang,
              ),
            ),
          );
        },
      );
    }

    void onPressedSelectTab(
        String key, Map<String, String> tabLabels, AppLanguage lang) {
      if (key != selectedTabKey) {
        setState(() {
          selectedTabKey = key;
        });
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width < 600 ? 16 : 32,
        vertical: size.width < 600 ? 0 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Text(
            AppLocalizations.tr('your_library', lang),
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSearchBar(lang, context, _searchController, onSearchChanged),
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
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: selectedTabKey == 'history' ? 0 : 1,
              children: [
                buildHistoryWidget(),
                buildPurchasedWidget(),
              ],
            ),
          ),
        ],
      ),
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
    hintText: AppLocalizations.tr('search_placeholder', lang),
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
