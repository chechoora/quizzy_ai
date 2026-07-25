import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';

/// Outcome of a `PATCH /decks/{id}/cards/batch` call.
class BatchUpdateCardsResult extends Equatable {
  final List<RemoteCard> updated;

  /// Ids from the request that don't belong to this deck.
  final List<String> notFound;

  const BatchUpdateCardsResult({
    required this.updated,
    required this.notFound,
  });

  @override
  List<Object?> get props => [updated, notFound];
}
