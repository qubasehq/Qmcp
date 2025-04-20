import 'package:flutter/material.dart';
import 'keys_setting.dart';
import 'mcp_server.dart';
import 'general_setting.dart';
import 'package:qubase_mcp/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<SettingTab> _getTabs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SettingTab(
          title: l10n.general,
          icon: CupertinoIcons.settings,
          content: GeneralSettings()),
      SettingTab(
          title: l10n.providers,
          icon: CupertinoIcons.cube,
          content: KeysSettings()),
      SettingTab(
          title: l10n.mcpServer,
          icon: CupertinoIcons.cloud,
          content: McpServer()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs(context);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5,
            labelStyle: const TextStyle(fontSize: 14),
            tabs: tabs
                .map((tab) => Tab(
                      icon: Icon(tab.icon),
                      text: tab.title,
                    ))
                .toList(),
            onTap: (index) {
              setState(() {});
            },
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) => tab.content).toList(),
        ),
      ),
    );
  }
}


class SettingTab {
  final String title;
  final IconData icon;
  final Widget content;

  SettingTab({
    required this.title,
    required this.icon,
    required this.content,
  });
}

