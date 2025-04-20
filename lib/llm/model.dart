import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:qubase_mcp/dao/chat_message.dart';

// Message role enumeration
enum MessageRole {
  system,
  user,
  assistant,
  function,
  tool,
  error,
  loading;

  String get value => name;
}

class File {
  final String name;
  final int size;
  final String? path;
  final String fileType;
  final String fileContent;

  File({
    required this.name,
    required this.path,
    required this.size,
    required this.fileType,
    this.fileContent = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'fileType': fileType,
      'fileContent': fileContent,
    };
  }

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      name: json['name'],
      path: json['path'],
      size: json['size'],
      fileType: json['fileType'],
      fileContent: json['fileContent'],
    );
  }
}

// Message structure
class ChatMessage {
  final String messageId;
  final String parentMessageId;
  final MessageRole role;
  final String? content;
  final String? name;
  final String? mcpServerName;
  final String? toolCallId;
  final List<Map<String, dynamic>>? toolCalls;
  final List<File>? files;
  List<String>? brotherMessageIds;
  List<String>? childMessageIds;

  ChatMessage({
    required this.role,
    String? content,
    this.name,
    this.mcpServerName,
    this.toolCallId,
    this.toolCalls,
    this.files,
    this.brotherMessageIds,
    this.childMessageIds,
    String? messageId,
    String? parentMessageId,
  })  : messageId = messageId ?? Uuid().v4(),
        parentMessageId = parentMessageId ?? '',
        content = content,
        // Add validation for user and assistant messages
        assert((role == MessageRole.user || role == MessageRole.assistant) && 
            (content == null || content.trim().isEmpty) == false, 'Content is required for user and assistant messages');

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'role': role.value,
      if (content != null) 'content': content,
    };

    if (role == MessageRole.tool && name != null && toolCallId != null) {
      json['name'] = name!;
      json['tool_call_id'] = toolCallId!;
    }

    if (toolCalls != null) {
      json['tool_calls'] = toolCalls;
    }

    if (mcpServerName != null) {
      json['mcpServerName'] = mcpServerName!;
    }

    if (files != null) {
      json['files'] = files?.map((file) => file.toJson()).toList();
    }

    json['messageId'] = messageId;
    json['parentMessageId'] = parentMessageId;
    if (brotherMessageIds != null) {
      json['brotherMessageIds'] = brotherMessageIds;
    }

    if (childMessageIds != null) {
      json['childMessageIds'] = childMessageIds;
    }

    return json;
  }

  factory ChatMessage.fromDb(DbChatMessage dbChatMessage) {
    return ChatMessage.fromJson(dbChatMessage.messageId,
        dbChatMessage.parentMessageId, jsonDecode(dbChatMessage.body));
  }

  factory ChatMessage.fromJson(
      String messageId, String parentMessageId, Map<String, dynamic> json) {
    // Handle type conversion for toolCalls
    List<Map<String, dynamic>>? toolCalls;
    if (json['tool_calls'] != null) {
      toolCalls = (json['tool_calls'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    List<File>? files;
    if (json['files'] != null) {
      files = (json['files'] as List)
          .map((item) => File.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return ChatMessage(
      role: MessageRole.values.firstWhere((e) => e.value == json['role']),
      content: json['content'],
      name: json['name'],
      mcpServerName: json['mcpServerName'],
      toolCallId: json['tool_call_id'],
      toolCalls: toolCalls,
      files: files,
      messageId: messageId,
      parentMessageId: parentMessageId,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  ChatMessage copyWith({
    String? messageId,
    String? parentMessageId,
    String? content,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      role: role,
      content: content ?? this.content,
      name: name,
      mcpServerName: mcpServerName,
      toolCallId: toolCallId,
      toolCalls: toolCalls,
      files: files,
    );
  }
}

// Add tool call data structure
class ToolCall {
  final String id;
  final String type;
  final FunctionCall function;

  ToolCall({
    required this.id,
    required this.type,
    required this.function,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'function': function.toJson(),
      };
}

class FunctionCall {
  final String name;
  final String arguments;

  FunctionCall({
    required this.name,
    required this.arguments,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'arguments': arguments,
      };

  // Parse arguments to Map
  Map<String, dynamic> get parsedArguments =>
      json.decode(arguments) as Map<String, dynamic>;
}

class LLMResponse {
  final String? content;
  final List<ToolCall>? toolCalls;
  final bool needToolCall;

  LLMResponse({
    this.content,
    this.toolCalls,
  }) : needToolCall = toolCalls != null && toolCalls.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'content': content,
        'tool_calls': toolCalls?.map((t) => t.toJson()).toList(),
        'need_tool_call': needToolCall,
      };
}

class Model {
  final String name;
  final String label;
  final String providerId;
  final String icon;
  final String providerName;

  Model({
    required this.name,
    required this.label,
    required this.providerId,
    required this.icon,
    required this.providerName,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      name: json['name'],
      label: json['label'],
      providerId: json['provider'],
      icon: json['icon'],
      providerName: json['providerName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'label': label,
        'provider': providerId,
        'icon': icon,
        'providerName': providerName,
      };

  @override
  String toString() => jsonEncode(toJson());
}

class CompletionRequest {
  final String model;
  final List<ChatMessage> messages;
  final ModelSetting? modelSetting;
  final List<Map<String, dynamic>>? tools;

  CompletionRequest({
    required this.model,
    required this.messages,
    this.modelSetting,
    this.tools,
  });
}

class ModelSetting {
  final double temperature;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;
  final int? maxTokens;

  ModelSetting({
    this.temperature = 0.7,
    this.topP = 1.0,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.maxTokens,
  });
}

