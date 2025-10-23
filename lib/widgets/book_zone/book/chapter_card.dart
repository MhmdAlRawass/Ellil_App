import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const ChapterCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon = Icons.menu_book_outlined,
    this.trailingIcon = Icons.arrow_forward_ios,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.onSurface.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.transparent,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Icon(
          leadingIcon,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          trailingIcon,
          color: theme.colorScheme.secondary,
          size: 20,
        ),
      ),
    );
  }
}
