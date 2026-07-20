import 'package:equatable/equatable.dart';

class AnswerCheckResult extends Equatable {
  final bool isCorrect;
  final String feedback;
  final double confidence;
  final List<String> suggestions;

  const AnswerCheckResult({
    required this.isCorrect,
    required this.feedback,
    required this.confidence,
    required this.suggestions,
  });

  @override
  List<Object?> get props => [isCorrect, feedback, confidence, suggestions];
}
