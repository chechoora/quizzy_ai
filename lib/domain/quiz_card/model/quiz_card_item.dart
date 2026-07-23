import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

class QuizCardItem extends Equatable {
  final int id;
  final int? uid;
  final int deckId;
  final String questionText;
  final String answerText;
  final bool isArchive;

  /// quizzy-ai-pro backend id, or null if this card has never been synced.
  final String? remoteId;

  /// True when this card has local changes not yet pushed to the backend.
  final bool isDirty;

  /// quizzy-ai-pro backend play stats, or null on the local-only quizzy
  /// flavor and for cards never synced.
  final ItemStats? stats;

  const QuizCardItem({
    required this.id,
    required this.deckId,
    required this.questionText,
    required this.answerText,
    required this.isArchive,
    this.uid,
    this.remoteId,
    this.isDirty = false,
    this.stats,
  });

  @override
  List<Object?> get props => [
        id,
        uid,
        deckId,
        questionText,
        answerText,
        isArchive,
        remoteId,
        isDirty,
        stats,
      ];
}
