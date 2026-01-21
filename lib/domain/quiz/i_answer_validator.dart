abstract class IAnswerValidator {
  Future<void> initialize() async {}

  Future<double> validateAnswer({
    required String correctAnswer,
    required String userAnswer,
  });

  String buildValidationPrompt({
    required String correctAnswer,
    required String userAnswer,
  }) {
    return """
You are a quiz scoring assistant. Your job is to compare a user's answer with the expected answer and provide a detailed evaluation.

Scoring Guidelines:
- 90-100: Excellent answer that covers all key points with additional insights
- 80-89: Good answer that covers most key points accurately
- 70-79: Adequate answer with some key points but missing important details
- 60-69: Basic answer with minimal coverage of key points
- 0-59: Inadequate answer with significant errors or omissions

Be fair but thorough in your evaluation. Consider both factual accuracy and completeness.

Expected Answer:
$correctAnswer

User Answer:
$userAnswer""";
  }
}
