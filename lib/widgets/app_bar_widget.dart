import 'package:audio_app_example/providers/theme_notifier.dart';
import 'package:audio_app_example/widgets/responsive_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarWidget extends ConsumerWidget {
  const AppBarWidget({super.key, this.automaticallyImplyLeading = false});
  final bool automaticallyImplyLeading;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      scrolledUnderElevation: 4,
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.surface,
      iconTheme: IconThemeData(color: colors.onSurface),
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      elevation: 0,
      centerTitle: true,
      title: ResponsiveLogo(
        maxHeight: kToolbarHeight * 0.85,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
