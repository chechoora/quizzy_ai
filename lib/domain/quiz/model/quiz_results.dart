import 'package:equatable/equatable.dart';

class QuizResults extends Equatable {
  const QuizResults({
    required this.quizMatchList,
  });

  final List<QuizAnswerMatch> quizMatchList;

  @override
  List<Object?> get props => quizMatchList;
}

class QuizAnswerMatch extends Equatable {
  const QuizAnswerMatch({
    required this.cardId,
    required this.question,
    required this.correctAnswer,
    required this.yourAnswer,
    required this.ratio,
    this.explanation,
  });

  final int cardId;
  final String question;
  final String correctAnswer;
  final String yourAnswer;
  final double ratio;
  final String? explanation;

  @override
  List<Object?> get props => [
        cardId,
        question,
        correctAnswer,
        yourAnswer,
        ratio,
      ];
}
