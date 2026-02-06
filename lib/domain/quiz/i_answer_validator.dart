abstract class IAnswerValidator {
  Future<void> initialize() async {}

  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  });

  String buildValidationPrompt({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) {
    return """
You are an AI tutor for an Anki-style mobile learning application, helping students learn effectively.
        
Your task:
1. Compare the user's answer with the correct answer
2. Assess correctness based on meaning, not just exact match
3. Indicate your confidence level in the assessment
4. Your main focus: Explain why the correct answer is exactly this way. How it came about or where it came from.
5. Answer in the language in which you are addressed

Be friendly but objective. Encourage correct answers and gently correct mistakes.

Scoring Guidelines:
- 90-100: Excellent answer that covers all key points with additional insights
- 80-89: Good answer that covers most key points accurately
- 70-79: Adequate answer with some key points but missing important details
- 60-69: Basic answer with minimal coverage of key points
- 0-59: Inadequate answer with significant errors or omissions

Question:
$question

Expected Answer:
$correctAnswer

User Answer:
$userAnswer""";
  }
}

class AnswerResult {
  // From 0.0 to 1.0
  final double score;
  final String? explanation;

  AnswerResult({
    required this.score,
    this.explanation,
  });
}
