import 'dart:ui';

import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/Loading.dart';
import 'package:audio_app_example/models/author_model.dart';
import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/models/comment_model.dart';
import 'package:audio_app_example/models/narrator_model.dart';
import 'package:audio_app_example/models/publisher_model.dart';
import 'package:audio_app_example/models/user_subscription.dart';
import 'package:audio_app_example/providers/author_notifier.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/chapter_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/narrator_notifier.dart';
import 'package:audio_app_example/providers/publisher_notifier.dart';
import 'package:audio_app_example/providers/purchased_books_notifier.dart';
import 'package:audio_app_example/providers/tab_index_notifier.dart';
import 'package:audio_app_example/providers/user_notifier.dart';
import 'package:audio_app_example/providers/user_progress_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/author/author.dart';
import 'package:audio_app_example/screens/tabs/book_zone/narrator/narrator.dart';
import 'package:audio_app_example/screens/tabs/book_zone/publisher/publisher.dart';
import 'package:audio_app_example/screens/tabs_screen.dart';
import 'package:audio_app_example/services/comment_service.dart';
import 'package:audio_app_example/services/stripe_service.dart';
import 'package:audio_app_example/services/user_progress_service.dart';
import 'package:audio_app_example/widgets/app_bar_widget.dart';
import 'package:audio_app_example/widgets/book_zone/book/chapter_card.dart';
import 'package:audio_app_example/widgets/book_zone/book/stat_card.dart';
import 'package:audio_app_example/widgets/overlay_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({
    super.key,
    this.onPressedBackward,
    required this.bookId,
    this.needAppBar = false,
  });

  final Function()? onPressedBackward;
  final bool needAppBar;
  final String bookId;

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  // services
  final _stripeService = StripeService();

  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  String? firstChapterId;

  // services
  final _userProgressService = UserProgressService();
  final _commentService = CommentService();

  void _onSelectNewBook(String bookId) {
    // reset old selections
    ref.read(currentBookIdProvider.notifier).state = null;
    ref.read(currentChapterIdProvider.notifier).state = null;

    // set new book id
    ref.read(currentBookIdProvider.notifier).state = bookId;

    // reset and fetch chapters for the new book
    ref.read(chapterProvider.notifier).setBook(bookId);

    // reset tab if needed
    ref.read(tabIndexProvider.notifier).state = 0;
  }

  popPage() {
    if (widget.needAppBar) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const TabsScreen(),
        ),
      );
    } else {
      return;
    }
  }

  Future<void> onPressedContinueListening(
      BookProgress? bookProgress, bool isBookFinished, AppLanguage lang,
      {required double price,
      required bool isBookPurchased,
      required String bookId,
      required String? firstChapterId}) async {
    if (currentUser == null) return;
    final userId = currentUser!.uid;
    final userSub = ref.watch(userSubscriptionProvider(userId));

    setState(() {
      _isLoading = true;
    });

    // 1️⃣ Paid book not purchased → trigger Stripe purchase
    if (price > 0 && !isBookPurchased) {
      final purchased = await _stripeService.purchaseBook(
        userId: currentUser!.uid,
        bookId: bookId,
      );
      if (purchased) {
        ref.invalidate(purchasedBooksProvider(currentUser!.uid));
        OverlayAlert.show(
          context,
          message: AppLocalizations.tr('book_purchased_successfully', lang),
          type: AlertType.success,
        );
      }

      if (!purchased) {
        setState(() {
          _isLoading = false;
        });
        OverlayAlert.show(
          context,
          message: AppLocalizations.tr('purchase_failed', lang),
          type: AlertType.error,
        );
        return;
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (price > 0 && isBookPurchased) {
      if (userSub.isLoading) {
        setState(() => _isLoading = false);
        return;
      }
      if (userSub.hasError) {
        OverlayAlert.show(
          context,
          message: AppLocalizations.tr('an_error_occurred', lang),
          type: AlertType.error,
        );
        setState(() => _isLoading = false);
        return;
      }
      final userSubscription = userSub.value;

      final isSubscribedNow = userSubscription != null &&
          DateTime.now().isBefore(userSubscription.endsAt);

      if (!isSubscribedNow) {
        OverlayAlert.show(
          context,
          message: AppLocalizations.tr('subscribe_before_listening', lang),
          type: AlertType.error,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // 2️⃣ Finished book → ask user if they want to restart
    if (isBookFinished) {
      final restartBook = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.tr('relisten_book_title', lang)),
          content: Text(AppLocalizations.tr('relisten_book_subtitle', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.tr('no', lang)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.tr('yes', lang)),
            ),
          ],
        ),
      );
      if (restartBook != true) return;
    }

    // 3️⃣ Start listening → initialize progress if needed
    setState(() => _isLoading = true);
    try {
      _onSelectNewBook(bookId);

      if (bookProgress == null) {
        await _userProgressService.initBookProgress(userId, bookId);
        if (firstChapterId != null) {
          await _userProgressService.startChapter(
              userId, firstChapterId, bookId);
        }
      }

      if (firstChapterId != null) {
        ref.read(currentBookIdProvider.notifier).state = bookId;
        ref.read(currentChapterIdProvider.notifier).state = firstChapterId;
        ref.read(tabIndexProvider.notifier).state = 3;

        popPage();
      }
    } catch (e) {
      // handle/log error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> onPressedListenSpecificChapter(
      bookProgress, String? chapterId, AppLanguage lang) async {
    if (currentUser == null || chapterId == null) return;

    setState(() => _isLoading = true);
    try {
      final userId = currentUser!.uid;

      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.tr('listen_chapter', lang)),
          content: Text(AppLocalizations.tr('start_listen', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.tr('no', lang)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.tr('yes', lang)),
            ),
          ],
        ),
      );

      if (shouldContinue != null && shouldContinue) {
        // Initialize book progress if not started
        _onSelectNewBook(widget.bookId);

        if (bookProgress == null) {
          await _userProgressService.initBookProgress(userId, widget.bookId);
          await _userProgressService.startChapter(
              userId, chapterId, widget.bookId);
        }

        // Update providers in correct order
        ref.read(currentBookIdProvider.notifier).state = widget.bookId;
        ref.read(currentChapterIdProvider.notifier).state = chapterId;

        // Switch to Listening tab
        ref.read(tabIndexProvider.notifier).state = 3;
        popPage();
      }
    } catch (e, st) {
      debugPrint("Error starting specific chapter: $e\n$st");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chapterProvider.notifier).setBook(widget.bookId);
    });
  }

  // Download comments pdf
  Future<void> onPressedDownloadComments(Book book) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Comment> comments = await _commentService
          .getCommentsByBookIdAndUserId(book.id, currentUser!.uid);
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (ctx) => [
            pw.Text(
              "${book.name} Comments",
              style: const pw.TextStyle(fontSize: 24),
            ),
            pw.SizedBox(height: 20),
            ...comments.map((c) {
              final time = formatTime(c.chapterTimestampSeconds);
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  '$time ${c.commentText}',
                ),
              );
            })
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${book.name}_comments.pdf',
      );

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print('Error fetching comments $err');
      setState(() {
        _isLoading = false;
      });
      return;
    }
  }

  onPressedNavigateToAuthorPage(Author author) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return AuthorScreen(
            needAppBar: true,
            onPressedBook: (book) {},
            author: author,
          );
        },
      ),
    );
  }

  onPressedNavigateToNarratorPage(Narrator narrator) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return NarratorScreen(
            needAppBar: true,
            onPressedBook: (book) {},
            narrator: narrator,
            narrationCount: 2,
          );
        },
      ),
    );
  }

  onPressedNavigateToPublisherPage(Publisher publisher) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return PublisherScreen(
            needAppBar: true,
            onPressedBook: (book) {},
            publisher: publisher,
          );
        },
      ),
    );
  }

  String formatTime(num seconds) {
    final duration = Duration(seconds: seconds.floor());

    String twoDigits(int n) => n.toString().padLeft(2, "0");

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(secs)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(secs)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final lang = ref.read(languageProvider);

    // providers
    final bookAsync = ref.watch(bookProvider);
    final bookHistoryAsync =
        ref.watch(userBooksHistoryStreamProvider(currentUser!.uid));
    final authorAsync = ref.watch(authorProvider);
    final narratorAsync = ref.watch(narratorProvider);
    final publisherAsync = ref.watch(publisherProvider);
    final booksPurchasedAsync =
        ref.watch(purchasedBooksProvider(currentUser!.uid));

    return Scaffold(
      appBar: widget.needAppBar
          ? const PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBarWidget(
                automaticallyImplyLeading: true,
              ),
            )
          : null,
      body: Stack(
        children: [
          bookAsync.when(
            loading: () => const Center(child: Loading()),
            error: (err, _) => Center(child: Text('Error loading book: $err')),
            data: (books) {
              final book = books.firstWhere((b) => b.id == widget.bookId);
              final chaptersAsync = ref.watch(chapterProvider);
              final isBookFinished = bookHistoryAsync.value?.any(
                    (history) =>
                        history.book.id == widget.bookId &&
                        history.finishedAt != null,
                  ) ??
                  false;

              final author = authorAsync.asData?.value
                  .firstWhere((a) => a.id == book.authorId);
              final narrator = narratorAsync.asData?.value
                  .firstWhere((n) => n.id == book.narratorId);
              final publisher = publisherAsync.asData?.value
                  .firstWhere((p) => p.id == book.publisherId);
              final bookPurchased =
                  booksPurchasedAsync.value?.where((b) => b.id == book.id);
              final chapters = chaptersAsync.value;

              final bool isBookPurchased = bookPurchased?.isNotEmpty ?? false;

              return Container(
                width: size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width < 600 ? 16 : 32,
                  vertical: size.width < 600 ? 0 : 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Top centered section ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.03),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: size.width * 0.6,
                              height: size.height * 0.35,
                              child: AspectRatio(
                                aspectRatio: 3 / 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    book.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          _buildTappableRowText(
                              labelKey: 'written_by',
                              tappableText: author?.name ?? 'Unkown',
                              lang: lang,
                              onTap: () {
                                if (author != null) {
                                  onPressedNavigateToAuthorPage(author);
                                }
                              },
                              theme: theme),
                          SizedBox(height: size.height * 0.005),
                          _buildTappableRowText(
                              labelKey: 'narrated_by',
                              tappableText: narrator?.name ?? 'Unkown',
                              lang: lang,
                              onTap: () {
                                if (narrator != null) {
                                  onPressedNavigateToNarratorPage(narrator);
                                }
                              },
                              theme: theme,
                              isSubTitle: true),
                          SizedBox(height: size.height * 0.02),
                          StatCard(
                            book: book,
                            chaptersCount: chapters?.length ?? 0,
                          ),
                          SizedBox(height: size.height * 0.02),
                          Consumer(
                            builder: (context, ref, child) {
                              final bookProgressAsync =
                                  ref.watch(bookProgressProvider(book.id));

                              return bookProgressAsync.when(
                                data: (bookProgress) {
                                  return _buildContinueButton(
                                    price: book.price,
                                    context,
                                    onTap: () => onPressedContinueListening(
                                      bookProgress,
                                      isBookFinished,
                                      lang,
                                      price: book.price,
                                      isBookPurchased: isBookPurchased,
                                      bookId: book.id,
                                      firstChapterId: firstChapterId,
                                    ),
                                    isNewBook: bookProgress == null,
                                    isBookFinished: isBookFinished,
                                    lang: lang,
                                    isBookPurchased: isBookPurchased,
                                  );
                                },
                                loading: () => const Loading(),
                                error: (e, st) => Text("Error: $e"),
                              );
                            },
                          ),
                          SizedBox(height: size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildIconButton(
                                context,
                                onTap: () {
                                  onPressedDownloadComments(book);
                                },
                                tooltip: AppLocalizations.tr(
                                    'download_comments', lang),
                                icon: Icons.file_download_outlined,
                              ),
                              const SizedBox(width: 8),
                              _buildIconButton(
                                context,
                                onTap: () {},
                                tooltip:
                                    AppLocalizations.tr('share_book', lang),
                                icon: Icons.share_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // --- Bottom start-aligned section ---
                      chaptersAsync.when(
                        loading: () => const Center(child: Loading()),
                        error: (err, _) =>
                            Center(child: Text('Error loading chapters: $err')),
                        data: (chapters) {
                          final bookProgressAsync =
                              ref.watch(bookProgressProvider(book.id));

                          final bookProgress = bookProgressAsync.value;

                          if (chapters.isNotEmpty && firstChapterId == null) {
                            firstChapterId = chapters.first.id;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAboutSection(
                                  book.about, theme.colorScheme, lang),
                              if (publisher != null)
                                _buildPublisherSection(
                                  publisher.name,
                                  theme.colorScheme,
                                  lang,
                                  onTap: () {
                                    onPressedNavigateToPublisherPage(publisher);
                                  },
                                ),
                              Text(
                                AppLocalizations.tr('chapters', lang),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (chapters.isEmpty)
                                Text(AppLocalizations.tr('no_chapters', lang)),
                              ...chapters.map((chapter) {
                                final minutes = chapter.durationSeconds ~/ 60;
                                final seconds = (chapter.durationSeconds % 60)
                                    .toStringAsFixed(2);
                                final formattedDuration =
                                    '${minutes}m ${seconds}s';
                                return GestureDetector(
                                  onTap: () {
                                    onPressedListenSpecificChapter(
                                        bookProgress, chapter.id, lang);
                                  },
                                  child: ChapterCard(
                                    title: chapter.title,
                                    subtitle: formattedDuration,
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Loading(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildContinueButton(
  BuildContext context, {
  required VoidCallback onTap,
  required double price,
  required bool isNewBook,
  required bool isBookPurchased,
  required bool isBookFinished,
  required AppLanguage lang,
}) {
  String label;

  if (price == 0) {
    // Free book
    if (isNewBook) {
      label = 'start_listening';
    } else if (isBookFinished) {
      label = 'listen_another_time';
    } else {
      label = 'continue_listening';
    }
  } else {
    // Paid book
    if (!isBookPurchased) {
      label = 'buy_now';
    } else {
      // Purchased
      label = isNewBook ? 'start_listening' : 'continue_listening';
    }
  }

  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
    ),
    onPressed: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.play_arrow_outlined,
          size: 24,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.tr(label, lang),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildIconButton(
  BuildContext context, {
  required Function() onTap,
  required IconData icon,
  required String tooltip,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return IconButton(
    tooltip: tooltip,
    style: IconButton.styleFrom(
      backgroundColor: isDark
          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.08)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      side: BorderSide(
        width: 1,
        color: Colors.grey.shade400,
      ),
    ),
    onPressed: onTap,
    icon: Icon(
      icon,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

Widget _buildAboutSection(
    String text, ColorScheme colorScheme, AppLanguage lang) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.tr('about', lang),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.9),
            height: 1.3,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    ),
  );
}

Widget _buildPublisherSection(
    String text, ColorScheme colorScheme, AppLanguage lang,
    {VoidCallback? onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.tr('publisher', lang),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            child: Card(
              color: colorScheme.onSurface.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Colors.transparent,
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
              child: Padding(
                padding: const EdgeInsetsGeometry.all(14),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.9),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTappableRowText({
  required String labelKey,
  required String? tappableText,
  required AppLanguage lang,
  required VoidCallback onTap,
  required ThemeData theme,
  bool isSubTitle = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '${AppLocalizations.tr(labelKey, lang)}: ',
        style: isSubTitle
            ? const TextStyle(fontSize: 14)
            : const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
      ),
      GestureDetector(
        onTap: onTap,
        child: Text(
          tappableText ?? "Unknown",
          style: TextStyle(
            fontSize: isSubTitle ? 14 : 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    ],
  );
}
