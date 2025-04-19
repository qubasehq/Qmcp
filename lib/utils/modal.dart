import 'package:flutter/material.dart';

void showModalBottom(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // Allows the modal content to exceed half the screen height
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6, // Initial height is 60% of the screen
        minChildSize: 0.3, // Minimum height is 30% of the screen
        maxChildSize: 0.9, // Maximum height is 90% of the screen
        expand: false,
        builder: (context, scrollController) {
          return child;
        },
      );
    },
  );
}
