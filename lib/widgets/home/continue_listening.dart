import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ContinueListening extends StatelessWidget {
  const ContinueListening({
    super.key,
    this.isLibraryPage = false,
    this.isPurchasedTab = false,
    required this.book,
    required this.writerName,
    required this.narratorName,
    this.commentsCount = 0,
    this.progressPercent = 0,
    required this.lang,
  });

  final Book book;
  final String writerName;
  final String narratorName;
  final int commentsCount;
  final double progressPercent;
  final bool isLibraryPage;
  final bool isPurchasedTab;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    int minutes = book.durationSeconds ~/ 60;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      height: isLibraryPage
          ? !isPurchasedTab
              ? 140
              : 120
          : 110,
      // width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              book.imageUrl,
              width: isLibraryPage ? 90 : 70,
              height: isLibraryPage ? 110 : 95,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surface,
                  highlightColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  child: Container(
                    width: isLibraryPage ? 90 : 70,
                    height: isLibraryPage ? 110 : 95,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Show error message if image fails to load
                return Container(
                  width: isLibraryPage ? 90 : 70,
                  height: isLibraryPage ? 110 : 95,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Error loading image",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  book.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNameAndIcon(
                        name: writerName,
                        icon: Icons.edit_outlined,
                        context: context,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Text('-'),
                      const SizedBox(
                        width: 2,
                      ),
                      _buildNameAndIcon(
                        name: narratorName,
                        icon: Icons.mic_outlined,
                        context: context,
                      )
                    ],
                  ),
                ),
                // Text(
                //   '$writerName - $narratorName',
                //   style: TextStyle(
                //     color: Theme.of(context)
                //         .colorScheme
                //         .onSurface
                //         .withOpacity(0.8),
                //     fontSize: isLibraryPage ? 16 : 14,
                //     fontWeight: FontWeight.w400,
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
                if (!isPurchasedTab)
                  _buildProgressBar(
                    progress: progressPercent,
                  ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.alarm,
                      size: 20,
                    ),
                    Text('$minutes ${AppLocalizations.tr('minutes', lang)}'),
                    const SizedBox(
                      width: 10,
                    ),
                    if (!isPurchasedTab)
                      const Icon(
                        Icons.note_add_outlined,
                        size: 20,
                        weight: 1,
                      ),
                    if (!isPurchasedTab)
                      Text(
                          '$commentsCount ${AppLocalizations.tr('comments', lang)}'),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildProgressBar({required double progress}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: progress),
    duration: const Duration(milliseconds: 500),
    builder: (context, value, _) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          minHeight: 4,
        ),
      );
    },
  );
}

Widget _buildNameAndIcon(
    {required String name,
    required IconData icon,
    required BuildContext context}) {
  return Row(
    children: [
      Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
        size: 18,
      ),
      const SizedBox(
        width: 4,
      ),
      Text(name),
    ],
  );
}
