import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/premium_info.dart';

class QuizCardItem extends Equatable {
  final int id;
  final int deckId;
  final String questionText;
  final String answerText;
  final bool isArchive;

  const QuizCardItem({
    required this.id,
    required this.deckId,
    required this.questionText,
    required this.answerText,
    required this.isArchive,
  });

  @override
  List<Object?> get props => [
        id,
        deckId,
        questionText,
        answerText,
        isArchive,
      ];
}