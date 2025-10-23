import 'package:audio_app_example/models/narrator_model.dart';
import 'package:flutter/material.dart';

class NarratorCard extends StatelessWidget {
  const NarratorCard({
    super.key,
    required this.narrator,
  });

  final Narrator narrator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
      ),
      child: Row(
        children: [
          // Leading icon
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: narrator.imageUrl == null
                  ? Icon(
                      Icons.mic,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 30,
                    )
                  : Image.network(
                      narrator.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: Icon(
                              Icons.mic,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 30,
                            ),
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.mic,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30,
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  narrator.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // Trailing icon
          Icon(
            Icons.chevron_right,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
