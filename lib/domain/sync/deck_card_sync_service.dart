import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/sync/sync_tombstone_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/decks_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/new_remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_draft.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_update.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/domain/sync/model/sync_result.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Max items per call to the batch card endpoints
/// (`POST`/`PATCH`/`DELETE /decks/{id}/cards/batch`), enforced server-side.
const _maxBatchSize = 100;

/// Orchestrates two-way sync between the local Drift-backed deck/card
/// repositories and the quizzy-ai-pro backend. Conflict resolution is
/// remote-wins: [pullRemoteChanges] overwrites local fields with remote
/// values for anything already linked to a remote id, *except* rows that are
/// still locally dirty (an unpushed local edit is never clobbered by a
/// concurrent pull). Push and pull each continue past a single failing
/// deck/card/batch (logged, counted in [SyncPushResult.failures]/
/// [SyncPullResult.failures]) rather than aborting the whole cycle, except
/// that a failing [DecksRepository.listDecks] call aborts the pull entirely
/// since nothing else can proceed safely without it, and that ANY
/// [QuizzyBackendException] with `statusCode == 429` aborts the *entire*
/// cycle immediately (see [_rethrowIfRateLimited]) — rate-limit responses
/// are never treated as a per-item failure to log-and-continue past, since
/// continuing would just draw more 429s. The exception propagates all the
/// way out of [runFullSync] for [SyncScheduler] to catch and back off on.
///
/// Only [SyncScheduler] should hold a reference to this class — it owns
/// `isSyncing` and all reentrancy/coalescing behavior; this service exposes
/// plain, unguarded async methods.
class DeckCardSyncService {
  DeckCardSyncService({
    required this.deckRepository,
    required this.quizCardRepository,
    required this.decksRepository,
    required this.tombstoneRepository,
    required this.logger,
  });

  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final DecksRepository decksRepository;
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
        _rethrowIfRateLimited(e);
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

  /// Groups pending card tombstones by their parent deck's remote id
  /// ([SyncTombstoneTableData.parentRemoteId]) and pushes one
  /// `DELETE /decks/{id}/cards/batch` call per deck (chunked at
  /// [_maxBatchSize]). A remote id coming back in either `deleted` or
  /// `notFound` purges its tombstone — `notFound` means the remote is
  /// already gone, same semantics the old per-item 404 handling had.
  Future<SyncPushResult> _pushCardTombstones(SyncPushResult result) async {
    final tombstones = await tombstoneRepository.fetchTombstones('card');
    logger.d('_pushCardTombstones: ${tombstones.length} pending');
    var purged = result.cardTombstonesPurged;
    var failures = result.failures;

    final byDeck = <String, List<SyncTombstoneTableData>>{};
    for (final tombstone in tombstones) {
      final parentRemoteId = tombstone.parentRemoteId;
      if (parentRemoteId == null) {
        logger.w('_pushCardTombstones: tombstone id=${tombstone.id} has no '
            'parent deck remoteId, skipping');
        failures++;
        continue;
      }
      byDeck.putIfAbsent(parentRemoteId, () => []).add(tombstone);
    }

    for (final entry in byDeck.entries) {
      final deckRemoteId = entry.key;
      for (final chunk in _chunk(entry.value, _maxBatchSize)) {
        final tombstoneByRemoteId = {
          for (final t in chunk) t.remoteId: t,
        };
        try {
          final response = await decksRepository.deleteCards(
            deckRemoteId,
            chunk.map((t) => t.remoteId).toList(),
          );
          final resolvedIds = {...response.deleted, ...response.notFound};
          for (final remoteId in resolvedIds) {
            final tombstone = tombstoneByRemoteId[remoteId];
            if (tombstone == null) continue;
            await tombstoneRepository.deleteTombstone(tombstone.id);
            purged++;
          }
          failures += chunk.length - resolvedIds.length.clamp(0, chunk.length);
        } catch (e, s) {
          _rethrowIfRateLimited(e);
          logger.e('_pushCardTombstones: batch delete failed for deck '
              'remoteId=$deckRemoteId',
              ex: e, stacktrace: s);
          failures += chunk.length;
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
        _rethrowIfRateLimited(e);
        logger.e('_pushDirtyDecks: failed to push deck id=${deck.id}',
            ex: e, stacktrace: s);
        failures++;
      }
    }
    return result.copyWith(decksPushed: pushed, failures: failures);
  }

  /// Splits dirty cards into new (`remoteId == null`) vs edited
  /// (`remoteId != null`), groups each by parent deck, and pushes them via
  /// the batch endpoints (chunked at [_maxBatchSize]).
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

    final newByDeck = <int, List<QuizCardItem>>{};
    final editedByDeck = <int, List<QuizCardItem>>{};
    for (final card in dirtyCards) {
      final parentRemoteId = remoteIdByLocalDeckId[card.deckId];
      if (parentRemoteId == null) {
        logger.w('_pushDirtyCards: parent deck ${card.deckId} not yet '
            'synced, deferring card id=${card.id}');
        continue;
      }
      final byDeck = card.remoteId == null ? newByDeck : editedByDeck;
      byDeck.putIfAbsent(card.deckId, () => []).add(card);
    }

    for (final entry in newByDeck.entries) {
      final parentRemoteId = remoteIdByLocalDeckId[entry.key]!;
      for (final chunk in _chunk(entry.value, _maxBatchSize)) {
        try {
          final created = await decksRepository.addCards(
            parentRemoteId,
            chunk
                .map((c) => RemoteCardDraft(
                      question: c.questionText,
                      answer: c.answerText,
                    ))
                .toList(),
          );
          if (created.length != chunk.length) {
            logger.w('_pushDirtyCards: addCards returned '
                '${created.length} results for ${chunk.length} cards');
          }
          for (var i = 0; i < chunk.length && i < created.length; i++) {
            await quizCardRepository.markCardSynced(
                chunk[i].id, created[i].id);
            pushed++;
          }
          failures += chunk.length - created.length.clamp(0, chunk.length);
        } catch (e, s) {
          _rethrowIfRateLimited(e);
          logger.e('_pushDirtyCards: addCards batch failed for deck '
              'remoteId=$parentRemoteId',
              ex: e, stacktrace: s);
          failures += chunk.length;
        }
      }
    }

    for (final entry in editedByDeck.entries) {
      final parentRemoteId = remoteIdByLocalDeckId[entry.key]!;
      for (final chunk in _chunk(entry.value, _maxBatchSize)) {
        try {
          final response = await decksRepository.updateCards(
            parentRemoteId,
            chunk
                .map((c) => RemoteCardUpdate(
                      remoteId: c.remoteId!,
                      question: c.questionText,
                      answer: c.answerText,
                      isArchived: c.isArchive,
                    ))
                .toList(),
          );
          final updatedIds = {for (final rc in response.updated) rc.id};
          for (final card in chunk) {
            if (updatedIds.contains(card.remoteId)) {
              await quizCardRepository.markCardSynced(
                  card.id, card.remoteId!);
              pushed++;
            }
          }
          // notFound cards stay dirty (retried next cycle) and count as
          // failures; anything else unaccounted for is a defensive
          // safety-net for a response that doesn't add up.
          failures += response.notFound.length;
          final accountedFor = updatedIds.length + response.notFound.length;
          if (accountedFor < chunk.length) {
            failures += chunk.length - accountedFor;
          }
        } catch (e, s) {
          _rethrowIfRateLimited(e);
          logger.e('_pushDirtyCards: updateCards batch failed for deck '
              'remoteId=$parentRemoteId',
              ex: e, stacktrace: s);
          failures += chunk.length;
        }
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
      _rethrowIfRateLimited(e);
      logger.e('pullRemoteChanges: listDecks failed, aborting pull',
          ex: e, stacktrace: s);
      return const SyncPullResult(failures: 1);
    }

    var result = const SyncPullResult();
    final localIdByRemoteDeckId = <String, int>{};
    final unchangedRemoteDeckIds = <String>{};

    // A dirty local row has unpushed edits — the pull must not clobber it
    // with the (now-stale) remote value it's trying to replace.
    final dirtyDecks = await deckRepository.fetchDirtyDecks();
    final dirtyDeckRemoteIds = {
      for (final d in dirtyDecks)
        if (d.remoteId != null) d.remoteId!,
    };
    final dirtyCards = await quizCardRepository.fetchDirtyCards();
    final dirtyCardRemoteIds = {
      for (final c in dirtyCards)
        if (c.remoteId != null) c.remoteId!,
    };

    // Fetched once and reused both for the unchanged-deck gate below and for
    // _reconcileDeletedDecks further down.
    final syncedLocalDecks = await deckRepository.fetchSyncedDecks();
    final remoteUpdatedAtByRemoteId = {
      for (final d in syncedLocalDecks)
        if (d.remoteId != null) d.remoteId!: d.remoteUpdatedAt,
    };

    for (final remoteDeck in remoteDecks) {
      try {
        // NOTE (unverified backend assumption): this gate assumes the
        // backend bumps a deck's `updatedAt` whenever one of its cards is
        // added/updated/deleted, not just on deck-field edits — the swagger
        // schema doesn't document this either way. If that assumption is
        // wrong, a card-only change on an otherwise-untouched deck would be
        // silently skipped here. TODO(backend): confirm this behavior with
        // the quizzy-ai-pro-be team; until then this is deck-fields-only in
        // effect, since deck.updatedAt is the only signal being trusted.
        final storedUpdatedAt = remoteUpdatedAtByRemoteId[remoteDeck.id];
        if (storedUpdatedAt != null &&
            storedUpdatedAt.isAtSameMomentAs(remoteDeck.updatedAt)) {
          final localId =
              await deckRepository.findLocalIdByRemoteId(remoteDeck.id);
          if (localId != null) {
            logger.d('pullRemoteChanges: deck remoteId=${remoteDeck.id} '
                'unchanged since last pull, skipping listCards + upsert');
            localIdByRemoteDeckId[remoteDeck.id] = localId;
            unchangedRemoteDeckIds.add(remoteDeck.id);
            continue;
          }
          // Stored updatedAt but no local row (shouldn't normally happen) —
          // fall through to a normal upsert below.
        }

        int? localId;
        if (dirtyDeckRemoteIds.contains(remoteDeck.id)) {
          logger.d('pullRemoteChanges: deck remoteId=${remoteDeck.id} is '
              'dirty locally, skipping overwrite');
          localId = await deckRepository.findLocalIdByRemoteId(remoteDeck.id);
        }
        if (localId == null) {
          localId = await deckRepository.upsertDeckFromRemote(
            remoteId: remoteDeck.id,
            title: remoteDeck.title,
            isArchive: remoteDeck.isArchived,
            stats: remoteDeck.stats,
          );
          result = result.copyWith(decksUpserted: result.decksUpserted + 1);
        }
        localIdByRemoteDeckId[remoteDeck.id] = localId;
      } catch (e, s) {
        _rethrowIfRateLimited(e);
        logger.e('pullRemoteChanges: failed to upsert deck '
            'id=${remoteDeck.id}',
            ex: e, stacktrace: s);
        result = result.copyWith(failures: result.failures + 1);
      }
    }

    result = await _reconcileDeletedDecks(
      remoteDeckIds: localIdByRemoteDeckId.keys.toSet(),
      syncedLocalDecks: syncedLocalDecks,
      result: result,
    );

    for (final remoteDeck in remoteDecks) {
      final localDeckId = localIdByRemoteDeckId[remoteDeck.id];
      if (localDeckId == null) continue;
      if (unchangedRemoteDeckIds.contains(remoteDeck.id)) continue;
      result = await _pullCardsForDeck(
        remoteDeckId: remoteDeck.id,
        localDeckId: localDeckId,
        remoteDeckUpdatedAt: remoteDeck.updatedAt,
        dirtyCardRemoteIds: dirtyCardRemoteIds,
        result: result,
      );
    }

    logger.i('pullRemoteChanges: complete, $result');
    return result;
  }

  Future<SyncPullResult> _reconcileDeletedDecks({
    required Set<String> remoteDeckIds,
    required List<DeckItem> syncedLocalDecks,
    required SyncPullResult result,
  }) async {
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
    required DateTime remoteDeckUpdatedAt,
    required Set<String> dirtyCardRemoteIds,
    required SyncPullResult result,
  }) async {
    final List<RemoteCard> remoteCards;
    try {
      remoteCards = await decksRepository.listCards(remoteDeckId);
    } catch (e, s) {
      _rethrowIfRateLimited(e);
      logger.e('_pullCardsForDeck: listCards failed for deck '
          'remoteId=$remoteDeckId',
          ex: e, stacktrace: s);
      return result.copyWith(failures: result.failures + 1);
    }

    // The card list was fetched successfully, so this deck's cards are now
    // known to be in sync as of remoteDeckUpdatedAt — record that so the
    // next pull can skip listCards for this deck entirely if it hasn't
    // changed remotely. Recorded even if individual card upserts below fail,
    // since it's the listCards call (not the upserts) that this is gating.
    await deckRepository.updateRemoteUpdatedAt(localDeckId, remoteDeckUpdatedAt);

    var upserted = result.cardsUpserted;
    var failures = result.failures;
    final remoteCardIds = <String>{};
    for (final remoteCard in remoteCards) {
      remoteCardIds.add(remoteCard.id);
      if (dirtyCardRemoteIds.contains(remoteCard.id)) {
        logger.d('_pullCardsForDeck: card remoteId=${remoteCard.id} is '
            'dirty locally, skipping overwrite');
        continue;
      }
      try {
        await quizCardRepository.upsertCardFromRemote(
          remoteId: remoteCard.id,
          deckId: localDeckId,
          question: remoteCard.question,
          answer: remoteCard.answer,
          isArchive: remoteCard.isArchived,
          stats: remoteCard.stats,
        );
        upserted++;
      } catch (e, s) {
        _rethrowIfRateLimited(e);
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

  /// Rethrows [e] unchanged if it's a 429 [QuizzyBackendException], so it
  /// propagates out of the per-item loop (and everything above it) to abort
  /// the whole sync cycle instead of being logged-and-continued like other
  /// per-item failures. Call as the first line of every push/pull catch
  /// block.
  void _rethrowIfRateLimited(Object e) {
    if (e is QuizzyBackendException && e.statusCode == 429) {
      logger.w('rate limited (429), aborting sync cycle');
      throw e;
    }
  }

  Iterable<List<T>> _chunk<T>(List<T> items, int size) sync* {
    for (var i = 0; i < items.length; i += size) {
      yield items.sublist(i, i + size > items.length ? items.length : i + size);
    }
  }
}
