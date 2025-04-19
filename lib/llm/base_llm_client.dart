import 'model.dart';
import 'utils.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

abstract class BaseLLMClient {
  Future<LLMResponse> chatCompletion(CompletionRequest request);

  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request);

  Future<Map<String, dynamic>> checkToolCall(
    String model,
    CompletionRequest request,
    Map<String, List<Map<String, dynamic>>> toolsResponse,
  ) async {
    final openaiTools = convertToOpenAITools(toolsResponse);

    try {
      final response = await chatCompletion(
        CompletionRequest(
          model: model,
          messages: request.messages,
          tools: openaiTools,
        ),
      );

      if (!response.needToolCall) {
        return {
          'need_tool_call': false,
          'content': response.content,
        };
      }

      // Return tool call details
      return {
        'need_tool_call': true,
        'content': response.content,
        'tool_calls': response.toolCalls
            ?.map((call) => {
                  'id': call.id,
                  'name': call.function.name,
                  'arguments': call.function.parsedArguments,
                })
            .toList(),
      };
    } catch (e) {
      rethrow; // Re-throw the exception for outer handling
    }
  }

  Future<LLMException> handleError(
      dynamic e, String name, String endpoint, String bodyStr) async {
    if (e is DioException && e.response != null) {
      // Get response content
      var responseData = e.response?.data;
      if (responseData is ResponseBody) {
        responseData = await utf8.decodeStream(responseData.stream);
      }

      return LLMException(
        name: name,
        endpoint: endpoint,
        requestBody: bodyStr,
        statusCode: e.response?.statusCode,
        responseData: responseData,
        originalError: e,
      );
    } else {
      return LLMException(
        name: name,
        endpoint: endpoint,
        requestBody: bodyStr,
        originalError: e,
      );
    }
  }

  Future<String> genTitle(List<ChatMessage> messages);

  Future<List<String>> models();
}

class LLMException implements Exception {
  final String name;
  final String endpoint;
  final String requestBody;
  final int? statusCode;
  final dynamic responseData;
  final dynamic originalError;

  LLMException({
    required this.name,
    required this.endpoint,
    required this.requestBody,
    this.statusCode,
    this.responseData,
    this.originalError,
  });

  @override
  String toString() {
    return '''
$name API call failed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Endpoint: $endpoint
${statusCode != null ? 'Status code: $statusCode\n' : ''}Request body: $requestBody
${responseData != null ? 'Response data: $responseData\n' : ''}Error message: $originalError
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''';
  }
}
