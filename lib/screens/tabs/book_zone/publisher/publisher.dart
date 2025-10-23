import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/models/Loading.dart';
import 'package:audio_app_example/models/publisher_model.dart';
import 'package:audio_app_example/providers/book_notifier.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/screens/tabs/book_zone/book/book.dart';
import 'package:audio_app_example/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublisherScreen extends ConsumerStatefulWidget {
  const PublisherScreen({
    super.key,
    required this.onPressedBook,
    required this.publisher,
    this.needAppBar = false,
  });

  final Function(String book) onPressedBook;
  final Publisher publisher;
  final bool needAppBar;

  @override
  ConsumerState<PublisherScreen> createState() => _PublisherScreenState();
}

class _PublisherScreenState extends ConsumerState<PublisherScreen> {
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
    final lang = ref.read(languageProvider);
    final booksAsync = ref.watch(bookProvider);

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
          final publisherBooks = books
              .where((book) => book.publisherId == widget.publisher.id)
              .toList();
          final booksCount = publisherBooks.length;

          return SingleChildScrollView(
            child: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(
                horizontal: size.width < 600 ? 16 : 32,
                vertical: size.width < 600 ? 0 : 24,
              ),
              child: Column(
                children: [
                  // --- Top section ---
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
                            color: theme.colorScheme.tertiary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: widget.publisher.imageUrl == null
                                ? Icon(
                                    Icons.business,
                                    size: 60,
                                    color: theme.colorScheme.tertiary,
                                  )
                                : Image.network(
                                    widget.publisher.imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: Icon(
                                            Icons.business,
                                            size: 60,
                                            color: theme.colorScheme.tertiary,
                                          ),
                                        );
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.business,
                                          size: 60,
                                          color: theme.colorScheme.tertiary,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        widget.publisher.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.01),
                      if (widget.publisher.type != null)
                        Text(
                          widget.publisher.type!,
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
                            AppLocalizations.tr('titles', lang),
                            booksCount.toString(),
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
                      if (widget.publisher.bio != null &&
                          widget.publisher.bio!.isNotEmpty)
                        _buildAboutSection(
                          AppLocalizations.tr('about', lang),
                          widget.publisher.bio!,
                          theme.colorScheme,
                        ),
                      Text(
                        AppLocalizations.tr('publications', lang),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (publisherBooks.isEmpty)
                        Text(AppLocalizations.tr('no_books_available', lang))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: publisherBooks.length,
                          itemBuilder: (ctx, index) {
                            final book = publisherBooks[index];
                            return GestureDetector(
                              onTap: () => onPressedBook(book.id),
                              child:
                                  _buildPublicationItem(book.name, book.genre),
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

  Widget _buildPublicationItem(String title, String category) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.book,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(category),
      trailing: Icon(
        Icons.chevron_right,
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
