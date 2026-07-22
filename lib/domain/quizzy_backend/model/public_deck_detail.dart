import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_tag.dart';

class PublicDeckDetail extends Equatable {
  final String id;
  final String categoryId;
  final String title;
  final String? description;
  final List<PublicTag> tags;
  final num cardCount;
  final List<PublicCard> cards;

  const PublicDeckDetail({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    required this.tags,
    required this.cardCount,
    required this.cards,
  });

  @override
  List<Object?> get props =>
      [id, categoryId, title, description, tags, cardCount, cards];
}
