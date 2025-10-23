import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    this.isSwitcher = false,
    this.onPressed,
    this.onSwitchChanged,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.switchValue = false,
  });

  final bool isSwitcher;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onSwitchChanged;
  final IconData icon;
  final String title;
  final String subTitle;
  final bool? switchValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.transparent,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (subTitle != '')
                      Text(subTitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  )),
                  ],
                ),
              ),

              // 👇 Trailing widget
              isSwitcher
                  ? Switch.adaptive(
                      value: switchValue ?? false,
                      onChanged: onSwitchChanged,
                      activeColor: Theme.of(context).colorScheme.primary,
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: onPressed,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
