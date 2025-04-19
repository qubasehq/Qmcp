import 'package:qubase_mcp/mcp/models/server.dart';
import 'package:qubase_mcp/mcp/sse/sse_client.dart';
import 'package:test/test.dart';

void main() {
  group('SSEClient Integration Tests', () {
    late SSEClient sseClient;

    setUp(() {
      final serverConfig = ServerConfig(
        command: 'http://localhost:8080/sse', // Make sure this is your actual server address
        args: [],
      );

      sseClient = SSEClient(serverConfig: serverConfig);
    });

    test('Complete Flow Test', () async {
      // 1. Initialize connection
      await sseClient.initialize();

      // 2. Send initialization request
      final initResponse = await sseClient.sendInitialize();
      expect(initResponse.id, 'init-1');
      expect(initResponse.error, isNull);

      // 3. Test ping
      final pingResponse = await sseClient.sendPing();
      expect(pingResponse.error, isNull);

      // 4. Get tool list
      final toolListResponse = await sseClient.sendToolList();
      print(toolListResponse);
      expect(toolListResponse.error, isNull);
      expect(toolListResponse.result, isNotNull);

      // 5. Test tool invocation
      final toolCallResponse = await sseClient.sendToolCall(
        name: 'sample.hello',
        arguments: {'message': 'Hello, World!'},
      );
      expect(toolCallResponse.error, isNull);
      expect(toolCallResponse.result, isNotNull);
    });

    test('Process Status Stream Test', () async {
      // Monitor process status changes
      sseClient.processStateStream.listen((state) {
        print(state);
      });

      await sseClient.initialize();
      // Wait for a while to observe status changes
      await Future.delayed(const Duration(seconds: 2));
    });

    tearDown(() async {
      await sseClient.dispose();
    });
  });
}

