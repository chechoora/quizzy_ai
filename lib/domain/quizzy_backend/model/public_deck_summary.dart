import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_tag.dart';

class PublicDeckSummary extends Equatable {
  final String id;
  final String categoryId;
  final String title;
  final String? description;
  final List<PublicTag> tags;
  final num cardCount;

  const PublicDeckSummary({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    required this.tags,
    required this.cardCount,
  });

  @override
  List<Object?> get props =>
      [id, categoryId, title, description, tags, cardCount];
}
