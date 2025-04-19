import 'package:flutter/material.dart';

class SettingSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double titleFontSize;
  final double subtitleFontSize;
  final int subtitleAlpha;

  const SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.titleFontSize = 16,
    this.subtitleFontSize = 13,
    this.subtitleAlpha = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: subtitleFontSize,
          color:
              Theme.of(context).colorScheme.onSurface.withAlpha(subtitleAlpha),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
