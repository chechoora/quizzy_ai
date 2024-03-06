import 'package:equatable/equatable.dart';

class QuizResults {
  QuizResults({required this.quizMatchList});

  final List<QuizAnswerMatch> quizMatchList;
}

class QuizAnswerMatch extends Equatable {
  const QuizAnswerMatch({
    required this.cardId,
    required this.question,
    required this.correctAnswer,
    required this.yourAnswer,
    required this.ratio,
  });

  final int cardId;
  final String question;
  final String correctAnswer;
  final String yourAnswer;
  final double ratio;

  @override
  List<Object?> get props => [
        cardId,
        question,
        correctAnswer,
        yourAnswer,
        ratio,
      ];
}
