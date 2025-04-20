import 'dart:convert';
import 'package:logging/logging.dart';
import 'base_llm_client.dart';
import 'model.dart' as llm_model;
import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import 'package:qubase_mcp/utils/file_content.dart';

class GeminiClient extends BaseLLMClient {
  final _logger = Logger('GeminiClient');
  final String apiKey;
  final String baseUrl;
  final Map<String, genai.GenerativeModel> _models = {};

  GeminiClient({
    required this.apiKey,
    String? baseUrl,
  }) : baseUrl = (baseUrl == null || baseUrl.isEmpty)
            ? 'https://generativelanguage.googleapis.com/v1'
            : baseUrl;

  genai.GenerativeModel _getModel(String modelName) {
    return _models.putIfAbsent(
      modelName,
      () => genai.GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      ),
    );
  }

  genai.Content _convertMessage(llm_model.ChatMessage message) {
    // Add more detailed logging
    if (message.content?.trim().isEmpty ?? true) {
      _logger.severe('Empty message content detected. Message ID: ${message.messageId}, Role: ${message.role}');
      throw Exception('Message content cannot be empty');
    }

    final parts = <genai.Part>[];
    
    // Add text part
    parts.add(genai.TextPart(message.content!));

    // Add image parts if present
    if (message.files != null) {
      for (final file in message.files!) {
        if (isImageFile(file.fileType)) {
          parts.add(genai.DataPart('image/jpeg', base64.decode(file.fileContent)));
        }
      }
    }

    return genai.Content(message.role == llm_model.MessageRole.user ? 'user' : 'assistant', parts);
  }

  @override
  Future<llm_model.LLMResponse> chatCompletion(llm_model.CompletionRequest request) async {
    try {
      final modelName = request.model.isEmpty ? 'gemini-2.0-flash' : request.model;
      
      // Validate messages
      if (request.messages.isEmpty) {
        throw Exception('No messages provided');
      }

      // Initialize chat with proper configuration
      final chat = _getModel(modelName).startChat(
        generationConfig: genai.GenerationConfig(
          temperature: request.modelSetting?.temperature ?? 0.7,
          topP: request.modelSetting?.topP ?? 1,
          maxOutputTokens: request.modelSetting?.maxTokens,
        ),
        history: request.messages.length > 1 
            ? request.messages.sublist(0, request.messages.length - 1)
                .map((m) => _convertMessage(m))
                .toList() 
            : [],
      );

      // Send the last message
      final response = await chat.sendMessage(
        _convertMessage(request.messages.last)
      );

      if (response.text == null) {
        throw Exception('No response from Gemini API');
      }

      // Handle function calls if present
      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        if (candidate.content.parts.isNotEmpty && 
            candidate.content.parts.first is genai.FunctionCall) {
          final functionCall = candidate.content.parts.first as genai.FunctionCall;
          return llm_model.LLMResponse(
            content: response.text,
            toolCalls: [
              llm_model.ToolCall(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: 'function',
                function: llm_model.FunctionCall(
                  name: functionCall.name,
                  arguments: jsonEncode(functionCall.args),
                ),
              ),
            ],
          );
        }
      }

      return llm_model.LLMResponse(content: response.text);
    } on genai.GenerativeAIException catch (e) {
      _logger.severe('Gemini API error: ${e.message}');
      throw Exception('Gemini API error: ${e.message}');
    } catch (e) {
      _logger.severe('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Stream<llm_model.LLMResponse> chatStreamCompletion(llm_model.CompletionRequest request) async* {
    try {
      final modelName = request.model.isEmpty ? 'gemini-2.0-flash' : request.model;
      final chat = _getModel(modelName).startChat(
        generationConfig: genai.GenerationConfig(
          temperature: request.modelSetting?.temperature ?? 0.7,
          topP: request.modelSetting?.topP ?? 1,
          maxOutputTokens: request.modelSetting?.maxTokens,
        ),
      );

      // Send each message in sequence to maintain conversation history
      for (int i = 0; i < request.messages.length - 1; i++) {
        await chat.sendMessage(_convertMessage(request.messages[i]));
      }

      // Stream the response for the last message
      final responseStream = chat.sendMessageStream(
        _convertMessage(request.messages.last)
      );

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield llm_model.LLMResponse(content: chunk.text);
        }
      }
    } on genai.GenerativeAIException catch (e) {
      _logger.severe('Gemini API error: ${e.message}');
      throw Exception('Gemini API error: ${e.message}');
    } catch (e) {
      _logger.severe('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<String> genTitle(List<llm_model.ChatMessage> messages) async {
    final conversationText = messages.map((msg) {
      final role = msg.role == llm_model.MessageRole.user ? "Human" : "Assistant";
      return "$role: ${msg.content}";
    }).join("\n");

    try {
      final prompt = llm_model.ChatMessage(
        role: llm_model.MessageRole.user,
        content:
            """Generate a concise title (max 20 characters) for the following conversation.
The title should summarize the main topic. Return only the title without any explanation or extra punctuation.

Conversation:
$conversationText""",
      );

      final response = await chatCompletion(llm_model.CompletionRequest(
        model: "gemini-pro",
        messages: [prompt],
      ));

      return response.content?.trim() ?? "New Chat";
    } catch (e, trace) {
      _logger.severe('Gemini gen title error: $e, trace: $trace');
      return "New Chat";
    }
  }

  @override
  Future<Map<String, dynamic>> checkToolCall(
    String model,
    llm_model.CompletionRequest request,
    Map<String, List<Map<String, dynamic>>> toolsResponse,
  ) async {
    try {
      final response = await chatCompletion(request);
      
      if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
        return {
          'need_tool_call': true,
          'content': response.content ?? '',
          'tool_calls': response.toolCalls!.map((tc) => {
            'id': tc.id,
            'name': tc.function.name,
            'arguments': tc.function.arguments,
          }).toList(),
        };
      }

      return {
        'need_tool_call': false,
        'content': response.content ?? '',
      };
    } catch (e) {
      _logger.severe('Error checking tool call: $e');
      throw Exception('Failed to check tool call: $e');
    }
  }

  @override
  Future<List<String>> models() async {
    if (apiKey.isEmpty) {
      throw Exception('API key is not set');
    }
    return [
      'gemini-2.0-flash-001',
      'gemini-2.0-flash',
    ];
  }
} 