import 'dart:async';
import 'package:provider/provider.dart';
import 'settings_provider.dart';
import 'mcp_server_provider.dart';
import 'chat_provider.dart';
import 'chat_model_provider.dart';
import 'serve_state_provider.dart';

class ProviderManager {
  static List<ChangeNotifierProvider> providers = [
    ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(),
    ),
    ChangeNotifierProvider<McpServerProvider>(
      create: (_) => McpServerProvider(),
    ),
    ChangeNotifierProvider<ChatProvider>(
      create: (_) => ChatProvider(),
    ),
    ChangeNotifierProvider<ChatModelProvider>(
      create: (_) => ChatModelProvider(),
    ),
    ChangeNotifierProvider<ServerStateProvider>(
      create: (_) => ServerStateProvider(),
    ),
    // Add other Providers here
  ];

  static SettingsProvider? _settingsProvider;

  static SettingsProvider get settingsProvider {
    _settingsProvider ??= SettingsProvider();
    return _settingsProvider!;
  }

  static McpServerProvider? _mcpServerProvider;

  static McpServerProvider get mcpServerProvider {
    _mcpServerProvider ??= McpServerProvider();
    return _mcpServerProvider!;
  }

  static ChatProvider? _chatProvider;

  static ChatProvider get chatProvider {
    _chatProvider ??= ChatProvider();
    return _chatProvider!;
  }

  static ChatModelProvider? _chatModelProvider;

  static ChatModelProvider get chatModelProvider {
    _chatModelProvider ??= ChatModelProvider();
    return _chatModelProvider!;
  }

  static ServerStateProvider? _serverStateProvider;

  static ServerStateProvider get serverStateProvider {
    _serverStateProvider ??= ServerStateProvider();
    return _serverStateProvider!;
  }

  static Future<void> init() async {
    await SettingsProvider().loadSettings();
    await ChatProvider().loadChats();
  }
}
