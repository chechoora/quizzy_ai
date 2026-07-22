import 'package:equatable/equatable.dart';

class PublicCategory extends Equatable {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final num deckCount;

  const PublicCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    required this.deckCount,
  });

  @override
  List<Object?> get props => [id, slug, name, description, deckCount];
}
