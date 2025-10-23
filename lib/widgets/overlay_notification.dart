import 'package:flutter/material.dart';

enum AlertType { success, error, info }

class OverlayAlert {
  static OverlayEntry? _currentEntry; // only one active at a time

  static void show(
    BuildContext context, {
    required String message,
    required AlertType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);

    // Dismiss previous if exists
    _dismissCurrent();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _AlertWidget(
        message: message,
        type: type,
        onDismiss: () => dismiss(overlayEntry),
      ),
    );

    overlay.insert(overlayEntry);
    _currentEntry = overlayEntry;

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (_currentEntry == overlayEntry) {
        dismiss(overlayEntry);
      }
    });
  }

  static void dismiss(OverlayEntry entry) {
    entry.remove();
    if (_currentEntry == entry) {
      _currentEntry = null;
    }
  }

  static void _dismissCurrent() {
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }
  }
}

class _AlertWidget extends StatefulWidget {
  final String message;
  final AlertType type;
  final VoidCallback onDismiss;

  const _AlertWidget({
    Key? key,
    required this.message,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_AlertWidget> createState() => _AlertWidgetState();
}

class _AlertWidgetState extends State<_AlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  Color get _backgroundColor {
    switch (widget.type) {
      case AlertType.success:
        return Colors.green.shade600;
      case AlertType.error:
        return Colors.red.shade600;
      case AlertType.info:
        return Colors.blue.shade600;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.info:
        return Icons.info;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: _backgroundColor,
          child: ListTile(
            leading: Icon(_icon, color: Colors.white),
            title: Text(
              widget.message,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: widget.onDismiss,
            ),
          ),
        ),
      ),
    );
  }
}
