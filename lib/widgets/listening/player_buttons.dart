import 'package:audio_app_example/providers/audio_notifier.dart';
import 'package:audio_app_example/services/user_progress_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class Playerbuttons extends ConsumerWidget {
  const Playerbuttons({
    Key? key,
    // required this.audioPlayer,
    required this.isPurchased,
    required this.price,
    required this.onPay,
    this.canReplay = true,
    required this.bookId,
    required this.chapterId,
  }) : super(key: key);

  // final AudioPlayer audioPlayer;
  final bool isPurchased;
  final double price;
  final VoidCallback onPay;
  final bool canReplay;
  final String bookId;
  final String chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioNotifierProvider)!;
    final audioNotifier = ref.read(audioNotifierProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    // Responsive icon sizes:
    final double mainIcon = width < 500 ? 62 : 72;
    final double sideIcon = width < 500 ? 32 : 42;

    // services
    final userProgressService = UserProgressService();

    // Future<void> onPressedPauseAudio(
    //     {required String userId,
    //     required String bookId,
    //     required String chapterId}) async {
    //   // first pause audio
    //   await audioPlayer.pause();

    //   // second get progress info
    //   final pos = audioPlayer.position.inSeconds;
    //   final dur = audioPlayer.duration?.inSeconds ?? 1;
    //   final percent = pos / dur;

    //   // 3rd save chapter and book progress
    //   await userProgressService.updateChapterProgress(
    //     userId,
    //     chapterId,
    //     progressPercent: percent,
    //     lastPositionSeconds: pos,
    //     estimatedTimeRemainingSeconds: dur - pos,
    //     bookId: bookId,
    //   );
    // }

    // If not purchased and paywall needed
    if (!isPurchased && price > 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  color: theme.colorScheme.primary, size: sideIcon + 8),
              const SizedBox(width: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: const StadiumBorder(),
                ),
                onPressed: onPay,
                icon: Icon(Icons.payment, color: theme.colorScheme.primary),
                label: Text(
                  'Unlock (\$${price.toStringAsFixed(2)})',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Normal player buttons, safe for web/desktop ---
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: canReplay ? MediaQuery.of(context).size.width * 0.8 : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // -10 seconds
            if (canReplay)
              IconButton(
                onPressed: audioNotifier.seekBackward,
                iconSize: sideIcon,
                icon: Icon(
                  Icons.replay_10,
                  color: theme.colorScheme.primary,
                ),
                tooltip: "-10s",
              ),
            // Play/Pause/Replay main button
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final playerState = snapshot.data!;
                  final processingState = playerState.processingState;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      width: mainIcon,
                      height: mainIcon,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  } else if (!audioPlayer.playing) {
                    return IconButton(
                      onPressed: audioNotifier.play,
                      iconSize: mainIcon,
                      icon: Icon(
                        Icons.play_circle,
                        color: canReplay
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSecondary,
                      ),
                      tooltip: "Play",
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      onPressed: () {
                        audioNotifier.pauseAndSaveProgress(bookId, chapterId);
                      },
                      iconSize: mainIcon,
                      icon: Icon(
                        Icons.pause_circle,
                        color: canReplay
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSecondary,
                      ),
                      tooltip: "Pause",
                    );
                  } else {
                    return IconButton(
                      onPressed: () => audioPlayer.seek(Duration.zero,
                          index: audioPlayer.effectiveIndices?.first ?? 0),
                      iconSize: mainIcon,
                      icon: Icon(Icons.replay_circle_filled_outlined,
                          color: theme.colorScheme.primary),
                      tooltip: "Replay",
                    );
                  }
                } else {
                  return SizedBox(
                    width: mainIcon,
                    height: mainIcon,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: theme.colorScheme.primary),
                  );
                }
              },
            ),
            // +10 seconds
            if (canReplay)
              IconButton(
                onPressed: () => {audioNotifier.seekForward()},
                iconSize: sideIcon,
                icon: Icon(Icons.forward_10_outlined,
                    color: theme.colorScheme.primary),
                tooltip: "+10s",
              ),
          ],
        ),
      ),
    );
  }
}
