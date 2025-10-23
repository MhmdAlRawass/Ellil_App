import 'package:audio_app_example/services/user_progress_service.dart';
import 'package:audio_app_example/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

final audioNotifierProvider =
    StateNotifierProvider<AudioNotifier, AudioPlayer?>((ref) {
  return AudioNotifier();
});

class AudioNotifier extends StateNotifier<AudioPlayer?> {
  final userProgressService = UserProgressService();

  AudioNotifier() : super(AudioPlayer());

  AudioPlayer get player => state!;

  Stream<SeekBarData> get seekBarDataStream => Rx.combineLatest3(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (position, bufferedPosition, duration) => SeekBarData(
          position,
          duration ?? Duration.zero,
        ),
      );

  Future<void> play() async {
    await player.play();
  }

  Future<void> setAudioUrl(String url) async {
    try {
      await player.setUrl(url);
    } catch (e) {
      print('Error setting audio URL: $e');
    }
  }

  Future<void> pauseAndSaveProgress(String bookId, String chapterId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await player.pause();

    final pos = player.position.inSeconds;
    final dur = player.duration?.inSeconds ?? 1;
    final percent = pos / dur;
    print(
        'AudioNotifier player: ${state?.playing}, position: ${state?.position}');

    await userProgressService.updateChapterProgress(
      currentUser.uid,
      chapterId,
      progressPercent: percent,
      lastPositionSeconds: pos,
      estimatedTimeRemainingSeconds: dur - pos,
      bookId: bookId,
    );
  }

  Future<void> stopAudio() async {
    await player.stop();
  }

  Future<void> seekForward() async {
    player.seek(player.position + const Duration(seconds: 10));
  }

  Future<void> seekBackward() async {
    player.seek(player.position - const Duration(seconds: 10));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
