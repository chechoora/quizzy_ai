import 'package:equatable/equatable.dart';

/// Outcome of a `DELETE /decks/{id}/cards/batch` call.
class BatchDeleteCardsResult extends Equatable {
  final List<String> deleted;

  /// Ids from the request that don't belong to this deck.
  final List<String> notFound;

  const BatchDeleteCardsResult({
    required this.deleted,
    required this.notFound,
  });

  @override
  List<Object?> get props => [deleted, notFound];
}
