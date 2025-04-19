import 'package:flutter/material.dart';
import 'package:qubase_mcp/widgets/tabs.dart';

class ToolsSettings extends StatefulWidget {
  const ToolsSettings({super.key});

  @override
  State<ToolsSettings> createState() => _ToolsSettingsState();
}

class _ToolsSettingsState extends State<ToolsSettings> {
  @override
  Widget build(BuildContext context) {
    return Tabs(
      selectedIndex: 0,
      onTap: (index) {},
      tabs: [
        MyTab(text: 'Tavily Search1', child: Text('Tavily Search1')),
        MyTab(text: 'Tavily Search2', child: Text('Tavily Search2')),
        MyTab(text: 'Tavily Search3', child: Text('Tavily Search3')),
      ],
    );
  }
}

