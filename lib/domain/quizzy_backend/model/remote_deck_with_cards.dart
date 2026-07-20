import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';

class RemoteDeckWithCards extends Equatable {
  final String id;
  final String userId;
  final String title;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RemoteCard> cards;

  const RemoteDeckWithCards({
    required this.id,
    required this.userId,
    required this.title,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.cards,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        isArchived,
        createdAt,
        updatedAt,
        cards,
      ];
}
