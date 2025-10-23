import 'package:flutter/material.dart';

class TabZone extends StatelessWidget {
  const TabZone({
    super.key,
    required this.onPressed,
    required this.tabName,
    this.isActive = false,
  });

  final Function(String) onPressed;
  final String tabName;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: () => onPressed(tabName),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? theme.colorScheme.primary : theme.colorScheme.surface,
          foregroundColor: isActive
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          elevation: isActive ? 4 : 0,
          shadowColor: theme.colorScheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
