import 'package:dio/dio.dart';
import 'base_llm_client.dart';
import 'dart:convert';
import 'model.dart';
import 'package:logging/logging.dart';
import 'package:qubase_mcp/utils/file_content.dart';

class OpenAIClient extends BaseLLMClient {
  final String apiKey;
  final String baseUrl;
  final Dio _dio;

  OpenAIClient({
    required this.apiKey,
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = (baseUrl == null || baseUrl.isEmpty)
            ? 'https://api.openai.com/v1'
            : baseUrl,
        _dio = dio ??
            Dio(BaseOptions(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
            ));

  @override
  Future<LLMResponse> chatCompletion(CompletionRequest request) async {
    final body = {
      'model': request.model,
      'messages': chatMessageToOpenAIMessage(request.messages),
    };

    if (request.modelSetting != null) {
      body['temperature'] = request.modelSetting!.temperature;
      body['top_p'] = request.modelSetting!.topP;
      body['frequency_penalty'] = request.modelSetting!.frequencyPenalty;
      body['presence_penalty'] = request.modelSetting!.presencePenalty;
      if (request.modelSetting!.maxTokens != null) {
        body['max_tokens'] = request.modelSetting!.maxTokens!;
      }
    }

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = request.tools!;
      body['tool_choice'] = 'auto';
    }

    final bodyStr = jsonEncode(body);

    try {
      final response = await _dio.post(
        "$baseUrl/chat/completions",
        data: bodyStr,
      );

      // Handle ResponseBody type response
      dynamic jsonData;
      if (response.data is ResponseBody) {
        final responseBody = response.data as ResponseBody;
        final responseStr = await utf8.decodeStream(responseBody.stream);
        jsonData = jsonDecode(responseStr);
      } else {
        jsonData = response.data;
      }

      final message = jsonData['choices'][0]['message'];

      // Parse tool calls
      final toolCalls = message['tool_calls']
          ?.map<ToolCall>((t) => ToolCall(
                id: t['id'],
                type: t['type'],
                function: FunctionCall(
                  name: t['function']['name'],
                  arguments: t['function']['arguments'],
                ),
              ))
          ?.toList();

      return LLMResponse(
        content: message['content'],
        toolCalls: toolCalls,
      );
    } catch (e) {
      throw await handleError(
          e, 'OpenAI', '$baseUrl/chat/completions', bodyStr);
    }
  }

  @override
  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request) async* {
    final body = {
      'model': request.model,
      'messages': chatMessageToOpenAIMessage(request.messages),
      'stream': true,
    };

    if (request.modelSetting != null) {
      body['temperature'] = request.modelSetting!.temperature;
      body['top_p'] = request.modelSetting!.topP;
      body['frequency_penalty'] = request.modelSetting!.frequencyPenalty;
      body['presence_penalty'] = request.modelSetting!.presencePenalty;
      if (request.modelSetting!.maxTokens != null) {
        body['max_tokens'] = request.modelSetting!.maxTokens!;
      }
    }

    Logger.root.fine("debug log:openai stream body: ${jsonEncode(body)}");

    try {
      _dio.options.responseType = ResponseType.stream;
      final response = await _dio.post(
        "$baseUrl/chat/completions",
        data: jsonEncode(body),
      );

      String buffer = '';
      await for (final chunk in response.data.stream) {
        final decodedChunk = utf8.decode(chunk);
        buffer += decodedChunk;

        // Handle possible multiline data
        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

            try {
              final json = jsonDecode(jsonStr);

              // Check if choices array is empty
              if (json['choices'] == null || json['choices'].isEmpty) {
                continue;
              }

              final delta = json['choices'][0]['delta'];
              if (delta == null) continue;

              // Parse tool calls
              final toolCalls = delta['tool_calls']
                  ?.map<ToolCall>((t) => ToolCall(
                        id: t['id'] ?? '',
                        type: t['type'] ?? '',
                        function: FunctionCall(
                          name: t['function']?['name'] ?? '',
                          arguments: t['function']?['arguments'] ?? '{}',
                        ),
                      ))
                  ?.toList();

              // Only yield response when there is content or tool calls
              if (delta['content'] != null || toolCalls != null) {
                yield LLMResponse(
                  content: delta['content'],
                  toolCalls: toolCalls,
                );
              }
            } catch (e) {
              Logger.root.severe('Failed to parse chunk: $jsonStr $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw await handleError(
          e, 'OpenAI', '$baseUrl/chat/completions', jsonEncode(body));
    }
  }

  @override
  Future<String> genTitle(List<ChatMessage> messages) async {
    final conversationText = messages.map((msg) {
      final role = msg.role == MessageRole.user ? "Human" : "Assistant";
      return "$role: ${msg.content}";
    }).join("\n");

    try {
      final prompt = ChatMessage(
        role: MessageRole.assistant,
        content:
            """You are a conversation title generator. Generate a concise title (max 20 characters) for the following conversation.
The title should summarize the main topic. Return only the title without any explanation or extra punctuation.

Conversation:
$conversationText""",
      );

      final response = await chatCompletion(CompletionRequest(
        model: "gpt-4o-mini",
        messages: [prompt],
      ));
      return response.content?.trim() ?? "New Chat";
    } catch (e, trace) {
      Logger.root.severe('OpenAI gen title error: $e, trace: $trace');
      return "New Chat";
    }
  }

  @override
  Future<List<String>> models() async {
    if (apiKey.isEmpty) {
      Logger.root.info('OpenAI API key not set, skipping model list fetch');
      return [];
    }

    try {
      final response = await _dio.get("$baseUrl/models");

      final data = response.data;

      final models =
          (data['data'] as List).map((m) => m['id'].toString()).toList();

      return models;
    } catch (e, trace) {
      Logger.root.severe('Failed to get model list: $e, trace: $trace');
      // Return predefined model list as fallback
      return [];
    }
  }
}

List<Map<String, dynamic>> chatMessageToOpenAIMessage(
    List<ChatMessage> messages) {
  return messages.map((message) {
    final json = <String, dynamic>{
      'role': message.role.value,
    };

    // If there is both text content and files, use array format
    if (message.content != null || message.files != null) {
      final List<Map<String, dynamic>> contentParts = [];

      // Add file content
      if (message.files != null) {
        for (final file in message.files!) {
          if (isImageFile(file.fileType)) {
            contentParts.add({
              'type': 'image_url',
              'image_url': {
                "url": "data:${file.fileType};base64,${file.fileContent}",
              },
            });
          }
          if (isTextFile(file.fileType)) {
            contentParts.add({
              'type': 'text',
              'text': file.fileContent,
            });
          }
        }
      }

      // Add text content
      if (message.content != null) {
        contentParts.add({
          'type': 'text',
          'text': message.content,
        });
      }

      // If there is only one text content and no files, use simple string format
      if (contentParts.length == 1 && message.files == null) {
        json['content'] = message.content;
      } else {
        json['content'] = contentParts;
      }
    }

    // Add tool call related fields
    if (message.role == MessageRole.tool &&
        message.name != null &&
        message.toolCallId != null) {
      json['name'] = message.name!;
      json['tool_call_id'] = message.toolCallId!;
    }

    if (message.toolCalls != null) {
      json['tool_calls'] = message.toolCalls;
    }

    return json;
  }).toList();
}

