import 'package:equatable/equatable.dart';

class DeckItem extends Equatable {
  final int id;
  final int? uid;
  final String title;
  final bool isArchive;

  /// quizzy-ai-pro backend id, or null if this deck has never been synced.
  final String? remoteId;

  /// True when this deck has local changes not yet pushed to the backend.
  final bool isDirty;

  const DeckItem({
    required this.id,
    required this.title,
    required this.isArchive,
    this.uid,
    this.remoteId,
    this.isDirty = false,
  });

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        isArchive,
        remoteId,
        isDirty,
      ];
}
