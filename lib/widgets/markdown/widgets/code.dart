import 'package:qubase_mcp/components/widgets/base.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:qubase_mcp/utils/color.dart';
import 'package:flutter/services.dart';
import 'package:qubase_mcp/generated/app_localizations.dart';

import 'mermaid_diagram_view.dart' show MermaidDiagramView;
import 'html_view.dart';

SpanNodeGeneratorWithTag codeBlockGenerator = SpanNodeGeneratorWithTag(
    tag: "pre",
    generator: (e, config, visitor) => CodeBlockNode(e, config.pre, visitor));

class CodeBlockNode extends ElementNode {
  CodeBlockNode(this.element, this.preConfig, this.visitor);

  String get content => element.textContent;
  final PreConfig preConfig;
  final m.Element element;
  final WidgetVisitor visitor;

  @override
  InlineSpan build() {
    // m.ExtensionSet
    String? language = preConfig.language;
    try {
      final firstChild = element.children?.firstOrNull;
      if (firstChild is m.Element) {
        language = firstChild.attributes['class']?.split('-').lastOrNull;
      }
    } catch (e) {
      language = null;
      debugPrint('get language error:$e');
    }
    final splitContents = content
        .trim()
        .split(visitor.splitRegExp ?? WidgetVisitor.defaultSplitRegExp);
    if (splitContents.last.isEmpty) splitContents.removeLast();

    final codeBuilder = preConfig.builder;
    if (codeBuilder != null) {
      return WidgetSpan(child: codeBuilder.call(content, language ?? ''));
    }

    bool isClosed = element.attributes['isClosed'] == 'true';

    final widget = SizedBox(
      width: double.infinity,
      child: _CodeBlock(
          code: content,
          language: language ?? '',
          isClosed: isClosed,
          preConfig: preConfig,
          splitContents: splitContents,
          visitor: visitor),
    );
    return WidgetSpan(
        child:
            preConfig.wrapper?.call(widget, content, language ?? '') ?? widget);
  }

  @override
  TextStyle get style => preConfig.textStyle.merge(parentStyle);
}

class _CodeBlock extends StatefulWidget {
  final String code;
  final String language;
  final bool isClosed;

  final PreConfig preConfig;
  final WidgetVisitor visitor;
  final List<String> splitContents;
  const _CodeBlock({
    required this.code,
    required this.language,
    required this.isClosed,
    required this.preConfig,
    required this.splitContents,
    required this.visitor,
  });

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock>
    with AutomaticKeepAliveClientMixin {
  bool _isPreviewVisible = false;
  bool _isSupportPreview = false;
  Widget? previewWidget;
  @override
  bool get wantKeepAlive => true;

  final List<String> _supportedLanguages = ['mermaid', 'html', 'svg'];

  final List<String> _htmlLanguages = ['html', 'svg'];

  @override
  void initState() {
    super.initState();
    bool supportPreview = false;
    if (_supportedLanguages.contains(widget.language)) {
      supportPreview = true;
      // Create preview component during initialization
      previewWidget = _buildPreviewWidget();
    }

    setState(() {
      _isSupportPreview = supportPreview;
      if (supportPreview && widget.isClosed) {
        _isPreviewVisible = true;
        print('widget.isClosed: ${widget.isClosed}');
      }
    });
  }

  Widget? _buildPreviewWidget() {
    if (widget.language == 'mermaid') {
      return MermaidDiagramView(
        key: ValueKey(widget.code), // Use content-based key
        code: widget.code,
      );
    } else if (_htmlLanguages.contains(widget.language)) {
      return HtmlView(
        key: ValueKey(widget.code), // Use content-based key
        html: widget.code,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    super.build(context);
    return Container(
      width: double.infinity,
      decoration: widget.preConfig.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildToolBar(t),
          // if (_isSupportPreview)
          //   Offstage(
          //     offstage: !_isPreviewVisible,
          //     child: previewWidget!,
          //   ),
          if (_isSupportPreview && _isPreviewVisible) previewWidget!,
          Gap(size: 20),
          if (!_isPreviewVisible) ...buildCodeBlockList(),
          Gap(size: 20),
        ],
      ),
    );
  }

  Widget buildToolBar(AppLocalizations t) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.getCodeBlockToolbarBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.language.isEmpty ? 'text' : widget.language,
            style: TextStyle(
              color: AppColors.getCodeBlockLanguageTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: const Icon(Icons.copy, size: 14),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.codeCopiedToClipboard),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (_isSupportPreview) ...[
                Gap(size: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(20, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor:
                        AppColors.getCodePreviewButtonBackgroundColor(context),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPreviewVisible = !_isPreviewVisible;
                    });
                  },
                  child: Text(
                    _isPreviewVisible ? 'Code' : 'Preview',
                    style: const TextStyle(fontSize: 9, height: 1),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> buildCodeBlockList() {
    return List.generate(widget.splitContents.length, (index) {
      final currentContent = widget.splitContents[index];
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProxyRichText(
            TextSpan(
              children: highLightSpans(
                currentContent,
                language: widget.preConfig.language,
                theme: widget.preConfig.theme,
                textStyle: widget.preConfig.textStyle,
                styleNotMatched: widget.preConfig.styleNotMatched,
              ),
            ),
            richTextBuilder: widget.visitor.richTextBuilder,
          ));
    });
  }
}

class FencedCodeBlockSyntax extends m.BlockSyntax {
  static final _pattern = RegExp(r'^[ ]{0,3}(~{3,}|`{3,})(.*)$');

  @override
  RegExp get pattern => _pattern;

  const FencedCodeBlockSyntax();

  @override
  m.Node parse(m.BlockParser parser) {
    // Get start marker and language
    final match = pattern.firstMatch(parser.current.content)!;
    final openingFence = match.group(1)!;
    final infoString = match.group(2)!.trim();

    bool isClosed = false;
    final lines = <String>[];

    // Advance to content line
    parser.advance();

    // Collect content until end marker is found
    while (!parser.isDone) {
      final currentLine = parser.current.content;
      final closingMatch = pattern.firstMatch(currentLine);

      // Check if it's an end marker
      if (closingMatch != null &&
          closingMatch.group(1)!.startsWith(openingFence) &&
          closingMatch.group(2)!.trim().isEmpty) {
        isClosed = true;
        parser.advance();
        break;
      }

      lines.add(currentLine);
      parser.advance();
    }

    // If last line is empty and no end marker found, remove it
    if (!isClosed && lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }

    // Create code element
    final code = m.Element.text('code', '${lines.join('\n')}\n');

    // If language marker exists, add class
    if (infoString.isNotEmpty) {
      code.attributes['class'] = 'language-$infoString';
    }

    // Add closure marker
    code.attributes['isClosed'] = isClosed.toString();

    // Create pre element
    final pre = m.Element('pre', [code]);
    pre.attributes['isClosed'] = isClosed.toString();

    return pre;
  }
}

