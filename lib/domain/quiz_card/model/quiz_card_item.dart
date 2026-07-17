import 'package:equatable/equatable.dart';

class QuizCardItem extends Equatable {
  final int id;
  final int? uid;
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
    this.uid,
  });

  @override
  List<Object?> get props => [
        id,
        uid,
        deckId,
        questionText,
        answerText,
        isArchive,
      ];
}
