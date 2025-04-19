import '../models/json_rpc_message.dart';
import '../models/server.dart';

abstract class McpClient {
  ServerConfig get serverConfig;

  Future<void> initialize();
  Future<void> dispose();
  Future<JSONRPCMessage> sendMessage(JSONRPCMessage message);
  Future<JSONRPCMessage> sendInitialize();
  Future<JSONRPCMessage> sendPing();
  Future<JSONRPCMessage> sendToolList();
  Future<JSONRPCMessage> sendToolCall({
    required String name,
    required Map<String, dynamic> arguments,
    String? id,
  });
}
