import 'dart:async';
import 'package:audio_app_example/services/user_progress_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final sleepTimerProvider = AsyncNotifierProvider<SleepTimerNotifier, Duration?>(
    SleepTimerNotifier.new);

class SleepTimerNotifier extends AsyncNotifier<Duration?> {
  Timer? _timer;
  Duration? _remaining;
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  FutureOr<Duration?> build() {
    // No timer running initially
    return null;
  }

  String? _currentBookId;
  String? _currentChapterId;

  /// Start the sleep timer
  void start(Duration duration,
      {required AudioPlayer audioPlayer,
      required String? bookId,
      required String? chapterId}) {
    _audioPlayer = audioPlayer;
    _currentBookId = bookId;
    _currentChapterId = chapterId;
    _remaining = duration;
    state = AsyncData(_remaining);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remaining == null) return;

      _remaining = _remaining! - const Duration(seconds: 1);
      state = AsyncData(_remaining);

      if (_remaining!.inSeconds <= 0) {
        timer.cancel();
        await _handleTimerEnd();
      }
    });
  }

  bool get isTimerRunning => _timer?.isActive ?? false;

  /// Stop manually
  void stop() {
    _timer?.cancel();
    _remaining = null;
    state = const AsyncData(null);
  }

  /// When timer ends → stop audio & save progress
  Future<void> _handleTimerEnd() async {
    // 1️⃣ Get current user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 2️⃣ Stop audio
    await _audioPlayer.stop();

    // 3️⃣ Save progress if audio is available
    // You need to pass bookId & chapterId to the sleep timer notifier
    if (_audioPlayer.duration != null && _audioPlayer.position.inSeconds > 0) {
      final userProgressService = UserProgressService();

      // Make sure you store these when starting timer:
      // _currentBookId & _currentChapterId
      if (_currentBookId != null && _currentChapterId != null) {
        final pos = _audioPlayer.position.inSeconds;
        final dur = _audioPlayer.duration!.inSeconds;
        final percent = pos / dur;

        await userProgressService.updateChapterProgress(
          currentUser.uid,
          _currentChapterId!,
          progressPercent: percent,
          lastPositionSeconds: pos,
          estimatedTimeRemainingSeconds: dur - pos,
          bookId: _currentBookId!,
        );
      }
    }

    // 4️⃣ Reset timer state
    _remaining = null;
    state = const AsyncData(null);
  }

  @override
  FutureOr<void> onDispose() {
    _timer?.cancel();
  }
}
