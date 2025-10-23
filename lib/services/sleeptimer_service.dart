import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class SleepTimerService {
  final AudioPlayer audioPlayer;
  final Function saveProgress;
  Timer? _timer;

  SleepTimerService({required this.audioPlayer, required this.saveProgress});

  void start(Duration duration) {
    _timer?.cancel();
    _timer = Timer(duration, _onTimerComplete);
  }

  void cancel() {
    _timer?.cancel();
  }

  Future<void> _onTimerComplete() async {
    await audioPlayer.stop();

    try {
      await saveProgress();
    } catch (e) {
      print("Error saving progress: $e");
    }

    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      print('Sleep timer ended. Audio stopped');
    }
  }
}
