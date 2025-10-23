import 'package:audio_app_example/models/book.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.book, required this.chaptersCount});

  final Book book;
  final int chaptersCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String formatBookDuration(double totalSeconds) {
      final int seconds = totalSeconds.round();

      final int hours = seconds ~/ 3600;
      final int minutes = (seconds % 3600) ~/ 60;
      final int remainingSeconds = seconds % 60;

      if (hours > 0) {
        if (minutes > 0) {
          return '${hours}h ${minutes}m';
        } else {
          return '${hours}h';
        }
      } else {
        if (remainingSeconds > 0) {
          return '${minutes}m ${remainingSeconds}s';
        } else {
          return '${minutes}m';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: theme.dividerColor.withOpacity(0.3),
        ),
        color: isDark
            ? theme.colorScheme.onSurface.withOpacity(0.08)
            : theme.colorScheme.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(context,
              icon: Icons.category, stat: book.genre, title: 'Genre'),
          _buildSplitter(context),
          _buildStat(context,
              icon: Icons.timer_outlined,
              stat: formatBookDuration(book.durationSeconds),
              title: 'Length'),
          _buildSplitter(context),
          _buildStat(context,
              icon: Icons.menu_book,
              stat: chaptersCount.toString(),
              title: 'Chapters'),
        ],
      ),
    );
  }
}

Widget _buildSplitter(BuildContext context) {
  final theme = Theme.of(context);
  return Container(
    height: 50,
    width: 1.5,
    color: theme.dividerColor.withOpacity(0.5),
  );
}

Widget _buildStat(BuildContext context,
    {required IconData icon, required String stat, required String title}) {
  final theme = Theme.of(context);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      const SizedBox(height: 6),
      Text(
        stat,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
