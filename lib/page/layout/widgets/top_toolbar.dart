import 'package:qubase_mcp/components/widgets/base.dart';
import 'package:flutter/material.dart';
import 'package:qubase_mcp/provider/provider_manager.dart';
import './model_selector.dart';
import 'package:window_manager/window_manager.dart' as wm;
import 'package:qubase_mcp/utils/platform.dart';
import 'package:qubase_mcp/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:qubase_mcp/provider/chat_provider.dart';
import 'package:qubase_mcp/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:qubase_mcp/provider/mcp_server_provider.dart';
// test page
import 'package:qubase_mcp/widgets/markdown/markit_widget.dart';
import 'package:qubase_mcp/utils/event_bus.dart';
import 'package:qubase_mcp/page/layout/widgets/chat_setting.dart';

class TopToolbar extends StatelessWidget {
  final bool hideSidebar;
  final VoidCallback onToggleSidebar;

  const TopToolbar({
    super.key,
    required this.hideSidebar,
    required this.onToggleSidebar,
  });

  void _onShowChatSetting(BuildContext context) {
    if (kIsMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SafeArea(
            child: ChatSetting(),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: const ChatSetting(),
          ),
        ),
      );
    }
  }

  Widget _buildMoreMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      iconSize: 18,
      icon: const Icon(CupertinoIcons.ellipsis_vertical),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (ProviderManager.chatProvider.activeChat != null)
          PopupMenuItem<String>(
            value: 'share',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.share, size: 18),
                const SizedBox(width: 8),
                CText(text: l10n.share),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'config',
          onTap: () => _onShowChatSetting(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.slider_horizontal_3, size: 18),
              const SizedBox(width: 8),
              CText(text: l10n.modelConfig),
            ],
          ),
        ),
        if (kIsDebug)
          PopupMenuItem<String>(
            value: 'debug',
            child: Row(
              children: [
                const Icon(CupertinoIcons.ant, size: 18),
                const SizedBox(width: 8),
                CText(text: l10n.debug),
              ],
            ),
          ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'share':
            emit(ShareEvent(false));
            break;
          case 'debug':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(l10n.webSearchTest),
                  ),
                  body: const MarkitTestPage(),
                ),
              ),
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        return Consumer<McpServerProvider>(
          builder: (context, mcpProvider, child) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: () async {
                  debugPrint('double tap');
                  if (kIsDesktop) {
                    try {
                      bool isMaximized = await wm.windowManager.isMaximized();
                      if (isMaximized) {
                        await wm.windowManager.unmaximize();
                      } else {
                        await wm.windowManager.maximize();
                      }
                    } catch (e) {
                      debugPrint('Window operation failed: $e');
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.getToolbarBottomBorderColor(context),
                      ),
                    ),
                  ),
                  padding: kIsDesktop
                      ? EdgeInsets.only(left: hideSidebar ? 70 : 0, top: 2)
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hideSidebar && kIsDesktop)
                              IconButton(
                                iconSize: 18,
                                icon: Icon(
                                  CupertinoIcons.sidebar_right,
                                  color: AppColors.getSidebarToggleIconColor(),
                                ),
                                onPressed: onToggleSidebar,
                              ),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 50),
                                child: Row(
                                  children: [
                                    if (kIsMobile)
                                      IconButton(
                                        iconSize: 18,
                                        icon: const Icon(
                                          Icons.menu,
                                        ),
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                      ),
                                    Gap(size: 4),
                                    const ModelSelector(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ProviderManager.chatProvider.activeChat != null)
                            IconButton(
                              iconSize: 18,
                              icon: const Icon(CupertinoIcons.add),
                              onPressed: () {
                                ProviderManager.chatProvider.clearActiveChat();
                              },
                            ),
                          _buildMoreMenu(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

