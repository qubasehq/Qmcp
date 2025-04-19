import 'package:qubase_mcp/provider/provider_manager.dart';
import 'package:qubase_mcp/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:qubase_mcp/utils/event_bus.dart';
import 'package:qubase_mcp/widgets/markdown/markit_widget.dart';
import 'package:qubase_mcp/utils/color.dart';
import 'package:qubase_mcp/generated/app_localizations.dart';

class ChatCodePreview extends StatefulWidget {
  final CodePreviewEvent codePreviewEvent;
  const ChatCodePreview({
    super.key,
    required this.codePreviewEvent,
  });

  @override
  State<ChatCodePreview> createState() => _ChatCodePreviewState();
}

class _ChatCodePreviewState extends State<ChatCodePreview> {
  final double _height = 300; // Default height
  InAppWebViewController? controller;
  bool _hasError = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  Key _webViewKey = UniqueKey();

  bool _showCode = true;

  bool _supportPreview = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _handleError() {
    if (_retryCount < maxRetries) {
      _retryCount++;
      _resetWebView();
    } else {
      setState(() => _hasError = true);
    }
  }

  void _resetWebView() {
    controller?.dispose();
    controller = null;
    setState(() => _webViewKey = UniqueKey());
  }

  Widget _buildToolBar() {
    var t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getToolbarBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  iconSize: 16,
                  padding: const EdgeInsets.all(0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  if (kIsMobile) {
                    Navigator.pop(context);
                    return;
                  }
                  setState(() {
                    emit(CodePreviewEvent(widget.codePreviewEvent.textContent,
                        widget.codePreviewEvent.attributes));
                  });
                },
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 4),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: _showCode
                      ? AppColors.getCodeTabActiveColor(context)
                      : AppColors.getCodeTabInactiveColor(context),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showCode = true;
                  });
                },
                child: Text(
                  t.code,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1,
                    color: _showCode
                        ? Theme.of(context).primaryColor
                        : AppColors.getInactiveTextColor(context),
                  ),
                ),
              ),
              if (_supportPreview) ...[
                const SizedBox(width: 4),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.getTextButtonColor(context),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showCode = false;
                    });
                  },
                  child: Text(
                    t.preview,
                    style: TextStyle(
                      fontSize: 9,
                      height: 1,
                      color: !_showCode
                          ? Theme.of(context).primaryColor
                          : AppColors.getInactiveTextColor(context),
                    ),
                  ),
                ),
              ]
            ],
          ),
          const Spacer(),
          Text(
            widget.codePreviewEvent.attributes['type']?.isEmpty ?? true
                ? 'text'
                : widget.codePreviewEvent.attributes['type']!,
            style: TextStyle(
              color: AppColors.getCodeLanguageTextColor(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    if (_hasError) {
      return Center(child: Text(t.loadContentFailed));
    }

    String language = widget.codePreviewEvent.attributes['type'] ?? '';
    if (language.contains("react")) {
      language = "react";
      _supportPreview = true;
    } else if (language.contains("vue")) {
      language = "vue";
    } else if (language.contains("html")) {
      language = "html";
      _supportPreview = true;
    } else if (language.contains("css")) {
      language = "css";
    } else if (language.contains("js")) {
      language = "javascript";
    } else if (language.contains("ts")) {
      language = "typescript";
    } else if (language.contains("python")) {
      language = "python";
    } else if (language.contains("java")) {
      language = "java";
    } else if (language.contains("c")) {
      language = "c";
    }

    final sandboxServerPort =
        ProviderManager.settingsProvider.sandboxServerPort;

    if (!_supportPreview) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.getCodePreviewBorderColor(context),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToolBar(),
            Expanded(
              child: language == "text/markdown"
                  ? Markit(data: widget.codePreviewEvent.textContent)
                  : Markit(data: '''```$language
${widget.codePreviewEvent.textContent}
```'''),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.getCodePreviewBorderColor(context),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolBar(),
          Expanded(
            child: !_showCode
                ? InAppWebView(
                    key: _webViewKey,
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      transparentBackground: true,
                      isInspectable: kDebugMode,
                    ),
                    initialUrlRequest: URLRequest(
                      url: WebUri('http://localhost:$sandboxServerPort'),
                      headers: {
                        'Content-Type': 'text/html; charset=UTF-8',
                      },
                    ),
                    onLoadStop: (controller, url) async {
                      await Future.delayed(const Duration(milliseconds: 1000));
                      // Inject and execute JavaScript code
                      await controller.evaluateJavascript(
                          source:
                              '''updateCode("${Uri.encodeComponent(widget.codePreviewEvent.textContent)}")''');
                    },
                    onCreateWindow: (controller, request) =>
                        Future.value(false),
                    onReceivedError: (controller, request, error) {
                      debugPrint(
                          'Error on received error: ${error.description}');
                      _handleError();
                    },
                  )
                : Markit(data: '''```$language
${widget.codePreviewEvent.textContent}
```'''),
          ),
        ],
      ),
    );
  }
}

