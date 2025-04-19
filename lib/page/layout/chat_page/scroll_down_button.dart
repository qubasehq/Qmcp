import 'package:flutter/material.dart';

class ScrollDownButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScrollDownButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 30,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
