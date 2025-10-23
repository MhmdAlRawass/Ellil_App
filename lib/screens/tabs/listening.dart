import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/Loading.dart';
import 'package:audio_app_example/main.dart';
import 'package:audio_app_example/models/audio.dart';
import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/models/chapter_model.dart';
import 'package:audio_app_example/models/user.dart';
import 'package:audio_app_example/Services-old/database.dart';
import 'package:audio_app_example/providers/audio_notifier.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/chapter_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/purchased_books_notifier.dart';
import 'package:audio_app_example/providers/tab_index_notifier.dart';
import 'package:audio_app_example/providers/user_notifier.dart';
import 'package:audio_app_example/services/book.service.dart';
import 'package:audio_app_example/services/user_progress_service.dart';
import 'package:audio_app_example/widgets/listening/lyrics_widget.dart';
import 'package:audio_app_example/widgets/listening/music_player.dart';
import 'package:audio_app_example/widgets/listening/no_book_page.dart';
import 'package:audio_app_example/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

final currentUser = FirebaseAuth.instance.currentUser;

class Listening extends ConsumerStatefulWidget {
  const Listening({Key? key}) : super(key: key);

  @override
  ConsumerState<Listening> createState() => _ListeningState();
}

class _ListeningState extends ConsumerState<Listening> {
  AudioPlayer get audioPlayer =>
      ref.read(audioNotifierProvider.notifier).player;

  final _userProgressService = UserProgressService();
  final _bookService = BookService();
  late ProviderSubscription<Map<String, String?>> removeListener;

  bool _isLoading = false;
  late DatabaseService db;
  AppAudioData? audioData;
  AppUserData? userData;
  bool isPurchased = false;
  bool isNotSubscribed = false;

  Book? book;
  Chapter? chapter;

  final currentBookAndChapterProvider =
      Provider.autoDispose<Map<String, String?>>((ref) {
    final bookId = ref.watch(currentBookIdProvider);
    final chapterId = ref.watch(currentChapterIdProvider);
    return {'bookId': bookId, 'chapterId': chapterId};
  });

  /// Computed getter to check access
  bool get canUserAccessBook {
    if (book == null) return false;
    return isPurchased || book!.price == 0 || !isNotSubscribed;
  }

  @override
  void initState() {
    super.initState();

    // Listen for audio completion
    audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        if (book != null && chapter != null) {
          await _onChapterFinished();
        }
      }
    });

    // Save progress every 30 seconds
    audioPlayer.positionStream.listen((position) {
      if (book != null &&
          chapter != null &&
          position.inSeconds > 0 &&
          position.inSeconds % 30 == 0) {
        _saveAudioProgression(currentUser!.uid, book!.id, chapter!.id);
      }
    });

    // Load initial book/chapter
    final initialValue = ref.read(currentBookAndChapterProvider);
    final initialBookId = initialValue['bookId'];
    final initialChapterId = initialValue['chapterId'];
    if (initialBookId != null && initialChapterId != null) {
      _fetchBookAndChapter(initialBookId, initialChapterId);
    }

    // Listen for future changes
    removeListener = ref.listenManual<Map<String, String?>>(
      currentBookAndChapterProvider,
      (previous, next) {
        final newBookId = next['bookId'];
        final newChapterId = next['chapterId'];
        if (newBookId != null &&
            newChapterId != null &&
            (newBookId != book?.id || newChapterId != chapter?.id)) {
          _fetchBookAndChapter(newBookId, newChapterId);
        }
      },
    );
  }

  @override
  void dispose() {
    removeListener.close();
    super.dispose();
  }

  Future<void> _saveAudioProgression(
      String userId, String bookId, String chapterId) async {
    final pos = audioPlayer.position.inSeconds;
    final dur = audioPlayer.duration?.inSeconds ?? 1;
    final percent = pos / dur;

    await _userProgressService.updateChapterProgress(
      userId,
      chapterId,
      progressPercent: percent,
      lastPositionSeconds: pos,
      estimatedTimeRemainingSeconds: dur - pos,
      bookId: bookId,
    );
  }

  Future<void> _fetchBookAndChapter(String bookId, String? chapterId) async {
    setState(() => _isLoading = true);
    try {
      final fetchedBook = await _bookService.getBookById(bookId);
      final chapters =
          await ref.read(chapterProvider.notifier).fetchBook(bookId);

      if (chapters.isEmpty) throw Exception("No chapters found");

      final chapterToLoad = chapterId != null
          ? chapters.firstWhere((c) => c.id == chapterId,
              orElse: () => chapters.first)
          : chapters.first;

      await _userProgressService.startChapter(
        currentUser!.uid,
        chapterToLoad.id,
        bookId,
      );

      setState(() {
        book = fetchedBook;
        chapter = chapterToLoad;
      });

      await ref
          .read(audioNotifierProvider.notifier)
          .setAudioUrl(chapterToLoad.audioUrl);

      final savedPos = await _userProgressService.getSavedPosition(
        userId: currentUser!.uid,
        chapterId: chapterToLoad.id,
      );
      if (savedPos != null && savedPos > 0) {
        await audioPlayer.seek(Duration(seconds: savedPos));
      }

      ref.read(currentChapterIdProvider.notifier).state = chapterToLoad.id;

      // Check access after fetching
      _checkAccess();
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed fetching book/chapter: $err')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkAccess() {
    final subscriptionAsync =
        ref.read(userSubscriptionProvider(currentUser!.uid));

    subscriptionAsync.whenData((sub) {
      final hasActiveSubscription =
          sub != null && sub.endsAt.isAfter(DateTime.now());
      setState(() {
        isNotSubscribed =
            book!.price > 0 && !isPurchased && !hasActiveSubscription;
      });
      if (isNotSubscribed) audioPlayer.stop();
    });
  }

  Future<void> _handlePurchase() async {
    ref.read(tabIndexProvider.notifier).state = 4;
  }

  void _onPressedShowLyrics(AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            final colorScheme = Theme.of(context).colorScheme;

            return LyricsWidget(
              isPurchased: isPurchased,
              audioPlayer: audioPlayer,
              book: book!,
              chapter: chapter!,
              controller: controller,
              lang: lang,
            );
          }),
    );
  }

  Future<void> _onChapterFinished() async {
    if (book == null || chapter == null) return;

    final userId = currentUser!.uid;

    // Mark chapter as finished
    await _userProgressService.finishChapter(userId, chapter!.id);

    // Get all chapters of the current book
    final chapters = ref.read(chapterProvider).asData?.value ?? [];
    if (chapters.isEmpty) return;

    final currentIndex = chapters.indexWhere((c) => c.id == chapter!.id);
    final lang = ref.read(languageProvider);

    // If there's a next chapter, ask user if they want to continue
    if (currentIndex >= 0 && currentIndex < chapters.length - 1) {
      final nextChapter = chapters[currentIndex + 1];
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.tr('continue_to_chapter_title', lang)),
          content:
              Text(AppLocalizations.tr('continue_to_chapter_subtitle', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.tr('no', lang)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.tr('yes', lang)),
            ),
          ],
        ),
      );

      if (shouldContinue == true) {
        // Load next chapter
        ref.read(currentChapterIdProvider.notifier).state = nextChapter.id;
      }
    } else {
      // No more chapters, mark book as finished
      await _markBookAsFinished(userId, book!.id);

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.tr('book_completed', lang)),
          content: Text(AppLocalizations.tr('book_completed_congrats', lang)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.tr('ok', lang)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _markBookAsFinished(String userId, String bookId) async {
    final bookProgressRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('booksProgress')
        .where('bookId', isEqualTo: bookId);

    final bookHistoryRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('booksHistory')
        .where('bookId', isEqualTo: bookId);

    final progressSnapshot = await bookProgressRef.get();
    if (progressSnapshot.docs.isNotEmpty) {
      await progressSnapshot.docs.first.reference.update({
        "progressPercent": 100,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    final historySnapshot = await bookHistoryRef.get();
    if (historySnapshot.docs.isNotEmpty) {
      await historySnapshot.docs.first.reference.update({
        "finishedAt": FieldValue.serverTimestamp(),
      });
    }

    final chaptersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chaptersProgress')
        .where('bookId', isEqualTo: bookId);

    final chaptersSnapshot = await chaptersRef.get();
    for (var doc in chaptersSnapshot.docs) {
      await doc.reference.update({
        "progressPercent": 100,
        "lastPositionSeconds": doc.data()['lastPositionSeconds'] ?? 0,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  /// BUILD STATES
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 1️⃣ No book chosen
    if (book == null) {
      return const Scaffold(body: NoBookPage());
    }

    // 2️⃣ Book chosen but cannot access
    if (!canUserAccessBook) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: size.height * 0.1,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/564/564619.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.tr(
                      'access_restricted', ref.read(languageProvider)),
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.tr('subscription_required_to_listen',
                      ref.read(languageProvider)),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    AppLocalizations.tr(
                        'subscribe_unlock_book', ref.read(languageProvider)),
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3️⃣ Normal listening UI
    final contentMaxWidth = size.width < 600 ? size.width : 520.0;
    final seekBarStream =
        ref.watch(audioNotifierProvider.notifier).seekBarDataStream;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width < 600 ? 16 : 32,
                  vertical: size.width < 600 ? 0 : 24),
              child: Center(
                child: SizedBox(
                  width: contentMaxWidth,
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.07),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height:
                                size.height * (size.width < 600 ? 0.4 : 0.34),
                            width: contentMaxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.0),
                              child: Image.network(
                                book!.imageUrl.isNotEmpty
                                    ? book!.imageUrl
                                    : 'https://firebasestorage.googleapis.com/v0/b/audioapp-database.appspot.com/o/images%2Fdefault.jpg?alt=media',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height:
                                size.height * (size.width < 600 ? 0.4 : 0.34),
                            width: contentMaxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black54
                                ],
                              ),
                            ),
                          ),
                          Playerbuttons(
                            isPurchased: true,
                            price: book!.price,
                            onPay: _handlePurchase,
                            bookId: book!.id,
                            chapterId: chapter!.id,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MusicPlayer(
                        seekBarDataStream: seekBarStream,
                        audioPlayer: audioPlayer,
                        isPurchased: isPurchased,
                        price: book!.price,
                        onPay: _handlePurchase,
                        maxWidth: contentMaxWidth,
                        book: book!,
                        chapter: chapter!,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _onPressedShowLyrics(ref.read(languageProvider));
                        },
                        icon: const Icon(Icons.lyrics_outlined,
                            color: Colors.white),
                        label: Text(
                          AppLocalizations.tr(
                              'show_transcript', ref.read(languageProvider)),
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(child: Loading()),
            ),
        ],
      ),
    );
  }
}

class NoBookPage extends ConsumerWidget {
  const NoBookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 78,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF33485D)
                      : const Color(0xFFC8A959),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.tr(
                    'no_book_selected', ref.read(languageProvider)),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.tr(
                    'choose_book_to_listen', ref.read(languageProvider)),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
