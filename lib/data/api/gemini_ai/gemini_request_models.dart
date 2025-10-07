class GeminiRequest {
  final List<Content> contents;
  final GenerationConfig? generationConfig;
  final List<SafetySetting>? safetySettings;

  GeminiRequest({
    required this.contents,
    this.generationConfig,
    this.safetySettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'contents': contents.map((c) => c.toJson()).toList(),
      if (generationConfig != null) 'generationConfig': generationConfig!.toJson(),
      if (safetySettings != null) 'safetySettings': safetySettings!.map((s) => s.toJson()).toList(),
    };
  }
}

class Content {
  final List<Part> parts;
  final String? role;

  Content({
    required this.parts,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'parts': parts.map((p) => p.toJson()).toList(),
      if (role != null) 'role': role,
    };
  }
}

class Part {
  final String text;

  Part({required this.text});

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}

class GenerationConfig {
  final double? temperature;
  final int? maxOutputTokens;
  final double? topP;
  final int? topK;
  final Map<String, dynamic>? responseSchema;
  final String? responseMimeType;

  GenerationConfig({
    this.temperature,
    this.maxOutputTokens,
    this.topP,
    this.topK,
    this.responseSchema,
    this.responseMimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      if (temperature != null) 'temperature': temperature,
      if (maxOutputTokens != null) 'maxOutputTokens': maxOutputTokens,
      if (topP != null) 'topP': topP,
      if (topK != null) 'topK': topK,
      if (responseSchema != null) 'responseSchema': responseSchema,
      if (responseMimeType != null) 'responseMimeType': responseMimeType,
    };
  }
}

class SafetySetting {
  final String category;
  final String threshold;

  SafetySetting({
    required this.category,
    required this.threshold,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'threshold': threshold,
    };
  }
}