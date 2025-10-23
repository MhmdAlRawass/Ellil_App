import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/models/narrator_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecommendedBookCard extends StatelessWidget {
  const RecommendedBookCard({
    super.key,
    required this.book,
    required this.narrator,
  });

  final Book book;
  final Narrator narrator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              book.imageUrl,
              // width: isLibraryPage ? 90 : 70,
              height: 170,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surface,
                  highlightColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  child: Container(
                    // width: isLibraryPage ? 90 : 70,
                    height: 170,
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
                  // width: isLibraryPage ? 90 : 70,
                  height: 170,
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
            height: 12,
          ),

          Text(
            book.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // const SizedBox(
          //   height: 8,
          // ),
          Text(
            narrator.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
