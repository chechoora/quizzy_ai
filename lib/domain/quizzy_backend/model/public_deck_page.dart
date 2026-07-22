import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_summary.dart';

class PublicDeckPage extends Equatable {
  final List<PublicDeckSummary> items;
  final String? nextCursor;
  final bool hasMore;

  const PublicDeckPage({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}
