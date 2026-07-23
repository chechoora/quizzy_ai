import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

class RemoteDeck extends Equatable {
  final String id;
  final String userId;
  final String title;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ItemStats? stats;

  const RemoteDeck({
    required this.id,
    required this.userId,
    required this.title,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        isArchived,
        createdAt,
        updatedAt,
        stats,
      ];
}
