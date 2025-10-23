import 'dart:convert';

import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/models/chapter_model.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/services/comment_service.dart';
import 'package:audio_app_example/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class LyricsWidget extends StatefulWidget {
  const LyricsWidget({
    super.key,
    required this.audioPlayer,
    required this.controller,
    required this.isPurchased,
    required this.book,
    required this.chapter,
    required this.lang,
  });

  final AudioPlayer audioPlayer;
  final ScrollController controller;
  final bool isPurchased;
  final Book book;
  final Chapter chapter;
  final AppLanguage lang;

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends State<LyricsWidget> {
  final commentService = CommentService();
  int currentWordIndex = -1;

  // enable/disable highlight
  bool isHighlightEnabled = true;

  // final String transcriptJsonStr = '''
  // [
  //   {"word": "yshhd", "end_time": 0.68, "start_time": 0.28},
  //   {"word": "alaqtsad", "end_time": 1.261, "start_time": 0.72},
  //   {"word": "alalmy", "end_time": 1.841, "start_time": 1.341},
  //   {"word": "am", "end_time": 2.001, "start_time": 1.921},
  //   {"word": "alfyn", "end_time": 2.141, "start_time": 2.041},
  //   {"word": "wkhmsa", "end_time": 2.261, "start_time": 2.141},
  //   {"word": "wshryn", "end_time": 3.422, "start_time": 2.941},
  //   {"word": "adtrabat", "end_time": 4.422, "start_time": 3.862},
  //   {"word": "tjarya", "end_time": 4.962, "start_time": 4.462},
  //   {"word": "hada", "end_time": 5.443, "start_time": 5.062},
  //   {"word": "wdm", "end_time": 6.363, "start_time": 5.983},
  //   {"word": "astqrar", "end_time": 6.923, "start_time": 6.423},
  //   {"word": "maly", "end_time": 7.283, "start_time": 6.983},
  //   {"word": "wtwtrat", "end_time": 8.624, "start_time": 7.884},
  //   {"word": "jywsyasya", "end_time": 9.564, "start_time": 8.744},
  //   {"word": "tsada", "end_time": 10.245, "start_time": 9.745},
  //   {"word": "thll", "end_time": 11.165, "start_time": 10.685},
  //   {"word": "hthh", "end_time": 11.505, "start_time": 11.225},
  //   {"word": "aldrasa", "end_time": 12.066, "start_time": 11.585},
  //   {"word": "hthh", "end_time": 12.466, "start_time": 12.166},
  //   {"word": "alttwrat", "end_time": 13.286, "start_time": 12.546},
  //   {"word": "mn", "end_time": 13.486, "start_time": 13.366},
  //   {"word": "mnzwr", "end_time": 13.906, "start_time": 13.526},
  //   {"word": "atfaq", "end_time": 14.447, "start_time": 13.966},
  //   {"word": "maralaghw", "end_time": 15.187, "start_time": 14.647},
  //   {"word": "althy", "end_time": 16.288, "start_time": 15.967},
  //   {"word": "ymthl", "end_time": 16.808, "start_time": 16.348},
  //   {"word": "alasas", "end_time": 17.348, "start_time": 16.848},
  //   {"word": "almrjy", "end_time": 17.908, "start_time": 17.428},
  //   {"word": "llsyasa", "end_time": 18.609, "start_time": 18.068},
  //   {"word": "alhmayeya", "end_time": 19.269, "start_time": 18.649},
  //   {"word": "lidara", "end_time": 20.129, "start_time": 19.669},
  //   {"word": "alryeys", "end_time": 20.55, "start_time": 20.249},
  //   {"word": "alamyrky", "end_time": 21.11, "start_time": 20.63},
  //   {"word": "dwnald", "end_time": 21.53, "start_time": 21.17},
  //   {"word": "trmb", "end_time": 21.91, "start_time": 21.61},
  //   {"word": "althy", "end_time": 22.35, "start_time": 22.09},
  //   {"word": "ydy", "end_time": 22.811, "start_time": 22.41},
  //   {"word": "malja", "end_time": 23.411, "start_time": 22.891},
  //   {"word": "aljz", "end_time": 23.871, "start_time": 23.511},
  //   {"word": "altjary", "end_time": 24.411, "start_time": 23.951},
  //   {"word": "alamyrky", "end_time": 24.952, "start_time": 24.451},
  //   {"word": "almzmn", "end_time": 25.412, "start_time": 24.972},
  //   {"word": "mn", "end_time": 25.992, "start_time": 25.872},
  //   {"word": "khlal", "end_time": 26.412, "start_time": 26.072},
  //   {"word": "frd", "end_time": 26.772, "start_time": 26.512},
  //   {"word": "tryfat", "end_time": 27.433, "start_time": 26.812},
  //   {"word": "jmrkya", "end_time": 27.993, "start_time": 27.473},
  //   {"word": "shamla", "end_time": 28.493, "start_time": 28.073},
  //   {"word": "wiada", "end_time": 29.674, "start_time": 29.033},
  //   {"word": "tnzym", "end_time": 30.094, "start_time": 29.714},
  //   {"word": "almlat", "end_time": 30.614, "start_time": 30.154}
  // ]
  // ''';

  @override
  void initState() {
    super.initState();
    // used to upload to firestore rather than doing it manually trancript timings only ! can be removed later
    // uploadTranscriptTimings(widget.chapter.id, transcriptJsonStr);

    widget.audioPlayer.positionStream.listen((position) {
      final seconds = position.inMilliseconds / 1000.0;
      final index = widget.chapter.transcriptTimings.indexWhere(
        (word) => word.startTime <= seconds && seconds < word.endTime,
      );

      if (index != -1 && index != currentWordIndex) {
        setState(() {
          currentWordIndex = index;
        });
        // scrollToCurrentWord();
      }
    });
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String removeArabicDiacritics(String text) {
    final arabicDiacritics = RegExp(r'[\u064B-\u065F]');
    return text.replaceAll(arabicDiacritics, '');
  }

  void uploadTranscriptTimings(String chapterId, String jsonStr) async {
    final List<dynamic> jsonData = jsonDecode(jsonStr);

    // Convert to proper maps and remove diacritics
    final List<Map<String, dynamic>> timings = jsonData.map((item) {
      final cleanWord = removeArabicDiacritics(item['word'] ?? '');
      return {
        'word': cleanWord,
        'start_time': item['start_time'],
        'end_time': item['end_time'],
      };
    }).toList();

    await firestore
        .collection('books')
        .doc(widget.book.id)
        .collection('chapters')
        .doc(widget.chapter.id)
        .update({
      'transcriptTimings': timings,
    });

    print("Transcript timings uploaded successfully!");
  }

  onPressedAddComment() async {
    final textController = TextEditingController();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.tr('add_comment', widget.lang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.tr('write_your_comment', widget.lang),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.tr('cancel', widget.lang)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: Text(AppLocalizations.tr('submit', widget.lang)),
                      onPressed: () =>
                          Navigator.pop(context, textController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await commentService.createComment(
        userId: FirebaseAuth.instance.currentUser!.uid,
        bookId: widget.book.id,
        chapterId: widget.chapter.id,
        chapterTimestampSeconds: widget.audioPlayer.position.inSeconds,
        commentText: result,
      );
    }
  }

  void scrollToCurrentWord() {
    if (currentWordIndex == -1) return;

    const wordHeight = 24.0;
    final offset = currentWordIndex * wordHeight;

    widget.controller.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  /// Function to remove Arabic diacritics
  String removeDiacritics(String input) {
    final diacritics = RegExp(
        r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06ED]'); // Arabic diacritics Unicode ranges
    return input.replaceAll(diacritics, '');
  }

  /// Function to clean Arabic text
  List<String> cleanArabicText(String transcript) {
    // 1. Remove diacritics
    String cleaned = removeDiacritics(transcript);

    // 2. Replace non-Arabic letters and digits with space
    cleaned = cleaned.replaceAll(RegExp(r'[^\wء-ي]'), ' ');

    // 3. Split by whitespace and remove empty entries
    final words =
        cleaned.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();

    return words;
  }

  @override
  Widget build(BuildContext context) {
    final cleanedWords = cleanArabicText(widget.chapter.transcript ?? '');
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: widget.controller,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Playerbuttons(
                // audioPlayer: widget.audioPlayer,
                isPurchased: widget.isPurchased,
                price: 0,
                onPay: () {},
                canReplay: false,
                bookId: widget.book.id,
                chapterId: widget.chapter.id,
              ),
              const Spacer(),

              // Add Comment Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: onPressedAddComment,
                child: const Icon(Icons.add_comment_rounded),
              ),

              // Highlight toggle
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  setState(() {
                    isHighlightEnabled = !isHighlightEnabled;
                  });
                },
                child: Icon(
                  Icons.highlight_outlined,
                  color: isHighlightEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            widget.chapter.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Text(
          //   widget.chapter.transcript ?? 'Transcript not available right now!',
          //   style: const TextStyle(
          //     color: Colors.white70,
          //     fontSize: 16,
          //     height: 1.6,
          //   ),
          //   textAlign: TextAlign.center,
          // ),
          // SingleChildScrollView(
          //   controller: widget.controller,
          //   child: RichText(
          //     text: TextSpan(
          //       children: List.generate(widget.chapter.transcriptTimings.length,
          //           (index) {
          //         final timingWord = widget.chapter.transcriptTimings[index];
          //         final displayWord = index < cleanedWords.length
          //             ? cleanedWords[index]
          //             : timingWord.word;

          //         return TextSpan(
          //           text: '$displayWord ',
          //           style: TextStyle(
          //             color: currentWordIndex == index
          //                 ? colorScheme.onSecondary
          //                 : colorScheme.onSurface,
          //             fontWeight: currentWordIndex == index
          //                 ? FontWeight.bold
          //                 : FontWeight.normal,
          //             fontSize: 16,
          //             height: 1.6,
          //           ),
          //         );
          //       }),
          //     ),
          //   ),
          // ),

          RichText(
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl, 
            text: TextSpan(
              children: () {
                final spans = <TextSpan>[];
                int wordIndex = 0;

                // Split into tokens but keep spaces/punctuation
                final regex = RegExp(r'[\s.,،!?;:«»"“”]+');
                final tokens = widget.chapter.transcript!.split(regex);
                final separators = regex
                    .allMatches(widget.chapter.transcript!)
                    .map((m) => m.group(0)!)
                    .toList();

                for (int i = 0; i < tokens.length; i++) {
                  final token = tokens[i];
                  if (token.isEmpty) continue;

                  // If token is a "real word"
                  if (wordIndex < widget.chapter.transcriptTimings.length) {
                    final isActive =
                        wordIndex == currentWordIndex && isHighlightEnabled;
                    spans.add(TextSpan(
                      text: token,
                      style: TextStyle(
                        color: isActive
                            ? colorScheme.onSecondary
                            : colorScheme.onSurface,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ));
                    wordIndex++;
                  } else {
                    spans.add(
                      TextSpan(
                        text: token,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }

                  // Add separator if exists
                  if (i < separators.length) {
                    spans.add(
                      TextSpan(
                        text: separators[i],
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }
                }

                return spans;
              }(),
            ),
          ),
        ],
      ),
    );
  }
}
