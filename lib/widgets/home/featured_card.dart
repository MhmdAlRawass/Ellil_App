import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/book.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.book,
    required this.lang,
    required this.onPressed,
    required this.isBookPurchased,
  });

  final Book book;
  final bool isBookPurchased;
  final AppLanguage lang;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var colorScheme = Theme.of(context).colorScheme;
    Locale currentlocale = Localizations.localeOf(context);

    // check if language of app is arabic
    bool isArabic = currentlocale.languageCode == 'ar';

    return Container(
      // height: 200,
      width: size.width * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              book.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                // Shimmer effect while loading
                return Shimmer.fromColors(
                  baseColor: colorScheme.surface,
                  highlightColor: colorScheme.onSurface.withOpacity(0.3),
                  child: Container(
                    width: double.infinity,
                    height: 200,
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
                  width: double.infinity,
                  height: 200,
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
          Positioned(
            bottom: 10,
            left: isArabic ? 0 : 10,
            right: isArabic ? 10 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white, fontSize: 24),
                ),
                // const Text(
                //   'Desc',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 16,
                //   ),
                // ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary),
                  child: Text(
                    AppLocalizations.tr(
                      book.price != 0 && !isBookPurchased ? 'purchase' : 'play',
                      lang,
                    ),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: book.price != 0
                      ? [
                          const Color(0xFFD32F2F)
                              .withOpacity(0.45), // deeper red
                          const Color(0xFFF57C00).withOpacity(0.45), // orange
                        ]
                      : [
                          const Color(0xFF388E3C)
                              .withOpacity(0.45), // deep green
                          const Color(0xFF2E7D32)
                              .withOpacity(0.45), // forest green
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                book.price != 0
                    ? '\$ ${book.price.toStringAsFixed(2)}'
                    : AppLocalizations.tr('free', lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
