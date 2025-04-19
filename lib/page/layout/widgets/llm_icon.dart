import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LlmIcon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double size;

  const LlmIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return icon.isNotEmpty
        ? SvgPicture.asset(
            'assets/logo/$icon.svg',
            width: 20,
            height: 20,
            placeholderBuilder: (BuildContext context) => Icon(
              CupertinoIcons.cloud,
            ),
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          )
        : Icon(
            CupertinoIcons.cloud,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          );
  }
}
