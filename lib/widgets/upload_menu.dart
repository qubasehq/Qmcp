import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qubase_mcp/generated/app_localizations.dart';

class UploadMenu extends StatelessWidget {
  final bool disabled;
  final VoidCallback onPickImages;
  final VoidCallback onPickFiles;

  const UploadMenu({
    super.key,
    required this.disabled,
    required this.onPickImages,
    required this.onPickFiles,
  });

  void _showUploadOptions(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonSize = button.size;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);

    final double menuWidth = 150.0;
    final double menuHeight = 96.0;

    final double left = buttonPosition.dx + (buttonSize.width - menuWidth) / 2;
    final double top = buttonPosition.dy - menuHeight - 4;

    final RelativeRect position = RelativeRect.fromLTRB(
      left,
      top,
      left + menuWidth,
      top + menuHeight,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(CupertinoIcons.photo, size: 20),
              const SizedBox(width: 8),
              Text(t.selectFromGallery),
            ],
          ),
          onTap: () => Future(() => onPickImages()),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(CupertinoIcons.doc, size: 20),
              const SizedBox(width: 8),
              Text(t.selectFile),
            ],
          ),
          onTap: () => Future(() => onPickFiles()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: disabled ? null : () => _showUploadOptions(context),
      tooltip: t.uploadFile,
    );
  }
}

