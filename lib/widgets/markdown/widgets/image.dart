import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

import "package:qubase_mcp/widgets/cache_image.dart";

SpanNodeGeneratorWithTag imageGenerator = SpanNodeGeneratorWithTag(
    tag: "img",
    generator: (e, config, visitor) => ImageNode(e, config.img, visitor));

class ImageNode extends ElementNode {
  ImageNode(this.element, this.imgConfig, this.visitor);

  final m.Element element;
  final ImgConfig imgConfig;
  final WidgetVisitor visitor;

  @override
  InlineSpan build() {
    final src = element.attributes['src'];
    if (src == null) {
      return WidgetSpan(child: Text(''));
    }
    return WidgetSpan(
      child: CacheImage(imageUrl: src),
    );
  }
}

