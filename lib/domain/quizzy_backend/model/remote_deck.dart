import 'package:equatable/equatable.dart';

class RemoteDeck extends Equatable {
  final String id;
  final String userId;
  final String title;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RemoteDeck({
    required this.id,
    required this.userId,
    required this.title,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        isArchived,
        createdAt,
        updatedAt,
      ];
}
