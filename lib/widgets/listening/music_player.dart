import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/models/chapter_model.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/services/comment_service.dart';
import 'package:audio_app_example/widgets/listening/music_player_btns.dart';
import 'package:audio_app_example/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({
    Key? key,
    required Stream<SeekBarData> seekBarDataStream,
    required this.audioPlayer,
    required this.isPurchased,
    required this.price,
    required this.onPay,
    this.maxWidth = 500,
    required this.book,
    required this.chapter,
  })  : _seekBarDataStream = seekBarDataStream,
        super(key: key);

  final Stream<SeekBarData> _seekBarDataStream;
  final AudioPlayer audioPlayer;
  final bool isPurchased;
  final double price;
  final VoidCallback onPay;
  final double maxWidth;
  final Book book;
  final Chapter chapter;

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  double _playbackSpeed = 1.0;
  final commentService = CommentService();

  void setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    widget.audioPlayer.setSpeed(speed);
  }

  onPressedAddComment() async {
    final textController = TextEditingController();
    final lang = ref.read(languageProvider);

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
                  AppLocalizations.tr('add_comment', lang),
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
                    hintText: AppLocalizations.tr('write_your_comment', lang),
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
                      child: Text(AppLocalizations.tr('cancel', lang)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: Text(AppLocalizations.tr('submit', lang)),
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    final maxWidth = widget.maxWidth;

    return Padding(
      padding: EdgeInsets.symmetric(
              horizontal: maxWidth * 0.07, vertical: height * 0.04)
          .copyWith(bottom: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.book.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.chapter.title,
            style: const TextStyle(fontSize: 14),
          ),
          SizedBox(height: height * 0.03),
          StreamBuilder<SeekBarData>(
            stream: widget._seekBarDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                position: positionData?.position ?? Duration.zero,
                duration: positionData?.duration ?? const Duration(minutes: 10),
                onChangeEnd: widget.audioPlayer.seek,
              );
            },
          ),
          SizedBox(height: height * 0.02),
          MusicPlayerBtns(
            maxWidth: widget.maxWidth,
            onPressedPlaybackSpeed: setPlaybackSpeed,
            playBackSpeed: _playbackSpeed,
            onPressedComment: onPressedAddComment,
          ),
        ],
      ),
    );
  }
}
