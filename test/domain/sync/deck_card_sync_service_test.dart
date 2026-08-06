import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/sync/sync_tombstone_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/decks_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/batch_delete_cards_result.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/batch_update_cards_result.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/new_remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_draft.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_update.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck_with_cards.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockDecksRepository extends Mock implements DecksRepository {}

class MockSyncTombstoneRepository extends Mock
    implements SyncTombstoneRepository {}

DateTime _now() => DateTime(2026, 1, 1);

const _testStats = ItemStats(
  accuracy: PeriodStats(week: 0.5, month: null, year: null),
  attempts: PeriodStats(week: 2, month: 2, year: 2),
  bestStreak: PeriodStats(week: 1, month: 1, year: 1),
);

RemoteDeck _remoteDeck(String id,
    {String title = 'Deck',
    bool archived = false,
    ItemStats? stats,
    DateTime? lastActivityAt}) {
  return RemoteDeck(
    id: id,
    userId: 'user-1',
    title: title,
    isArchived: archived,
    createdAt: _now(),
    updatedAt: _now(),
    lastActivityAt: lastActivityAt ?? _now(),
    stats: stats,
  );
}

RemoteDeckWithCards _remoteDeckWithCards(String id, {String title = 'Deck'}) {
  return RemoteDeckWithCards(
    id: id,
    userId: 'user-1',
    title: title,
    isArchived: false,
    createdAt: _now(),
    updatedAt: _now(),
    cards: const [],
  );
}

RemoteCard _remoteCard(String id, String deckId,
    {String question = 'Q', String answer = 'A', ItemStats? stats}) {
  return RemoteCard(
    id: id,
    deckId: deckId,
    question: question,
    answer: answer,
    isArchived: false,
    createdAt: _now(),
    updatedAt: _now(),
    stats: stats,
  );
}

QuizCardItem _newCard(int id, int deckId, {String question = 'Q', String answer = 'A'}) {
  return QuizCardItem(
    id: id,
    deckId: deckId,
    questionText: question,
    answerText: answer,
    isArchive: false,
  );
}

QuizCardItem _editedCard(int id, int deckId, String remoteId,
    {String question = 'Q2', String answer = 'A2'}) {
  return QuizCardItem(
    id: id,
    deckId: deckId,
    questionText: question,
    answerText: answer,
    isArchive: false,
    remoteId: remoteId,
    isDirty: true,
  );
}

SyncTombstoneTableData _cardTombstone(int id, String remoteId, String parentRemoteId) {
  return SyncTombstoneTableData(
    id: id,
    entityType: 'card',
    remoteId: remoteId,
    parentRemoteId: parentRemoteId,
    createdAt: _now(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NewRemoteDeck(title: ''));
    registerFallbackValue(<RemoteCardDraft>[]);
    registerFallbackValue(<RemoteCardUpdate>[]);
    registerFallbackValue(<String>[]);
  });

  late MockDeckRepository deckRepository;
  late MockQuizCardRepository quizCardRepository;
  late MockDecksRepository decksRepository;
  late MockSyncTombstoneRepository tombstoneRepository;
  late DeckCardSyncService service;

  setUp(() {
    deckRepository = MockDeckRepository();
    quizCardRepository = MockQuizCardRepository();
    decksRepository = MockDecksRepository();
    tombstoneRepository = MockSyncTombstoneRepository();
    service = DeckCardSyncService(
      deckRepository: deckRepository,
      quizCardRepository: quizCardRepository,
      decksRepository: decksRepository,
      tombstoneRepository: tombstoneRepository,
      logger: Logger.withTag('test'),
    );

    // Defaults so every push/pull test only needs to stub what it cares
    // about.
    when(() => tombstoneRepository.fetchTombstones(any()))
        .thenAnswer((_) async => const []);
    when(() => deckRepository.fetchDirtyDecks()).thenAnswer((_) async => const []);
    when(() => quizCardRepository.fetchDirtyCards())
        .thenAnswer((_) async => const []);
    when(() => deckRepository.fetchDecks()).thenAnswer((_) async => const []);
    when(() => deckRepository.fetchSyncedDecks())
        .thenAnswer((_) async => const []);
    when(() => deckRepository.updateRemoteSyncMarkers(
          any(),
          remoteUpdatedAt: any(named: 'remoteUpdatedAt'),
          remoteLastActivityAt: any(named: 'remoteLastActivityAt'),
        )).thenAnswer((_) async {});
  });

  group('pushLocalChanges - decks', () {
    test('a failing deck does not stop the next deck from being pushed',
        () async {
      const deckA = DeckItem(id: 1, title: 'A', isArchive: false, cardCount: 0);
      const deckB = DeckItem(id: 2, title: 'B', isArchive: false, cardCount: 0);
      when(() => deckRepository.fetchDirtyDecks())
          .thenAnswer((_) async => const [deckA, deckB]);

      var call = 0;
      when(() => decksRepository.createDeck(any())).thenAnswer((_) async {
        call++;
        if (call == 1) throw Exception('network error');
        return _remoteDeckWithCards('rdB');
      });
      when(() => deckRepository.markDeckSynced(2, 'rdB'))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.decksPushed, 1);
      expect(result.failures, 1);
      verifyNever(() => deckRepository.markDeckSynced(1, any()));
      verify(() => deckRepository.markDeckSynced(2, 'rdB')).called(1);
    });

    test(
        'deck tombstone push purges on success and on 404, retries on other errors',
        () async {
      final t1 = SyncTombstoneTableData(
          id: 1, entityType: 'deck', remoteId: 'd1', createdAt: _now());
      final t2 = SyncTombstoneTableData(
          id: 2, entityType: 'deck', remoteId: 'd2', createdAt: _now());
      final t3 = SyncTombstoneTableData(
          id: 3, entityType: 'deck', remoteId: 'd3', createdAt: _now());
      when(() => tombstoneRepository.fetchTombstones('deck'))
          .thenAnswer((_) async => [t1, t2, t3]);
      when(() => tombstoneRepository.fetchTombstones('card'))
          .thenAnswer((_) async => const []);

      when(() => decksRepository.deleteDeck('d1')).thenAnswer((_) async {});
      when(() => decksRepository.deleteDeck('d2')).thenThrow(
          QuizzyBackendException('not found', statusCode: 404));
      when(() => decksRepository.deleteDeck('d3'))
          .thenThrow(QuizzyBackendException('server error', statusCode: 500));
      when(() => tombstoneRepository.deleteTombstone(any()))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.deckTombstonesPurged, 2);
      expect(result.failures, 1);
      verify(() => tombstoneRepository.deleteTombstone(1)).called(1);
      verify(() => tombstoneRepository.deleteTombstone(2)).called(1);
      verifyNever(() => tombstoneRepository.deleteTombstone(3));
    });
  });

  group('pushLocalChanges - cards', () {
    test('new cards are pushed via addCards and marked synced by array order',
        () async {
      const deck =
          DeckItem(
              id: 1,
              title: 'Deck',
              isArchive: false,
              cardCount: 0,
              remoteId: 'rd1');
      final card1 = _newCard(1, 1, question: 'Q1');
      final card2 = _newCard(2, 1, question: 'Q2');
      when(() => deckRepository.fetchDecks())
          .thenAnswer((_) async => const [deck]);
      when(() => quizCardRepository.fetchDirtyCards())
          .thenAnswer((_) async => [card1, card2]);
      when(() => decksRepository.addCards('rd1', any())).thenAnswer(
          (_) async => [_remoteCard('rc1', 'rd1'), _remoteCard('rc2', 'rd1')]);
      when(() => quizCardRepository.markCardSynced(any(), any()))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.cardsPushed, 2);
      expect(result.failures, 0);
      verify(() => quizCardRepository.markCardSynced(1, 'rc1')).called(1);
      verify(() => quizCardRepository.markCardSynced(2, 'rc2')).called(1);
    });

    test('skips a card whose deck is not yet synced', () async {
      final card = _newCard(2, 5);
      when(() => deckRepository.fetchDecks()).thenAnswer((_) async => const [
            DeckItem(id: 5, title: 'Deck', isArchive: false, cardCount: 0),
          ]);
      when(() => quizCardRepository.fetchDirtyCards())
          .thenAnswer((_) async => [card]);

      final result = await service.pushLocalChanges();

      expect(result.cardsPushed, 0);
      expect(result.failures, 0);
      verifyNever(() => decksRepository.addCards(any(), any()));
      verifyNever(() => quizCardRepository.markCardSynced(any(), any()));
    });

    test('new cards for the same deck are chunked at 100 per addCards call',
        () async {
      const deck =
          DeckItem(
              id: 1,
              title: 'Deck',
              isArchive: false,
              cardCount: 0,
              remoteId: 'rd1');
      final cards = List.generate(150, (i) => _newCard(i, 1, question: 'Q$i'));
      when(() => deckRepository.fetchDecks())
          .thenAnswer((_) async => const [deck]);
      when(() => quizCardRepository.fetchDirtyCards())
          .thenAnswer((_) async => cards);
      when(() => decksRepository.addCards('rd1', any())).thenAnswer((invocation) async {
        final body = invocation.positionalArguments[1] as List<RemoteCardDraft>;
        return body
            .map((c) => _remoteCard('remote-${c.question}', 'rd1'))
            .toList();
      });
      when(() => quizCardRepository.markCardSynced(any(), any()))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.cardsPushed, 150);
      final captured = verify(() => decksRepository.addCards('rd1', captureAny()))
          .captured
          .cast<List<RemoteCardDraft>>();
      expect(captured, hasLength(2));
      expect(captured[0], hasLength(100));
      expect(captured[1], hasLength(50));
    });

    test(
        'edited cards are pushed via updateCards; updated cards are marked '
        'synced, notFound cards count as failures and stay dirty', () async {
      const deck =
          DeckItem(
              id: 1,
              title: 'Deck',
              isArchive: false,
              cardCount: 0,
              remoteId: 'rd1');
      final cardA = _editedCard(1, 1, 'rcA');
      final cardB = _editedCard(2, 1, 'rcB');
      when(() => deckRepository.fetchDecks())
          .thenAnswer((_) async => const [deck]);
      when(() => quizCardRepository.fetchDirtyCards())
          .thenAnswer((_) async => [cardA, cardB]);
      when(() => decksRepository.updateCards('rd1', any())).thenAnswer(
          (_) async => BatchUpdateCardsResult(
                updated: [_remoteCard('rcA', 'rd1')],
                notFound: const ['rcB'],
              ));
      when(() => quizCardRepository.markCardSynced(any(), any()))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.cardsPushed, 1);
      expect(result.failures, 1);
      verify(() => quizCardRepository.markCardSynced(1, 'rcA')).called(1);
      verifyNever(() => quizCardRepository.markCardSynced(2, any()));
    });
  });

  group('pushLocalChanges - card tombstones', () {
    test(
        'card tombstones are grouped by parent deck and purged on deleted or notFound',
        () async {
      final t1 = _cardTombstone(1, 'rc1', 'rd1');
      final t2 = _cardTombstone(2, 'rc2', 'rd1');
      final t3 = _cardTombstone(3, 'rc3', 'rd2');
      when(() => tombstoneRepository.fetchTombstones('card'))
          .thenAnswer((_) async => [t1, t2, t3]);
      when(() => decksRepository.deleteCards('rd1', any())).thenAnswer(
          (_) async => const BatchDeleteCardsResult(
                deleted: ['rc1'],
                notFound: ['rc2'],
              ));
      when(() => decksRepository.deleteCards('rd2', any())).thenAnswer(
          (_) async => const BatchDeleteCardsResult(deleted: [], notFound: []));
      when(() => tombstoneRepository.deleteTombstone(any()))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.cardTombstonesPurged, 2);
      expect(result.failures, 1);
      verify(() => tombstoneRepository.deleteTombstone(1)).called(1);
      verify(() => tombstoneRepository.deleteTombstone(2)).called(1);
      verifyNever(() => tombstoneRepository.deleteTombstone(3));
      verify(() => decksRepository.deleteCards('rd1', ['rc1', 'rc2'])).called(1);
      verify(() => decksRepository.deleteCards('rd2', ['rc3'])).called(1);
    });

    test('card tombstones with no parent deck id are counted as failures',
        () async {
      final orphan = SyncTombstoneTableData(
          id: 1, entityType: 'card', remoteId: 'rc1', createdAt: _now());
      when(() => tombstoneRepository.fetchTombstones('card'))
          .thenAnswer((_) async => [orphan]);

      final result = await service.pushLocalChanges();

      expect(result.failures, 1);
      expect(result.cardTombstonesPurged, 0);
      verifyNever(() => decksRepository.deleteCards(any(), any()));
    });

    test('card tombstones for the same deck are chunked at 100 per delete call',
        () async {
      final tombstones =
          List.generate(150, (i) => _cardTombstone(i, 'rc$i', 'rd1'));
      when(() => tombstoneRepository.fetchTombstones('card'))
          .thenAnswer((_) async => tombstones);
      when(() => decksRepository.deleteCards('rd1', any())).thenAnswer(
          (invocation) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        return BatchDeleteCardsResult(deleted: ids, notFound: const []);
      });
      when(() => tombstoneRepository.deleteTombstone(any()))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.cardTombstonesPurged, 150);
      final captured = verify(() => decksRepository.deleteCards('rd1', captureAny()))
          .captured
          .cast<List<String>>();
      expect(captured, hasLength(2));
      expect(captured[0], hasLength(100));
      expect(captured[1], hasLength(50));
    });
  });

  group('pullRemoteChanges', () {
    test('upserts decks and cards by remoteId', () async {
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1')]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 10);
      when(() => decksRepository.listCards('d1'))
          .thenAnswer((_) async => [_remoteCard('c1', 'd1')]);
      when(() => quizCardRepository.upsertCardFromRemote(
            remoteId: 'c1',
            deckId: 10,
            question: 'Q',
            answer: 'A',
            isArchive: false,
          )).thenAnswer((_) async => 100);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(10))
          .thenAnswer((_) async => const []);

      final result = await service.pullRemoteChanges();

      expect(result.decksUpserted, 1);
      expect(result.cardsUpserted, 1);
      expect(result.failures, 0);
    });

    test('forwards remote deck/card stats through to the upsert calls',
        () async {
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1', stats: _testStats)]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
            stats: _testStats,
          )).thenAnswer((_) async => 10);
      when(() => decksRepository.listCards('d1')).thenAnswer(
          (_) async => [_remoteCard('c1', 'd1', stats: _testStats)]);
      when(() => quizCardRepository.upsertCardFromRemote(
            remoteId: 'c1',
            deckId: 10,
            question: 'Q',
            answer: 'A',
            isArchive: false,
            stats: _testStats,
          )).thenAnswer((_) async => 100);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(10))
          .thenAnswer((_) async => const []);

      final result = await service.pullRemoteChanges();

      expect(result.decksUpserted, 1);
      expect(result.cardsUpserted, 1);
      expect(result.failures, 0);
      verify(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
            stats: _testStats,
          )).called(1);
      verify(() => quizCardRepository.upsertCardFromRemote(
            remoteId: 'c1',
            deckId: 10,
            question: 'Q',
            answer: 'A',
            isArchive: false,
            stats: _testStats,
          )).called(1);
    });

    test('deletes a local synced deck missing from listDecks (remote-wins)',
        () async {
      when(() => decksRepository.listDecks()).thenAnswer((_) async => const []);
      when(() => deckRepository.fetchSyncedDecks()).thenAnswer((_) async => const [
            DeckItem(
                id: 7,
                title: 'Gone',
                isArchive: false,
                cardCount: 0,
                remoteId: 'gone',
                isDirty: true),
          ]);
      when(() => deckRepository.deleteDeckByRemoteId('gone'))
          .thenAnswer((_) async => true);

      final result = await service.pullRemoteChanges();

      expect(result.decksDeletedLocally, 1);
      verify(() => deckRepository.deleteDeckByRemoteId('gone')).called(1);
    });

    test('continues to the next deck when one deck\'s listCards throws',
        () async {
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1'), _remoteDeck('d2')]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 1);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd2',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 2);
      when(() => decksRepository.listCards('d1')).thenThrow(Exception('boom'));
      when(() => decksRepository.listCards('d2')).thenAnswer((_) async => const []);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(any()))
          .thenAnswer((_) async => const []);

      final result = await service.pullRemoteChanges();

      expect(result.decksUpserted, 2);
      expect(result.failures, 1);
    });

    test('a dirty local deck is not clobbered by a conflicting remote pull',
        () async {
      const dirtyDeck = DeckItem(
          id: 10,
          title: 'Local edit',
          isArchive: false,
          cardCount: 0,
          remoteId: 'd1',
          isDirty: true);
      when(() => deckRepository.fetchDirtyDecks())
          .thenAnswer((_) async => const [dirtyDeck]);
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1', title: 'Remote title')]);
      when(() => deckRepository.findLocalIdByRemoteId('d1'))
          .thenAnswer((_) async => 10);
      when(() => decksRepository.listCards('d1'))
          .thenAnswer((_) async => const []);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(10))
          .thenAnswer((_) async => const []);

      final result = await service.pullRemoteChanges();

      expect(result.decksUpserted, 0);
      verifyNever(() => deckRepository.upsertDeckFromRemote(
            remoteId: any(named: 'remoteId'),
            title: any(named: 'title'),
            isArchive: any(named: 'isArchive'),
            stats: any(named: 'stats'),
          ));
      // Cards still get pulled for a dirty-but-known deck.
      verify(() => decksRepository.listCards('d1')).called(1);
    });

    test('a dirty local card is not clobbered by a conflicting remote pull',
        () async {
      final dirtyCard = _editedCard(1, 10, 'c1');
      when(() => quizCardRepository.fetchDirtyCards())
          .thenAnswer((_) async => [dirtyCard]);
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1')]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 10);
      when(() => decksRepository.listCards('d1')).thenAnswer(
          (_) async => [_remoteCard('c1', 'd1', question: 'Remote Q')]);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(10))
          .thenAnswer((_) async => const []);

      final result = await service.pullRemoteChanges();

      expect(result.cardsUpserted, 0);
      verifyNever(() => quizCardRepository.upsertCardFromRemote(
            remoteId: any(named: 'remoteId'),
            deckId: any(named: 'deckId'),
            question: any(named: 'question'),
            answer: any(named: 'answer'),
            isArchive: any(named: 'isArchive'),
            stats: any(named: 'stats'),
          ));
      // The remote still lists the card, so it must not be treated as
      // remotely-deleted either.
      verifyNever(() => quizCardRepository.deleteCardByRemoteId(any()));
    });

    test(
        'a second consecutive pull with no remote changes performs no '
        'listCards calls at all', () async {
      final deck = _remoteDeck('d1');
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [deck]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 10);
      when(() => decksRepository.listCards('d1'))
          .thenAnswer((_) async => const []);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(10))
          .thenAnswer((_) async => const []);

      // First cycle: deck is new locally, so it's upserted and its cards
      // fetched once, recording remoteUpdatedAt/remoteLastActivityAt ==
      // deck.updatedAt/deck.lastActivityAt.
      final first = await service.pullRemoteChanges();
      expect(first.decksUpserted, 1);
      verify(() => decksRepository.listCards('d1')).called(1);
      verify(() => deckRepository.updateRemoteSyncMarkers(
            10,
            remoteUpdatedAt: deck.updatedAt,
            remoteLastActivityAt: deck.lastActivityAt,
          )).called(1);

      // Second cycle: the remote deck is unchanged (same updatedAt and
      // lastActivityAt) — the now-synced local deck (with matching stored
      // markers) must make listCards entirely skippable.
      when(() => deckRepository.fetchSyncedDecks()).thenAnswer((_) async => [
            DeckItem(
              id: 10,
              title: 'Deck',
              isArchive: false,
              cardCount: 0,
              remoteId: 'd1',
              remoteUpdatedAt: deck.updatedAt,
              remoteLastActivityAt: deck.lastActivityAt,
            ),
          ]);
      when(() => deckRepository.findLocalIdByRemoteId('d1'))
          .thenAnswer((_) async => 10);
      clearInteractions(decksRepository);
      clearInteractions(deckRepository);
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [deck]);
      when(() => deckRepository.findLocalIdByRemoteId('d1'))
          .thenAnswer((_) async => 10);
      when(() => deckRepository.fetchSyncedDecks()).thenAnswer((_) async => [
            DeckItem(
              id: 10,
              title: 'Deck',
              isArchive: false,
              cardCount: 0,
              remoteId: 'd1',
              remoteUpdatedAt: deck.updatedAt,
              remoteLastActivityAt: deck.lastActivityAt,
            ),
          ]);

      final second = await service.pullRemoteChanges();

      expect(second.decksUpserted, 0);
      expect(second.cardsUpserted, 0);
      // Exactly one HTTP request this cycle: listDecks. listCards is never
      // called since the deck is unchanged.
      verify(() => decksRepository.listDecks()).called(1);
      verifyNever(() => decksRepository.listCards(any()));
      verifyNever(() => deckRepository.upsertDeckFromRemote(
            remoteId: any(named: 'remoteId'),
            title: any(named: 'title'),
            isArchive: any(named: 'isArchive'),
            stats: any(named: 'stats'),
          ));
      verifyNever(() => quizCardRepository.upsertCardFromRemote(
            remoteId: any(named: 'remoteId'),
            deckId: any(named: 'deckId'),
            question: any(named: 'question'),
            answer: any(named: 'answer'),
            isArchive: any(named: 'isArchive'),
            stats: any(named: 'stats'),
          ));
    });

    test(
        'a remote change visible in only one of updatedAt/lastActivityAt '
        'still triggers listCards (defensive dual gate)', () async {
      final deck = _remoteDeck('d1', lastActivityAt: DateTime(2026, 1, 2));
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [deck]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 10);
      when(() => deckRepository.fetchSyncedDecks()).thenAnswer((_) async => [
            DeckItem(
              id: 10,
              title: 'Deck',
              isArchive: false,
              cardCount: 0,
              remoteId: 'd1',
              // Matches the deck's unchanged `updatedAt` ...
              remoteUpdatedAt: deck.updatedAt,
              // ... but stale against its bumped `lastActivityAt` — one
              // signal matching isn't enough, the gate requires both.
              remoteLastActivityAt: DateTime(2026, 1, 1),
            ),
          ]);
      when(() => deckRepository.findLocalIdByRemoteId('d1'))
          .thenAnswer((_) async => 10);
      when(() => decksRepository.listCards('d1'))
          .thenAnswer((_) async => const []);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(10))
          .thenAnswer((_) async => const []);

      await service.pullRemoteChanges();

      verify(() => decksRepository.listCards('d1')).called(1);
      verify(() => deckRepository.updateRemoteSyncMarkers(
            10,
            remoteUpdatedAt: deck.updatedAt,
            remoteLastActivityAt: deck.lastActivityAt,
          )).called(1);
    });
  });

  group('429 aborts the entire cycle', () {
    test('a 429 during push aborts before pull ever starts', () async {
      final tombstone = SyncTombstoneTableData(
          id: 1, entityType: 'deck', remoteId: 'd1', createdAt: _now());
      when(() => tombstoneRepository.fetchTombstones('deck'))
          .thenAnswer((_) async => [tombstone]);
      when(() => decksRepository.deleteDeck('d1')).thenThrow(
          QuizzyBackendException('rate limited', statusCode: 429));

      await expectLater(
        () => service.runFullSync(),
        throwsA(isA<QuizzyBackendException>()),
      );

      // pull never starts once push aborts on the 429.
      verifyNever(() => decksRepository.listDecks());
    });

    test(
        'a 429 on one deck\'s listCards aborts before the next deck is '
        'checked', () async {
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1'), _remoteDeck('d2')]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 1);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd2',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 2);
      when(() => decksRepository.listCards('d1')).thenThrow(
          QuizzyBackendException('rate limited', statusCode: 429));

      await expectLater(
        () => service.pullRemoteChanges(),
        throwsA(isA<QuizzyBackendException>()),
      );

      verifyNever(() => decksRepository.listCards('d2'));
    });
  });
}
