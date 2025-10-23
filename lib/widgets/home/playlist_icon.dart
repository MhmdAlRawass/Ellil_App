import 'package:audio_app_example/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:audio_app_example/Pages/iconlist.dart';

String playlist = '';
String research = '';

class PlaylistRow extends StatelessWidget {
  final double width;
  final dynamic lang;
  final double maxWidth;

  const PlaylistRow({
    super.key,
    required this.width,
    required this.lang,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: maxWidth * 0.075,
        vertical: maxWidth * 0.027,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: maxWidth * 0.05,
        vertical: maxWidth * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlaylistIcon(
            context,
            AppLocalizations.tr('research', lang),
            Icons.article_outlined,
            Theme.of(context).colorScheme.primary,
          ),
          _buildPlaylistIcon(
            context,
            AppLocalizations.tr('science', lang),
            Icons.auto_stories_outlined,
            Theme.of(context).colorScheme.secondary,
          ),
          _buildPlaylistIcon(
            context,
            AppLocalizations.tr('literature', lang),
            Icons.play_circle_outline,
            Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistIcon(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              playlist = label;
              research = label;
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Iconlist(
                    pressedGenre: label,
                  ),
                ),
              );
            },
            icon: Icon(icon, size: maxWidth * 0.07),
            color: scheme.onPrimary,
          ),
        ),
        SizedBox(height: maxWidth * 0.014),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
