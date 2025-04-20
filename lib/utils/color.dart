import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const MaterialColor green = Colors.green;
  static const MaterialColor primary = Colors.green;
  static const Color transparent = Colors.transparent;
  static const Color red = Colors.red;

  /// Returns the corresponding color based on the theme
  static Color getThemeColor(BuildContext context,
      {Color? lightColor, Color? darkColor}) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? (lightColor ?? black)
        : (darkColor ?? white);
  }

  /// Gets the background color related to the theme
  static Color getThemeBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: const Color(0xFF121212),
    );
  }

  static Color getThemeTextColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black,
      darkColor: white,
    );
  }

  static Color getLayoutBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: const Color(0xFF1E1E1E),
    );
  }

  static Color getSidebarBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: black,
    );
  }

  static Color getSidebarActiveConversationColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[50],
      darkColor: green[900],
    );
  }

  static Color getToolbarBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: black,
    );
  }

  static Color getTextButtonColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[600],
      darkColor: green[300],
    );
  }

  static Color getCodeTabActiveColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[600],
      darkColor: green[300],
    );
  }

  static Color getCodeTabInactiveColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[100],
      darkColor: green[900],
    );
  }

  static Color getCodePreviewBorderColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[100],
      darkColor: green[900],
    );
  }

  static Color getCodeLanguageTextColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black,
      darkColor: white,
    );
  }

  static Color getInactiveTextColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.6),
      darkColor: white.withOpacity(0.6),
    );
  }

  static Color getMessageBranchDisabledColor() {
    return black.withOpacity(0.4);
  }

  static Color getMessageBranchIndicatorTextColor() {
    return black.withOpacity(0.6);
  }

  static Color getFileAttachmentBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[50],
      darkColor: green[900],
    );
  }

  static Color getImageErrorIconColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.6),
      darkColor: white.withOpacity(0.6),
    );
  }

  static Color getMessageBubbleBackgroundColor(
      BuildContext context, bool isUserMessage) {
    return getThemeColor(
      context,
      lightColor: isUserMessage ? green[50] : white,
      darkColor: isUserMessage ? green[900] : black,
    );
  }

  static Color getToolCallTextColor() {
    return black.withOpacity(0.7);
  }

  static Color getChatAvatarBackgroundColor() {
    return green[700]!;
  }

  static Color getChatAvatarIconColor() {
    return white;
  }

  static Color getWelcomeMessageColor() {
    return black.withOpacity(0.7);
  }

  static Color getErrorIconColor() {
    return red;
  }

  static Color getErrorTextColor() {
    return red;
  }

  static Color getBottomSheetHandleColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.3),
      darkColor: white.withOpacity(0.3),
    );
  }

  static Color getToolbarBottomBorderColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.1),
      darkColor: white.withOpacity(0.1),
    );
  }

  static Color getSidebarToggleIconColor() {
    return black.withOpacity(0.7);
  }

  static Color getArtifactBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: black,
    );
  }

  static Color getArtifactBorderColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[100],
      darkColor: green[900],
    );
  }

  static Color getProgressIndicatorColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[600],
      darkColor: green[300],
    );
  }

  static Color getThinkBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: black,
    );
  }

  static Color getThinkBorderColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[100],
      darkColor: green[900],
    );
  }

  static Color getThinkIconColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[600],
      darkColor: green[300],
    );
  }

  static Color getThinkTextColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.6),
      darkColor: white.withOpacity(0.6),
    );
  }

  static Color getExpandIconColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.6),
      darkColor: white.withOpacity(0.6),
    );
  }

  static Color getFunctionBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: black,
    );
  }

  static Color getFunctionBorderColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[100],
      darkColor: green[900],
    );
  }

  static Color getFunctionIconColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[600],
      darkColor: green[300],
    );
  }

  static Color getFunctionTextColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.6),
      darkColor: white.withOpacity(0.6),
    );
  }

  static Color getPlayButtonColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: green[600],
      darkColor: green[300],
    );
  }

  static Color getCodeBlockToolbarBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: black,
    );
  }

  static Color getCodeBlockLanguageTextColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: black.withOpacity(0.7),
      darkColor: white.withOpacity(0.7),
    );
  }

  static Color getCodePreviewButtonBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: white,
      darkColor: black,
    );
  }

  static Color getLinkColor() {
    return green[600]!;
  }
}
