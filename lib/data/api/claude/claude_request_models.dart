class ClaudeRequest {
  final String model;
  final List<Message> messages;
  final int maxTokens;
  final double? temperature;
  final double? topP;
  final List<String>? stopSequences;
  final Map<String, dynamic>? metadata;
  final String? system;
  final List<Tool>? tools;
  final Map<String, dynamic>? toolChoice;

  ClaudeRequest({
    required this.model,
    required this.messages,
    required this.maxTokens,
    this.temperature,
    this.topP,
    this.stopSequences,
    this.metadata,
    this.system,
    this.tools,
    this.toolChoice,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'max_tokens': maxTokens,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (stopSequences != null) 'stop_sequences': stopSequences,
      if (metadata != null) 'metadata': metadata,
      if (system != null) 'system': system,
      if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
      if (toolChoice != null) 'tool_choice': toolChoice,
    };
  }
}

class Tool {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;

  Tool({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'input_schema': inputSchema,
    };
  }
}

class Message {
  final String role;
  final dynamic content; // Can be String or List<ContentBlock>

  Message({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}