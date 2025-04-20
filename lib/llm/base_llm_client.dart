import 'model.dart';
import 'utils.dart';
import 'package:http/http.dart' as http;

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
    if (e is http.ClientException) {
      return LLMException(
        name: name,
        endpoint: endpoint,
        requestBody: bodyStr,
        originalError: e,
      );
    } else if (e is Exception && e.toString().contains('HTTP')) {
      // Handle HTTP errors (like "HTTP 400: Bad Request")
      final errorMsg = e.toString();
      final statusCodeMatch = RegExp(r'HTTP (\d+)').firstMatch(errorMsg);
      final statusCode = statusCodeMatch != null
          ? int.tryParse(statusCodeMatch.group(1) ?? '')
          : null;

      return LLMException(
        name: name,
        endpoint: endpoint,
        requestBody: bodyStr,
        statusCode: statusCode,
        responseData: errorMsg,
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