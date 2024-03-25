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

class QuizCardItemWithPremium extends QuizCardItem with PremiumInfo {
  QuizCardItemWithPremium({
    required super.id,
    required super.deckId,
    required super.questionText,
    required super.answerText,
    required super.isArchive,
    required bool isLocked,
  }) {
    isObjectLocked = isLocked;
  }

  factory QuizCardItemWithPremium.fromQuizCard({
    required QuizCardItem quizCardItem,
    required bool isLocked,
  }) {
    return QuizCardItemWithPremium(
      id: quizCardItem.id,
      deckId: quizCardItem.deckId,
      questionText: quizCardItem.questionText,
      answerText: quizCardItem.answerText,
      isArchive: quizCardItem.isArchive,
      isLocked: isLocked,
    );
  }

  @override
  List<Object?> get props => super.props..add(isObjectLocked);
}
