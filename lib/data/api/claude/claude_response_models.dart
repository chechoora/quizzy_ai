class ClaudeResponse {
  final String? id;
  final String? type;
  final String? role;
  final List<Content>? content;
  final String? model;
  final String? stopReason;
  final String? stopSequence;
  final Usage? usage;

  ClaudeResponse({
    this.id,
    this.type,
    this.role,
    this.content,
    this.model,
    this.stopReason,
    this.stopSequence,
    this.usage,
  });

  factory ClaudeResponse.fromJson(Map<String, dynamic> json) {
    return ClaudeResponse(
      id: json['id'] as String?,
      type: json['type'] as String?,
      role: json['role'] as String?,
      content: (json['content'] as List<dynamic>?)
          ?.map((c) => Content.fromJson(c as Map<String, dynamic>))
          .toList(),
      model: json['model'] as String?,
      stopReason: json['stop_reason'] as String?,
      stopSequence: json['stop_sequence'] as String?,
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Content {
  final String? type;
  final String? text;
  final String? id;
  final String? name;
  final Map<String, dynamic>? input;

  Content({
    this.type,
    this.text,
    this.id,
    this.name,
    this.input,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      type: json['type'] as String?,
      text: json['text'] as String?,
      id: json['id'] as String?,
      name: json['name'] as String?,
      input: json['input'] as Map<String, dynamic>?,
    );
  }
}

class Usage {
  final int? inputTokens;
  final int? outputTokens;

  Usage({
    this.inputTokens,
    this.outputTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      inputTokens: json['input_tokens'] as int?,
      outputTokens: json['output_tokens'] as int?,
    );
  }
}