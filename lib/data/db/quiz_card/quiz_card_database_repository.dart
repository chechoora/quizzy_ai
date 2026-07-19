import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/util/uid_generator.dart';

class QuizCardDataBaseRepository {
  final AppDatabase appDatabase;

  QuizCardDataBaseRepository(this.appDatabase);

  Future<List<QuizCardTableData>> fetchQuizCardList(int deckId) {
    return (appDatabase.select(appDatabase.quizCardTable)
          ..where(
            (table) {
              return table.deckId.isValue(deckId);
            },
          ))
        .get();
  }

  /// Watches all cards across every deck. Emits on any card insert/update/
  /// delete, used to trigger the iCloud auto-backup.
  Stream<List<QuizCardTableData>> watchAllCards() {
    return appDatabase.select(appDatabase.quizCardTable).watch();
  }

  Future<int> saveQuizCard({
    required String question,
    required String answer,
    required int deckId,
  }) async {
    final result = await appDatabase.into(appDatabase.quizCardTable).insert(
          QuizCardTableCompanion.insert(
            deckId: deckId,
            questionText: question,
            answerText: answer,
            isArchive: false,
            uid: Value(UidGenerator.next()),
          ),
        );
    return result;
  }

  /// Deletes the card. When [recordTombstone] is true (the default) and the
  /// card already has a [remoteId], a [SyncTombstoneTable] entry is written
  /// first so the delete can be propagated to the backend. Pull-side
  /// reconciliation passes `recordTombstone: false` since the remote is
  /// already the source of truth in that case.
  Future<bool> deleteQuizCard(int id, {bool recordTombstone = true}) async {
    return appDatabase.transaction(() async {
      if (recordTombstone) {
        final card = await (appDatabase.select(appDatabase.quizCardTable)
              ..where((table) => table.id.isValue(id)))
            .getSingleOrNull();
        final cardRemoteId = card?.remoteId;
        if (cardRemoteId != null) {
          await appDatabase.into(appDatabase.syncTombstoneTable).insert(
                SyncTombstoneTableCompanion.insert(
                  entityType: 'card',
                  remoteId: cardRemoteId,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
      final result = await (appDatabase.delete(appDatabase.quizCardTable)
            ..where(
              (table) => table.id.isValue(
                id,
              ),
            ))
          .go();
      return result >= 0;
    });
  }

  Future<bool> editQuizCard({
    required QuizCardItem currentCard,
    required QuizCardRequestItem request,
  }) async {
    final result = await (appDatabase.update(appDatabase.quizCardTable)
          ..where(
            (table) => table.id.isValue(
              currentCard.id,
            ),
          ))
        .write(
      QuizCardTableCompanion(
        questionText: Value(request.question),
        answerText: Value(request.answer),
        isDirty: const Value(true),
      ),
    );
    return result >= 0;
  }

  Future<List<int>> saveQuizCards(
      List<PlainCardModel> cards, int deckId) async {
    return appDatabase.transaction(
      () async {
        final result = <int>[];
        for (final card in cards) {
          final id = await appDatabase.into(appDatabase.quizCardTable).insert(
                QuizCardTableCompanion.insert(
                  deckId: deckId,
                  questionText: card.question,
                  answerText: card.answer,
                  isArchive: false,
                  uid: Value(UidGenerator.next()),
                ),
              );
          result.add(id);
        }
        return result;
      },
    );
  }

  /// The set of (non-null) card uids currently stored for [deckId].
  Future<Set<int>> fetchCardUids(int deckId) async {
    final rows = await (appDatabase.select(appDatabase.quizCardTable)
          ..where((table) => table.deckId.isValue(deckId)))
        .get();
    return rows
        .map((r) => r.uid)
        .whereType<int>()
        .toSet();
  }

  /// Inserts cards preserving their backup uid (used by iCloud restore).
  /// Falls back to a fresh uid when a card has none.
  Future<List<int>> saveCardsWithUid(
      List<PlainCardModel> cards, int deckId) async {
    return appDatabase.transaction(
      () async {
        final result = <int>[];
        for (final card in cards) {
          final id = await appDatabase.into(appDatabase.quizCardTable).insert(
                QuizCardTableCompanion.insert(
                  deckId: deckId,
                  questionText: card.question,
                  answerText: card.answer,
                  isArchive: false,
                  uid: Value(card.uid ?? UidGenerator.next()),
                ),
              );
          result.add(id);
        }
        return result;
      },
    );
  }

  /// Updates the text of the card identified by its backup [uid] within
  /// [deckId] (used by iCloud restore to reflect edits from another device).
  Future<bool> updateCardByUid(int deckId, PlainCardModel card) async {
    final uid = card.uid;
    if (uid == null) return false;
    final result = await (appDatabase.update(appDatabase.quizCardTable)
          ..where(
            (table) => table.deckId.isValue(deckId) & table.uid.isValue(uid),
          ))
        .write(
      QuizCardTableCompanion(
        questionText: Value(card.question),
        answerText: Value(card.answer),
      ),
    );
    return result > 0;
  }

  /// Local rows with unpushed changes (new inserts default to dirty).
  Future<List<QuizCardTableData>> fetchDirtyCards() async {
    return (appDatabase.select(appDatabase.quizCardTable)
          ..where((table) => table.isDirty.equals(true)))
        .get();
  }

  /// Local rows in [deckId] already linked to a remote card.
  Future<List<QuizCardTableData>> fetchSyncedCardsForDeck(int deckId) async {
    return (appDatabase.select(appDatabase.quizCardTable)
          ..where((table) =>
              table.deckId.isValue(deckId) & table.remoteId.isNotNull()))
        .get();
  }

  /// Returns the local row id of the card with the given [remoteId], or null.
  Future<int?> findCardIdByRemoteId(String remoteId) async {
    final row = await (appDatabase.select(appDatabase.quizCardTable)
          ..where((table) => table.remoteId.isValue(remoteId))
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  /// Marks a local card as pushed: links it to [remoteId] and clears the
  /// dirty flag.
  Future<void> markCardSynced(int id, String remoteId) async {
    await (appDatabase.update(appDatabase.quizCardTable)
          ..where((table) => table.id.isValue(id)))
        .write(
      QuizCardTableCompanion(
        remoteId: Value(remoteId),
        isDirty: const Value(false),
      ),
    );
  }

  /// Upserts a local card by [remoteId] (pull-side, remote wins): updates
  /// the matching local row's fields if found, otherwise inserts a new one.
  /// Returns the local row id.
  Future<int> upsertCardByRemoteId({
    required String remoteId,
    required int deckId,
    required String question,
    required String answer,
    required bool isArchive,
  }) async {
    final existingId = await findCardIdByRemoteId(remoteId);
    if (existingId != null) {
      await (appDatabase.update(appDatabase.quizCardTable)
            ..where((table) => table.id.isValue(existingId)))
          .write(
        QuizCardTableCompanion(
          questionText: Value(question),
          answerText: Value(answer),
          isArchive: Value(isArchive),
          isDirty: const Value(false),
        ),
      );
      return existingId;
    }
    return appDatabase.into(appDatabase.quizCardTable).insert(
          QuizCardTableCompanion.insert(
            deckId: deckId,
            questionText: question,
            answerText: answer,
            isArchive: isArchive,
            uid: Value(UidGenerator.next()),
            remoteId: Value(remoteId),
            isDirty: const Value(false),
          ),
        );
  }
}
