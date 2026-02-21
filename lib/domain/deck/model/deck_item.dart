import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/premium_info.dart';

class DeckItem extends Equatable {
  final int id;
  final String title;
  final bool isArchive;

  const DeckItem({
    required this.id,
    required this.title,
    required this.isArchive,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        isArchive,
      ];
}
