// lib/screens/home/home.dart
import 'dart:math';
import 'package:audio_app_example/models/loading.dart';
import 'package:audio_app_example/models/narrator_model.dart';
import 'package:audio_app_example/providers/author_notifier.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/narrator_notifier.dart';
import 'package:audio_app_example/providers/purchased_books_notifier.dart';
import 'package:audio_app_example/providers/user_progress_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/book/book.dart';
import 'package:audio_app_example/services/book.service.dart';
import 'package:audio_app_example/widgets/home/continue_listening.dart';
import 'package:audio_app_example/widgets/home/featured_card.dart';
import 'package:audio_app_example/widgets/home/recommended_book_card.dart';
import 'package:audio_app_example/widgets/home/playlist_icon.dart';
import 'package:audio_app_example/widgets/home/section_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/language_notifier.dart';
import '../../app_localizations.dart';

final search = TextEditingController();
var count;
String tit = '';
String descr = '';
String aut = '';
int aime = 0;
bool most = false;

final currentUser = FirebaseAuth.instance.currentUser;

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => MyHome();
}

class MyHome extends ConsumerState<Home> {
  Set<String> purchasedAudioIds = {};
  bool _isLoading = true;

  // services
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
  }

  // navigate to book page
  onPressedBook(String bookId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BookScreen(
          bookId: bookId,
          needAppBar: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final bookAsync = ref.watch(bookProvider);
    final userBooksHistoryAsync = ref.watch(
      userBooksHistoryStreamProvider(currentUser!.uid),
    );
    final narratorAsync = ref.watch(narratorProvider);
    final authorAsync = ref.watch(authorProvider);
    final purchasedBooksAsync = ref.watch(
      purchasedBooksProvider(currentUser!.uid),
    );
    var size = MediaQuery.of(context).size;
    var width = size.width;
    final themeColor = Theme.of(context).colorScheme;

    final contentMaxWidth = width < 600 ? width : min(width * 0.65, 900.0);

    if (bookAsync.isLoading ||
        narratorAsync.isLoading ||
        userBooksHistoryAsync.isLoading ||
        authorAsync.isLoading ||
        purchasedBooksAsync.isLoading) {
      return const Scaffold(
        body: Center(
          child: Loading(),
        ),
      );
    }

    // If either has error
    if (bookAsync.hasError) {
      return Scaffold(body: Center(child: Text("Error: ${bookAsync.error}")));
    }
    if (narratorAsync.hasError) {
      return Scaffold(
          body: Center(child: Text("Error: ${narratorAsync.error}")));
    }
    if (userBooksHistoryAsync.hasError) {
      return Scaffold(
          body: Center(child: Text("Error: ${userBooksHistoryAsync.error}")));
    }

    if (authorAsync.hasError) {
      return Scaffold(body: Center(child: Text("Error: ${authorAsync.error}")));
    }

    if (purchasedBooksAsync.hasError) {
      return Scaffold(
          body: Center(child: Text("Error: ${purchasedBooksAsync.error}")));
    }

    final books = bookAsync.value!;
    final narrators = narratorAsync.value!;
    final authors = authorAsync.value!;
    final booksHistory = userBooksHistoryAsync.value!;
    final purchasedBooks = purchasedBooksAsync.value!;
    final recommendedBooks = books.where((b) => b.isRecommended).toList();

    return Scaffold(
      backgroundColor: themeColor.surface,
      body: Center(
        child: Container(
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
                  AppLocalizations.tr('welcome_back', lang),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// --- Section headers (moved out)
                SectionHeader(
                  title: AppLocalizations.tr('featured_books', lang),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length > 6 ? 6 : books.length,
                    itemBuilder: (ctx, index) {
                      final book = books[index];
                      final narrator = narrators.firstWhere(
                        (n) => n.id == book.narratorId,
                        orElse: () => Narrator(
                          id: '',
                          name: 'Unknown',
                          bio: '',
                          imageUrl: null,
                        ),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: FeaturedCard(
                          book: book,
                          isBookPurchased:
                              purchasedBooks.any((b) => b.id == book.id),
                          lang: lang,
                          onPressed: () {
                            onPressedBook(book.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (booksHistory.isNotEmpty)
                  SectionHeader(
                    title: AppLocalizations.tr('continue_listening', lang),
                  ),
                if (booksHistory.isNotEmpty)
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: booksHistory.length,
                      itemBuilder: (ctx, index) {
                        final b = booksHistory[index];
                        final narrator = narrators.where((n) {
                          return n.id == b.book.narratorId;
                        }).toList()[0];
                        final author = authors.where((author) {
                          return author.id == b.book.authorId;
                        }).toList()[0];
                        final progressAsync =
                            ref.watch(bookProgressProvider(b.book.id));

                        return progressAsync.when(
                          data: (progressData) {
                            return GestureDetector(
                              onTap: () {
                                onPressedBook(progressData.bookId);
                              },
                              child: Container(
                                padding: const EdgeInsets.only(right: 16),
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ContinueListening(
                                  book: b.book,
                                  narratorName: narrator.name,
                                  writerName: author.name,
                                  progressPercent:
                                      progressData!.progressPercent,
                                  commentsCount: b.commentsCount ?? 0,
                                  lang: lang,
                                ),
                              ),
                            );
                          },
                          loading: () => ListTile(
                              title: Text(b.book.name),
                              subtitle: const Text("Loading progress...")),
                          error: (err, stack) => ListTile(
                              title: Text(b.book.name),
                              subtitle: Text("Error: $err")),
                        );
                      },
                    ),
                  ),
                if (recommendedBooks.isNotEmpty)
                  SectionHeader(
                    title: AppLocalizations.tr('recommended_books', lang),
                  ),
                if (recommendedBooks.isNotEmpty)
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedBooks.length,
                      itemBuilder: (ctx, index) {
                        final book = recommendedBooks[index];
                        final narrator = narrators.firstWhere(
                          (n) => n.id == book.narratorId,
                          orElse: () => Narrator(
                            id: '',
                            name: 'Unknown',
                            bio: '',
                            imageUrl: null,
                          ),
                        );
                        return GestureDetector(
                          onTap: () {
                            onPressedBook(book.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: RecommendedBookCard(
                              book: book,
                              narrator: narrator,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                SectionHeader(
                  title: AppLocalizations.tr('explore', lang),
                ),
                PlaylistRow(
                  width: width,
                  lang: lang,
                  maxWidth: contentMaxWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
