import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

class DeckItem extends Equatable {
  final int id;
  final int? uid;
  final String title;
  final bool isArchive;

  /// quizzy-ai-pro backend id, or null if this deck has never been synced.
  final String? remoteId;

  /// True when this deck has local changes not yet pushed to the backend.
  final bool isDirty;

  /// The remote deck's `updatedAt` as of the last successful card pull for
  /// it. Null for local-only rows and for synced rows never card-pulled yet.
  final DateTime? remoteUpdatedAt;

  /// quizzy-ai-pro backend play stats, or null on the local-only quizzy
  /// flavor and for decks never synced.
  final ItemStats? stats;

  const DeckItem({
    required this.id,
    required this.title,
    required this.isArchive,
    this.uid,
    this.remoteId,
    this.isDirty = false,
    this.remoteUpdatedAt,
    this.stats,
  });

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        isArchive,
        remoteId,
        isDirty,
        remoteUpdatedAt,
        stats,
      ];
}
