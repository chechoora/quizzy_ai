class GeminiResponse {
  final List<Candidate>? candidates;
  final PromptFeedback? promptFeedback;

  GeminiResponse({
    this.candidates,
    this.promptFeedback,
  });

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    return GeminiResponse(
      candidates: (json['candidates'] as List<dynamic>?)
          ?.map((c) => Candidate.fromJson(c as Map<String, dynamic>))
          .toList(),
      promptFeedback: json['promptFeedback'] != null
          ? PromptFeedback.fromJson(json['promptFeedback'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Candidate {
  final Content? content;
  final String? finishReason;
  final int? index;
  final List<SafetyRating>? safetyRatings;

  Candidate({
    this.content,
    this.finishReason,
    this.index,
    this.safetyRatings,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      content: json['content'] != null
          ? Content.fromJson(json['content'] as Map<String, dynamic>)
          : null,
      finishReason: json['finishReason'] as String?,
      index: json['index'] as int?,
      safetyRatings: (json['safetyRatings'] as List<dynamic>?)
          ?.map((s) => SafetyRating.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Content {
  final List<Part>? parts;
  final String? role;

  Content({
    this.parts,
    this.role,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      parts: (json['parts'] as List<dynamic>?)
          ?.map((p) => Part.fromJson(p as Map<String, dynamic>))
          .toList(),
      role: json['role'] as String?,
    );
  }
}

class Part {
  final String? text;

  Part({this.text});

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      text: json['text'] as String?,
    );
  }
}

class SafetyRating {
  final String? category;
  final String? probability;

  SafetyRating({
    this.category,
    this.probability,
  });

  factory SafetyRating.fromJson(Map<String, dynamic> json) {
    return SafetyRating(
      category: json['category'] as String?,
      probability: json['probability'] as String?,
    );
  }
}

class PromptFeedback {
  final List<SafetyRating>? safetyRatings;

  PromptFeedback({this.safetyRatings});

  factory PromptFeedback.fromJson(Map<String, dynamic> json) {
    return PromptFeedback(
      safetyRatings: (json['safetyRatings'] as List<dynamic>?)
          ?.map((s) => SafetyRating.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}