import 'package:equatable/equatable.dart';

class RemoteCard extends Equatable {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RemoteCard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
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
      ];
}
