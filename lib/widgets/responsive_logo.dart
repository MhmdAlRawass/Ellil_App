import 'package:flutter/material.dart';

class ResponsiveLogo extends StatelessWidget {
  const ResponsiveLogo({
    Key? key,
    this.maxHeight = 48,
    required this.isDarkMode,
  }) : super(key: key);

  final double maxHeight;
  final bool isDarkMode;
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context).brightness;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.asset(
          isDarkMode
              ? 'assets/images/logos/Ellil-FR-Blanc-Logo.png'
              : 'assets/images/LOGO2.png',
          height: constraints.maxHeight < maxHeight
              ? constraints.maxHeight
              : maxHeight,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
