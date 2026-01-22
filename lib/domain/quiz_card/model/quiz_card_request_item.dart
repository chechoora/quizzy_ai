class QuizCardRequestItem {
  const QuizCardRequestItem({
    required String question,
    required String answer,
  })  : _question = question,
        _answer = answer;

  final String _question;
  final String _answer;

  String get question => _question.trim();

  String get answer => _answer.trim();
}
