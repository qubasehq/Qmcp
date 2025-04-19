import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qubase_mcp/provider/mcp_server_provider.dart';

class ServerStateProvider extends ChangeNotifier {
  static final ServerStateProvider _instance = ServerStateProvider._internal();
  factory ServerStateProvider() => _instance;
  ServerStateProvider._internal();

  // 服务器启用状态
  final Map<String, bool> _enabledStates = {};
  // 服务器运行状态
  final Map<String, bool> _runningStates = {};
  // 正在启动的服务器
  final Map<String, bool> _startingStates = {};

  // 获取已启用的服务器数量
  int get enabledCount => _enabledStates.values.where((value) => value).length;

  // 获取服务器启用状态
  bool isEnabled(String serverName) => _enabledStates[serverName] ?? false;

  // 获取服务器运行状态
  bool isRunning(String serverName) => _runningStates[serverName] ?? false;

  // 获取服务器启动中状态
  bool isStarting(String serverName) => _startingStates[serverName] ?? false;

  // 设置服务器启用状态
  void setEnabled(String serverName, bool value) {
    _enabledStates[serverName] = value;
    notifyListeners();
  }

  // 设置服务器运行状态
  void setRunning(String serverName, bool value) {
    _runningStates[serverName] = value;
    _startingStates.remove(serverName); // 不再处于启动中状态
    notifyListeners();
  }

  // 设置服务器启动中状态
  void setStarting(String serverName, bool value) {
    _startingStates[serverName] = value;
    notifyListeners();
  }

  // 从McpServerProvider同步状态
  void syncFromProvider(McpServerProvider provider, List<String> servers) {
    if (servers.isEmpty) return;

    bool changed = false;
    for (String server in servers) {
      // 同步启用状态
      bool enabled = provider.isToolCategoryEnabled(server);
      if (_enabledStates[server] != enabled) {
        _enabledStates[server] = enabled;
        changed = true;
      }

      // 同步运行状态
      bool running = provider.mcpServerIsRunning(server);
      if (_runningStates[server] != running) {
        _runningStates[server] = running;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }
}

