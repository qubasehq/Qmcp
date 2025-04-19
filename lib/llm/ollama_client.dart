import 'package:dio/dio.dart';
import 'base_llm_client.dart';
import 'dart:convert';
import 'model.dart';
import 'package:logging/logging.dart';

class OllamaClient extends BaseLLMClient {
  final String baseUrl;
  final Dio _dio;

  OllamaClient({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = (baseUrl == null || baseUrl.isEmpty)
            ? 'http://localhost:11434'
            : baseUrl,
        _dio = dio ??
            Dio(BaseOptions(
              headers: {
                'Content-Type': 'application/json',
              },
            ));

  @override
  Future<List<String>> models() async {
    try {
      final response = await _dio.get("$baseUrl/api/tags");
      final data = response.data;
      final modelsList = data['models'] as List;
      return modelsList.map((model) => (model['name'] as String)).toList();
    } catch (e, trace) {
      Logger.root.severe('Failed to get model list: $e, trace: $trace');
      return [];
    }
  }

  @override
  Future<String> genTitle(List<ChatMessage> messages) async {
    final conversationText = messages.map((msg) {
      final role = msg.role == MessageRole.user ? "Human" : "Assistant";
      return "$role: ${msg.content}";
    }).join("\n");

    final prompt = ChatMessage(
      role: MessageRole.user,
      content:
          """You are a conversation title generator. Please generate a concise title (maximum 20 characters) for the following conversation.
The title should summarize the main topic. Only return the title without any explanation or extra punctuation.

Conversation:
$conversationText""",
    );

    try {
      final response = await chatCompletion(CompletionRequest(
        model: "llama3.2",
        messages: [prompt],
      ));
      return response.content?.trim() ?? "New Chat";
    } catch (e) {
      Logger.root.warning('Failed to generate title: $e');
      return "New Chat";
    }
  }

  @override
  Future<LLMResponse> chatCompletion(CompletionRequest request) async {
    final messages = request.messages.map((m) {
      final role = m.role == MessageRole.user ? 'user' : 'assistant';
      return {
        'role': role,
        'content': m.content,
      };
    }).toList();

    final body = {
      'model': request.model,
      'messages': messages,
      'stream': false,
    };

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = request.tools!;
    }

    final bodyStr = jsonEncode(body);

    try {
      final response = await _dio.post(
        "$baseUrl/v1/chat/completions",
        data: bodyStr,
      );

      var jsonData;
      if (response.data is ResponseBody) {
        final responseBody = response.data as ResponseBody;
        final responseStr = await utf8.decodeStream(responseBody.stream);
        jsonData = jsonDecode(responseStr);
      } else {
        jsonData = response.data;
      }
      Logger.root.fine('Response data: ${jsonEncode(jsonData)}');
      final message = jsonData['choices'][0]['message'];

      // Parse tool calls
      final toolCalls = message['tool_calls']
          ?.map<ToolCall>((t) => ToolCall(
                id: t['id'] ?? '',
                type: 'function',
                function: FunctionCall(
                  name: t['function']['name'],
                  arguments: jsonEncode(t['function']['arguments']),
                ),
              ))
          ?.toList();

      return LLMResponse(
        content: message['content'] ?? '',
        toolCalls: toolCalls,
      );
    } catch (e) {
      throw await handleError(e, 'Ollama', '$baseUrl/v1/chat/completions', bodyStr);
    }
  }

  @override
  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request) async* {
    final messages = request.messages.map((m) {
      final role = m.role == MessageRole.user ? 'user' : 'assistant';
      return {
        'role': role,
        'content': m.content,
      };
    }).toList();

    final body = {
      'model': request.model,
      'messages': messages,
      'stream': true,
    };

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = request.tools!;
      body['tool_choice'] = 'auto';
    }

    try {
      _dio.options.responseType = ResponseType.stream;
      final response = await _dio.post(
        "$baseUrl/v1/chat/completions",
        data: jsonEncode(body),
      );

      String buffer = '';
      await for (final chunk in response.data.stream) {
        final decodedChunk = utf8.decode(chunk);
        buffer += decodedChunk;

        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

            try {
              final json = jsonDecode(jsonStr);

              // 检查 choices 数组是否为空
              if (json['choices'] == null || json['choices'].isEmpty) {
                continue;
              }

              final delta = json['choices'][0]['delta'];
              if (delta == null) continue;

              // Parse tool calls
              final toolCalls = delta['tool_calls']
                  ?.map<ToolCall>((t) => ToolCall(
                        id: t['id'] ?? '',
                        type: 'function',
                        function: FunctionCall(
                          name: t['function']?['name'] ?? '',
                          arguments:
                              jsonEncode(t['function']?['arguments'] ?? {}),
                        ),
                      ))
                  ?.toList();

              // Only yield when content is not empty or there are tool calls
              if (delta['content'] != null || toolCalls != null) {
                yield LLMResponse(
                  content: delta['content'],
                  toolCalls: toolCalls,
                );
              }
            } catch (e) {
              Logger.root.severe('Failed to parse stream chunk: $jsonStr $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw await handleError(
          e, 'Ollama', "$baseUrl/v1/chat/completions", jsonEncode(body));
    }
  }
}
