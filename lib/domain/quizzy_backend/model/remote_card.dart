import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

class RemoteCard extends Equatable {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ItemStats? stats;

  const RemoteCard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
  });

  @override
  List<Object?> get props => [
        id,
        deckId,
        question,
        answer,
        isArchived,
        createdAt,
        updatedAt,
        stats,
      ];
}
