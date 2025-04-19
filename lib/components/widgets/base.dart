import 'package:qubase_mcp/utils/color.dart';
import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  const Gap({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
    );
  }
}

class CText extends StatelessWidget {
  const CText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight,
    this.overflow,
    this.color,
  });

  final String text;
  final double? size;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size ?? 12,
        color: color ?? AppColors.getThemeTextColor(context),
        fontWeight: fontWeight,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}

