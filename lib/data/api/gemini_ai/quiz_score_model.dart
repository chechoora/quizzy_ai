class QuizScore {
  final int score;
  final String explanation;
  final List<String> correctPoints;
  final List<String> missingPoints;

  QuizScore({
    required this.score,
    required this.explanation,
    required this.correctPoints,
    required this.missingPoints,
  });

  factory QuizScore.fromJson(Map<String, dynamic> json) {
    return QuizScore(
      score: json['score'] as int,
      explanation: json['explanation'] as String,
      correctPoints: (json['correctPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      missingPoints: (json['missingPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'explanation': explanation,
      'correctPoints': correctPoints,
      'missingPoints': missingPoints,
    };
  }
}