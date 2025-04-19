import 'package:dio/dio.dart';
import 'dart:convert';
import 'base_llm_client.dart';
import 'model.dart';
import 'package:logging/logging.dart';
import 'package:qubase_mcp/provider/provider_manager.dart';
import 'package:qubase_mcp/utils/file_content.dart';

class ClaudeClient extends BaseLLMClient {
  final String apiKey;
  String baseUrl;
  final Dio _dio;

  ClaudeClient({
    required this.apiKey,
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = (baseUrl == null || baseUrl.isEmpty)
            ? 'https://api.anthropic.com/v1'
            : baseUrl,
        _dio = dio ??
            Dio(BaseOptions(
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': apiKey,
                'anthropic-version': '2023-06-01',
              },
            ));

  @override
  Future<LLMResponse> chatCompletion(CompletionRequest request) async {
    final messages = chatMessageToClaudeMessage(request.messages);

    final body = {
      'model': request.model,
      'messages': messages,
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
      body['tools'] = {
        'function_calling': {
          'tools': request.tools,
        }
      };
    }

    try {
      final response = await _dio.post(
        '$baseUrl/messages',
        data: jsonEncode(body),
      );

      var json;
      if (response.data is ResponseBody) {
        final responseBody = response.data as ResponseBody;
        final responseStr = await utf8.decodeStream(responseBody.stream);
        json = jsonDecode(responseStr);
      } else {
        json = response.data;
      }

      final content = json['content'][0]['text'];

      // Parse tool calls if present
      final toolCalls = json['tool_calls']
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
        content: content,
        toolCalls: toolCalls,
      );
    } catch (e) {
      throw Exception(
          "Claude API call failed: $baseUrl/messages body: ${jsonEncode(body)} error: $e");
    }
  }

  @override
  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request) async* {
    final messages = chatMessageToClaudeMessage(request.messages);

    final body = {
      'model': request.model,
      'messages': messages,
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

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = {
        'function_calling': {
          'tools': request.tools,
        }
      };
      body['tool_choice'] = {'type': 'any'};
    }

    try {
      _dio.options.responseType = ResponseType.stream;
      final response = await _dio.post(
        '$baseUrl/messages',
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

          if (!line.startsWith('data:')) continue;

          final jsonStr = line.substring(5).trim();
          if (jsonStr.isEmpty) continue;

          try {
            final event = jsonDecode(jsonStr);
            final eventType = event['type'];

            switch (eventType) {
              case 'content_block_start':
                final content = event['content_block'];
                final text = content['text'];
                yield LLMResponse(content: text);
              case 'content_block_delta':
                final delta = event['delta'];
                if (delta['type'] == 'text_delta') {
                  yield LLMResponse(content: delta['text']);
                } else if (delta['type'] == 'input_json_delta') {
                  // Handle tool use delta
                  // final partialJson = delta['partial_json'];
                  // You may want to accumulate the JSON and parse it when complete
                }
                break;

              case 'content_block_stop':
                // Handle end of a content block
                break;

              case 'message_stop':
                // Handle end of message
                break;

              case 'error':
                final error = event['error'];
                throw Exception('Stream error: ${error['message']}');

              case 'ping':
                // Ignore ping events
                break;
            }
          } catch (e) {
            Logger.root.warning('Failed to parse chunk: $jsonStr error: $e');
            continue;
          }
        }
      }
    } catch (e) {
      throw await handleError(
          e, 'Claude', '$baseUrl/messages', jsonEncode(body));
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
        role: MessageRole.user,
        content:
            """Generate a concise title (max 20 characters) for the following conversation.
The title should summarize the main topic. Return only the title without any explanation or extra punctuation.

Conversation:
$conversationText""",
      );

      final response = await chatCompletion(CompletionRequest(
        model: "claude-3-5-haiku-20241022",
        messages: [prompt],
      ));

      return response.content?.trim() ?? "New Chat";
    } catch (e, trace) {
      Logger.root.severe('Claude gen title error: $e, trace: $trace');
      return "New Chat";
    }
  }

  @override
  Future<Map<String, dynamic>> checkToolCall(
    String model,
    CompletionRequest request,
    Map<String, List<Map<String, dynamic>>> toolsResponse,
  ) async {
    // Convert tools to Claude's format
    final tools = toolsResponse.entries
        .map((entry) {
          return entry.value.map((tool) {
            final parameters = tool['parameters'];
            if (parameters is! Map<String, dynamic>) {
              return {
                'name': tool['name'],
                'description': tool['description'],
                'input_schema': {
                  'type': 'object',
                  'properties': {},
                  'required': [],
                },
              };
            }

            return {
              'name': tool['name'],
              'description': tool['description'],
              'input_schema': {
                'type': 'object',
                'properties': parameters['properties'] ?? {},
                'required': parameters['required'] ?? [],
              },
            };
          }).toList();
        })
        .expand((x) => x)
        .toList();

    final body = {
      'model': ProviderManager.chatModelProvider.currentModel.name,
      'messages': request.messages,
      'tools': tools,
      'max_tokens': 4096,
    };

    try {
      final response = await _dio.post(
        '$baseUrl/messages',
        data: jsonEncode(body),
      );

      dynamic jsonData;
      if (response.data is ResponseBody) {
        final responseBody = response.data as ResponseBody;
        final responseStr = await utf8.decodeStream(responseBody.stream);
        jsonData = jsonDecode(responseStr);
      } else {
        jsonData = response.data;
      }

      // Check if response contains tool calls in the content array
      final contentBlocks = jsonData['content'] as List?;
      if (contentBlocks == null || contentBlocks.isEmpty) {
        return {
          'need_tool_call': false,
          'content': '',
        };
      }

      // Look for tool_calls in the response
      final toolUseBlocks = contentBlocks.where((block) =>
          block['type'] == 'tool_calls' || block['type'] == 'tool_use');

      if (toolUseBlocks.isEmpty) {
        // Get text content from the first text block
        final textBlock = contentBlocks.firstWhere(
          (block) => block['type'] == 'text',
          orElse: () => {'text': ''},
        );
        return {
          'need_tool_call': false,
          'content': textBlock['text'] ?? '',
        };
      }

      // Extract tool calls
      final toolCalls = toolUseBlocks
          .map((block) => {
                'id': block['id'],
                'name': block['name'],
                'arguments': block['input'],
              })
          .toList();

      // Get any accompanying text content
      final textBlock = contentBlocks.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => {'text': ''},
      );

      return {
        'need_tool_call': true,
        'content': textBlock['text'] ?? '',
        'tool_calls': toolCalls,
      };
    } catch (e) {
      throw await handleError(
          e, 'Claude', '$baseUrl/messages', jsonEncode(body));
    }
  }

  @override
  Future<List<String>> models() async {
    if (apiKey.isEmpty) {
      Logger.root.info('Claude API key not set, skipping model list retrieval');
      return [];
    }

    try {
      final response = await _dio.get("$baseUrl/models");

      final data = response.data;

      final models = (data['data'] as List)
          .map((m) => m['id'].toString())
          .where((id) => id.contains('claude'))
          .toList();

      return models;
    } catch (e, trace) {
      Logger.root.severe('Failed to get model list: $e, trace: $trace');
      // Return predefined model list as fallback
      return [];
    }
  }
}

List<Map<String, dynamic>> chatMessageToClaudeMessage(
    List<ChatMessage> messages) {
  return messages.map((message) {
    final List<Map<String, dynamic>> contentParts = [];

    // Add file content (if any)
    if (message.files != null) {
      for (final file in message.files!) {
        if (isImageFile(file.fileType)) {
          contentParts.add({
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': file.fileType,
              'data': file.fileContent,
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

    final json = {
      'role': message.role == MessageRole.user ? 'user' : 'assistant',
      'content': contentParts,
    };

    if (contentParts.length == 1 && message.files == null) {
      json['content'] = message.content ?? '';
    } else {
      json['content'] = contentParts;
    }

    return json;
  }).toList();
}

