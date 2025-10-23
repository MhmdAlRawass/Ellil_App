import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/Loading.dart';
import 'package:audio_app_example/models/narrator_model.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/book/book.dart';
import 'package:audio_app_example/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NarratorScreen extends ConsumerStatefulWidget {
  const NarratorScreen({
    super.key,
    required this.onPressedBook,
    required this.narrator,
    required this.narrationCount,
    this.needAppBar = false,
  });

  final Function(String book) onPressedBook;
  final Narrator narrator;
  final int narrationCount;
  final bool needAppBar;

  @override
  ConsumerState<NarratorScreen> createState() => _NarratorScreenState();
}

class _NarratorScreenState extends ConsumerState<NarratorScreen> {
  void onPressedBook(String bookId) {
    if (widget.needAppBar) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => BookScreen(
            bookId: bookId,
            needAppBar: true,
          ),
        ),
      );
    } else {
      widget.onPressedBook(bookId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final booksAsync = ref.watch(bookProvider);
    final lang = ref.read(languageProvider);

    return Scaffold(
      appBar: widget.needAppBar
          ? const PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBarWidget(
                automaticallyImplyLeading: true,
              ),
            )
          : null,
      body: booksAsync.when(
        loading: () => const Center(child: Loading()),
        error: (err, stack) => Center(
          child: Text("${AppLocalizations.tr('error', lang)}: $err"),
        ),
        data: (books) {
          final narratorBooks = books
              .where((book) => book.narratorId == widget.narrator.id)
              .toList();
          final narrationCount = narratorBooks.length;

          return SingleChildScrollView(
            child: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(
                horizontal: size.width < 600 ? 16 : 32,
                vertical: size.width < 600 ? 0 : 24,
              ),
              child: Column(
                children: [
                  // --- Top centered section ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.03),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: widget.narrator.imageUrl == null
                                ? Icon(
                                    Icons.mic,
                                    size: 60,
                                    color: theme.colorScheme.secondary,
                                  )
                                : Image.network(
                                    widget.narrator.imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: Icon(
                                            Icons.mic,
                                            size: 60,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        );
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.mic,
                                          size: 60,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        widget.narrator.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        AppLocalizations.tr('narrator', lang),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem(
                            AppLocalizations.tr('narrations', lang),
                            narrationCount.toString(),
                          ),
                          SizedBox(width: size.width * 0.03),
                          _buildIconButton(
                            context,
                            onTap: () {},
                            icon: Icons.share_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // --- Bottom section ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.narrator.bio.isNotEmpty)
                        _buildAboutSection(
                          AppLocalizations.tr('about_the_narrator', lang),
                          widget.narrator.bio,
                          theme.colorScheme,
                        ),
                      Text(
                        AppLocalizations.tr('works', lang),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (narratorBooks.isEmpty)
                        Text(AppLocalizations.tr('no_books_available', lang))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: narratorBooks.length,
                          itemBuilder: (ctx, index) {
                            final book = narratorBooks[index];
                            return GestureDetector(
                              onTap: () => onPressedBook(book.id),
                              child: _buildBookItem(book.name, book.genre),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBookItem(String title, String genre) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.audiotrack,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      title: Text(title),
      subtitle: Text(genre),
      trailing: Icon(
        Icons.play_arrow,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required Function() onTap, required IconData icon}) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(
          width: 1,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      onPressed: onTap,
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildAboutSection(
      String title, String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.3,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
