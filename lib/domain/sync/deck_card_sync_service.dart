import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/cards_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/decks_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/new_remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/data/db/sync/sync_tombstone_repository.dart';
import 'package:poc_ai_quiz/domain/sync/model/sync_result.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Orchestrates two-way sync between the local Drift-backed deck/card
/// repositories and the quizzy-ai-pro backend. Conflict resolution is
/// remote-wins: [pullRemoteChanges] simply overwrites local fields with
/// remote values for anything already linked to a remote id. Push and pull
/// each continue past a single failing deck/card (logged, counted in
/// [SyncPushResult.failures]/[SyncPullResult.failures]) rather than aborting
/// the whole cycle, except that a failing [DecksRepository.listDecks] call
/// aborts the pull entirely since nothing else can proceed safely without it.
class DeckCardSyncService {
  DeckCardSyncService({
    required this.deckRepository,
    required this.quizCardRepository,
    required this.decksRepository,
    required this.cardsRepository,
    required this.tombstoneRepository,
    required this.logger,
  });

  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final DecksRepository decksRepository;
  final CardsRepository cardsRepository;
  final SyncTombstoneRepository tombstoneRepository;
  final Logger logger;

  Future<SyncRunResult> runFullSync() async {
    logger.d('runFullSync: starting');
    final push = await pushLocalChanges();
    final pull = await pullRemoteChanges();
    logger.i('runFullSync: complete, push=$push, pull=$pull');
    return SyncRunResult(push: push, pull: pull);
  }

  Future<SyncPushResult> pushLocalChanges() async {
    logger.d('pushLocalChanges: starting');
    var result = const SyncPushResult();

    result = await _pushDeckTombstones(result);
    result = await _pushCardTombstones(result);
    result = await _pushDirtyDecks(result);
    result = await _pushDirtyCards(result);

    logger.i('pushLocalChanges: complete, $result');
    return result;
  }

  Future<SyncPushResult> _pushDeckTombstones(SyncPushResult result) async {
    final tombstones = await tombstoneRepository.fetchTombstones('deck');
    logger.d('_pushDeckTombstones: ${tombstones.length} pending');
    var purged = result.deckTombstonesPurged;
    var failures = result.failures;
    for (final tombstone in tombstones) {
      try {
        await decksRepository.deleteDeck(tombstone.remoteId);
        await tombstoneRepository.deleteTombstone(tombstone.id);
        purged++;
      } catch (e, s) {
        if (e is QuizzyBackendException && e.statusCode == 404) {
          logger.w('_pushDeckTombstones: remote already gone, purging '
              'tombstone id=${tombstone.id}');
          await tombstoneRepository.deleteTombstone(tombstone.id);
          purged++;
        } else {
          logger.e('_pushDeckTombstones: failed to delete remote deck '
              'id=${tombstone.remoteId}, leaving for retry',
              ex: e, stacktrace: s);
          failures++;
        }
      }
    }
    return result.copyWith(deckTombstonesPurged: purged, failures: failures);
  }

  Future<SyncPushResult> _pushCardTombstones(SyncPushResult result) async {
    final tombstones = await tombstoneRepository.fetchTombstones('card');
    logger.d('_pushCardTombstones: ${tombstones.length} pending');
    var purged = result.cardTombstonesPurged;
    var failures = result.failures;
    for (final tombstone in tombstones) {
      try {
        await cardsRepository.deleteCard(tombstone.remoteId);
        await tombstoneRepository.deleteTombstone(tombstone.id);
        purged++;
      } catch (e, s) {
        if (e is QuizzyBackendException && e.statusCode == 404) {
          logger.w('_pushCardTombstones: remote already gone, purging '
              'tombstone id=${tombstone.id}');
          await tombstoneRepository.deleteTombstone(tombstone.id);
          purged++;
        } else {
          logger.e('_pushCardTombstones: failed to delete remote card '
              'id=${tombstone.remoteId}, leaving for retry',
              ex: e, stacktrace: s);
          failures++;
        }
      }
    }
    return result.copyWith(cardTombstonesPurged: purged, failures: failures);
  }

  Future<SyncPushResult> _pushDirtyDecks(SyncPushResult result) async {
    final dirtyDecks = await deckRepository.fetchDirtyDecks();
    logger.d('_pushDirtyDecks: ${dirtyDecks.length} dirty');
    var pushed = result.decksPushed;
    var failures = result.failures;
    for (final deck in dirtyDecks) {
      try {
        final remoteId = deck.remoteId;
        if (remoteId == null) {
          final created = await decksRepository
              .createDeck(NewRemoteDeck(title: deck.title));
          await deckRepository.markDeckSynced(deck.id, created.id);
        } else {
          await decksRepository.updateDeck(
            remoteId,
            title: deck.title,
            isArchived: deck.isArchive,
          );
          await deckRepository.markDeckSynced(deck.id, remoteId);
        }
        pushed++;
      } catch (e, s) {
        logger.e('_pushDirtyDecks: failed to push deck id=${deck.id}',
            ex: e, stacktrace: s);
        failures++;
      }
    }
    return result.copyWith(decksPushed: pushed, failures: failures);
  }

  Future<SyncPushResult> _pushDirtyCards(SyncPushResult result) async {
    final dirtyCards = await quizCardRepository.fetchDirtyCards();
    logger.d('_pushDirtyCards: ${dirtyCards.length} dirty');
    if (dirtyCards.isEmpty) return result;

    final decks = await deckRepository.fetchDecks();
    final remoteIdByLocalDeckId = <int, String?>{
      for (final deck in decks) deck.id: deck.remoteId,
    };

    var pushed = result.cardsPushed;
    var failures = result.failures;
    for (final card in dirtyCards) {
      final parentRemoteId = remoteIdByLocalDeckId[card.deckId];
      if (parentRemoteId == null) {
        logger.w('_pushDirtyCards: parent deck ${card.deckId} not yet '
            'synced, deferring card id=${card.id}');
        continue;
      }
      try {
        final cardRemoteId = card.remoteId;
        if (cardRemoteId == null) {
          final created = await decksRepository.addCard(
            parentRemoteId,
            question: card.questionText,
            answer: card.answerText,
          );
          await quizCardRepository.markCardSynced(card.id, created.id);
        } else {
          await cardsRepository.updateCard(
            cardRemoteId,
            question: card.questionText,
            answer: card.answerText,
            isArchived: card.isArchive,
          );
          await quizCardRepository.markCardSynced(card.id, cardRemoteId);
        }
        pushed++;
      } catch (e, s) {
        logger.e('_pushDirtyCards: failed to push card id=${card.id}',
            ex: e, stacktrace: s);
        failures++;
      }
    }
    return result.copyWith(cardsPushed: pushed, failures: failures);
  }

  Future<SyncPullResult> pullRemoteChanges() async {
    logger.d('pullRemoteChanges: starting');
    final List<RemoteDeck> remoteDecks;
    try {
      remoteDecks = await decksRepository.listDecks();
    } catch (e, s) {
      logger.e('pullRemoteChanges: listDecks failed, aborting pull',
          ex: e, stacktrace: s);
      return const SyncPullResult(failures: 1);
    }

    var result = const SyncPullResult();
    final localIdByRemoteDeckId = <String, int>{};

    for (final remoteDeck in remoteDecks) {
      try {
        final localId = await deckRepository.upsertDeckFromRemote(
          remoteId: remoteDeck.id,
          title: remoteDeck.title,
          isArchive: remoteDeck.isArchived,
        );
        localIdByRemoteDeckId[remoteDeck.id] = localId;
        result = result.copyWith(decksUpserted: result.decksUpserted + 1);
      } catch (e, s) {
        logger.e('pullRemoteChanges: failed to upsert deck '
            'id=${remoteDeck.id}',
            ex: e, stacktrace: s);
        result = result.copyWith(failures: result.failures + 1);
      }
    }

    result = await _reconcileDeletedDecks(
      remoteDeckIds: localIdByRemoteDeckId.keys.toSet(),
      result: result,
    );

    for (final remoteDeck in remoteDecks) {
      final localDeckId = localIdByRemoteDeckId[remoteDeck.id];
      if (localDeckId == null) continue;
      result = await _pullCardsForDeck(
        remoteDeckId: remoteDeck.id,
        localDeckId: localDeckId,
        result: result,
      );
    }

    logger.i('pullRemoteChanges: complete, $result');
    return result;
  }

  Future<SyncPullResult> _reconcileDeletedDecks({
    required Set<String> remoteDeckIds,
    required SyncPullResult result,
  }) async {
    final syncedLocalDecks = await deckRepository.fetchSyncedDecks();
    var deleted = result.decksDeletedLocally;
    for (final DeckItem deck in syncedLocalDecks) {
      final remoteId = deck.remoteId;
      if (remoteId != null && !remoteDeckIds.contains(remoteId)) {
        logger.d('_reconcileDeletedDecks: deck remoteId=$remoteId no '
            'longer on remote, deleting locally');
        await deckRepository.deleteDeckByRemoteId(remoteId);
        deleted++;
      }
    }
    return result.copyWith(decksDeletedLocally: deleted);
  }

  Future<SyncPullResult> _pullCardsForDeck({
    required String remoteDeckId,
    required int localDeckId,
    required SyncPullResult result,
  }) async {
    final List<RemoteCard> remoteCards;
    try {
      remoteCards = await decksRepository.listCards(remoteDeckId);
    } catch (e, s) {
      logger.e('_pullCardsForDeck: listCards failed for deck '
          'remoteId=$remoteDeckId',
          ex: e, stacktrace: s);
      return result.copyWith(failures: result.failures + 1);
    }

    var upserted = result.cardsUpserted;
    var failures = result.failures;
    final remoteCardIds = <String>{};
    for (final remoteCard in remoteCards) {
      remoteCardIds.add(remoteCard.id);
      try {
        await quizCardRepository.upsertCardFromRemote(
          remoteId: remoteCard.id,
          deckId: localDeckId,
          question: remoteCard.question,
          answer: remoteCard.answer,
          isArchive: remoteCard.isArchived,
        );
        upserted++;
      } catch (e, s) {
        logger.e('_pullCardsForDeck: failed to upsert card '
            'id=${remoteCard.id}',
            ex: e, stacktrace: s);
        failures++;
      }
    }

    var deleted = result.cardsDeletedLocally;
    final syncedLocalCards =
        await quizCardRepository.fetchSyncedCardsForDeck(localDeckId);
    for (final card in syncedLocalCards) {
      final remoteId = card.remoteId;
      if (remoteId != null && !remoteCardIds.contains(remoteId)) {
        logger.d('_pullCardsForDeck: card remoteId=$remoteId no longer on '
            'remote, deleting locally');
        await quizCardRepository.deleteCardByRemoteId(remoteId);
        deleted++;
      }
    }

    return result.copyWith(
      cardsUpserted: upserted,
      cardsDeletedLocally: deleted,
      failures: failures,
    );
  }
}
