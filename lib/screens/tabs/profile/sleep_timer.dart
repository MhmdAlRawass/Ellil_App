import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/providers/audio_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/providers/sleep_timer_notifier.dart';
import 'package:audio_app_example/providers/tab_index_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SleepTimerScreen extends ConsumerStatefulWidget {
  const SleepTimerScreen({super.key});

  @override
  ConsumerState<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends ConsumerState<SleepTimerScreen> {
  Duration selectedDuration = const Duration(minutes: 15);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final timerState = ref.watch(sleepTimerProvider);
    final timerNotifier = ref.read(sleepTimerProvider.notifier);

    final currentBookId = ref.watch(currentBookIdProvider);
    final currentChapterId = ref.watch(currentChapterIdProvider);

    return AlertDialog(
      title: Text(AppLocalizations.tr('sleep_timer', lang)),
      content: timerState.when(
        data: (remaining) {
          if (remaining == null) {
            // Timer not started → show + / - buttons
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (selectedDuration.inMinutes > 1) {
                      setState(() {
                        selectedDuration -= const Duration(minutes: 1);
                      });
                    }
                  },
                ),
                Text(
                  '${selectedDuration.inMinutes} ${AppLocalizations.tr('minutes', lang)}',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      selectedDuration += const Duration(minutes: 1);
                    });
                  },
                ),
              ],
            );
          } else {
            // Timer running → show remaining time
            return Text(
              _formatDuration(remaining),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            );
          }
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, _) => Text('${AppLocalizations.tr('error', lang)}: $err'),
      ),
      actions: [
        timerState.asData?.value == null
            ? TextButton(
                onPressed: () {
                  timerNotifier.start(
                    selectedDuration,
                    audioPlayer:
                        ref.read(audioNotifierProvider.notifier).player,
                    bookId: currentBookId,
                    chapterId: currentChapterId,
                  );
                },
                child: Text(AppLocalizations.tr('start', lang)),
              )
            : TextButton(
                onPressed: () => timerNotifier.stop(),
                child: Text(AppLocalizations.tr('stop', lang)),
              ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.tr('close', lang)),
        ),
      ],
    );
  }
}
